;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (Mac OS X ppc)
;--------------------------------------------------------
	.module smram
	
	.optsdcc -mz80 sdcccall(1)
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _runROM_page2_end
	.globl _runROM_page2
	.globl _runROM_page1_end
	.globl _runROM_page1
	.globl _jump
	.globl _hexToNum
	.globl _dos2_getenv
	.globl _dos2_read
	.globl _dos2_close
	.globl _dos2_open
	.globl _chgcpu
	.globl _rdslt
	.globl _enaslt
	.globl _to_upper
	.globl _fputs
	.globl _bdos_c_rawio
	.globl _bdos_c_write
	.globl _bdos
	.globl _printf
	.globl _opll_vol
	.globl _psg_vol
	.globl _scc_vol
	.globl _help
	.globl _page2
	.globl _cpumode
	.globl _presAB
	.globl _paramlen
	.globl _megaram_type
	.globl _filename
	.globl _found
	.globl _c
	.globl _romstart
	.globl _path
	.globl _slotid
	.globl _romsize
	.globl _page
	.globl _addr
	.globl _i
	.globl _bytes_read
	.globl _handle
	.globl _params
	.globl _t
	.globl _s
	.globl _b
	.globl _sslt
	.globl _cursslt
	.globl _curslt
	.globl _putchar
	.globl _getchar
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_MEGA_PORT0	=	0x008e
_MEGA_PORT1	=	0x008f
_PPIA	=	0x00a8
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_curslt::
	.ds 1
_cursslt::
	.ds 1
_sslt::
	.ds 1
_b::
	.ds 1
_s::
	.ds 2
_t::
	.ds 2
_params::
	.ds 2
_handle::
	.ds 1
_bytes_read::
	.ds 2
_i::
	.ds 2
_addr::
	.ds 2
_page::
	.ds 1
_romsize::
	.ds 4
_slotid::
	.ds 1
_path::
	.ds 256
_romstart::
	.ds 2
_c::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_found::
	.ds 1
_filename::
	.ds 2
_megaram_type::
	.ds 2
_paramlen::
	.ds 1
_presAB::
	.ds 1
_cpumode::
	.ds 1
_page2::
	.ds 1
_help::
	.ds 1
_scc_vol::
	.ds 1
_psg_vol::
	.ds 1
_opll_vol::
	.ds 1
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;smram.c:41: void bdos() __naked
;	---------------------------------
; Function bdos
; ---------------------------------
_bdos::
;smram.c:50: __endasm;
	push	ix
	push	iy
	call	5
	pop	iy
	pop	ix
	ret
;smram.c:51: }
;smram.c:53: void bdos_c_write(uchar c) __naked
;	---------------------------------
; Function bdos_c_write
; ---------------------------------
_bdos_c_write::
;smram.c:63: __endasm;
	ld	e,a
	ld	c,#2
	call	_bdos
	ret
;smram.c:64: }
;smram.c:66: uchar bdos_c_rawio() __naked
;	---------------------------------
; Function bdos_c_rawio
; ---------------------------------
_bdos_c_rawio::
;smram.c:75: __endasm;
	ld	e,#0xFF;
	ld	c,#6
	call	_bdos
	ret
;smram.c:76: }
;smram.c:78: int putchar(int c) 
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	ex	de, hl
;smram.c:80: if (c >= 0)
	bit	7, d
	ret	NZ
;smram.c:81: bdos_c_write((char)c);
	ld	a, e
	push	de
	call	_bdos_c_write
	pop	de
;smram.c:82: return c;
;smram.c:83: }
	ret
;smram.c:85: int getchar()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;smram.c:88: do {
00101$:
;smram.c:89: c = bdos_c_rawio();
	call	_bdos_c_rawio
	ld	e, a
;smram.c:90: } while(c == 0);
	or	a, a
	jr	Z, 00101$
;smram.c:91: return (int)c;
	ld	d, #0x00
;smram.c:92: }
	ret
;smram.c:94: void fputs(const char *s)
;	---------------------------------
; Function fputs
; ---------------------------------
_fputs::
;smram.c:96: while(*s != NULL)
00101$:
	ld	a, (hl)
	or	a, a
	ret	Z
