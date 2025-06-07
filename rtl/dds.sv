/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int PHASE_WIDTH = 16,
    parameter int DATA_WIDTH  = 16,
    parameter     SIN_FILE    = "sin_lut.mem"
) (
    input  logic                          clk_i,
    input  logic                          arstn_i,
    input  logic        [PHASE_WIDTH-1:0] phase_inc_i,
    output logic signed [DATA_WIDTH-1:0]  sin_o
);

localparam int MEM_DEPTH = 2**PHASE_WIDTH;

logic [PHASE_WIDTH-1:0] phase_acc;

always @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        phase_acc <= '0;
    end else begin
        phase_acc <= phase_acc + phase_inc_i;
    end
end

brom #(
    .MEM_FILE  (SIN_FILE  ),
    .MEM_DEPTH (MEM_DEPTH ),
    .MEM_WIDTH (DATA_WIDTH)
) i_sin_lut (
    .clk_i     (clk_i     ),
    .addr_i    (phase_acc ),
    .data_o    (sin_o     )
);

endmodule
