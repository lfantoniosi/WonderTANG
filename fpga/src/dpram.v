module dpram
#(
parameter int widthad_a = 8,
parameter int width_a = 8
)
(
    input [widthad_a-1:0] address_a,
    input [widthad_a-1:0] address_b,
    input clock_a,
    input clock_b,
    input [width_a-1:0] data_a,
    input [width_a-1:0] data_b,
    input wren_a,
    input rden_a,
    input wren_b,
    input rden_b,
    output [width_a-1:0] q_a,
    output [width_a-1:0] q_b
);

localparam int array_size = $rtoi($pow(2.0,$itor(widthad_a)));

    reg [width_a-1:0] mem_r[0:array_size-1];
    reg [width_a-1:0] a_r;
    reg [width_a-1:0] b_r;

    always_ff @(posedge clock_a) begin
    
        if (wren_a || rden_a) 
            if (wren_a) 
                mem_r[address_a] <= data_a;
            else
                a_r <= mem_r[address_a];
    end

    always_ff @(posedge clock_b) begin
    
        if (wren_b || rden_b) 
            if (wren_b) 
                mem_r[address_b] <= data_b;
            else
                b_r <= mem_r[address_b];
    end

assign q_a = a_r;
assign q_b = b_r;

endmodule