`define SMS
`define PSG
`define OPLL
`define SCC

module top(
    input   clk,
    input   s1,

    output led,

`ifdef SMS
    // hdmi output
    output            tmds_clk_p,
    output            tmds_clk_n,
    output     [2:0]  tmds_data_p,
    output     [2:0]  tmds_data_n,
`endif

    output hp_ws,
    output hp_din,
    output hp_bck,
    output pa_en,

    input clock,
    input rd_n,
    input wr_n,
    input sltsl_n,

    output int_n,
    output busdir_n,
    output wait_n,
    output datadir,

    inout [7:0] cd,

    input [7:0] mp,

    output [2:0] msel_n,

//    // flash
    output mspi_cs,
    output mspi_sclk,
    inout mspi_miso,
    inout mspi_mosi,
 
    // MicroSD
    output sd_sclk,
    inout sd_cmd,      // MOSI
    inout  sd_dat0,     // MISO
    output sd_dat1,     // 1
    output sd_dat2,     // 1
    output sd_dat3,     // 1
   
    // SDRAM
    output O_sdram_clk,
    output O_sdram_cke,
    output O_sdram_cs_n,            // chip select
    output O_sdram_cas_n,           // columns address select
    output O_sdram_ras_n,           // row address select
    output O_sdram_wen_n,           // write enable
    inout [31:0] IO_sdram_dq,       // 32 bit bidirectional data bus
    output [10:0] O_sdram_addr,     // 11 bit multiplexed address bus
    output [1:0] O_sdram_ba,        // two banks
    output [3:0] O_sdram_dqm       // 32/4
);

wire reset_ram_n;
wire reset_rom_n;
wire res_n_w;

    wire clk_w;
    BUFG(
    .O(clk_w),
    .I(clk)
    );


    reg [2:0] ff_cold_boot = 4;
    reg ff_res1 = 1;
    reg ff_res2 = 1;

    localparam CLK_FRQ              = 27_000_000;
    localparam BS_RES0              = 0;
    localparam BS_RES1              = CLK_FRQ/2;
    localparam BS_WARM              = CLK_FRQ;

    reg ff_s1n = 0;
    always @(posedge clk_w) ff_s1n <= ~s1;
    wire s1n_w = ff_s1n && ff_res1 && res_n_w;
    wire rgb;
    wire rgb_done;

    ws2812(
    .clk(clk_w),
    .rst_n(ff_s1n && res_n_w),
    .WS2812(rgb), // output to the interface of WS2812
    .done(rgb_done)
    );       

    reg [31:0] ff_bootstate          = BS_RES0;
    reg ff_wait = 1;
    reg ff_rgb_state = 0;

    always @(posedge clk_w) begin
        //ff_wait <= 1;
        if (rgb_done)
            case(ff_bootstate)
            BS_RES0: if (reset_ram_n) begin
                        ff_bootstate <= ff_bootstate + 1;
                        ff_res1 <= 0;
                        ff_res2 <= 1;
                        ff_wait <= 1;
                        ff_rgb_state <= 0;
            end
            BS_RES0+32: begin
                        ff_bootstate <= ff_bootstate + 1;
                        ff_res1 <= 1;
            end
            BS_RES1: if (reset_ram_n) begin
                        ff_bootstate <= ff_bootstate + 1;
                        ff_res2 <= 0;
            end
            BS_RES1+32: begin
                        ff_bootstate <= ff_bootstate + 1;
                        ff_res2 <= 1;
            end
            BS_WARM: begin
                        ff_res1 <= 1;
                        ff_res2 <= 1;
                        ff_wait <= 0;
            end
            default: begin
                        ff_bootstate <= ff_bootstate + 1;
            end
            endcase
    end
 


`ifdef SMS
    clk135 (
        .clkout(clk135), //output clkout
        .lock(clk135_lock_w), //output lock
        .reset(~s1n_w), //input reset
        .clkin(clk) //input clkin
    );
    BUFG (
    .O(clk135_w),
    .I(clk135)
    );

    assign rst_w = ~clk135_lock_w & ~clk108_lock_w;
`else

    assign rst_w = ~clk108_lock_w;
