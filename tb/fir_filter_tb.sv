`timescale 1ns/1ps

module fir_filter_tb();

localparam int DATA_WIDTH  = 16;
localparam int COE_WIDTH   = 16;
localparam int COE_NUM     = 66;
localparam     COE_MEM     = "tb/fir_coe.mem";
localparam int PHASE_WIDTH = 16;
localparam     SIN_FILE    = "tb/sin_lut.mem";
localparam int OUT_WIDTH   = DATA_WIDTH + COE_WIDTH;

localparam int CLK_PER     = 2;
localparam int RESET_DELAY = 10;
localparam int SIM_TIME    = 1000;
localparam     PHASE_INC_1 = PHASE_WIDTH'(100);
localparam     PHASE_INC_2 = PHASE_WIDTH'(200);

logic                          clk_i;
logic                          arstn_i;
logic signed [DATA_WIDTH-1:0]  sin_out_1;
logic signed [DATA_WIDTH-1:0]  sin_out_2;
logic signed [OUT_WIDTH-1:0]   fir_out;
logic signed [DATA_WIDTH-1:0]  noise;

assign noise = (sin_out_1 + sin_out_2)/2;

initial begin
    clk_i = 1'b0;
    forever begin
        #(CLK_PER/2) clk_i = ~clk_i;
    end
end

initial begin
    arstn_i = 1'b0;
    repeat (RESET_DELAY) @(posedge clk_i);
    arstn_i = 1'b1;
    repeat (SIM_TIME) @(posedge clk_i);
    `ifdef VERILATOR
    $finish();
    `else
    $stop();
    `endif
end

initial begin
    $dumpfile("fir_filter_tb.vcd");
    $dumpvars(0, fir_filter_tb);
end


fir_filter #(
    .DATA_WIDTH (DATA_WIDTH),
    .COE_WIDTH  (COE_WIDTH ),
    .COE_NUM    (COE_NUM   ),
    .COE_MEM    (COE_MEM   )
) i_fir_filter (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   ),
    .en_i       (1'b1      ),
    .data_i     (noise     ),
    .data_o     (fir_out   )
);

dds #(
    .PHASE_WIDTH (PHASE_WIDTH),
    .DATA_WIDTH  (DATA_WIDTH ),
    .SIN_FILE    (SIN_FILE   )
) i_dds_1 (
    .clk_i       (clk_i      ),
    .arstn_i     (arstn_i    ),
    .phase_inc_i (PHASE_INC_1),
    .sin_o       (sin_out_1  )
);

dds #(
    .PHASE_WIDTH (PHASE_WIDTH),
    .DATA_WIDTH  (DATA_WIDTH ),
    .SIN_FILE    (SIN_FILE   )
) i_dds_2 (
    .clk_i       (clk_i      ),
    .arstn_i     (arstn_i    ),
    .phase_inc_i (PHASE_INC_2),
    .sin_o       (sin_out_2  )
);

endmodule
