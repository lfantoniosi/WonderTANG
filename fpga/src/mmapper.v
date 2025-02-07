module mmapper(
    input clk,
    input reset_n,
    input [15:0] addr,
    input [7:0] cdin,
    output [7:0] cdout,
    output busreq,
    input enable,
    input sltsl_n,
    input iorq_n,
    input m1_n,
    input rd_n,
    input merq_n,
    input wr_n,
    output [22:0] mem_addr,
    output cart_ena
);

reg [7:0] ff_memreg[0:3];
reg [7:0] ff_cdout;
reg ff_busreq;
integer i;

always_ff @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        for (i=0; i<=3; i=i+1)
            ff_memreg[i] <= 3-i;
        ff_busreq <= 1'b0;
    end else begin
        if (enable) begin
            ff_busreq <= 0;
            if (iorq_n == 0 && m1_n == 1) begin
                if (wr_n == 0) begin
                    if (addr[7:2] == 6'h3F) begin
                        ff_memreg[ addr[1:0] ] <= cdin;
                    end
                end

                if (rd_n == 0) begin
                    if (addr[7:2] == 6'h3F) begin
                        ff_cdout <= ff_memreg[ addr[1:0] ];
                        ff_busreq <= 1;
                    end
                end
            end
        end
    end
end

assign cdout = ff_cdout;
assign busreq = ff_busreq;

wire [7:0] page_w;
assign page_w = ff_memreg[ addr[15:14] ];

assign mem_addr = 23'h020000 + { 1'b0, page_w, addr[13:0] };
assign cart_ena = ~merq_n && ~sltsl_n && iorq_n;

endmodule
