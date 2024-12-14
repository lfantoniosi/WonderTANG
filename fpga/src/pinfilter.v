// filter noise from GPIO pins
// takes 2 cycles with enabled signal to stabilize a line

module pinfilter(
    input clk,
    input reset_n,
    input din,
    input ena,
    output dout,
    output pos_edge, // detect posedge
    output neg_edge // detect negedge
);

    logic [1:0] dpipe;

    always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
            dpipe <= 2'b11;
        end else begin
            if (ena) begin
                dpipe <= { dpipe[0], din };
            end
        end
    end

    assign dout = (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : dout; 

endmodule