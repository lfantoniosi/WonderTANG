
module expslot(
    input clk,
    input reset_n,
    input [15:0] addr,
    input [7:0] cdin,
    output [7:0] cdout,
    output busreq,
    input enable,
    input sltsl_n,
    input rd_n,
    input wr_n,
    output [3:0] slotsel
);

reg [7:0] ff_slotreg = 8'b01010101;
reg [7:0] ff_slotsel;
reg [7:0] ff_cdout;
reg ff_busreq;

wire ffff_w;
assign ffff_w = addr == 16'hffff ? 1 : 0;

wire [7:0]slotreg_w;
always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        ff_slotreg <= 8'b01010101;
        ff_busreq <= 1'b0;
    end else begin
        if (enable) begin
            ff_busreq <= 0;
            if (ffff_w == 1 && sltsl_n == 0) begin
                if (wr_n == 0) 
                    ff_slotreg <= cdin;
                else 
                    if (rd_n == 0) begin
                        ff_cdout <= ~ff_slotreg;
                        ff_busreq <= 1;
                    end
            end
        end
    end
end

assign slotreg_w = ff_slotreg;
assign cdout = ff_cdout;
assign busreq = ff_busreq;

wire page0_w;
wire page1_w;
wire page2_w;
wire page3_w;
assign page0_w = ffff_w == 0 && addr[15:14] == 2'b00 ? 1 : 0;
assign page1_w = ffff_w == 0 && addr[15:14] == 2'b01 ? 1 : 0;
assign page2_w = ffff_w == 0 && addr[15:14] == 2'b10 ? 1 : 0;
assign page3_w = ffff_w == 0 && addr[15:14] == 2'b11 ? 1 : 0;

assign slotsel[0] = (page3_w && slotreg_w[7:6] == 2'b00 || 
                     page2_w && slotreg_w[5:4] == 2'b00 || 
                     page1_w && slotreg_w[3:2] == 2'b00 || 
                     page0_w && slotreg_w[1:0] == 2'b00) ? ~sltsl_n : 0;

assign slotsel[1] = (page3_w && slotreg_w[7:6] == 2'b01 || 
                     page2_w && slotreg_w[5:4] == 2'b01 || 
                     page1_w && slotreg_w[3:2] == 2'b01 || 
                     page0_w && slotreg_w[1:0] == 2'b01) ? ~sltsl_n : 0;

assign slotsel[2] = (page3_w && slotreg_w[7:6] == 2'b10 || 
                     page2_w && slotreg_w[5:4] == 2'b10 || 
                     page1_w && slotreg_w[3:2] == 2'b10 || 
                     page0_w && slotreg_w[1:0] == 2'b10) ? ~sltsl_n : 0;

assign slotsel[3] = (page3_w && slotreg_w[7:6] == 2'b11 || 
                     page2_w && slotreg_w[5:4] == 2'b11 || 
                     page1_w && slotreg_w[3:2] == 2'b11 || 
                     page0_w && slotreg_w[1:0] == 2'b11) ? ~sltsl_n : 0;

endmodule
