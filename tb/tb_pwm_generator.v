`timescale 1ns/1ps

module tb_pwm_generator;
    localparam integer PERIOD_CYCLES = 16;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg [7:0] duty0 = 0;
    reg [7:0] duty1 = 25;
    reg [7:0] duty2 = 50;
    reg [7:0] duty3 = 100;
    wire [3:0] pwm_out;
    integer checks;

    always #5 clk = ~clk;

    pwm_generator #(.PERIOD_CYCLES(PERIOD_CYCLES)) dut (
        .clk(clk), .rst_n(rst_n),
        .duty0(duty0), .duty1(duty1), .duty2(duty2), .duty3(duty3),
        .pwm_out(pwm_out)
    );

    task check_one_period;
        input integer expected0;
        input integer expected1;
        input integer expected2;
        input integer expected3;
        integer i;
        begin
            for (i = 0; i < PERIOD_CYCLES; i = i + 1) begin
                #1;
                if (pwm_out[0] !== (i < expected0) ||
                    pwm_out[1] !== (i < expected1) ||
                    pwm_out[2] !== (i < expected2) ||
                    pwm_out[3] !== (i < expected3)) begin
                    $display("FAIL at %0t, period index %0d, pwm_out=%b",
                             $time, i, pwm_out);
                    $display("Expected high cycles: %0d, %0d, %0d, %0d",
                             expected0, expected1, expected2, expected3);
                    $fatal(1);
                end
                checks = checks + 1;
                @(posedge clk);
            end
            #1;
        end
    endtask

    initial begin
        $dumpfile("build/pwm_generator.vcd");
        $dumpvars(0, tb_pwm_generator);
    end

    initial begin
        checks = 0;
        repeat (2) @(posedge clk);
        #1;
        if (pwm_out !== 4'b0000) begin
            $display("FAIL: outputs should be low during reset");
            $fatal(1);
        end

        @(negedge clk);
        rst_n = 1'b1;

        // The input settings are captured at the next period boundary.
        repeat (PERIOD_CYCLES) @(posedge clk);
        #1;
        check_one_period(0, 4, 8, 16);

        // Change the inputs halfway through a run. Active values must not
        // change until the next period begins.
        @(negedge clk);
        duty0 = 100;
        duty1 = 75;
        duty2 = 25;
        duty3 = 0;
        check_one_period(0, 4, 8, 16);
        check_one_period(16, 12, 4, 0);

        // Check rounding and clamping of an out-of-range request.
        @(negedge clk);
        duty0 = 10;
        duty1 = 40;
        duty2 = 60;
        duty3 = 150;
        check_one_period(16, 12, 4, 0);
        check_one_period(1, 6, 9, 16);

        $display("PASS: %0d period-position checks completed", checks);
        $finish;
    end

    initial begin
        #10000;
        $display("FAIL: testbench timeout");
        $fatal(1);
    end
endmodule