`endif

    clkp_108 (
        .clkout(clk108), //output clkout
        .lock(clk108_lock_w), //output lock
        .clkoutp(clk108p), //output clkoutp
        .clkoutd(clk_pa),
        .reset(~s1n_w), //input reset
        .clkin(clk) //input clkin
    );
    BUFG(
    .O(clk108_w),
    .I(clk108)
    );
    BUFG(
    .O(clk108p_w),
    .I(clk108p)
    );
    BUFG(
    .O(clk_pa_w),
    .I(clk_pa)
    );
    assign rst_n_w = ~rst_w;

    clockdiv2(
        .clk_src(clk108_w),
        .reset_n(clk108_lock_w),
        .clk_div(clk54)
    );

    BUFG(
    .O(clk54_w),
    .I(clk54)
    );

/// FLASH ROM LOADER - BIOS


reg ff_rom_wr = 0;
reg [7:0] ff_rom_dout;
reg [22:0] ff_rom_addr;

wire rom_wr_w;
wire [7:0] rom_dout_w;
wire [22:0] rom_addr_w;
assign rom_wr_w = ff_rom_wr;
assign rom_dout_w = ff_rom_dout;
assign rom_addr_w = ff_rom_addr;

reg ff_flash_rd = 0;
reg [23:0] ff_flash_addr = 24'd0;
reg [31:0] ff_flash_counter;

wire flash_data_ready_w;
wire flash_busy_w;

wire[7:0] flash_dout_w;
reg ff_flash_terminate = 0;
flash(
    .clk(clk_w),
    .reset_n(reset_rom_n),
    .SCLK(mspi_sclk),
    .CS(mspi_cs),
    .MISO(mspi_miso),
    .MOSI(mspi_mosi),
    .addr(ff_flash_addr),
    .rd(ff_flash_rd),
    .dout(flash_dout_w),
    .data_ready(flash_data_ready_w),
    .busy(flash_busy_w),
    .terminate(ff_flash_terminate)
);

reg [7:0] ff_flash_state = 8'd0;

localparam STATE_RESET          = 8'd0;
localparam STATE_READ_START     = 8'd1;
localparam STATE_READ_LOOP      = 8'd2;
localparam STATE_IDLE           = 8'd3;

wire flash_idle_w = (ff_flash_state == STATE_IDLE) ? 1'b1 : 1'b0;

always @(posedge clk_w, negedge reset_rom_n) begin
if (reset_rom_n == 0) begin
    ff_flash_state = STATE_RESET;
    ff_flash_rd <= 0;
    ff_rom_wr <= 0;
end else
    case (ff_flash_state)

        STATE_RESET: begin   // reset
            ff_flash_state <= STATE_READ_START;
            ff_flash_rd <= 0;
            ff_rom_wr <= 0;
            ff_flash_terminate <= 0;
        end

        STATE_READ_START: begin  // start read
            if (flash_busy_w == 0) begin
                ff_flash_addr <= 24'h100000;
                ff_rom_addr <= 23'h7fffff;
                ff_flash_rd <= 1;
                ff_flash_state = STATE_READ_LOOP;
                ff_flash_counter <= 128*1024;
            end
        end

        STATE_READ_LOOP: begin  // loop read
            if (flash_busy_w == 0) begin
                if (ff_flash_counter > 0) begin
                    if (~ff_flash_rd) begin

                        ff_flash_addr <= ff_flash_addr + 1;
                        ff_flash_counter <= ff_flash_counter - 1;
                        ff_flash_rd <= 1;

                        ff_rom_wr <= 1;
                        ff_rom_addr <= ff_rom_addr + 1;
                        ff_rom_dout <= flash_dout_w; 

                    end
                end else begin    
                    ff_rom_wr <= 0;
                    ff_flash_rd <= 0;
                    ff_flash_state <= STATE_IDLE;
                end
            end else begin
                ff_rom_wr <= 0;
                ff_flash_rd <= 0;
            end
        end

        STATE_IDLE: begin  // idle
            ff_flash_terminate <= 1;
        end

    endcase
end

//// DOT STATE

reg  [2:0] ff_msel_n;
reg  ff_dotena;

reg [2:0] dotena_state_ff;

always@(posedge clk108_w or negedge rst_n_w) begin
    if (rst_n_w == 0) begin
        dotena_state_ff = 3'd0;
        ff_msel_n <= 3'b111; // none
        ff_dotena <= 1'b0;
    end
    else begin
        case(dotena_state_ff)
        default: begin
            ff_msel_n <= 3'b110; // A0-A7
            ff_dotena <= 1'b0;
            dotena_state_ff <= 3'd1;
        end
        3'd1: begin
            ff_dotena <= 1'b1;
            dotena_state_ff <= 3'd2;
        end
        3'd2: begin
            ff_msel_n <= 3'b101; // A8-A15
            ff_dotena <= 1'b0;
            dotena_state_ff <= 3'd3;
        end
        3'd3: begin
            ff_dotena <= 1'b1;
            dotena_state_ff <= 3'd4;
        end
        3'd4: begin
            ff_msel_n <= 3'b011; // merq, iorq, cs1,cs2,c12, rfsh, m1
            ff_dotena <= 1'b0;
            dotena_state_ff <= 3'd5;
        end
        3'd5: begin
            ff_dotena <= 1'b1;
            dotena_state_ff <= 3'd6;
        end
        3'd6: begin
            ff_msel_n <= 3'b111; // none
            ff_dotena <= 1'b0;
            dotena_state_ff <= 3'd0;
        end
        endcase
    end
end

assign msel_n = ff_msel_n;

wire int_n_w;
wire wait_n_w;
wire busdir_n_w;

wire sltsl_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(sltsl_n),
    .dout(sltsl_n_w),
    .ena(ff_dotena)
);

pinfilter 
 (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(clock),
    .dout(clock3),
    .ena(1)
);

BUFG (
.O(clock_w),
.I(clock3)
);


wire rd_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(rd_n),
    .dout(rd_n_w),
    .ena(ff_dotena)
);

wire wr_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(wr_n),
    .dout(wr_n_w),
    .ena(ff_dotena)
);

wire [15:0] addrmux_w;
wire [7:0] cdin_w;
genvar i;
generate
    for (i = 0; i <= 7; i++)
    begin: address
        pinfilter (
            .clk(clk108_w),
            .reset_n(rst_n_w),
            .din(mp[i]),
            .dout(addrmux_w[i]),
            .ena(~msel_n[0] & ff_dotena)
        );

        pinfilter (
            .clk(clk108_w),
            .reset_n(rst_n_w),
            .din(mp[i]),
            .dout(addrmux_w[i+8]),
            .ena(~msel_n[1] & ff_dotena)
        );

        pinfilter (
            .clk(clk108_w),
            .reset_n(rst_n_w),
            .din(cd[i]),
            .dout(cdin_w[i]),
            .ena(datadir)
        );

    end
endgenerate

reg [15:0] ff_addr;
always@(posedge clk108_w ) begin
    if (~msel_n[2] & ff_dotena) ff_addr = addrmux_w;
end

wire [15:0] addr_w;
assign addr_w = ff_addr;

wire merq_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(mp[0]),
    .dout(merq_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

wire merq_scc_n_w;
pinfilter_reg
(
    .clk(clk108_w),
    .reg_clk(clock_w),
    .reset_n(rst_n_w),
    .din(mp[0]),
    .dout(merq_scc_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

wire iorq_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(mp[1]),
    .dout(iorq_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

//wire cs1_n_w;
//pinfilter (
//    .clk(clk108_w),
//    .reset_n(rst_n_w),
//    .din(mp[2]),
//    .dout(cs1_n_w),
//    .ena(~msel_n[2] & ff_dotena)
//);

//wire cs2_n_w;
//pinfilter (
//    .clk(clk108_w),
//    .reset_n(rst_n_w),
//    .din(mp[3]),
//    .dout(cs2_n_w),
//    .ena(~msel_n[2] & ff_dotena)
//);

//wire res_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(mp[4]),
    .dout(res_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

wire rfsh_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(mp[5]),
    .dout(rfsh_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

//wire cs12_n_w;
//pinfilter (
//    .clk(clk108_w),
//    .reset_n(rst_n_w),
//    .din(mp[6]),
//    .dout(cs12_n_w),
//    .ena(~msel_n[2] & ff_dotena)
//);

wire m1_n_w;
pinfilter (
    .clk(clk108_w),
    .reset_n(rst_n_w),
    .din(mp[7]),
    .dout(m1_n_w),
    .ena(~msel_n[2] & ff_dotena)
);

//////////////
wire reset_n_w;
assign reset_n_w = rst_n_w & res_n_w & ff_res2;

wire ram_fail_w;
wire ram_enabled_w;


assign reset_ram_n = ram_enabled_w && ~ram_fail_w && flash_idle_w;
assign reset_rom_n = ram_enabled_w && ~ram_fail_w ;

/////////////////////////////


////// SMS

`ifdef SMS

