// filter noise from GPIO pins
// takes 2 cycles with enabled signal to stabilize a line
// tri-states when not stable

module pinfilter(
    input clk,
    input reset_n,
    input din,
    input ena,
    output reg dout,
    output pos_edge, // detect posedge
    output neg_edge // detect negedge
);

    logic [3:0] dpipe;

    reg d;
    wire d_com;
    wire e_com;

    always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
            d <= 1'b1;
            dpipe <= 4'b1111;

        end else begin
            if (ena) begin
                dpipe <= { dpipe[0], din };

                dout <= d_com;
            end
        end
    end

    assign d_com = (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : d_com; 

endmodule
