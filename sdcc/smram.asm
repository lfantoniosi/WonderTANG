;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.4.0 #14620 (Linux)
;--------------------------------------------------------
	.module smram
	.optsdcc -mz80
	
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
	.globl _calslt
	.globl _enaslt
	.globl _to_upper
	.globl _fputs
	.globl _bdos_c_rawio
	.globl _bdos_c_write
	.globl _bdos
	.globl _printf
	.globl _soft_reset
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
_soft_reset::
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
;smram.c:39: void bdos() __naked
;	---------------------------------
; Function bdos
; ---------------------------------
_bdos::
;smram.c:48: __endasm;
	push	ix
	push	iy
	call	5
	pop	iy
	pop	ix
	ret
;smram.c:49: }
;smram.c:51: void bdos_c_write(uchar c) __naked
;	---------------------------------
; Function bdos_c_write
; ---------------------------------
_bdos_c_write::
;smram.c:61: __endasm;
	ld	e,a
	ld	c,#2
	call	_bdos
	ret
;smram.c:62: }
;smram.c:64: uchar bdos_c_rawio() __naked
;	---------------------------------
; Function bdos_c_rawio
; ---------------------------------
_bdos_c_rawio::
;smram.c:73: __endasm;
	ld	e,#0xFF;
	ld	c,#6
	call	_bdos
	ret
;smram.c:74: }
;smram.c:76: int putchar(int c) 
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	ex	de, hl
;smram.c:78: if (c >= 0)
	bit	7, d
	ret	NZ
;smram.c:79: bdos_c_write((char)c);
	ld	c, e
	push	de
	ld	a, c
	call	_bdos_c_write
	pop	de
;smram.c:80: return c;
;smram.c:81: }
	ret
;smram.c:83: int getchar()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;smram.c:86: do {
00101$:
;smram.c:87: c = bdos_c_rawio();
	call	_bdos_c_rawio
	ld	e, a
;smram.c:88: } while(c == 0);
	or	a, a
	jr	Z, 00101$
;smram.c:89: return (int)c;
	ld	d, #0x00
;smram.c:90: }
	ret
;smram.c:92: void fputs(const char *s)
;	---------------------------------
; Function fputs
; ---------------------------------
_fputs::
	ex	de, hl
;smram.c:94: while(*s != NULL)
00101$:
	ld	a, (de)
	or	a, a
	ret	Z
;smram.c:95: putchar(*s++);
	inc	de
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	push	de
	call	_putchar
	pop	de
;smram.c:96: }
	jr	00101$
;smram.c:98: char to_upper(char c)
;	---------------------------------
; Function to_upper
; ---------------------------------
_to_upper::
;smram.c:100: if (c >= 'a' && c <= 'z')
	ld	c, a
	sub	a, #0x61
	jr	C, 00102$
	ld	a, #0x7a
	sub	a, c
	jr	C, 00102$
;smram.c:101: c = c - ('a'-'A');
	ld	a, c
	add	a, #0xe0
	ld	c, a
00102$:
;smram.c:102: return c;
	ld	a, c
;smram.c:103: }
	ret
;smram.c:105: void enaslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function enaslt
; ---------------------------------
_enaslt::
;smram.c:127: __endasm;
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
;smram.c:128: }
;smram.c:130: void calslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function calslt
; ---------------------------------
_calslt::
;smram.c:155: __endasm;
	push	af
	push	bc
	push	de
	push	hl
	push	ix
	push	iy
	push	af
	pop	iy
	push	de
	pop	ix
	call	#0x001C
	pop	iy
	pop	ix
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
;smram.c:156: }
;smram.c:159: uchar rdslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function rdslt
; ---------------------------------
_rdslt::
;smram.c:174: __endasm;
	push	bc
	push	de
	ex	de,hl
	call	#0x000C
	ex	de,hl
	pop	de
	pop	bc
	ret