//reg ff_sms_init = 0;
wire sms_reset_n = reset_n_w;

reg ce_cpu;
reg ce_vdp;
reg ce_pix;
reg ce_sp;
always @(negedge clk54_w or negedge sms_reset_n) begin
	reg [4:0] clkd;
    if (~sms_reset_n) begin
        clkd <= 0;
        ce_sp <= 0;
        ce_vdp <= 0;//div5
        ce_pix <= 0;//div10
        ce_cpu <= 0;//div15
    end else begin
        ce_sp <= clkd[0];
        ce_vdp <= 0;//div5
        ce_pix <= 0;//div10
        ce_cpu <= 0;//div15
        clkd <= clkd + 1'd1;
        if (clkd==29) begin
            clkd <= 0;
            ce_vdp <= 1;
            ce_pix <= 1;
        end else if (clkd==24) begin
            ce_vdp <= 1;
            ce_cpu <= 1;
        end else if (clkd==19) begin
            ce_vdp <= 1;
            ce_pix <= 1;
        end else if (clkd==14) begin
            ce_vdp <= 1;
        end else if (clkd==9) begin
            ce_cpu <= 1;
            ce_vdp <= 1;
            ce_pix <= 1;
        end else if (clkd==4) begin
            ce_vdp <= 1;
        end
    end
end

BUFG (
.O(ce_vdp_w),
.I(ce_vdp)
);
BUFG (
.O(ce_pix_w),
.I(ce_pix)
);
BUFG (
.O(ce_sp_w),
.I(ce_sp)
);
BUFG (
.O(ce_cpu_w),
.I(ce_cpu)
);

