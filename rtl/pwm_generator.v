// Four independent PWM outputs with one shared period counter.
// Duty inputs are sampled at the start of each period.
module pwm_generator #(
    parameter integer PERIOD_CYCLES = 1000
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] duty0,
    input  wire [7:0] duty1,
    input  wire [7:0] duty2,
    input  wire [7:0] duty3,
    output wire [3:0] pwm_out
);

    function integer clog2;
        input integer value;
        integer temp;
        begin
            temp = value - 1;
            for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
                temp = temp >> 1;
            if (clog2 < 1) clog2 = 1;
        end
    endfunction

    localparam integer COUNTER_WIDTH = clog2(PERIOD_CYCLES);
    localparam [63:0] PERIOD_64 = PERIOD_CYCLES;

    `ifndef SYNTHESIS
    initial begin
        if (PERIOD_CYCLES < 2)
            $error("PERIOD_CYCLES must be at least 2.");
    end
    `endif

    reg [COUNTER_WIDTH-1:0] counter;
    reg [7:0] duty0_active;
    reg [7:0] duty1_active;
    reg [7:0] duty2_active;
    reg [7:0] duty3_active;

    wire [63:0] high_cycles0 = (PERIOD_64 * duty0_active) / 100;
    wire [63:0] high_cycles1 = (PERIOD_64 * duty1_active) / 100;
    wire [63:0] high_cycles2 = (PERIOD_64 * duty2_active) / 100;
    wire [63:0] high_cycles3 = (PERIOD_64 * duty3_active) / 100;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter      <= 0;
            duty0_active <= 0;
            duty1_active <= 0;
            duty2_active <= 0;
            duty3_active <= 0;
        end else if (counter == PERIOD_CYCLES - 1) begin
            counter      <= 0;
            duty0_active <= (duty0 > 100) ? 8'd100 : duty0;
            duty1_active <= (duty1 > 100) ? 8'd100 : duty1;
            duty2_active <= (duty2 > 100) ? 8'd100 : duty2;
            duty3_active <= (duty3 > 100) ? 8'd100 : duty3;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign pwm_out[0] = (counter < high_cycles0);
    assign pwm_out[1] = (counter < high_cycles1);
    assign pwm_out[2] = (counter < high_cycles2);
    assign pwm_out[3] = (counter < high_cycles3);

endmodule
