
module bitshift
(
    input clk,
    input [15:0] din,
    input [3:0] shift,
    output reg [15:0] dout
);
    always @(posedge clk) begin

        case(shift)

        4'd0:    dout <= din;
        4'd1:    dout <= { 1'b0, din[15:1] };
        4'd2:    dout <= { 2'b0, din[15:2] };
        4'd3:    dout <= { 3'b0, din[15:3] };
        4'd4:    dout <= { 4'b0, din[15:4] };
        4'd5:    dout <= { 5'b0, din[15:5] };
        4'd6:    dout <= { 6'b0, din[15:6] };
        4'd7:    dout <= { 7'b0, din[15:7] };
        4'd8:    dout <= { 8'b0, din[15:8] };
        4'd9:    dout <= { 9'b0, din[15:9] };        
        4'd10:    dout <= { 10'b0, din[15:10] };
        4'd11:    dout <= { 11'b0, din[15:11] };
        4'd12:    dout <= { 12'b0, din[15:12] };
        4'd13:    dout <= { 13'b0, din[15:13] };
        4'd14:    dout <= { 14'b0, din[15:14] };
        4'd15:    dout <= { 15'b0, din[15] };

        endcase

    end

endmodule
