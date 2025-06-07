/* verilator lint_off TIMESCALEMOD */
module fir_filter #(
    parameter int DATA_WIDTH = 16,
    parameter int COE_WIDTH  = 16,
    parameter int COE_NUM    = 66,
    parameter     COE_MEM    = "fir_coe.mem",
    parameter int OUT_WIDTH  = DATA_WIDTH + COE_WIDTH
) (
    input  logic                         clk_i,
    input  logic                         arstn_i,
    input  logic                         en_i,
    input  logic signed [DATA_WIDTH-1:0] data_i,
    output logic signed [OUT_WIDTH-1:0]  data_o
);

logic signed [OUT_WIDTH-1:0]  acc   [COE_NUM-1];
logic signed [OUT_WIDTH-1:0]  mult  [COE_NUM];
logic signed [COE_WIDTH-1:0]  coe   [COE_NUM];
logic signed [DATA_WIDTH-1:0] shift [COE_NUM];

initial begin
    $readmemh(COE_MEM, coe);
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        shift[0] <= '0;
    end else if (en_i) begin
        shift[0] <= data_i;
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        acc[0] <= '0;
    end else if (en_i) begin
        acc[0] <= mult[0] + mult[1];
    end
end

for (genvar i = 1; i < COE_NUM; i++) begin
    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            shift[i] <= '0;
        end else if (en_i) begin
            shift[i] <= shift[i-1];
        end
    end
end

for (genvar j = 0; j < COE_NUM; j++) begin
    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            mult[j] <= '0;
        end else if (en_i) begin
            mult[j] <= shift[j] * coe[j];
        end
    end
end

for (genvar k = 1; k < COE_NUM - 1; k++) begin
    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            acc[k] <= '0;
        end else if (en_i) begin
            acc[k] <= acc[k-1] + mult[k+1];
        end
    end
end

assign data_o = acc[COE_NUM-2];

endmodule
