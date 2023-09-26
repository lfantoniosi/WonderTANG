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
    input wren_b,
    output reg [width_a-1:0] q_a,
    output reg [width_a-1:0] q_b
);

localparam int array_size = $pow(2,widthad_a);

    reg [width_a-1:0] mem_r[0:array_size-1];

    always @(posedge clock_a) begin
    
        q_a <= mem_r[address_a];

        if (wren_a) 
            mem_r[address_a] <= data_a;

    end

    always @(posedge clock_b) begin
    
        q_b <= mem_r[address_b];

        if (wren_b) 
            mem_r[address_b] <= data_b;

    end


endmodule