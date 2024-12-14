// filter noise from GPIO pins
// takes 2 cycles with enabled signal to stabilize a line

module pinfilter
#(
    parameter bit REGISTERED = 1'b0
)
(
    input clk,
    input reset_n,
    input din,
    input ena,
    output dout
);

    reg [1:0] dpipe;
    reg d;
    wire o;

    always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
            dpipe <= 2'b11;
            d <= 2'b1;
        end else begin
            if (ena) begin
                dpipe <= { dpipe[0], din };
                d <= (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : d;      
            end
        end
    end

    assign o = (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : o;

    assign dout = (REGISTERED) ? d : o;

endmodule

module pinfilter2
(
    input clk,
    input reg_clk,
    input reset_n,
    input din,
    input ena,
    output dout
);

    reg [1:0] dpipe;
    reg d;
    wire o;

    always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
            dpipe <= 2'b11;
            d <= 2'b1;
        end else begin
            if (ena) begin
                dpipe <= { dpipe[0], din };
                d <= (dpipe[1:0] == 2'b00) ? 1'b0 : (dpipe[1:0] == 2'b11) ? 1'b1 : d;      
            end
        end
    end

    assign dout = (reg_clk) ? d : dout;

endmodule