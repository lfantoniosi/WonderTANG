// filter noise from GPIO pins
// takes 2 cycles with enabled signal to stabilize a line
// tri-states when not stable

module pinfilter(
    input clk,
    input reset_n,
    input din,
    input ena,
    output dout
);

    logic [1:0] dpipe;

    reg d;
    
    always @(posedge clk or negedge reset_n) begin

    if (~reset_n) begin

            d <= 1'b1;
            dpipe <= 2'b11;

        end else begin

            if (ena) begin
                dpipe <= { dpipe[0], din };
            end

            d <= (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : d; 

        end
    end

    assign dout = d;

//    assign dout = (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : d; 

endmodule