;smram.c:175: }
;smram.c:177: void chgcpu(uchar mode) __naked
;	---------------------------------
; Function chgcpu
; ---------------------------------
_chgcpu::
;smram.c:207: __endasm;
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
;smram.c:208: }
;smram.c:225: FHANDLE dos2_open(uchar mode, const char* filepath) __naked
;	---------------------------------
; Function dos2_open
; ---------------------------------
_dos2_open::
;smram.c:243: __endasm;
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
;smram.c:244: }
;smram.c:246: void dos2_close(FHANDLE hnd) __naked
;	---------------------------------
; Function dos2_close
; ---------------------------------
_dos2_close::
;smram.c:256: __endasm;
	push	bc
	ld	a,b
	ld	c,#0x45
	call	5
	pop	bc
	ret
;smram.c:257: }
;smram.c:259: uint dos2_read(FHANDLE hnd, void *dst, uint size) __naked
;	---------------------------------
; Function dos2_read
; ---------------------------------
_dos2_read::
;smram.c:279: __endasm;	
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
;smram.c:280: }
;smram.c:282: uchar dos2_getenv(char *var, char *buf) __naked
;	---------------------------------
; Function dos2_getenv
; ---------------------------------
_dos2_getenv::
;smram.c:290: __endasm;	
	ld	b,#255
	ld	c,#0x6B
	call	5
	ret
;smram.c:291: }
;smram.c:293: char hexToNum(char h)
;	---------------------------------
; Function hexToNum
; ---------------------------------
_hexToNum::
;smram.c:297: if (h >= '0' && h <='9')
	ld	c, a
	sub	a, #0x30
	jr	C, 00102$
	ld	a, #0x39
	sub	a, c
	jr	C, 00102$
;smram.c:298: return h-'0';    
	ld	a, c
	add	a, #0xd0
	ret
00102$:
;smram.c:299: return 0;
	xor	a, a
;smram.c:300: }
	ret
;smram.c:302: void jump(uint addr) __naked
;	---------------------------------
; Function jump
; ---------------------------------
_jump::
;smram.c:310: __endasm;
	ld	sp,(0x0006)
	jp	(hl)
