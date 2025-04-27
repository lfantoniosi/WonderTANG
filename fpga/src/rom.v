module rom #(
parameter int ADDR_WIDTH = 14,
parameter int DATA_WIDTH = 8,
parameter [255*8-1:0] FILENAME = ""
)
(
    input [ADDR_WIDTH-1:0] address,
    input clock,
    output reg [DATA_WIDTH-1:0] q,
    input enable
);

localparam int SIZE = $rtoi($pow(2.0,$itor(ADDR_WIDTH)));

reg [DATA_WIDTH-1:0] mem[0:SIZE-1];


initial begin
    $readmemh(FILENAME, mem);
end

    always @(posedge clock) begin
        if (enable)
            q <= mem[address[ADDR_WIDTH-1:0]];
        else q <= 1'bz;
    end

endmodule