/* verilator lint_off TIMESCALEMOD */
module brom #(
    parameter int DATA_WIDTH = 16,
    parameter int ADDR_WIDTH = 32,
    parameter     MEM_FILE   = ""
) (
    input  logic                  clk_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic [DATA_WIDTH-1:0] data_o
);

localparam int MEM_DEPTH = 2**ADDR_WIDTH;

logic [DATA_WIDTH-1:0] rom [MEM_DEPTH];

initial begin
    $readmemb(MEM_FILE, rom);
end

always_ff @(posedge clk_i) begin
    data_o <= rom[addr_i];
end

endmodule