;smram.c:97: putchar(*s++);
	inc	hl
	ld	c, #0x00
	push	hl
	ld	l, a
	ld	h, c
	call	_putchar
	pop	hl
;smram.c:98: }
	jr	00101$
;smram.c:100: char to_upper(char c)
;	---------------------------------
; Function to_upper
; ---------------------------------
_to_upper::
;smram.c:102: if (c >= 'a' && c <= 'z')
	cp	a, #0x61
	ret	C
	cp	a, #0x7b
	ret	NC
;smram.c:103: c = c - ('a'-'A');
	add	a, #0xe0
;smram.c:104: return c;
;smram.c:105: }
	ret
;smram.c:107: void enaslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function enaslt
; ---------------------------------
_enaslt::
;smram.c:129: __endasm;
	push	af
	push	bc
	push	de
	push	hl
	push	ix
	push	iy
	ex	de,hl
	call	#0x0024
	pop	iy
	pop	ix
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
;smram.c:130: }
;smram.c:132: uchar rdslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function rdslt
; ---------------------------------
_rdslt::
;smram.c:147: __endasm;
	push	bc
	push	de
	ex	de,hl
	call	#0x000C
	ex	de,hl
	pop	de
	pop	bc
	ret
;smram.c:148: }
;smram.c:150: void chgcpu(uchar mode) __naked
;	---------------------------------
; Function chgcpu
; ---------------------------------
_chgcpu::
;smram.c:180: __endasm;
	push	bc
	push	de
	push	af
	ld	a,(0xFCC1)
	ld	hl,#0x0180
	call	#0x000C
	cp	#0xC3
	jr	nz,__no_turbo
	ld	a,b
	pop	af
	ld	iy,(0xFCC1 -1)
	ld	ix,#0x0180
	call	#0x001C
	push	af
__no_turbo:
	pop	af
	pop	de
	pop	bc
	ret
;smram.c:181: }
;smram.c:198: FHANDLE dos2_open(uchar mode, const char* filepath) __naked
;	---------------------------------
; Function dos2_open
; ---------------------------------
_dos2_open::
;smram.c:216: __endasm;
	push	bc
	push	de
	push	hl
	ld	c,#0x43
	call	5
	or	a
	jr	z,__open_no_err
	ld	b,#0
__open_no_err:
	ld	a,b
	pop	hl
	pop	de
	pop	bc
	ret
;smram.c:217: }
;smram.c:219: void dos2_close(FHANDLE hnd) __naked
;	---------------------------------
; Function dos2_close
; ---------------------------------
_dos2_close::
;smram.c:229: __endasm;
	push	bc
	ld	a,b
	ld	c,#0x45
	call	5
	pop	bc
	ret
;smram.c:230: }
;smram.c:232: uint dos2_read(FHANDLE hnd, void *dst, uint size) __naked
;	---------------------------------
; Function dos2_read
; ---------------------------------
_dos2_read::
;smram.c:252: __endasm;	
	push	ix
	ld	ix,#0
	add	ix,sp
	push	bc
	ld	b,a
	ld	l, 4 (ix)
	ld	h, 5 (ix)
	ld	c,#0x48
	call	5
	pop	bc
	pop	ix
	ex	de,hl
	ret
;smram.c:253: }
;smram.c:255: uchar dos2_getenv(char *var, char *buf) __naked
;	---------------------------------
; Function dos2_getenv
; ---------------------------------
_dos2_getenv::
;smram.c:263: __endasm;	
	ld	b,#255
	ld	c,#0x6B
	call	5
	ret
;smram.c:264: }
;smram.c:266: char hexToNum(char h)
;	---------------------------------
; Function hexToNum
; ---------------------------------
_hexToNum::
;smram.c:270: if (h >= '0' && h <='9')
	cp	a, #0x30
	jr	C, 00102$
	cp	a, #0x3a
	jr	NC, 00102$
;smram.c:271: return h-'0';    
	add	a, #0xd0
	ret
00102$:
;smram.c:272: return 0;
	xor	a, a
;smram.c:273: }
	ret
;smram.c:275: void jump(uint addr) __naked
;	---------------------------------
; Function jump
; ---------------------------------
_jump::
;smram.c:283: __endasm;
	ld	sp,(0x0006)
	jp	(hl)
