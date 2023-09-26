

// https://github.com/WangXuan95/FPGA-SDcard-Reader
//--------------------------------------------------------------------------------------------------------
// Module  : sd_reader
// Type    : synthesizable, IP's top
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: A SD-host to initialize SDcard and read sector
// Compatibility: CardType : SDv1.1 , SDv2  or SDHCv2
//--------------------------------------------------------------------------------------------------------

module sd_reader # (
    parameter [2:0] CLK_DIV = 3'd1,     // when clk =   0~ 25MHz , set CLK_DIV = 3'd0,
                                        // when clk =  25~ 50MHz , set CLK_DIV = 3'd1,
                                        // when clk =  50~100MHz , set CLK_DIV = 3'd2,
                                        // when clk = 100~200MHz , set CLK_DIV = 3'd3,
                                        // ......
    parameter       SIMULATE = 0
) (
    // rstn active-low, 1:working, 0:reset
    input  wire         rstn,
    // clock
    input  wire         clk,
    // SDcard signals (connect to SDcard), this design do not use sddat1~sddat3.
    output wire         sdclk,
    inout               sdcmd,
    inout               sddat0,            // FPGA only read SDDAT signal but never drive it
    // show card status
    output wire [ 3:0]  card_stat,         // show the sdcard initialize status
    output reg  [ 1:0]  card_type,         // 0=UNKNOWN    , 1=SDv1    , 2=SDv2  , 3=SDHCv2
    // user read sector command interface (sync with clk)
    input  wire         rstart, 
    input  wire [31:0]  rsector,
    output wire         rbusy,
    output wire         rdone,
    // sector data output interface (sync with clk)
    output reg          outen,             // when outen=1, a byte of sector content is read out from outbyte
    output reg  [ 8:0]  outaddr,           // outaddr from 0 to 511, because the sector size is 512
    output reg  [ 7:0]  outbyte,            // a byte of sector content
    input  wire         wstart, 
    input  reg  [ 7:0]  inbyte,
    output reg [21:0]   c_size,
    output reg [2:0]    c_size_mult,
    output reg [3:0]    read_bl_len,
    output reg [7:0]    mid,
    output reg [15:0]   oid,
    output reg [39:0]   pnm,
    output reg [31:0]   psn
);

initial {outen, outaddr, outbyte} = '0;

localparam [1:0] UNKNOWN = 2'd0,      // SD card type
                 SDv1    = 2'd1,
                 SDv2    = 2'd2,
                 SDHCv2  = 2'd3;

localparam [15:0] FASTCLKDIV = 16'd1 << CLK_DIV ;
localparam [15:0] SLOWCLKDIV = FASTCLKDIV * (SIMULATE ? 16'd2 : 16'd48);

reg        start  = 1'b0;
reg [15:0] precnt = '0;
reg [ 5:0] cmd    = '0;
reg [31:0] arg    = '0;
reg [15:0] clkdiv = SLOWCLKDIV;
reg [31:0] rsectoraddr = '0;

wire       busy, done, timeout, syntaxe;
wire[31:0] resparg;
wire[127:1] r2;

reg        sdv1_maybe = 1'b0;
reg [ 2:0] cmd8_cnt   = '0;
reg [15:0] rca = '0;

enum logic [4:0] {CMD0, CMD8, CMD55_41, ACMD41, CMD2, CMD3, CMD7, CMD9, CMD10, CMD16, CMD17, CMD24, READING, READING2, WRITING, WRITING2, IDLING, WABORT} sdcmd_stat = CMD0;

reg        sdclkl = 1'b0;
enum logic [3:0] {RWAIT, RDURING, RTAIL, RDONE, RTIMEOUT, WWAIT, WDURING, WCRC, WBUSY, WTAIL, WDONE, WTIMEOUT } sddat_stat = RWAIT;
reg [31:0] ridx   = 0;

assign     rbusy  = sdcmd_stat != IDLING;
assign     rdone  = sdcmd_stat == READING2 && sddat_stat==RDONE || sdcmd_stat == WRITING2 && sddat_stat==WDONE;

assign card_stat = sdcmd_stat;

reg sdcmd_write;
reg sdcmdoe;
reg sdcmdout;

