// filter noise from GPIO pins
// takes 2 cycles with enabled signal to stabilize a line


module pinfilter
//#(
//    parameter bit REGISTERED = 1'b1
//)
(
    input clk,
    input reset_n,
    input din,
    input ena,
    output reg dout
);

    reg [1:0] dpipe;
    reg d;

    always @(posedge clk or negedge reset_n) begin

    if (~reset_n) begin

            dpipe <= 2'b11;
            dout <= 1'b1;

        end else begin

            if (ena) begin

                dpipe <= { dpipe[0], din };
    
                //if (REGISTERED)
                dout <= (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : dout;

            end

            //if (~REGISTERED)
            //    dout <= (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : dout;

        end
    end

endmodule