wire vdp_cs, psg_cs;
assign vdp_cs = (sms_reset_n && ~iorq_n_w && m1_n_w && addr_w[7:1] == 7'b1000100) ? 1 : 0; // ports 88 and 89
assign psg_cs = (sms_reset_n && ~iorq_n_w && m1_n_w && addr_w[7:1] == 7'b0100100) ? 1 : 0; // ports 48 and 49
wire vdp_rd_n, vdp_wr_n, vdp_irq_n;
assign vdp_rd_n = (~rd_n_w && (vdp_cs || psg_cs)) ? 0 : 1;
assign vdp_wr_n = (~wr_n_w && vdp_cs) ? 0: 1;
wire [7:0] vdp_cdout;
wire [8:0] vdp_x;
wire [8:0] vdp_y;
wire [11:0] vdp_color;
wire vdp_mask_colum;

reg ff_vdp_rd_n, ff_vdp_wr_n;
reg ff_prev_vdp_rd_n = 1;
reg ff_prev_vdp_wr_n = 1;

always @(posedge clk54_w) begin

    if (ce_vdp_w) begin
        ff_vdp_rd_n <= 1;
        ff_vdp_wr_n <= 1;
    end

        if (ff_prev_vdp_rd_n != vdp_rd_n) begin
            ff_vdp_rd_n <= vdp_rd_n;
            ff_prev_vdp_rd_n <= vdp_rd_n;
        end

        if (ff_prev_vdp_wr_n != vdp_wr_n) begin
            ff_vdp_wr_n <= vdp_wr_n;
            ff_prev_vdp_wr_n <= vdp_wr_n;
        end
end

wire psg_wr_n = (~wr_n_w && psg_cs) ? 0: 1;
wire [10:0] jt89_wave;
jt89 (
    .rst(~sms_reset_n),
    .clk(clk54_w),
    .clk_en(ce_cpu_w),
    .din(cdin_w),
    .wr_n(psg_wr_n),
    //.ready(),
    .mux(8'b11111111),
    .soundL(jt89_wave)
    //.soundR(jt89_wave)
);


wire vdp_smode_M1,vdp_smode_M2,vdp_smode_M3,vdp_smode_M4;
vdp #(
        .MAX_SPPL(7)
	)(
        .clk_sys(clk54_w),
        .ce_vdp(ce_vdp_w),
        .ce_pix(ce_pix_w),
        .ce_sp(ce_sp_w),
        .gg(0), // game gear ?
        .sp64(0), // 64 sprites per line ?
        .HL(0), // hsync counter for gun ?
        .RD_n(ff_vdp_rd_n),
        .WR_n(ff_vdp_wr_n),
        .IRQ_n(vdp_irq_n),
        .A(addr_w[7:0]),
        .D_in(cdin_w),
        .D_out(vdp_cdout),
        .x(vdp_x),
        .y(vdp_y),
        .color(vdp_color),
        .mask_column(vdp_mask_column),
        .smode_M1(vdp_smode_M1),
        .smode_M2(vdp_smode_M2),
        .smode_M3(vdp_smode_M3),
        .smode_M4(vdp_smode_M4),
        .reset_n(sms_reset_n)
);

wire vdp_HSync, vdp_VSync, vdp_HBlank, vdp_VBlank;
video (
	.clk(clk54_w),
	.ce_pix(ce_pix_w),
	.pal(0),
	.border(0),
	.mask_column(vdp_mask_column),
	.x(vdp_x),
	.y(vdp_y),
    .smode_M1(vdp_smode_M1),
	.smode_M3(vdp_smode_M3),
	.hsync(vdp_HSync),
	.vsync(vdp_VSync),
	.hblank(vdp_HBlank),
	.vblank(vdp_VBlank)
);

reg [8:0] vx;
reg [8:0] vy;
wire [15:0] vdp_color_addr;
always @(posedge clk54_w or negedge sms_reset_n) begin    
    if (~sms_reset_n) begin
        vx <= 9'b111111110;
        vy <= '0;
    end else if (ce_pix_w) begin
        vx <= vx + 1;
        if (vdp_x == 0) begin 
            vx <= 9'b111111110;
            vy <= vy + 1;
        end
        if (vdp_y == 0) begin 
            vy <= '0;
        end
    end
end

/////////////////////////// HDMI OUTPUT //////////////////////////////
wire [9:0] cy_w;
wire [9:0] cx_w;
wire [7:0] r_w;
wire [7:0] g_w;
wire [7:0] b_w;
wire [5:0] out_color_w;
wire [15:0] out_color_addr;


reg [9:0] cx_off;
reg [9:0] cy_off;

always @(posedge clk_w) begin   
    cx_off <= cx_w - 9'd112; //9'd83; //9'd112;
    cy_off <= cy_w - 9'd44;

end

assign out_color_addr = { cy_off[8:1], cx_off[8:1] };
assign vdp_color_addr = { vy[7:0], vx[7:0] };
assign {r_w[5:0], g_w[5:0], b_w[5:0] } = '0;

wire [5:0] vdp_color_out;
assign b_w[7:6] =  cx_off[9] ? 2'b00 : vdp_color_out[5:4];
assign g_w[7:6] =  cx_off[9] ? 2'b00 : vdp_color_out[3:2];
assign r_w[7:6] =  cx_off[9] ? 2'b00 : vdp_color_out[1:0];


dpram#(
    .widthad_a(16),
    .width_a(6)
)(
    .clock_a(clk_w),
    .address_a(vdp_color_addr),
    .wren_a(~vx[8] & ~vy[8]),
    .rden_a(0),
    .data_a({vdp_color[11:10], vdp_color[7:6], vdp_color[3:2] }),
//    .q_a(),

    .clock_b(clk_w),
    .address_b(out_color_addr),
    .wren_b(0),
    .rden_b(1),
//    .data_b( 6'd0 ),
    .q_b(vdp_color_out) 
);

    logic[2:0] tmds;
    logic [9:0] tmds_internal [NUM_CHANNELS-1:0];

    assign tmds_internal = tmds_ntsc;

    localparam AUDIO_RATE=44100;
    localparam AUDIO_BIT_WIDTH = 16;
    localparam NUM_CHANNELS = 3;

    clockdivint #(
        .CLK_SRC(27),
        .CLK_DIV(0.044100)//,
        //.PRECISION_BITS(16)
    ) (
        .clk_src(clk_w),
        .reset_n(sms_reset_n),
        .clk_div(clk_audio)
    );
    BUFG (
    .O(clk_audio_w),
    .I(clk_audio)
    );

    wire [15:0] sample_w;

    reg [15:0] audio_sample_word [1:0], audio_sample_word0 [1:0];
    always @(posedge clk_w) begin       // crossing clock domain
        audio_sample_word0[0] <= sample_w;
        audio_sample_word[0] <= audio_sample_word0[0];
        audio_sample_word0[1] <= sample_w;
        audio_sample_word[1] <= audio_sample_word0[1];
    end
    wire [15:0] audio_sample_word_w [1:0];
    assign audio_sample_word_w = audio_sample_word;

    logic [9:0] tmds_ntsc [NUM_CHANNELS-1:0];
    hdmi #( .VIDEO_ID_CODE(2), 
            .DVI_OUTPUT(0), 
            .VIDEO_REFRESH_RATE(60.0), //59.94),
            .IT_CONTENT(1),
            .AUDIO_RATE(AUDIO_RATE), 
            .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH),
            .VENDOR_NAME({"Unknown", 8'd0}), // Must be 8 bytes null-padded 7-bit ASCII
            .PRODUCT_DESCRIPTION({"FPGA", 96'd0}), // Must be 16 bytes null-padded 7-bit ASCII
            .SOURCE_DEVICE_INFORMATION(8'h00), // See README.md or CTA-861-G for the list of valid codes
            .START_X(0),
            .START_Y(0),
            .NUM_CHANNELS(NUM_CHANNELS)
            )

    hdmi_inst ( .clk_pixel_x5(clk135_w), 
          .clk_pixel(clk_w), 
          .clk_audio(clk_audio_w),
          .rgb({r_w, g_w, b_w}), 
          .reset( ~sms_reset_n ),
          .audio_sample_word(audio_sample_word_w),
          .cx(cx_w), 
          .cy(cy_w),
          .tmds_internal(tmds_internal)
        );

    
    serializer #(.NUM_CHANNELS(NUM_CHANNELS), .VIDEO_RATE(0)) serializer(.clk_pixel(clk_w), .clk_pixel_x5(clk135_w), .reset(~sms_reset_n),
    .tmds_internal(tmds_internal), .tmds(tmds) ); 

    // Gowin LVDS output buffer
    ELVDS_OBUF tmds_bufds [3:0] (
        .I({clk_w, tmds}),
        .O({tmds_clk_p, tmds_data_p}),
        .OB({tmds_clk_n, tmds_data_n})
    );

`endif
/////////////////////////////////////////////////////////////////




wire [3:0] slotsel_w;
wire [7:0] expslot_cd_w;
wire expslot_busreq_w;
wire [3:0] cart_ena_w;
expslot(
    .clk(clk108_w),
    .reset_n(ram_enabled_w),
    .addr(addr_w),
    .cdin(cdin_w),
    .cdout(expslot_cd_w),
    .busreq(expslot_busreq_w),
    .enable(clock_w),
    .rd_n(rd_n_w),
    .wr_n(wr_n_w),
    .sltsl_n(sltsl_n_w),
    .slotsel(slotsel_w)
);

///////////////////////// SUB SLOTS //////////////////////////////
localparam MM_SSLT = 3;
localparam MR_SSLT = 2;
localparam FM_SSLT = 1;
localparam BIOS_SSLT = 0;


wire [22:0] bios_addr_w;
megaromBIOS(
    .clk(clk108_w),
    .reset_n(ram_enabled_w),
    .addr(addr_w),
    .cdin(cdin_w),
    .merq_n(merq_n_w),
    .enable(clock_w),
    .sltsl_n(~slotsel_w[BIOS_SSLT]),
    .iorq_n(iorq_n_w),
    .m1_n(m1_n_w),
    .rd_n(rd_n_w),
    .wr_n(wr_n_w),
    .mem_addr(bios_addr_w),
    .cart_ena(cart_ena_w[BIOS_SSLT])
);

////
localparam int SDC_SDATA		=  16'h7C00;		 	// rw: 7C00h-7Dff - sector transfer area
localparam int SDC_ENABLE  	    =  16'h7E00;		    // wo: 1: enable SDC register, 0: disable
localparam int SDC_CMD			=  SDC_ENABLE+1; 		// wo: cmd to SDC fpga: 1=sd read, 2=sd write
localparam int SDC_STATUS		=  SDC_CMD+1;	 		// ro: SDC status bits
localparam int SDC_SADDR		=  SDC_STATUS+1;	 	// wo: 4 bytes: sector addr for read/write
localparam int SDC_C_SIZE  	    =  SDC_SADDR+4;			// ro: 3 bytes: device size blocks
localparam int SDC_C_SIZE_MULT	=  SDC_C_SIZE+3;		// ro: 3 bits size multiplier
localparam int SDC_RD_BL_LEN	=  SDC_C_SIZE_MULT+1;	// ro: 4 bits block length
localparam int SDC_CTYPE		=  SDC_RD_BL_LEN+1;		// ro: SDC Card type: 0=unknown, 1=SDv1, 2=SDv2, 3=SDHCv2 
localparam int SDC_MID		    =  SDC_CTYPE+1;		    // ro: manufacture ID: 8 bits unsigned
localparam int SDC_OID		    =  SDC_MID+1;		    // ro: oem id: 2 character
localparam int SDC_PNM		    =  SDC_OID+2;		    // ro: product name: 5 character
localparam int SDC_PSN		    =  SDC_PNM+5;		    // ro: serial number: 32 bits unsigned
localparam int SCC_ENABLE       =  16'h7E80;            // wo: enable disable SCC+
localparam int SDC_END          =  16'h7EFF; 

wire [8:0] sram_addr_w;
reg ff_sram_we = 0;
reg [7:0] ff_sram_cdin;
reg [7:0] ff_sram_cdout;
//
reg ff_sd_en = 0;
wire sram_cs_w;
wire sram_busreq_w;
wire [7:0] sram_cd_w;

wire [3:0] sd_card_stat_w;
wire [1:0] sd_card_type_w;
reg ff_sd_rstart;
reg ff_sd_init;
reg [31:0] ff_sd_sector;
wire sd_busy_w;
wire sd_done_w;
wire sd_outen_w;
wire [8:0] sd_outaddr_w;
wire [7:0] sd_outbyte_w;
reg ff_sd_wstart;
wire [7:0] sd_inbyte_w;

wire [21:0] sd_c_size_w;
wire [2:0] sd_c_size_mult_w;
wire [3:0] sd_read_bl_len_w;

wire [7:0] sd_mid_w;
wire [15:0] sd_oid_w;
wire [39:0] sd_pnm_w;
wire [31:0] sd_psn_w;
wire sd_crc_error_w;
wire sd_timeout_error_w;
//reg ff_scc_enable;
//wire scc_enable_w;
//assign scc_enable_w = ff_scc_enable;
assign sram_cs_w = ram_enabled_w && ff_sd_en && iorq_n_w && m1_n_w && ~merq_n_w && slotsel_w[BIOS_SSLT] && (addr_w >= SDC_SDATA && addr_w < SDC_ENABLE) ? 1 : 0;
assign sram_busreq_w = sram_cs_w && ~rd_n_w;

dpram#(
    .widthad_a(9),
    .width_a(8)
)(
    .clock_a(clk108_w),
    .wren_a(clock_w && sram_cs_w && ~wr_n_w),
    .rden_a(clock_w && sram_cs_w && ~rd_n_w),
    .address_a(addr_w[8:0]),
    .data_a(cdin_w),
    .q_a(sram_cd_w),

    .clock_b(clk108_w),
    .wren_b(ff_sd_rstart && sd_outen_w),
    .rden_b(ff_sd_wstart && sd_outen_w),
    .address_b(sd_outaddr_w),
    .data_b(sd_outbyte_w),
    .q_b(sd_inbyte_w)
);

sd_reader #(
    .CLK_DIV(3'd4),
    .SIMULATE(0)
) (
    .rstn(ram_enabled_w),
    .clk(clk108_w),
    .sdclk(sd_sclk),
    .sdcmd(sd_cmd),
    .sddat0(sd_dat0),                  
    .card_stat(sd_card_stat_w),        // show the sdcard initialize status
    .card_type(sd_card_type_w),        // 0=UNKNOWN    , 1=SDv1    , 2=SDv2  , 3=SDHCv2
    .rstart(ff_sd_rstart), 
    .rsector(ff_sd_sector),
    .rbusy(sd_busy_w),
    .rdone(sd_done_w),
    .outen(sd_outen_w),                // when outen=1, a byte of sector content is read out from outbyte
    .outaddr(sd_outaddr_w),            // outaddr from 0 to 511, because the sector size is 512
    .outbyte(sd_outbyte_w),            // a byte of sector content
    .wstart(ff_sd_wstart), 
    .inbyte(sd_inbyte_w),
    .c_size(sd_c_size_w),
    .c_size_mult(sd_c_size_mult_w),
    .read_bl_len(sd_read_bl_len_w),
    .mid(sd_mid_w),
    .oid(sd_oid_w),
    .pnm(sd_pnm_w),
    .psn(sd_psn_w),
    .crc_error(sd_crc_error_w),
    .timeout_error(sd_timeout_error_w),
    .init(ff_sd_init)
);

assign sd_dat1 = 1;
assign sd_dat2 = 1;
assign sd_dat3 = 1; // Must set sddat1~3 to 1 to avoid SD card from entering SPI mode


always @(posedge clk108_w or negedge ram_enabled_w) begin
    if (~ram_enabled_w) begin
        ff_sd_en <= 0;
    end else begin
        if (slotsel_w[BIOS_SSLT] && addr_w == SDC_ENABLE && ~wr_n_w && iorq_n_w && m1_n_w) 
            ff_sd_en <= cdin_w[0];
    end
end

wire sd_cs_w;
assign sd_cs_w = ram_enabled_w && ff_sd_en && iorq_n_w && m1_n_w && ~merq_n_w && slotsel_w[BIOS_SSLT] && (addr_w >= SDC_ENABLE && addr_w <= SDC_END) ? 1 : 0;
wire sd_busreq_w;
assign sd_busreq_w = sd_cs_w && ~rd_n_w;
reg [7:0] ff_sd_cd;
wire [7:0] sd_cd_w;
assign sd_cd_w = ff_sd_cd;

always @(posedge clk108_w or negedge ram_enabled_w) begin
    if (~ram_enabled_w) begin
        ff_sd_rstart <= '0;
        ff_sd_wstart <= '0;
        ff_sd_init <= '0;
    end else begin
        if (sd_done_w) begin
            ff_sd_rstart <= '0;
            ff_sd_wstart <= '0;
        end

        if (sd_cs_w) begin
            if (~wr_n_w) begin
                case(addr_w) 
                    SDC_CMD: begin
                        ff_sd_rstart <= ff_sd_rstart | cdin_w[0];
                        ff_sd_wstart <= ff_sd_wstart | cdin_w[1];
                        ff_sd_init   <= ff_sd_init   | cdin_w[7];
                        //ff_sms_init  <= ff_sms_init  | cdin_w[7];
                    end
                    SDC_SADDR+0:    ff_sd_sector[ 7: 0] <= cdin_w;
                    SDC_SADDR+1:    ff_sd_sector[15: 8] <= cdin_w;
                    SDC_SADDR+2:    ff_sd_sector[23:16] <= cdin_w;
                    SDC_SADDR+3:    ff_sd_sector[31:24] <= cdin_w;
                endcase
            end else
            if (~rd_n_w) begin
                case(addr_w) 
                    SDC_ENABLE:     ff_sd_cd <= { 7'b0, ff_sd_en };
                    SDC_STATUS:     ff_sd_cd <= { sd_busy_w, 5'b0, sd_timeout_error_w, sd_crc_error_w };
                    SDC_C_SIZE+0:   ff_sd_cd <= sd_c_size_w[7:0];
                    SDC_C_SIZE+1:   ff_sd_cd <= sd_c_size_w[15:8];
                    SDC_C_SIZE+2:   ff_sd_cd <= { 2'b0, sd_c_size_w[21:16] };
                    SDC_C_SIZE_MULT:ff_sd_cd <= { 5'b0, sd_c_size_mult_w };
                    SDC_RD_BL_LEN:  ff_sd_cd <= { 4'b0, sd_read_bl_len_w };
                    SDC_CTYPE:      ff_sd_cd <= { 6'b0, sd_card_type_w };
                    SDC_MID:        ff_sd_cd <= sd_mid_w;
                    SDC_OID+0:      ff_sd_cd <= sd_oid_w[7:0];
                    SDC_OID+1:      ff_sd_cd <= sd_oid_w[15:8];
                    SDC_PNM+0:      ff_sd_cd <= sd_pnm_w[7:0];
                    SDC_PNM+1:      ff_sd_cd <= sd_pnm_w[15:8];
                    SDC_PNM+2:      ff_sd_cd <= sd_pnm_w[23:16];
                    SDC_PNM+3:      ff_sd_cd <= sd_pnm_w[31:24];
                    SDC_PNM+4:      ff_sd_cd <= sd_pnm_w[39:32];
                    SDC_PSN+0:      ff_sd_cd <= sd_psn_w[7:0];
                    SDC_PSN+1:      ff_sd_cd <= sd_psn_w[15:8];
                    SDC_PSN+2:      ff_sd_cd <= sd_psn_w[23:16];
                    SDC_PSN+3:      ff_sd_cd <= sd_psn_w[31:24];
                    default:        ff_sd_cd <= '1;
                endcase
            end
        end
    end
end


//////

wire [7:0] mmapper_cd_w;
wire mmapper_busreq_w;
wire [22:0] mmapper_addr_w;
mmapper(
    .clk(clk108_w),
    .reset_n(ram_enabled_w),
    .addr(addr_w),
    .cdin(cdin_w),
    .cdout(mmapper_cd_w),
    .busreq(mmapper_busreq_w),
    .enable(clock_w),
    .sltsl_n(~slotsel_w[MM_SSLT]),
    .iorq_n(iorq_n_w),
    .merq_n(merq_n_w),
    .m1_n(m1_n_w),
    .rd_n(rd_n_w),
    .wr_n(wr_n_w),
    .mem_addr(mmapper_addr_w),
    .cart_ena(cart_ena_w[MM_SSLT])
);

wire megaram_ena_w;
wire [22:0] megaram_addr_w;
wire scc_busreq_w;
wire [7:0] scc_cd_w;
wire [14:0] scc_wave_w;


wire megaram_cs_w;
assign megaram_cs_w = (ram_enabled_w && ~iorq_n_w && m1_n_w && rd_n_w && ~wr_n_w && addr_w[7:0] == 8'h8F) ? 1 : 0;
reg ff_scc_enable;
reg ff_scc_addr;
reg [1:0] ff_megaram_type; // 0 Konami, 1 Konami SCC+, 2 ASCII16, 3 ASCII8

//reg [3:0] ff_scc_vol;
//reg [3:0] ff_psg_vol;
//reg [3:0] ff_opll_vol;

always @(posedge clk108_w or negedge ram_enabled_w) begin
    if (~ram_enabled_w) begin
        ff_megaram_type <= 2'b01;
        ff_scc_enable <= '1;
        ff_scc_addr <= '0;

//        ff_scc_vol <= 4'h0;
//        ff_psg_vol <= 4'h0;
//        ff_opll_vol <= 4'h0;

    end else begin
        if (megaram_cs_w) begin

            case(cdin_w)
                8'h00: begin
                    ff_scc_enable <= 1'b1;
                    ff_megaram_type <= 2'b01;
                    ff_scc_addr <= '0;
                end
                8'h05: begin
                    ff_scc_enable <= 1'b1;
                    ff_megaram_type <= 2'b01;
                    ff_scc_addr <= '1;
                end
                8'h16: begin
                    ff_scc_enable <= 1'b0;
                    ff_megaram_type <= 2'b10;
                    ff_scc_addr <= '0;
                end
                8'h08: begin
                    ff_scc_enable <= 1'b0;
                    ff_megaram_type <= 2'b11;
                    ff_scc_addr <= '0;
                end
                8'h04: begin
                    ff_scc_enable <= 1'b0;
                    ff_megaram_type <= 2'b00;
                    ff_scc_addr <= '0;
                end
            endcase
/*
            case(cdin_w[7:4])
                4'hF: begin
                    ff_scc_vol <= 4'h9 - cdin_w[3:0];
                end
                4'hE: begin
                    ff_psg_vol <= 4'h9 - cdin_w[3:0];
                end
                4'hD: begin
                    ff_opll_vol <= 4'h9 - cdin_w[3:0];
                end
            endcase
*/            
        end
    end
end

wire scc_enable_w;
assign scc_enable_w = ff_scc_enable;
assign scc_addr_w = ff_scc_addr;
wire [1:0] megaram_type_w;
assign megaram_type_w = ff_megaram_type;

megaramSCC(
    .clk(clk108_w),
    .reset_n(ram_enabled_w),
    .addr(addr_w),
    .cdin(cdin_w),
    .cdout(scc_cd_w),
    .busreq(scc_busreq_w),
    .merq_n(merq_n_w),
    .merq_scc_n(merq_scc_n_w),
    .enable(clock_w),
    .sltsl_n(~slotsel_w[MR_SSLT]),
    .iorq_n(iorq_n_w),
    .m1_n(m1_n_w),
    .rd_n(rd_n_w),
    .wr_n(wr_n_w),
    .ram_ena(megaram_ena_w),
    .mem_addr(megaram_addr_w),
    .cart_ena(cart_ena_w[MR_SSLT]),
    .scc_wave(scc_wave_w),
    .scc_enable(scc_enable_w),
    .megaram_type(megaram_type_w),
    .scc_addr(scc_addr_w)
);
//////////////// AUDIO
`ifdef PSG
//wire [7:0] psg_cd_w;
wire [7:0] psg_wave_w;
wire psg_req_w;
assign psg_req_w = (ram_enabled_w && iorq_n_w == 0 && m1_n_w == 1 && addr_w[7:1] == 7'b1010000) ? 1 : 0;
//wire psg_busreq_w;

reg [7:0] psg_portb_w = 8'hFF;
reg [7:0] psg_portb2_w = 8'hFF;

clockdivint #(
    .CLK_SRC(108),
    .CLK_DIV(315.0/88.0/2.0)//,
    //.PRECISION_BITS(16)
) (
    .clk_src(clk108_w),
    .reset_n(clk108_lock_w),
    .clk_div(hclock)
);
BUFG(
.O(hclock_w),
.I(hclock)
);


YM2149(
  .I_DA(cdin_w),
  //.O_DA(psg_cd_w),
  //.O_DA_OE_L(psg_busreq_w),
  .I_A9_L(0), 
  .I_A8(1),   
  .I_BDIR( (psg_req_w && ~wr_n_w && ~addr_w[1]) ? 1 : 0),
  .I_BC2(1),   
  .I_BC1( psg_req_w && (~rd_n_w && addr_w[1] || ~wr_n_w && ~addr_w[0]) ? 1 : 0),  
  .I_SEL_L(1),
  .O_AUDIO(psg_wave_w),
  .I_IOA(8'b0),
  //.O_IOA(),
  //.O_IOA_OE_L(),
  .I_IOB(psg_portb_w),
  //.O_IOB(psg_portb_w),
  //O_IOB_OE_L(),
  .ENA(1),
  .RESET_L(ram_enabled_w),
  .CLK(hclock_w),
  .clkHigh(clock_w)
  //debug()
  );
`endif

`ifdef OPLL   
wire opll_req_w;
assign opll_req_w = (ram_enabled_w && ~iorq_n_w && m1_n_w && ~wr_n_w && addr_w[7:1] == 7'b0111110) ? 1 : 0;
wire [15:0] opll_mixout;


clockdivint #(
    .CLK_SRC(108),
    .CLK_DIV(315.0/88.0)//,
    //.PRECISION_BITS(16)
) (
    .clk_src(clk108_w),
    .reset_n(clk108_lock_w),
    .clk_div(clk_opll)
);
BUFG(
.O(clk_opll_w),
.I(clk_opll)
);
/*
opll(
    .xin(clk_opll_w),
    //.xout(),
    .xena(1),
    .d(cdin_w),
    .a(addr_w[0]),
    .cs_n(~opll_req_w),
    .we_n(wr_n_w),
    .ic_n(ram_enabled_w),
    .mixout(opll_mixout)
); 
*/
jt2413 (
    .rst(~ram_enabled_w),
    .clk(clk_opll_w),
    .cen(1'b1),
    .din(cdin_w),
    .addr(addr_w[0]),
    .cs_n(~opll_req_w),
    .wr_n(wr_n_w),
    //.dout
    //.irq_en
    .snd(opll_mixout)
    //.sample
);



`endif

reg [15:0] sound_sample;
reg [15:0] hdmi_sample;
reg [15:0] audio_hdmi;

always@(posedge clk108_w) begin

       hdmi_sample <= 16'b0
`ifdef OPLL       
       + {  opll_mixout[15], opll_mixout[15:1] }
`endif
`ifdef SCC
       + { scc_wave_w[14], scc_wave_w[14:0] }
`endif 
`ifdef PSG
       + { 3'b0, psg_wave_w[7:0], 5'b0 }
`endif
`ifdef SMS
       + { jt89_wave[10], jt89_wave[10], jt89_wave[10], jt89_wave[10], jt89_wave[10], jt89_wave[10:0] }
`endif
       ;

       sound_sample <= hdmi_sample + 16'b0001000000000000;
       audio_hdmi <= (~{hdmi_sample[14:0], 1'b0} ) + 16'b1; // 2-complement signed
end

`ifdef SMS
assign sample_w = audio_hdmi;
`endif

clockdivint #(
    .CLK_SRC(27),
    .CLK_DIV(0.044100*16.0)
    //.PRECISION_BITS(16)
) (
    .clk_src(clk_w),
    .reset_n(clk108_lock_w),
    .clk_div(clk_sound)
);
BUFG (
.O(clk_sound_w),
.I(clk_sound)
);

audio_drive(
.clk_1p536m(clk_sound_w),
.rst_n(clk108_lock_w),
.idata(sound_sample),
//.req(),
.HP_BCK(hp_bck),
.HP_WS(hp_ws),
.HP_DIN(hp_din)
);


///// FM ROM
`ifdef OPLL   
wire [7:0] fmrom_cd_w;
wire fmrom_busreq_w;

assign fmrom_busreq_w = (ram_enabled_w && slotsel_w[FM_SSLT] && iorq_n_w && ~merq_n_w && ~rd_n_w && addr_w[15:14] == 2'b01) ? 1 : 0;
rom #(
.ADDR_WIDTH(14),
.FILENAME("roms/16k_fm_opl.bin.hex")    
)(
    .address(addr_w[13:0]),
    .clock(clk108_w),
    .q(fmrom_cd_w),
    .enable(fmrom_busreq_w)
);
`endif

//// SDRAM
wire ram_re_w;
wire ram_we_w;
wire [15:0] ram_dout16_w;
wire [7:0] ram_dout_w;
wire [22:0] ram_addr_w;

reg ff_mem_ack = 0;

always @(posedge clk108_w) begin

    if (~merq_n_w) begin
        if ((ram_re_w || ram_we_w) && ~ram_busy_w && bus_idle_w) begin
            ff_mem_ack <= 1;
        end
    end else 
        ff_mem_ack <= 0;
end

assign ram_addr_w = (~flash_idle_w) ? rom_addr_w :
                    (ram_enabled_w && slotsel_w[BIOS_SSLT] && cart_ena_w[BIOS_SSLT]) ? bios_addr_w :
                    (ram_enabled_w && slotsel_w[MM_SSLT] && cart_ena_w[MM_SSLT]) ? mmapper_addr_w :
                    (ram_enabled_w && slotsel_w[MR_SSLT] && cart_ena_w[MR_SSLT]) ? megaram_addr_w :
                    23'h7fffff; 

assign ram_re_w = (~flash_idle_w) ? 0 : 
                  (ram_enabled_w && ~ff_mem_ack && slotsel_w[BIOS_SSLT] && cart_ena_w[BIOS_SSLT]) ? ~rd_n_w :
                  (ram_enabled_w && ~ff_mem_ack && slotsel_w[MM_SSLT] && cart_ena_w[MM_SSLT]) ? ~rd_n_w :
                  (ram_enabled_w && ~ff_mem_ack && slotsel_w[MR_SSLT] && cart_ena_w[MR_SSLT]) ? ~rd_n_w :
                  0; 

assign ram_we_w = (~flash_idle_w) ? rom_wr_w : 
                  (ram_enabled_w && ~ff_mem_ack && slotsel_w[MM_SSLT] && cart_ena_w[MM_SSLT]) ? ~wr_n_w :
                  (ram_enabled_w && ~ff_mem_ack && slotsel_w[MR_SSLT] && cart_ena_w[MR_SSLT] && megaram_ena_w) ? ~wr_n_w :
                  0; 

assign ram_dout_w = (ram_addr_w[0] == 1'b0) ? ram_dout16_w[7:0] : ram_dout16_w[15:8];

reg [7:0] ff_cdout;
always @(posedge clk108_w) begin
    //ff_cdout = 'z;
    if (slotsel_w[BIOS_SSLT] && cart_ena_w[BIOS_SSLT]||
        slotsel_w[MM_SSLT] && cart_ena_w[MM_SSLT] ||
        slotsel_w[MR_SSLT] && cart_ena_w[MR_SSLT]) ff_cdout <= ram_dout_w;
    if (sram_busreq_w) ff_cdout <= sram_cd_w;
    if (sd_busreq_w) ff_cdout <= sd_cd_w;
`ifdef SCC
    if (scc_busreq_w) ff_cdout <= scc_cd_w;
`endif
`ifdef OPLL
    if (fmrom_busreq_w) ff_cdout <= fmrom_cd_w;
`endif
`ifdef SMS
    if (~vdp_rd_n) ff_cdout <= vdp_cdout;
`endif

    if (mmapper_busreq_w) ff_cdout <= mmapper_cd_w;
    if (expslot_busreq_w) ff_cdout <= expslot_cd_w;
end

wire iord_w;
wire busdir_cs_w;

`ifndef SMS
wire vdp_rd_n = 1'b1;
`endif

assign busdir_cs_w = (mmapper_busreq_w || ~vdp_rd_n) ? 1 : 0;
assign iord_w = (mmapper_busreq_w || ~vdp_rd_n) ? 1 : 0;
assign busdir_n = ~iord_w; // io port without sltsl

assign datadir = rgb_done == 0 ? 0 : ((~sltsl_n_w || busdir_cs_w) && ~rd_n_w) ? 0 : 1;
assign cd = rgb_done == 0 ? { rgb, rgb, rgb, rgb, rgb, rgb, rgb, rgb } : datadir ? 8'bzzzzzzzz : ff_cdout;
wire bus_idle_w;
assign bus_idle_w = &msel_n || ~flash_idle_w; // read/write only when bus is idling to avoid getting corrupt addresses

wire ram_busy_w;
wire [19:0] ram_total_written_w;
wire [15:0] ram_din_w;
assign ram_din_w = (~flash_idle_w) ? { rom_dout_w, rom_dout_w }  : { cdin_w, cdin_w };
wire [1:0] ram_wdm_w;
assign ram_wdm_w = {~ram_addr_w[0], ram_addr_w[0]};

memory_controller #(.FREQ(108_000_000) )
   (.clk(clk108_w), 
    .clk_sdram(clk108p_w), 
    .resetn(reset_n_w), // keeps resetting until not fail
    .read(ram_re_w && ~ram_busy_w && bus_idle_w),
    .write(ram_we_w && ~ram_busy_w && bus_idle_w),
    //.refresh(~rfsh_n_w & ~ram_busy_w),
    .refresh(~ram_re_w && ~ram_we_w && ~ram_busy_w),
    .addr( ram_addr_w[22:1] ),
    .din(ram_din_w),
    .wdm( ram_wdm_w ),
    .dout( ram_dout16_w ),
    .busy(ram_busy_w), 
    .fail(ram_fail_w), 
    .total_written(ram_total_written_w),
    .enabled(ram_enabled_w),

    .SDRAM_DQ(IO_sdram_dq), .SDRAM_A(O_sdram_addr), .SDRAM_BA(O_sdram_ba), .SDRAM_nCS(O_sdram_cs_n),
    .SDRAM_nWE(O_sdram_wen_n), .SDRAM_nRAS(O_sdram_ras_n), .SDRAM_nCAS(O_sdram_cas_n), 
    .SDRAM_CLK(O_sdram_clk), .SDRAM_CKE(O_sdram_cke), .SDRAM_DQM(O_sdram_dqm)
);

`ifdef SMS
assign int_n = ~vdp_irq_n;
`else
assign int_n = 1'b0;
`endif

assign wait_n = (ff_wait || ~reset_ram_n) ? 1'b1 : 1'b0; 
assign led = sd_busy_w;

assign  pa_en = 1'b1;


endmodule