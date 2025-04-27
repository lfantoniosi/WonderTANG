module megaramSCC(
    input clk,
    input reset_n,
    input [15:0] addr,
    input [7:0] cdin,
    output [7:0] cdout,
    output busreq,
    input merq_n,
    input merq_scc_n,
    input enable,
    input sltsl_n,
    input iorq_n,
    input m1_n,
    input rd_n,
    input wr_n,
    output ram_ena,
    output cart_ena,
    output [22:0] mem_addr,
    output [14:0] scc_wave, 
    input scc_enable,
    input [1:0] megaram_type
);

reg [7:0] ff_memreg[0:3];
reg ff_ram_ena;

integer i;

wire [1:0] switch_bank_w;
assign switch_bank_w = megaram_type == 2'b11 ? {~addr[12], addr[11]} :
                       megaram_type == 2'b10 ? {addr[12], ~addr[12]} : { addr[14], addr[13]};

wire [1:0] page_select_w;
assign page_select_w =  megaram_type == 2'b10 ? {addr[15], addr[14]} : {addr[14], addr[13]};

always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        for (i=0; i<=3; i=i+1)
            ff_memreg[i] <= 3-i;
        ff_ram_ena <= 1'b0;
    end else begin
        if (enable) begin
            if (~iorq_n && m1_n) begin
                if (addr[7:0] == 8'h8E) begin
                    if (wr_n == 0) begin
                        ff_ram_ena <= 1'b0; // enable rom mode, page selection
                    end
                    if (rd_n == 0) begin
                        ff_ram_ena <= 1'b1; // enable ram mode, disable page selection
                    end
                end
            end
            if (~ff_ram_ena) begin 
                if (wr_n == 0 && cart_ena) begin
                    if (megaram_type != 2'b01 || addr[12:11] == 2'b10 )
                          ff_memreg[ switch_bank_w ] <= cdin;
                end
            end
        end
    end
end

wire scc_req_w;
wire wavemem_w;
megaram(
    .clk21m(enable),
    .reset(~reset_n),
    .clkena(1),
    .req(scc_req_w),
    //.ack(),
    .wrt(~wr_n),
    .adr(addr),
    .dbi(cdout),
    .dbo(cdin),
    //.ramreq(),
    //.ramwrt(),
    //.ramadr(),
    .ramdbi(8'h00),
    //.ramdbo(),
    .mapsel(2'b00), // SCC+ "-0":SCC+, "01":ASC8K, "11":ASC16K
    .wavl(scc_wave),
    .wavemem(wavemem_w)
    //.wavr()
);


assign ram_ena = ff_ram_ena;

wire [7:0] page_w;
assign page_w = ff_memreg[ page_select_w ];                            // Konami/KonamiSCC

wire [22:0] page_addr_w;
assign page_addr_w = (megaram_type == 2'b10) ? { 2'b0, page_w[6:0], addr[13:0] } :
                                               { 2'b0, page_w, addr[12:0] };

assign mem_addr = 23'h420000 + page_addr_w;

assign cart_ena = (addr[15:14] == 2'b01 || addr[15:14] == 2'b10) && ~sltsl_n && ~merq_n && iorq_n ? 1 : 0;

assign busreq = wavemem_w && scc_enable && ~ram_ena && ~sltsl_n && ~merq_scc_n && iorq_n && ~rd_n && addr[15:14] == 2'b10 && addr[12:11] == 2'b11 ? 1 : 0;
assign scc_req_w = scc_enable && ~ram_ena && ~sltsl_n && ~merq_scc_n && iorq_n && addr[15:14] == 2'b10 && addr[12:11] == 2'b11 ? 1 : 0;

endmodule
