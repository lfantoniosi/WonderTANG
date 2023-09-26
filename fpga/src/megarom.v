module megaromBIOS(
    input clk,
    input reset_n,
    input [15:0] addr,
    input [7:0] cdin,
    input merq_n,
    input enable,
    input sltsl_n,
    input iorq_n,
    input m1_n,
    input rd_n,
    input wr_n,
    output cart_ena,
    output [22:0] mem_addr
);

reg [2:0] ff_memreg;

integer i;

always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
       ff_memreg <= 3'b0;
    end else begin
        if (enable) begin
            if (wr_n == 0 && cart_ena && addr == 16'h6000) begin
                ff_memreg <= cdin[2:0]; // select page
            end
        end
    end
end

wire [2:0] page_w;
assign page_w = ff_memreg;

assign mem_addr = 23'h000000 + { 6'b0, page_w, addr[13:0] };

assign cart_ena = (addr[15:14] == 2'b01 || addr[15:14] == 2'b10) && ~sltsl_n && ~merq_n && iorq_n ? 1 : 0;

endmodule