sdcmd_ctrl sdcmd_ctrl_i (
    .rstn        ( rstn         ),
    .clk         ( clk          ),
    .sdclk       ( sdclk        ),
    .sdcmdin     ( sdcmdoe ? 1'b1 : sdcmd        ),
    .sdcmdout    ( sdcmdout     ),
    .sdcmdoe     ( sdcmdoe      ),
    .clkdiv      ( clkdiv       ),
    .start       ( start        ),
    .precnt      ( precnt       ),
    .cmd         ( cmd          ),
    .arg         ( arg          ),
    .busy        ( busy         ),
    .done        ( done         ),
    .timeout     ( timeout      ),
    .syntaxe     ( syntaxe      ),
    .resparg     ( resparg      ),
    .r2          ( r2           )
);
reg sddat0oe = 0;
reg sddat0out;

assign sdcmd = (sdcmdoe) ? sdcmdout : 1'bz;
assign sddat0 = (sddat0oe) ? sddat0out : 1'bz;

task automatic set_cmd(input _start, input[15:0] _precnt='0, input[5:0] _cmd='0, input[31:0] _arg='0 );
    start  <= _start;
    precnt <= _precnt;
    cmd    <= _cmd;
    arg    <= _arg;
endtask




always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        set_cmd(0);
        clkdiv      <= SLOWCLKDIV;
        rsectoraddr <= '0;
        rca         <= '0;
        sdv1_maybe  <= 1'b0;
        card_type   <= UNKNOWN;
        sdcmd_stat  <= CMD0;
        cmd8_cnt <= '0;
    end else begin
        set_cmd(0);
        if(sdcmd_stat == READING2) begin

            if(sddat_stat==RTIMEOUT) begin
                set_cmd(1, 96, 17, rsectoraddr);
                sdcmd_stat <= READING;
            end else if(sddat_stat==RDONE)
                sdcmd_stat <= IDLING;
        end else
        if(sdcmd_stat == WRITING2) begin

            if(sddat_stat==WTIMEOUT) begin
                set_cmd(1, 128, 12, rsectoraddr);
                sdcmd_stat <= WABORT;
            end else if(sddat_stat==WDONE)
                sdcmd_stat <= IDLING;
        end else if(~busy) begin
            case(sdcmd_stat)
                CMD0    :   set_cmd(1, (SIMULATE?512:64000),  0,  'h00000000);
                CMD8    :   set_cmd(1,                 512 ,  8,  'h000001aa);
                CMD55_41:   set_cmd(1,                 512 , 55,  'h00000000);
                ACMD41  :   set_cmd(1,                 256 , 41,  'h40100000);
                CMD2    :   set_cmd(1,                 256 ,  2,  'h00000000);
                CMD3    :   set_cmd(1,                 256 ,  3,  'h00000000);
                CMD7    :   set_cmd(1,                 256 ,  7, {rca,16'h0});
                CMD9    :   set_cmd(1,                 256 ,  9, {rca,16'h0});
                CMD10   :   set_cmd(1,                 256 , 10, {rca,16'h0});
                CMD16   :   set_cmd(1, (SIMULATE?512:64000), 16,  'h00000200);
                IDLING  :  begin
                                if(rstart) begin 
                                    set_cmd(1, 96, 17, (card_type==SDHCv2) ? rsector : {rsector[22:0], 9'b0} );
                                    rsectoraddr <= (card_type==SDHCv2) ? rsector : {rsector[22:0], 9'b0};
                                    sdcmd_stat <= READING;
                                end else
                                if(wstart) begin 
                                    set_cmd(1, 96, 24, (card_type==SDHCv2) ? rsector : {rsector[22:0], 9'b0} );
                                    rsectoraddr <= (card_type==SDHCv2) ? rsector : {rsector[22:0], 9'b0};
                                    sdcmd_stat <= WRITING;
                                end
                            end
            endcase
        end else if(done) begin
            case(sdcmd_stat)
                CMD0    :   sdcmd_stat <= CMD8;
                CMD8    :   if(~timeout && ~syntaxe && resparg[7:0]==8'haa) begin
                                sdcmd_stat <= CMD55_41;
                            end else if(timeout) begin
                                cmd8_cnt <= cmd8_cnt + 3'd1;
                                if(cmd8_cnt == '1) begin
                                    sdv1_maybe <= 1'b1;
                                    sdcmd_stat <= CMD55_41;
                                end
                            end
                CMD55_41:   if(~timeout && ~syntaxe)
                                sdcmd_stat <= ACMD41;
                ACMD41  :   if(~timeout && ~syntaxe && resparg[31]) begin
                                card_type <= sdv1_maybe ? SDv1 : (resparg[30] ? SDHCv2 : SDv2);
                                sdcmd_stat <= CMD2;
                            end else begin
                                sdcmd_stat <= CMD55_41;
                            end
                CMD2    :   if(~timeout && ~syntaxe) begin
                                sdcmd_stat <= CMD3;
                            end
                CMD3    :   if(~timeout && ~syntaxe) begin
                                rca <= resparg[31:16];
                                sdcmd_stat <= CMD9;
                            end

                CMD9   :    if(~timeout && ~syntaxe) begin
                                 sdcmd_stat <= CMD10;
                                 if (r2[127:126] == 2'b01) begin // CSD 2.0 ?
                                    c_size <= r2[69:48];
                                    c_size_mult <= 3'h2;
                                    read_bl_len <= 4'hF; // 2(+2) + 15 = 19 (512KB blocks)
                                 end else begin
                                    c_size <= { 10'b0, r2[73:62] };
                                    c_size_mult <= r2[49:47];
                                    read_bl_len <= r2[83:80];
                                 end
                            end

                CMD10   :   if(~timeout && ~syntaxe) begin
                                sdcmd_stat <= CMD7;
                                mid <= r2[127:120];
                                oid <= r2[119:104];
                                pnm <= r2[103:64];
                                psn <= r2[55:24];
                            end

                CMD7    :   if(~timeout && ~syntaxe) begin
                                clkdiv  <= FASTCLKDIV;
                                sdcmd_stat <= CMD16;
                            end
  
                CMD16   :   if(~timeout && ~syntaxe)
                                sdcmd_stat <= IDLING;

                READING :   if(~timeout && ~syntaxe)
                                sdcmd_stat <= READING2;
                            else
                                set_cmd(1, 128, 17, rsectoraddr);
                WRITING :   if(~timeout && ~syntaxe)
                                sdcmd_stat <= WRITING2;
                            else
                                set_cmd(1, 128, 24, rsectoraddr);
                WABORT:     if(~timeout && ~syntaxe)
                                sdcmd_stat <= IDLING;
            endcase
        end
    end

reg crc_init;
reg [15:0] crc_out;
reg crc_ena = 0;
reg crc_bit;

sd_crc_16(
.BITVAL(crc_bit), 
.ENABLE(crc_ena), 
.BITSTRB(clk), 
.CLEAR(crc_init), 
.CRC(crc_out)
);


always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        outen   <= 1'b0;
        outaddr <= '0;
        outbyte <='0;
        sdclkl  <= 1'b0;
        sddat_stat <= RWAIT;
        ridx    <= 0;
        sdcmd_write <= 1'bz;
        sddat0oe <= 0;
        crc_init <= 0;
    end else begin
        outen   <= 1'b0;
        outaddr <= '1;
        sdclkl  <= sdclk;
        crc_ena <= 0;
        crc_init <= 0;
        if (sdcmd_stat == IDLING) begin
            sddat0oe <= '0;
        end else if (sdcmd_stat == READING) begin
            sddat_stat <= RWAIT;
            ridx   <= 0;
        end else if (sdcmd_stat == WRITING) begin
            sddat_stat <= WWAIT;
            ridx   <= 0;
        end else if(~sdclkl & sdclk) begin
            sddat0oe <= 0;
            case(sddat_stat)
                // reading
                RWAIT   : begin
                    if(~sddat0) begin           // start bit = 0
                        sddat_stat <= RDURING;
                        ridx   <= 0;

                    end else begin
                        if(ridx > 1000000)      // according to SD datasheet, 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)
                            sddat_stat <= RTIMEOUT;
                        ridx   <= ridx + 1;
                    end
                end
                RDURING : begin
                    outbyte[3'd7 - ridx[2:0]] <= sddat0;
                  
                    if(ridx[2:0] == 3'd7) begin
                        outen  <= 1'b1;
                        outaddr<= ridx[11:3];
                    end
                    if(ridx >= 512*8-1) begin
                        sddat_stat <= RTAIL;
                        ridx   <= 0; 
                    end else begin
                        ridx   <= ridx + 1;
                    end
                end
                RTAIL   : begin
                    if(ridx >= 8*8-1)          // ignores crc and end bit
                        sddat_stat <= RDONE;
                    ridx   <= ridx + 1;
                end
                ////////////
                // writing
                ////////////
                WWAIT   : begin
                    sddat0out <= 1'b0; // start bit
                    sddat0oe <= '1;
                    sddat_stat <= WDURING;
                    ridx   <= 0;
                    crc_init <= 1;
                    outen  <= 1'b1;   // bring in first byte
                end
                WDURING : begin
                    sddat0out <= inbyte[3'd7 - ridx[2:0]];
                    sddat0oe <= 1;
                    crc_bit <= inbyte[3'd7 - ridx[2:0]];
                    crc_ena <= 1;
                    if(ridx[2:0] == 3'd7) begin
                        outen  <= 1'b1;
                        outaddr<= ridx[11:3];
                    end
                    if(ridx >= 512*8-1) begin
                        sddat_stat <= WCRC;
                        ridx   <= 0; 
                    end else begin
                        ridx   <= ridx + 1;
                    end
                end
                WCRC: begin
                    sddat0out <= crc_out[4'd15 - ridx[3:0]];
                    sddat0oe <= 1;

                    if(ridx >= 2*8-1) begin
                        sddat_stat <= WBUSY;
                        ridx   <= 0; 
                    end else begin
                        ridx   <= ridx + 1;
                    end
                end
                WBUSY   : begin                 // busy wait
                    if (ridx == 0) begin
                        sddat0out <= 1'b1;      // stop bit
                        sddat0oe <= 1;
                    end
                    else
                    if(!sddat0) begin           // start bit = 0
                        sddat_stat <= WTAIL;    // ack
                        ridx   <= 0;
                    end 
                    else if(ridx > 1000000)      // according to SD datasheet, 1ms is enough to wait for DAT result, here, we set timeout to 1000000 clock cycles = 80ms (when SDCLK=12.5MHz)
                         sddat_stat <= WTIMEOUT;

                    ridx   <= ridx + 1;
                end
                WTAIL   : begin                 // busy wait

                    sddat_stat <= WDONE;
                    ridx   <= 0;

                end

            endcase
        end
    end

endmodule

