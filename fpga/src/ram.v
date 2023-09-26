module sram512(
    input clk,
    input wea,
    input rea,
    input [8:0] addra,
    input [7:0] dina,
    output [7:0] douta,

    input web,
    input reb,
    input [8:0] addrb,
    input [7:0] dinb,
    output [7:0] doutb
);

    reg [7:0] mem_r[0:511];
    reg [7:0] douta_r;
    reg [7:0] doutb_r;

    always @(posedge clk) begin
    
        if (rea == 1)
            douta_r <= mem_r[addra];

        if (reb == 1)
            doutb_r <= mem_r[addrb];

        if (wea == 1) 
            mem_r[addra] <= dina;

        if (web == 1) 
            mem_r[addrb] <= dinb;


    end

    assign douta = douta_r;
    assign doutb = doutb_r;

endmodule