;smram.c:284: }
;smram.c:286: void runROM_page1() __naked
;	---------------------------------
; Function runROM_page1
; ---------------------------------
_runROM_page1::
;smram.c:302: __endasm;
	di
	ld	sp,#0xCFFF
	ld	hl,#0xFD9A
	ld	a,#0xC9
	ld	(hl),a
	ld	hl,#0xFD9F
	ld	(hl),a
	ld	a,(0xFCC1)
	ld	hl,#0
	call	#0x0024
	ld	hl,(0x4002)
	jp	(hl)
;smram.c:303: }
;smram.c:304: void runROM_page1_end() __naked {}
;	---------------------------------
; Function runROM_page1_end
; ---------------------------------
_runROM_page1_end::
;smram.c:306: void runROM_page2() __naked
;	---------------------------------
; Function runROM_page2
; ---------------------------------
_runROM_page2::
;smram.c:322: __endasm;
	di
	ld	sp,#0xCFFF
	ld	hl,#0xFD9A
	ld	a,#0xC9
	ld	(hl),a
	ld	hl,#0xFD9F
	ld	(hl),a
	ld	a,(0xFCC1)
	ld	hl,#0
	call	#0x0024
	ld	hl,(0x8002)
	jp	(hl)
;smram.c:323: }
;smram.c:324: void runROM_page2_end() __naked {}
;	---------------------------------
; Function runROM_page2_end
; ---------------------------------
_runROM_page2_end::
;smram.c:352: int main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;smram.c:354: curslt = (PPIA & 0x0C) >> 2;
	in	a, (_PPIA)
	and	a, #0x0c
	ld	c, a
	ld	b, #0x00
	sra	b
	rr	c
	sra	b
	rr	c
	ld	iy, #_curslt
	ld	0 (iy), c
