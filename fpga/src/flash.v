
module flash
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    input reset_n,
    output SCLK,
    output CS,
    input  MISO,
    output MOSI,

    input [23:0] addr,
    input rd,
    output [7:0] dout,
    output data_ready,
    output busy,
    input terminate
);


  localparam STATE_INIT_POWER = 8'd0;
  localparam STATE_LOAD_CMD_TO_SEND = 8'd1;
  localparam STATE_SEND = 8'd2;
  localparam STATE_LOAD_ADDRESS_TO_SEND = 8'd3;
  localparam STATE_READ_DATA = 8'd4;
  localparam STATE_DATA_END = 8'd5;
  localparam STATE_WAIT_NEXT = 8'd6;
  localparam STATE_DONE = 8'd7;

  localparam CMD_READ_DATA_BYTES = 8'h03;

  reg r_MOSI = 0;
  reg r_CS = 1;
  reg r_SCLK = 0;
  reg r_busy = 1;

  reg [23:0] readAddress = 0;
  reg [7:0] command = CMD_READ_DATA_BYTES;
  reg [7:0] currentByteOut = 0;
  reg [7:0] currentByteNum = 0;
  reg [7:0] dataIn = 0;
  reg [7:0] dataInBuffer = 0;


  reg [23:0] dataToSend = 0;
  reg [8:0] bitsToSend = 0;

  reg [32:0] counter = 0;
  reg [2:0] state = STATE_INIT_POWER;
  reg [2:0] returnState = 0;

  reg r_data_ready = 0;

  always_ff @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        state <= STATE_INIT_POWER;
        counter <= 0;
    end else begin
        case (state)

          STATE_INIT_POWER: begin
            if (counter > STARTUP_WAIT) begin
              state <= STATE_LOAD_CMD_TO_SEND;
              counter <= 32'b0;

              currentByteNum <= 0;
              currentByteOut <= 0;
              r_busy <= 0;
            end
            else
              counter <= counter + 1;
          end

          STATE_LOAD_CMD_TO_SEND: begin
              if (rd == 1) begin
                  r_CS <= 0;
                  r_busy <= 1;
                  r_data_ready <= 0;
                  readAddress <= addr;
                  dataToSend[23-:8] <= command;
                  bitsToSend <= 8;
                  state <= STATE_SEND;
                  returnState <= STATE_LOAD_ADDRESS_TO_SEND;
              end
          end

          STATE_SEND: begin
            if (counter == 32'd0) begin
              r_SCLK <= 0;
              r_MOSI <= dataToSend[23];
              dataToSend <= {dataToSend[22:0],1'b0};
              bitsToSend <= bitsToSend - 1;
              counter <= 32'd1;
            end
            else begin
              counter <= 32'd0;
              r_SCLK <= 1;
              if (bitsToSend == 0)
                state <= returnState;
            end
          end

          STATE_LOAD_ADDRESS_TO_SEND: begin
            dataToSend <= readAddress;
            bitsToSend <= 24;
            state <= STATE_SEND;
            returnState <= STATE_READ_DATA;
          end

          STATE_READ_DATA: begin
            if (counter[0] == 1'd0) begin
              r_SCLK <= 0;
              counter <= counter + 1;
              if (counter[3:0] == 0 && counter > 0) begin
                  dataIn <= currentByteOut;
                  state <= STATE_DATA_END;
              end
            end
            else begin
              r_SCLK <= 1;
              currentByteOut <= {currentByteOut[6:0], MISO};
              counter <= counter + 1;
            end
          end 

          STATE_DATA_END: begin
            r_data_ready <= 1;
            dataInBuffer <= dataIn;
            counter <= 32'd0;
            state <= STATE_WAIT_NEXT;
          end

          STATE_WAIT_NEXT: begin
              r_busy <= 0;
              if (rd == 1) begin
                  r_busy <= 1;
                  r_data_ready <= 0;
                  state <= STATE_READ_DATA;
              end else if (terminate == 1) begin
                  state <= STATE_DONE;
              end
          end

          STATE_DONE: begin
            r_CS <= 1;
            r_busy <= 1;
            r_MOSI <= 1;
            r_SCLK <= 1;
            //counter <= STARTUP_WAIT;
            //state <= STATE_INIT_POWER;
          end

        endcase
    end
  end

  assign MOSI = r_MOSI;
  assign CS =  r_CS;
  assign SCLK = r_SCLK;
  assign data_ready = r_data_ready;
  assign busy = r_busy;

  assign dout = dataInBuffer; //data_ready ? dataIn : { 8 {1'bz} };

endmodule