;smram.c:311: }
;smram.c:313: void runROM_page1() __naked
;	---------------------------------
; Function runROM_page1
; ---------------------------------
_runROM_page1::
;smram.c:329: __endasm;
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
;smram.c:330: }
;smram.c:331: void runROM_page1_end() __naked {}
;	---------------------------------
; Function runROM_page1_end
; ---------------------------------
_runROM_page1_end::
;smram.c:333: void runROM_page2() __naked
;	---------------------------------
; Function runROM_page2
; ---------------------------------
_runROM_page2::
;smram.c:349: __endasm;
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
;smram.c:350: }
;smram.c:351: void runROM_page2_end() __naked {}
;	---------------------------------
; Function runROM_page2_end
; ---------------------------------
_runROM_page2_end::
;smram.c:380: int main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;smram.c:382: curslt = (PPIA & 0x0C) >> 2;
	in	a, (_PPIA)
	and	a, #0x0c
	ld	c, a
	ld	b, #0x00
	sra	b
	rr	c
	sra	b
	rr	c
	ld	a, c
	ld	(#_curslt), a
;smram.c:383: cursslt = (~(*((uchar*)0xFFFF)) & 0x0C) | *((uchar*)EXPTBL+curslt);
	ld	a, (#0xffff)
	cpl
	and	a, #0x0c
	ld	c, a
	ld	a, (_curslt+0)
	add	a, #0xc1
	ld	e, a
	ld	a, #0x00
	adc	a, #0xfc
	ld	d, a
	ld	a, (de)
	or	a, c
	ld	(_cursslt+0), a
;smram.c:385: for(i = 1; i < 4; i++)
	ld	hl, #0x0001
	ld	(_i), hl
00230$:
;smram.c:387: slotid = *((uchar*)EXPTBL+i);
	ld	hl, (_i)
	ld	de, #0xfcc1
	add	hl, de
	ld	a, (hl)
	ld	(_slotid+0), a
;smram.c:389: if (slotid & 0x80) {    // expanded ?
	ld	a, (_slotid+0)
	rlca
	jr	NC, 00231$
;smram.c:391: enaslt(i | 0x80, 0x4000); // looking for BIOS, sslot 0
	ld	a, (_i+0)
	or	a, #0x80
	ld	de, #0x4000
	call	_enaslt
;smram.c:393: b = *(uchar*)(0x6000); // it might be RAM
	ld	a, (#0x6000)
	ld	(_b+0), a
;smram.c:394: *((uchar*)0x6000) = 7;
	ld	hl, #0x6000
	ld	(hl), #0x07
;smram.c:395: s = "WonderTANG! uSD Driver";
	ld	iy, #_s
	ld	0 (iy), #<(___str_0)
	ld	1 (iy), #>(___str_0)
;smram.c:396: t = (uchar*)0x4110;
	ld	hl, #0x4110
	ld	(_t), hl
;smram.c:397: for(int j=0; j<22; j++)
	ld	bc, #0x0000
00228$:
	ld	a, c
	sub	a, #0x16
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00105$
;smram.c:399: if (*s++ != *t++) break;
	ld	hl, (_s)
	ld	e, (hl)
	ld	hl, (_s)
	inc	hl
	ld	(_s), hl
	ld	hl, (_t)
	ld	d, (hl)
	ld	hl, (_t)
	inc	hl
	ld	(_t), hl
	ld	a, e
	sub	a, d
	jr	NZ, 00105$
;smram.c:401: if (j == 21) 
	ld	a, c
	sub	a, #0x15
	or	a, b
	jr	NZ, 00229$
;smram.c:403: found = TRUE;
	ld	hl, #_found
	ld	(hl), #0x01
;smram.c:404: break;
	jr	00105$
00229$:
;smram.c:397: for(int j=0; j<22; j++)
	inc	bc
	jr	00228$
00105$:
;smram.c:408: *((uchar*)0x6000) = b; // return whatever was there
	ld	hl, #0x6000
	ld	a, (_b+0)
	ld	(hl), a
;smram.c:410: enaslt(curslt | cursslt, 0x4000);
	ld	a, (_curslt+0)
	ld	hl, #_cursslt
	or	a, (hl)
	ld	de, #0x4000
	call	_enaslt
;smram.c:412: if (found) break;
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00110$
00231$:
;smram.c:385: for(i = 1; i < 4; i++)
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
	jp	C, 00230$
00110$:
;smram.c:416: sslt = 0;
	ld	hl, #_sslt
	ld	(hl), #0x00
;smram.c:418: if (found)
	ld	a, (_found+0)
	or	a, a
	jp	Z, 00177$
;smram.c:420: printf("WonderTANG! Super MegaRAM SCC+\n\r");
	ld	hl, #___str_1
	push	hl
	call	_printf
;smram.c:421: printf("v2.01\n\r");
	ld	hl, #___str_2
	ex	(sp),hl
	call	_printf
	pop	af
;smram.c:423: sslt = 0x80 | (2 << 2) | i;
	ld	a, (_i+0)
	or	a, #0x88
	ld	(_sslt+0), a
;smram.c:424: paramlen = *((char*)0x80);
	ld	hl, #0x0080
	ld	a, (hl)
	ld	(_paramlen+0), a
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, #0x0081
	ld	(_params), hl
00234$:
	ld	bc, (_params)
	ld	a, (bc)
	ld	e, a
	or	a, a
	jr	NZ, 00233$
	ld	a, (_paramlen+0)
	or	a, a
	jp	NZ, 00178$
00233$:
;smram.c:427: if (*params != ' ')
	ld	a, e
	sub	a, #0x20
	jp	Z,00235$
;smram.c:429: if (*params == '/')
	ld	a, e
	sub	a, #0x2f
	jp	NZ,00171$
;smram.c:431: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:432: if (to_upper(*params) == 'R') {
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x52
	jr	NZ, 00164$
;smram.c:433: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:434: if (*params == '6')
	cp	a, #0x36
	jr	NZ, 00121$
;smram.c:435: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00235$
00121$:
;smram.c:437: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00118$
;smram.c:438: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00235$
00118$:
;smram.c:440: if (*params == '1')
	cp	a, #0x31
	jr	NZ, 00115$
;smram.c:441: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00235$
00115$:
;smram.c:443: if (*params == '3')
	sub	a, #0x33
	jr	NZ, 00112$
;smram.c:444: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00235$
00112$:
;smram.c:446: megaram_type = TYPE_UNK;                    
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00235$
00164$:
;smram.c:448: else if (to_upper(*params) == 'K')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x4b
	jr	NZ, 00161$
;smram.c:450: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:451: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00127$
;smram.c:452: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00235$
00127$:
;smram.c:454: if (*params == '4')
	sub	a, #0x34
	jr	NZ, 00124$
;smram.c:455: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00235$
00124$:
;smram.c:457: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00235$
00161$:
;smram.c:459: else if (to_upper(*params) == 'A')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x41
	jr	NZ, 00158$
;smram.c:461: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:462: if (*params == '8')
	cp	a, #0x38
	jr	NZ, 00136$
;smram.c:463: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00235$
00136$:
;smram.c:465: if (*params == '1')
	sub	a, #0x31
	jr	NZ, 00133$
;smram.c:467: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:468: if (*params == '6')
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x36
	jr	NZ, 00130$
;smram.c:469: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00235$
00130$:
;smram.c:471: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00235$
00133$:
;smram.c:474: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00235$
00158$:
;smram.c:476: else if (to_upper(*params) == 'Y')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x59
	jr	NZ, 00155$
;smram.c:478: presAB = TRUE;
	ld	hl, #_presAB
	ld	(hl), #0x01
	jp	00235$
00155$:
;smram.c:480: else if (to_upper(*params) == 'B')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x42
	jr	NZ, 00152$
;smram.c:482: soft_reset = TRUE;
	ld	hl, #_soft_reset
	ld	(hl), #0x01
	jr	00235$
00152$:
;smram.c:512: else if (to_upper(*params) == 'Z')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x5a
	jr	NZ, 00149$
;smram.c:514: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	c, (hl)
;smram.c:515: if (*params >= '0' && *params <= '3')
	ld	a, c
	sub	a, #0x30
	jr	C, 00235$
	ld	a, #0x33
	sub	a, c
	jr	C, 00235$
;smram.c:516: cpumode = *params - '0';
	ld	a, c
	ld	hl, #_cpumode
	add	a, #0xd0
	ld	(hl), a
	jr	00235$
00149$:
;smram.c:518: else if (to_upper(*params) == '?')
	ld	hl, (_params)
	ld	a, (hl)
	call	_to_upper
	sub	a, #0x3f
	jr	NZ, 00142$
;smram.c:520: help = TRUE;
	ld	hl, #_help
	ld	(hl), #0x01
	jr	00235$
;smram.c:525: while(*params++ != 0 && *params != ' ');
00142$:
	ld	hl, (_params)
	ld	c, (hl)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	a, c
	or	a, a
	jr	Z, 00235$
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x20
	jr	Z, 00235$
	jr	00142$
00171$:
;smram.c:530: filename = params;
	ld	(_filename), bc
;smram.c:531: while(*params != 0 && *params != ' ') {
00167$:
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	c, (hl)
;smram.c:531: while(*params != 0 && *params != ' ') {
	ld	a, c
	or	a, a
	jr	Z, 00178$
	ld	a, c
	sub	a, #0x20
	jr	Z, 00178$
;smram.c:532: *params = to_upper(*params);
	push	hl
	ld	a, c
	call	_to_upper
	pop	hl
	ld	(hl), a
;smram.c:533: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	jr	00167$
;smram.c:536: break;
00235$:
;smram.c:425: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	iy, #_paramlen
	dec	0 (iy)
	jp	00234$
00177$:
;smram.c:541: } else megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
00178$:
;smram.c:543: if (!found) 
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00183$
;smram.c:545: printf("ERROR: WonderTANG! not found...\n\r");
	ld	hl, #___str_3
	push	hl
	call	_printf
	pop	af
;smram.c:546: return 0;
	ld	de, #0x0000
	ret
00183$:
;smram.c:549: if (help == TRUE || megaram_type == TYPE_UNK)
	ld	a, (_help+0)
	dec	a
	jr	Z, 00179$
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	NZ, 00184$
00179$:
;smram.c:569: );
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
;smram.c:570: return 0;
	ld	de, #0x0000
	ret
00184$:
;smram.c:573: printf("\r\nMapper Type: ");
	ld	hl, #___str_5
	push	hl
	call	_printf
	pop	af
;smram.c:574: switch(megaram_type)
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00185$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00186$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00188$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00187$
	jr	00189$
;smram.c:576: case TYPE_K4:
00185$:
;smram.c:577: printf("Konami (/R6 or /K4)\n\r");
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
;smram.c:578: break;
	jr	00189$
;smram.c:579: case TYPE_K5:
00186$:
;smram.c:580: printf("Konami SCC (/R5 or /K5)\n\r");
	ld	hl, #___str_7
	push	hl
	call	_printf
	pop	af
;smram.c:581: break;
	jr	00189$
;smram.c:582: case TYPE_A16:
00187$:
;smram.c:583: printf("ASCII16 (/R1 or /A16)\n\r");
	ld	bc, #___str_8+0
	push	bc
	call	_printf
	pop	af
;smram.c:584: break;
	jr	00189$
;smram.c:585: case TYPE_A8:
00188$:
;smram.c:586: printf("ASCII8 (/R3 or /A8)\n\r");
	ld	bc, #___str_9+0
	push	bc
	call	_printf
	pop	af
;smram.c:588: }
00189$:
;smram.c:590: MEGA_PORT1 = 0xF0 | scc_vol;
	ld	a, (_scc_vol+0)
	or	a, #0xf0
	out	(_MEGA_PORT1), a
;smram.c:591: MEGA_PORT1 = 0xE0 | psg_vol;
	ld	a, (_psg_vol+0)
	or	a, #0xe0
	out	(_MEGA_PORT1), a
;smram.c:592: MEGA_PORT1 = 0xD0 | opll_vol;
	ld	a, (_opll_vol+0)
	or	a, #0xd0
	out	(_MEGA_PORT1), a
;smram.c:594: if (filename == 0) {        
	ld	a, (_filename+1)
	ld	hl, #_filename
	or	a, (hl)
	jr	NZ, 00193$
;smram.c:595: if (megaram_type != TYPE_UNK)
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	Z, 00191$
;smram.c:596: MEGA_PORT1 = megaram_type;    
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
00191$:
;smram.c:597: return 0;
	ld	de, #0x0000
	ret
00193$:
;smram.c:600: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	hl, (_filename)
	ld	(_t), hl
00238$:
;smram.c:399: if (*s++ != *t++) break;
	ld	hl, (_t)
;smram.c:600: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	a, (hl)
	cp	a, #0x20
	jr	Z, 00194$
	or	a, a
	jr	Z, 00194$
	ld	hl, (_t)
	inc	hl
	ld	(_t), hl
	jr	00238$
00194$:
;smram.c:601: *t = 0;
	ld	(hl), #0x00
;smram.c:602: handle = dos2_open(0, filename);
	ld	de, (_filename)
	xor	a, a
	call	_dos2_open
	ld	(_handle+0), a
;smram.c:604: MEGA_PORT1 = TYPE_K4; //(megaram_type == TYPE_K5) ? TYPE_K5 : TYPE_K4;
	ld	a, #0x04
	out	(_MEGA_PORT1), a
;smram.c:606: if (handle)
	ld	a, (_handle+0)
	or	a, a
	jp	Z, 00202$
;smram.c:608: printf("Loading ROM file: %s - ", filename);
	ld	bc, #___str_10
	ld	hl, (_filename)
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:610: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt+0)
	call	_enaslt
;smram.c:611: page = 0;
	ld	hl, #_page
	ld	(hl), #0x00
;smram.c:612: romsize = 0;
	xor	a, a
	ld	(_romsize+0), a
	ld	(_romsize+1), a
	ld	(_romsize+2), a
	ld	(_romsize+3), a
;smram.c:613: printf("%04dKB", 0);
	ld	bc, #___str_11
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:615: do {
00198$:
;smram.c:617: MEGA_PORT0 = 0; // enable paging
	ld	a, #0x00
	out	(_MEGA_PORT0), a
;smram.c:618: *((uchar *)0x4000) = page++;
	ld	a, (_page+0)
	ld	c, a
	ld	hl, #_page
	inc	(hl)
	ld	hl, #0x4000
	ld	(hl), c
;smram.c:619: b = MEGA_PORT0; (b); // enable ram
	in	a, (_MEGA_PORT0)
	ld	(_b+0), a
;smram.c:620: bytes_read = dos2_read(handle, (void*)0x8000, 0x2000);
	ld	h, #0x20
	push	hl
	ld	de, #0x8000
	ld	a, (_handle+0)
	call	_dos2_read
	ex	de, hl
	ld	(_bytes_read), hl
;smram.c:621: if (presAB == FALSE && romsize == 0) 
	ld	a, (_presAB+0)
	or	a, a
	jr	NZ, 00196$
	ld	a, (_romsize+3)
	ld	iy, #_romsize
	or	a, 2 (iy)
	or	a, 1 (iy)
	or	a, 0 (iy)
	jr	NZ, 00196$
;smram.c:622: *((uchar*)(0x8000)) = 0;
	ld	hl, #0x8000
	ld	(hl), #0x00
00196$:
;smram.c:623: romsize += bytes_read;
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
;smram.c:624: memcpy((void*)0x4000, (void*)0x8000, bytes_read);
	ld	de, #0x4000
	ld	hl, #0x8000
	ld	bc, (_bytes_read)
	ld	a, b
	or	a, c
	jr	Z, 00762$
	ldir
00762$:
;smram.c:625: MEGA_PORT0 = 0; // enable paging
	ld	a, #0x00
	out	(_MEGA_PORT0), a
;smram.c:626: printf("\b\b\b\b\b\b%04dKB", (uint)(romsize >> 10));
	ld	hl, (_romsize + 1)
	ld	a, (#_romsize + 3)
	ld	e, a
	ld	b, #0x02
00763$:
	srl	e
	rr	h
	rr	l
	djnz	00763$
	ld	bc, #___str_12
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:628: } while (bytes_read > 0);
	ld	a, (_bytes_read+1)
	ld	hl, #_bytes_read
	or	a, (hl)
	jp	NZ, 00198$
;smram.c:630: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:632: dos2_close(handle);
	ld	a, (_handle+0)
	call	_dos2_close
	jr	00203$
00202$:
;smram.c:636: printf("ERROR: Failed loading %s\n\r", filename);
	ld	hl, (_filename)
	push	hl
	ld	hl, #___str_13
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:637: return 0;
	ld	de, #0x0000
	ret
00203$:
;smram.c:639: *t = ' '; // restore space
	ld	hl, (_t)
	ld	(hl), #0x20
;smram.c:640: MEGA_PORT1 = megaram_type;
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
;smram.c:642: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt+0)
	call	_enaslt
;smram.c:643: romstart = *((uint*)0x4002);
	ld	hl, #0x4002
	ld	a, (hl)
	inc	hl
	ld	(_romstart+0), a
	ld	a, (hl)
	ld	(_romstart+1), a
;smram.c:644: if (romstart > (uint)0x7fff)
	ld	a, #0xff
	ld	iy, #_romstart
	cp	a, 0 (iy)
	ld	a, #0x7f
	sbc	a, 1 (iy)
	jr	NC, 00205$
;smram.c:646: enaslt(sslt, 0x8000);
	ld	de, #0x8000
	ld	a, (_sslt+0)
	call	_enaslt
;smram.c:647: page2 = TRUE;
	ld	hl, #_page2
	ld	(hl), #0x01
00205$:
;smram.c:649: printf("\n\r\n\rStart address: 0x%04x (page %d)\n\r", romstart, page2 == TRUE ? 2 : 1);
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00242$
	ld	bc, #0x0002
	jr	00243$
00242$:
	ld	bc, #0x0001
00243$:
	push	bc
	ld	hl, (_romstart)
	push	hl
	ld	hl, #___str_14
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
;smram.c:651: switch(megaram_type)
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00207$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00207$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00213$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00210$
	jr	00217$
;smram.c:654: case TYPE_K5:
00207$:
;smram.c:655: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:656: *((uchar *)0x6000) = 1;
	ld	h, #0x60
	ld	(hl), #0x01
;smram.c:657: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00217$
;smram.c:659: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:660: *((uchar *)0xA000) = 1;
	ld	h, #0xa0
	ld	(hl), #0x01
;smram.c:662: break;
	jr	00217$
;smram.c:663: case TYPE_A16:
00210$:
;smram.c:664: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:665: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00217$
;smram.c:666: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:667: break;
	jr	00217$
;smram.c:668: case TYPE_A8:
00213$:
;smram.c:669: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:670: *((uchar *)0x6800) = 1;
	ld	h, #0x68
	ld	(hl), #0x01
;smram.c:671: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00217$
;smram.c:673: *((uchar *)0x7000) = 0;
	ld	h, #0x70
	ld	(hl), #0x00
;smram.c:674: *((uchar *)0x7800) = 1;
	ld	h, #0x78
	ld	(hl), #0x01
;smram.c:679: }
00217$:
;smram.c:681: printf("\n\rPress any key to proceed [ESC to abort]...\n\r");
	ld	hl, #___str_15
	push	hl
	call	_printf
	pop	af
;smram.c:682: c = getchar();
	call	_getchar
	ld	hl, #_c
	ld	(hl), e
;smram.c:683: if (c != 0x01b)
	ld	a, (_c+0)
	sub	a, #0x1b
	jr	Z, 00226$
;smram.c:685: if (soft_reset == TRUE)
	ld	a, (_soft_reset+0)
	dec	a
	jr	NZ, 00219$
;smram.c:687: uchar slotid = *((uchar*)(EXPTBL));
;smram.c:688: calslt(slotid, 0x0000); // soft boot
	ld	a, (#0xfcc1)
	ld	de, #0x0000
	call	_calslt
00219$:
;smram.c:691: if (page2 == TRUE)
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00221$
;smram.c:692: memcpy((void*)0xC000, &runROM_page2, ((uint)&runROM_page2_end - (uint)&runROM_page2));
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
	jr	Z, 00222$
	ldir
	jr	00222$
00221$:
;smram.c:694: memcpy((void*)0xC000, &runROM_page1, ((uint)&runROM_page1_end - (uint)&runROM_page1));
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
	jr	Z, 00777$
	ldir
00777$:
00222$:
;smram.c:696: if (cpumode != 0)
	ld	a, (_cpumode+0)
	or	a, a
	jr	Z, 00224$
;smram.c:697: chgcpu(cpumode == 1 ? Z80_ROM : cpumode == 2 ? R800_ROM : R800_DRAM);
	ld	a, (_cpumode+0)
	dec	a
	jr	NZ, 00244$
	ld	c, a
	jr	00245$
00244$:
	ld	a, (_cpumode+0)
	sub	a, #0x02
	ld	c, #0x81
	jr	Z, 00247$
	ld	c, #0x82
00247$:
00245$:
	ld	a, c
	call	_chgcpu
00224$:
;smram.c:699: jump(0xC000);
	ld	hl, #0xc000
	call	_jump
00226$:
;smram.c:702: enaslt(*((uchar*)RAMAD1), 0x4000);
	ld	a, (#0xf342)
	ld	de, #0x4000
	call	_enaslt
;smram.c:703: enaslt(*((uchar*)RAMAD2), 0x8000);
	ld	a, (#0xf343)
	ld	de, #0x8000
	call	_enaslt
;smram.c:705: jump(0x0000);
	ld	hl, #0x0000
	call	_jump
;smram.c:707: return 1; // make sdcc happy
	ld	de, #0x0001
;smram.c:708: }
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
	.ascii "   1: ASCII16    (/A16)"
	.db 0x0a
	.db 0x0d
	.ascii "   3: ASCII8     (/A8)"
	.db 0x0a
	.db 0x0d
	.ascii "   5: Konami SCC (/K5)"
	.db 0x0a
	.db 0x0d
	.ascii "   6: Konami     (/K4)"
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
	.ascii " /B:  Soft-reset after loading"
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
	.ascii "Konami (/R6 or /K4)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_7:
	.ascii "Konami SCC (/R5 or /K5)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_8:
	.ascii "ASCII16 (/R1 or /A16)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_9:
	.ascii "ASCII8 (/R3 or /A8)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_10:
	.ascii "Loading ROM file: %s - "
	.db 0x00
___str_11:
	.ascii "%04dKB"
	.db 0x00
___str_12:
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.ascii "%04dKB"
	.db 0x00
___str_13:
	.ascii "ERROR: Failed loading %s"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_14:
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii "Start address: 0x%04x (page %d)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_15:
	.db 0x0a
	.db 0x0d
	.ascii "Press any key to proceed [ESC to abort]..."
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
	.dw #0x0005
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
__xinit__soft_reset:
	.db #0x00	; 0
	.area _CABS (ABS)