;smram.c:355: cursslt = (~(*((uchar*)0xFFFF)) & 0x0C) | *((uchar*)EXPTBL+curslt);
	ld	a, (#0xffff)
	cpl
	and	a, #0x0c
	ld	c, a
	ld	l, 0 (iy)
	ld	h, #0x00
	ld	de, #0xfcc1
	add	hl, de
	ld	a, (hl)
	or	a, c
	ld	(_cursslt+0), a
;smram.c:357: for(i = 1; i < 4; i++)
	ld	hl, #0x0001
	ld	(_i), hl
00229$:
;smram.c:359: slotid = *((uchar*)EXPTBL+i);
	ld	hl, (_i)
	ld	de, #0xfcc1
	add	hl, de
	ld	a, (hl)
	ld	(_slotid+0), a
;smram.c:361: if (slotid & 0x80) {    // expanded ?
	ld	a, (_slotid)
	rlca
	jr	NC, 00230$
;smram.c:363: enaslt(i | 0x80, 0x4000); // looking for BIOS, sslot 0
	ld	a, (_i)
	set	7, a
	ld	de, #0x4000
	call	_enaslt
;smram.c:365: b = *(uchar*)(0x6000); // it might be RAM
	ld	a, (#0x6000)
	ld	(_b+0), a
;smram.c:366: *((uchar*)0x6000) = 7;
	ld	hl, #0x6000
	ld	(hl), #0x07
;smram.c:367: s = "WonderTANG! uSD Driver";
	ld	hl, #___str_0
	ld	(_s), hl
;smram.c:368: t = (uchar*)0x4110;
	ld	hl, #0x4110
	ld	(_t), hl
;smram.c:369: for(int j=0; j<22; j++)
	ld	c, #0x00
00227$:
	ld	a, c
	sub	a, #0x16
	jr	NC, 00105$
;smram.c:371: if (*s++ != *t++) break;
	ld	hl, (_s)
	ld	b, (hl)
	ld	hl, (_s)
	inc	hl
	ld	(_s), hl
	ld	hl, (_t)
	ld	e, (hl)
	ld	hl, (_t)
	inc	hl
	ld	(_t), hl
	ld	a, b
	sub	a, e
	jr	NZ, 00105$
;smram.c:373: if (j == 21) 
	ld	a, c
	sub	a, #0x15
	jr	NZ, 00228$
;smram.c:375: found = TRUE;
	ld	hl, #_found
	ld	(hl), #0x01
;smram.c:376: break;
	jr	00105$
00228$:
;smram.c:369: for(int j=0; j<22; j++)
	inc	c
	jr	00227$
00105$:
;smram.c:380: *((uchar*)0x6000) = b; // return whatever was there
	ld	hl, #0x6000
	ld	a, (_b)
	ld	(hl), a
;smram.c:382: enaslt(curslt | cursslt, 0x4000);
	ld	a, (_curslt)
	ld	hl, #_cursslt
	or	a, (hl)
	ld	de, #0x4000
	call	_enaslt
;smram.c:384: if (found) break;
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00110$
00230$:
;smram.c:357: for(i = 1; i < 4; i++)
	ld	hl, (_i)
	inc	hl
	ld	(_i), hl
	ld	a, (_i+0)
	sub	a, #0x04
	ld	a, (_i+1)
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C, 00229$
00110$:
;smram.c:388: sslt = 0;
	xor	a, a
	ld	(_sslt+0), a
;smram.c:390: if (found)
	ld	a, (_found+0)
	or	a, a
	jp	Z, 00177$
;smram.c:392: printf("WonderTANG! Super MegaRAM SCC+\n\r");
	ld	hl, #___str_1
	push	hl
	call	_printf
;smram.c:393: printf("v2.01\n\r");
	ld	hl, #___str_2
	ex	(sp),hl
	call	_printf
	pop	af
;smram.c:395: sslt = 0x80 | (2 << 2) | i;
	ld	a, (_i)
	or	a, #0x88
	ld	(_sslt+0), a
;smram.c:396: paramlen = *((char*)0x80);
	ld	a, (#0x0080)
	ld	(_paramlen+0), a
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, #0x0081
	ld	(_params), hl
00233$:
	ld	bc, (_params)
	ld	a, (bc)
	ld	e, a
	or	a, a
	jr	NZ, 00232$
	ld	a, (_paramlen+0)
	or	a, a
	jp	NZ, 00178$
00232$:
;smram.c:399: if (*params != ' ')
;smram.c:401: if (*params == '/')
	ld	a,e
	cp	a,#0x20
	jp	Z,00234$
	sub	a, #0x2f
	jp	NZ, 00171$
;smram.c:403: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:404: if (to_upper(*params) == 'R') {
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x52
	jr	NZ, 00164$
;smram.c:405: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:406: if (*params == '0')
	cp	a, #0x30
	jr	NZ, 00124$
;smram.c:407: megaram_type = TYPE_MSCC;
	ld	hl, #0x0000
	ld	(_megaram_type), hl
	jp	00234$
00124$:
;smram.c:409: if (*params == '6')
	cp	a, #0x36
	jr	NZ, 00121$
;smram.c:410: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00234$
00121$:
;smram.c:412: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00118$
;smram.c:413: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00234$
00118$:
;smram.c:415: if (*params == '1')
	cp	a, #0x31
	jr	NZ, 00115$
;smram.c:416: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00234$
00115$:
;smram.c:418: if (*params == '3')
	sub	a, #0x33
	jr	NZ, 00112$
;smram.c:419: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00234$
00112$:
;smram.c:421: megaram_type = TYPE_UNK;                    
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00234$
00164$:
;smram.c:423: else if (to_upper(*params) == 'K')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x4b
	jr	NZ, 00161$
;smram.c:425: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:426: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00130$
;smram.c:427: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00234$
00130$:
;smram.c:429: if (*params == '4')
	sub	a, #0x34
	jr	NZ, 00127$
;smram.c:430: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00234$
00127$:
;smram.c:432: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00234$
00161$:
;smram.c:434: else if (to_upper(*params) == 'A')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x41
	jr	NZ, 00158$
;smram.c:436: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:437: if (*params == '8')
	cp	a, #0x38
	jr	NZ, 00139$
;smram.c:438: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00234$
00139$:
;smram.c:440: if (*params == '1')
	sub	a, #0x31
	jr	NZ, 00136$
;smram.c:442: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:443: if (*params == '6')
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x36
	jr	NZ, 00133$
;smram.c:444: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00234$
00133$:
;smram.c:446: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00234$
00136$:
;smram.c:449: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00234$
00158$:
;smram.c:451: else if (to_upper(*params) == 'Y')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x59
	jr	NZ, 00155$
;smram.c:453: presAB = TRUE;
	ld	hl, #_presAB
	ld	(hl), #0x01
	jr	00234$
00155$:
;smram.c:483: else if (to_upper(*params) == 'Z')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x5a
	jr	NZ, 00152$
;smram.c:485: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:486: if (*params >= '0' && *params <= '3')
	cp	a, #0x30
	jr	C, 00234$
	cp	a, #0x34
	jr	NC, 00234$
;smram.c:487: cpumode = *params - '0';
	ld	hl, #_cpumode
	add	a, #0xd0
	ld	(hl), a
	jr	00234$
00152$:
;smram.c:489: else if (to_upper(*params) == '?')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x3f
	jr	NZ, 00145$
;smram.c:491: help = TRUE;
	ld	hl, #_help
	ld	(hl), #0x01
	jr	00234$
;smram.c:496: while(*params++ != 0 && *params != ' ');
00145$:
	ld	hl, (_params)
	ld	c, (hl)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	a, c
	or	a, a
	jr	Z, 00234$
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x20
	jr	Z, 00234$
	jr	00145$
00171$:
;smram.c:501: filename = params;
	ld	(_filename), bc
;smram.c:502: while(*params != 0 && *params != ' ') {
00167$:
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:502: while(*params != 0 && *params != ' ') {
	or	a, a
	jr	Z, 00178$
	cp	a, #0x20
	jr	Z, 00178$
;smram.c:503: *params = to_upper(*params);
	push	hl
	call	_to_upper
	pop	hl
	ld	(hl), a
;smram.c:504: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	jr	00167$
;smram.c:507: break;
00234$:
;smram.c:397: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	hl, #_paramlen
	dec	(hl)
	jp	00233$
00177$:
;smram.c:512: } else megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
00178$:
;smram.c:514: if (!found) 
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00183$
;smram.c:516: printf("ERROR: WonderTANG! not found...\n\r");
	ld	hl, #___str_3
	push	hl
	call	_printf
	pop	af
;smram.c:517: return 0;
	ld	de, #0x0000
	ret
00183$:
;smram.c:520: if (help == TRUE || megaram_type == TYPE_UNK)
	ld	a, (_help+0)
	dec	a
	jr	Z, 00179$
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	NZ, 00184$
00179$:
;smram.c:540: );
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
;smram.c:541: return 0;
	ld	de, #0x0000
	ret
00184$:
;smram.c:544: printf("\r\nMapper Type: ");
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
;smram.c:545: switch(megaram_type)
	ld	a, (_megaram_type+0)
	or	a, a
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00185$
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	or	a, 1 (iy)
	jr	Z, 00186$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00187$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00189$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00188$
	jr	00190$
;smram.c:547: case TYPE_MSCC:
00185$:
;smram.c:548: printf("MegaRAM SCC (default)\n\r");
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
;smram.c:549: break;
	jr	00190$
;smram.c:550: case TYPE_K4:
00186$:
;smram.c:551: printf("Konami (/R6 or /K4)\n\r");
	ld	bc, #___str_7
	push	bc
	call	_printf
	pop	af
;smram.c:552: break;
	jr	00190$
;smram.c:553: case TYPE_K5:
00187$:
;smram.c:554: printf("Konami SCC (/R5 or /K5)\n\r");
	ld	bc, #___str_8+0
	push	bc
	call	_printf
	pop	af
;smram.c:555: break;
	jr	00190$
;smram.c:556: case TYPE_A16:
00188$:
;smram.c:557: printf("ASCII16 (/R1 or /A16)\n\r");
	ld	hl, #___str_9
	push	hl
	call	_printf
	pop	af
;smram.c:558: break;
	jr	00190$
;smram.c:559: case TYPE_A8:
00189$:
;smram.c:560: printf("ASCII8 (/R3 or /A8)\n\r");
	ld	bc, #___str_10+0
	push	bc
	call	_printf
	pop	af
;smram.c:562: }
00190$:
;smram.c:568: if (filename == 0) {        
	ld	a, (_filename+1)
	ld	hl, #_filename
	or	a, (hl)
	jr	NZ, 00194$
;smram.c:569: if (megaram_type != TYPE_UNK)
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	Z, 00192$
;smram.c:570: MEGA_PORT1 = megaram_type;    
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
00192$:
;smram.c:571: return 0;
	ld	de, #0x0000
	ret
00194$:
;smram.c:574: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	hl, (_filename)
	ld	(_t), hl
00237$:
;smram.c:371: if (*s++ != *t++) break;
	ld	hl, (_t)
;smram.c:574: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	a, (hl)
	cp	a, #0x20
	jr	Z, 00195$
	or	a, a
	jr	Z, 00195$
	ld	hl, (_t)
	inc	hl
	ld	(_t), hl
	jr	00237$
00195$:
;smram.c:575: *t = 0;
	ld	(hl), #0x00
;smram.c:576: handle = dos2_open(0, filename);
	ld	de, (_filename)
	xor	a, a
	call	_dos2_open
	ld	(_handle+0), a
;smram.c:578: MEGA_PORT1 = TYPE_K4;
	ld	a, #0x04
	out	(_MEGA_PORT1), a
;smram.c:580: if (handle)
	ld	a, (_handle+0)
	or	a, a
	jp	Z, 00205$
;smram.c:582: printf("Loading ROM file: %s - ", filename);
	ld	hl, (_filename)
	push	hl
	ld	hl, #___str_11
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:584: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt)
	call	_enaslt
;smram.c:585: page = 0;
;smram.c:586: romsize = 0;
	xor	a, a
	ld	(_page+0), a
	ld	(_romsize+0), a
	ld	(_romsize+1), a
	ld	(_romsize+2), a
	ld	(_romsize+3), a
;smram.c:587: printf("%04dKB", 0);
	ld	hl, #0x0000
	push	hl
	ld	hl, #___str_12
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:589: do {
00201$:
;smram.c:591: MEGA_PORT0 = 0; // enable paging
	xor	a, a
	out	(_MEGA_PORT0), a
;smram.c:592: *((uchar *)0x4000) = page++;
	ld	a, (_page)
	ld	c, a
	ld	hl, #_page
	inc	(hl)
	ld	hl, #0x4000
	ld	(hl), c
;smram.c:593: b = MEGA_PORT0; (b); // enable ram
	in	a, (_MEGA_PORT0)
	ld	(_b+0), a
;smram.c:594: bytes_read = dos2_read(handle, (void*)0x8000, 0x2000);
	ld	h, #0x20
	push	hl
	ld	de, #0x8000
	ld	a, (_handle)
	call	_dos2_read
	ld	(_bytes_read), de
;smram.c:595: if (presAB == FALSE && romsize == 0) 
	ld	a, (_presAB+0)
	or	a, a
	jr	NZ, 00197$
	ld	a, (_romsize+3)
	ld	iy, #_romsize
	or	a, 2 (iy)
	or	a, 1 (iy)
	or	a, 0 (iy)
	jr	NZ, 00197$
;smram.c:596: *((uchar*)(0x8000)) = 0;
	ld	hl, #0x8000
	ld	(hl), #0x00
00197$:
;smram.c:597: romsize += bytes_read;
	ld	bc, (_bytes_read)
	ld	de, #0x0000
	ld	a, c
	ld	hl, #_romsize
	add	a, (hl)
	ld	(hl), a
	inc	hl
	ld	a, b
	adc	a, (hl)
	ld	(hl), a
	inc	hl
	ld	a, e
	adc	a, (hl)
	ld	(hl), a
	inc	hl
	ld	a, d
	adc	a, (hl)
	ld	(hl), a
;smram.c:598: memcpy((void*)0x4000, (void*)0x8000, bytes_read);
	ld	de, #0x4000
	ld	hl, #0x8000
	ld	bc, (_bytes_read)
	ld	a, b
	or	a, c
	jr	Z, 00756$
	ldir
00756$:
;smram.c:599: if (page == 0)
	ld	a, (_page+0)
	or	a, a
	jr	NZ, 00200$
;smram.c:600: romstart = *((uint*)0x8002);
	ld	hl, #0x8002
	ld	a, (hl)
	inc	hl
	ld	(_romstart+0), a
	ld	a, (hl)
	ld	(_romstart+1), a
00200$:
;smram.c:601: MEGA_PORT0 = 0; // enable paging
	xor	a, a
	out	(_MEGA_PORT0), a
;smram.c:602: printf("\b\b\b\b\b\b%04dKB", (uint)(romsize >> 10));
	ld	hl, (_romsize + 1)
	ld	a, (#_romsize + 3)
	ld	e, a
	ld	b, #0x02
00757$:
	srl	e
	rr	h
	rr	l
	djnz	00757$
	push	hl
	ld	hl, #___str_13
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:604: } while (bytes_read > 0);
	ld	a, (_bytes_read+1)
	ld	hl, #_bytes_read
	or	a, (hl)
	jp	NZ, 00201$
;smram.c:606: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:608: dos2_close(handle);
	ld	a, (_handle)
	call	_dos2_close
	jr	00206$
00205$:
;smram.c:612: printf("ERROR: Failed loading %s\n\r", filename);
	ld	hl, (_filename)
	push	hl
	ld	hl, #___str_14
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:613: return 0;
	ld	de, #0x0000
	ret
00206$:
;smram.c:615: *t = ' '; // restore space
	ld	hl, (_t)
	ld	(hl), #0x20
;smram.c:616: MEGA_PORT1 = megaram_type;
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
;smram.c:618: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt)
	call	_enaslt
;smram.c:619: romstart = 0x4002;
	ld	hl, #0x4002
	ld	(_romstart), hl
;smram.c:625: printf("\n\r\n\rStart address: 0x%04x (page %d)\n\r", romstart, page2 == TRUE ? 2 : 1);
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00241$
	ld	bc, #0x0002
	jr	00242$
00241$:
	ld	bc, #0x0001
00242$:
	push	bc
	ld	hl, #0x4002
	push	hl
	ld	hl, #___str_15
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
;smram.c:627: switch(megaram_type)
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00210$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00210$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00216$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00213$
	jr	00220$
;smram.c:630: case TYPE_K5:
00210$:
;smram.c:631: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:632: *((uchar *)0x6000) = 1;
	ld	h, #0x60
	ld	(hl), #0x01
;smram.c:633: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00220$
;smram.c:635: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:636: *((uchar *)0xA000) = 1;
	ld	h, #0xa0
	ld	(hl), #0x01
;smram.c:638: break;
	jr	00220$
;smram.c:639: case TYPE_A16:
00213$:
;smram.c:640: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:641: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00220$
;smram.c:642: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:643: break;
	jr	00220$
;smram.c:644: case TYPE_A8:
00216$:
;smram.c:645: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:646: *((uchar *)0x6800) = 1;
	ld	h, #0x68
	ld	(hl), #0x01
;smram.c:647: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00220$
;smram.c:649: *((uchar *)0x7000) = 0;
	ld	h, #0x70
	ld	(hl), #0x00
;smram.c:650: *((uchar *)0x7800) = 1;
	ld	h, #0x78
	ld	(hl), #0x01
;smram.c:655: }
00220$:
;smram.c:657: if (page2 == TRUE)
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00222$
;smram.c:658: memcpy((void*)0xC000, &runROM_page2, ((uint)&runROM_page2_end - (uint)&runROM_page2));
	ld	hl, #_runROM_page2
	ld	bc, #_runROM_page2_end
	ld	de, #_runROM_page2
	ld	a, c
	sub	a, e
	ld	c, a
	ld	a, b
	sbc	a, d
	ld	b, a
	ld	de, #0xc000
	ld	a, b
	or	a, c
	jr	Z, 00223$
	ldir
	jr	00223$
00222$:
;smram.c:660: memcpy((void*)0xC000, &runROM_page1, ((uint)&runROM_page1_end - (uint)&runROM_page1));
	ld	hl, #_runROM_page1
	ld	bc, #_runROM_page1_end
	ld	de, #_runROM_page1
	ld	a, c
	sub	a, e
	ld	c, a
	ld	a, b
	sbc	a, d
	ld	b, a
	ld	de, #0xc000
	ld	a, b
	or	a, c
	jr	Z, 00768$
	ldir
00768$:
00223$:
;smram.c:662: if (cpumode != 0)
	ld	a, (_cpumode+0)
	or	a, a
	jr	Z, 00225$
;smram.c:663: chgcpu(cpumode == 1 ? Z80_ROM : cpumode == 2 ? R800_ROM : R800_DRAM);
	ld	a, (_cpumode+0)
	dec	a
	jr	Z, 00244$
	ld	a, (_cpumode+0)
	sub	a, #0x02
	ld	a, #0x81
	jr	Z, 00246$
	ld	a, #0x82
00246$:
00244$:
	call	_chgcpu
00225$:
;smram.c:666: printf("\n\rPress any key to proceed...\n\r");
	ld	hl, #___str_16
	push	hl
	call	_printf
	pop	af
;smram.c:667: c = getchar();
	call	_getchar
	ld	hl, #_c
	ld	(hl), e
;smram.c:669: jump(0xC000);
	ld	hl, #0xc000
	call	_jump
;smram.c:671: return 1; // make sdcc happy
	ld	de, #0x0001
;smram.c:672: }
	ret
___str_0:
	.ascii "WonderTANG! uSD Driver"
	.db 0x00
___str_1:
	.ascii "WonderTANG! Super MegaRAM SCC+"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_2:
	.ascii "v2.01"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_3:
	.ascii "ERROR: WonderTANG! not found..."
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_4:
	.db 0x0a
	.db 0x0d
	.ascii "USAGE: SMRAM [/Rx /Zx /Y] [romfile]"
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii " /Rx: Set MegaROM type"
	.db 0x0a
	.db 0x0d
	.ascii "   0: Megaram SCC (default)"
	.db 0x0a
	.db 0x0d
	.ascii "   1: ASCII16     (/A16)"
	.db 0x0a
	.db 0x0d
	.ascii "   3: ASCII8      (/A8)"
	.db 0x0a
	.db 0x0d
	.ascii "   5: Konami SCC  (/K5)"
	.db 0x0a
	.db 0x0d
	.ascii "   6: Konami      (/K4)"
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii " /Zx: Set cpu mode"
	.db 0x0a
	.db 0x0d
	.ascii "   0: current"
	.db 0x0a
	.db 0x0d
	.ascii "   1: Z80"
	.db 0x0a
	.db 0x0d
	.ascii "   2: R800 ROM"
	.db 0x0a
	.db 0x0d
	.ascii "   3: R800 DRAM"
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii " /Y:  Preserve AB header"
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_5:
	.db 0x0d
	.db 0x0a
	.ascii "Mapper Type: "
	.db 0x00
___str_6:
	.ascii "MegaRAM SCC (default)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_7:
	.ascii "Konami (/R6 or /K4)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_8:
	.ascii "Konami SCC (/R5 or /K5)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_9:
	.ascii "ASCII16 (/R1 or /A16)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_10:
	.ascii "ASCII8 (/R3 or /A8)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_11:
	.ascii "Loading ROM file: %s - "
	.db 0x00
___str_12:
	.ascii "%04dKB"
	.db 0x00
___str_13:
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.ascii "%04dKB"
	.db 0x00
___str_14:
	.ascii "ERROR: Failed loading %s"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_15:
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii "Start address: 0x%04x (page %d)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_16:
	.db 0x0a
	.db 0x0d
	.ascii "Press any key to proceed..."
	.db 0x0a
	.db 0x0d
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__found:
	.db #0x00	; 0
__xinit__filename:
	.dw #0x0000
__xinit__megaram_type:
	.dw #0x0000
__xinit__paramlen:
	.db #0x00	; 0
__xinit__presAB:
	.db #0x00	; 0
__xinit__cpumode:
	.db #0x01	; 1
__xinit__page2:
	.db #0x00	; 0
__xinit__help:
	.db #0x00	; 0
__xinit__scc_vol:
	.db #0x09	; 9
__xinit__psg_vol:
	.db #0x09	; 9
__xinit__opll_vol:
	.db #0x09	; 9
	.area _CABS (ABS)
