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
;smram.c:40: void bdos() __naked
;	---------------------------------
; Function bdos
; ---------------------------------
_bdos::
;smram.c:49: __endasm;
	push	ix
	push	iy
	call	5
	pop	iy
	pop	ix
	ret
;smram.c:50: }
;smram.c:52: void bdos_c_write(uchar c) __naked
;	---------------------------------
; Function bdos_c_write
; ---------------------------------
_bdos_c_write::
;smram.c:62: __endasm;
	ld	e,a
	ld	c,#2
	call	_bdos
	ret
;smram.c:63: }
;smram.c:65: uchar bdos_c_rawio() __naked
;	---------------------------------
; Function bdos_c_rawio
; ---------------------------------
_bdos_c_rawio::
;smram.c:74: __endasm;
	ld	e,#0xFF;
	ld	c,#6
	call	_bdos
	ret
;smram.c:75: }
;smram.c:77: int putchar(int c) 
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	ex	de, hl
;smram.c:79: if (c >= 0)
	bit	7, d
	ret	NZ
;smram.c:80: bdos_c_write((char)c);
	ld	c, e
	push	de
	ld	a, c
	call	_bdos_c_write
	pop	de
;smram.c:81: return c;
;smram.c:82: }
	ret
;smram.c:84: int getchar()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;smram.c:87: do {
00101$:
;smram.c:88: c = bdos_c_rawio();
	call	_bdos_c_rawio
	ld	e, a
;smram.c:89: } while(c == 0);
	or	a, a
	jr	Z, 00101$
;smram.c:90: return (int)c;
	ld	d, #0x00
;smram.c:91: }
	ret
;smram.c:93: void fputs(const char *s)
;	---------------------------------
; Function fputs
; ---------------------------------
_fputs::
	ex	de, hl
;smram.c:95: while(*s != NULL)
00101$:
	ld	a, (de)
	or	a, a
	ret	Z
;smram.c:96: putchar(*s++);
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
;smram.c:97: }
	jr	00101$
;smram.c:99: char to_upper(char c)
;	---------------------------------
; Function to_upper
; ---------------------------------
_to_upper::
;smram.c:101: if (c >= 'a' && c <= 'z')
	ld	c, a
	sub	a, #0x61
	jr	C, 00102$
	ld	a, #0x7a
	sub	a, c
	jr	C, 00102$
;smram.c:102: c = c - ('a'-'A');
	ld	a, c
	add	a, #0xe0
	ld	c, a
00102$:
;smram.c:103: return c;
	ld	a, c
;smram.c:104: }
	ret
;smram.c:106: void enaslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function enaslt
; ---------------------------------
_enaslt::
;smram.c:128: __endasm;
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
;smram.c:129: }
;smram.c:131: uchar rdslt(uchar slotid, uint addr) __naked
;	---------------------------------
; Function rdslt
; ---------------------------------
_rdslt::
;smram.c:146: __endasm;
	push	bc
	push	de
	ex	de,hl
	call	#0x000C
	ex	de,hl
	pop	de
	pop	bc
	ret
;smram.c:147: }
;smram.c:149: void chgcpu(uchar mode) __naked
;	---------------------------------
; Function chgcpu
; ---------------------------------
_chgcpu::
;smram.c:179: __endasm;
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
;smram.c:180: }
;smram.c:197: FHANDLE dos2_open(uchar mode, const char* filepath) __naked
;	---------------------------------
; Function dos2_open
; ---------------------------------
_dos2_open::
;smram.c:215: __endasm;
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
;smram.c:216: }
;smram.c:218: void dos2_close(FHANDLE hnd) __naked
;	---------------------------------
; Function dos2_close
; ---------------------------------
_dos2_close::
;smram.c:228: __endasm;
	push	bc
	ld	a,b
	ld	c,#0x45
	call	5
	pop	bc
	ret
;smram.c:229: }
;smram.c:231: uint dos2_read(FHANDLE hnd, void *dst, uint size) __naked
;	---------------------------------
; Function dos2_read
; ---------------------------------
_dos2_read::
;smram.c:251: __endasm;	
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
;smram.c:252: }
;smram.c:254: uchar dos2_getenv(char *var, char *buf) __naked
;	---------------------------------
; Function dos2_getenv
; ---------------------------------
_dos2_getenv::
;smram.c:262: __endasm;	
	ld	b,#255
	ld	c,#0x6B
	call	5
	ret
;smram.c:263: }
;smram.c:265: char hexToNum(char h)
;	---------------------------------
; Function hexToNum
; ---------------------------------
_hexToNum::
;smram.c:269: if (h >= '0' && h <='9')
	ld	c, a
	sub	a, #0x30
	jr	C, 00102$
	ld	a, #0x39
	sub	a, c
	jr	C, 00102$
;smram.c:270: return h-'0';    
	ld	a, c
	add	a, #0xd0
	ret
00102$:
;smram.c:271: return 0;
	xor	a, a
;smram.c:272: }
	ret
;smram.c:274: void jump(uint addr) __naked
;	---------------------------------
; Function jump
; ---------------------------------
_jump::
;smram.c:282: __endasm;
	ld	sp,(0x0006)
	jp	(hl)
;smram.c:283: }
;smram.c:285: void runROM_page1() __naked
;	---------------------------------
; Function runROM_page1
; ---------------------------------
_runROM_page1::
;smram.c:301: __endasm;
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
;smram.c:302: }
;smram.c:303: void runROM_page1_end() __naked {}
;	---------------------------------
; Function runROM_page1_end
; ---------------------------------
_runROM_page1_end::
;smram.c:305: void runROM_page2() __naked
;	---------------------------------
; Function runROM_page2
; ---------------------------------
_runROM_page2::
;smram.c:321: __endasm;
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
;smram.c:322: }
;smram.c:323: void runROM_page2_end() __naked {}
;	---------------------------------
; Function runROM_page2_end
; ---------------------------------
_runROM_page2_end::
;smram.c:351: int main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	dec	sp
;smram.c:353: curslt = (PPIA & 0x0C) >> 2;
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
;smram.c:354: cursslt = (~(*((uchar*)0xFFFF)) & 0x0C) | *((uchar*)EXPTBL+curslt);
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
;smram.c:356: for(i = 1; i < 4; i++)
	ld	hl, #0x0001
	ld	(_i), hl
00233$:
;smram.c:358: slotid = *((uchar*)EXPTBL+i);
	ld	hl, (_i)
	ld	de, #0xfcc1
	add	hl, de
	ld	a, (hl)
	ld	(_slotid+0), a
;smram.c:360: if (slotid & 0x80) {    // expanded ?
	ld	a, (_slotid+0)
	rlca
	jr	NC, 00234$
;smram.c:362: enaslt(i | 0x80, 0x4000); // looking for BIOS, sslot 0
	ld	a, (_i+0)
	or	a, #0x80
	ld	de, #0x4000
	call	_enaslt
;smram.c:364: b = *(uchar*)(0x6000); // it might be RAM
	ld	a, (#0x6000)
	ld	(_b+0), a
;smram.c:365: *((uchar*)0x6000) = 7;
	ld	hl, #0x6000
	ld	(hl), #0x07
;smram.c:366: s = "WonderTANG! uSD Driver";
	ld	iy, #_s
	ld	0 (iy), #<(___str_0)
	ld	1 (iy), #>(___str_0)
;smram.c:367: t = (uchar*)0x4110;
	ld	hl, #0x4110
	ld	(_t), hl
;smram.c:368: for(int j=0; j<22; j++)
	ld	bc, #0x0000
00231$:
	ld	a, c
	sub	a, #0x16
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00105$
;smram.c:370: if (*s++ != *t++) break;
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
;smram.c:372: if (j == 21) 
	ld	a, c
	sub	a, #0x15
	or	a, b
	jr	NZ, 00232$
;smram.c:374: found = TRUE;
	ld	hl, #_found
	ld	(hl), #0x01
;smram.c:375: break;
	jr	00105$
00232$:
;smram.c:368: for(int j=0; j<22; j++)
	inc	bc
	jr	00231$
00105$:
;smram.c:379: *((uchar*)0x6000) = b; // return whatever was there
	ld	hl, #0x6000
	ld	a, (_b+0)
	ld	(hl), a
;smram.c:381: enaslt(curslt | cursslt, 0x4000);
	ld	a, (_curslt+0)
	ld	hl, #_cursslt
	or	a, (hl)
	ld	de, #0x4000
	call	_enaslt
;smram.c:383: if (found) break;
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00110$
00234$:
;smram.c:356: for(i = 1; i < 4; i++)
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
	jp	C, 00233$
00110$:
;smram.c:387: sslt = 0;
	ld	hl, #_sslt
	ld	(hl), #0x00
;smram.c:389: if (found)
	ld	a, (_found+0)
	or	a, a
	jp	Z, 00182$
;smram.c:391: printf("WonderTANG! Super MegaRAM SCC+\n\r");
	ld	hl, #___str_1
	push	hl
	call	_printf
;smram.c:392: printf("v2.00\n\r");
	ld	hl, #___str_2
	ex	(sp),hl
	call	_printf
	pop	af
;smram.c:394: sslt = 0x80 | (2 << 2) | i;
	ld	a, (_i+0)
	or	a, #0x88
	ld	(_sslt+0), a
;smram.c:395: paramlen = *((char*)0x80);
	ld	hl, #0x0080
	ld	a, (hl)
	ld	(_paramlen+0), a
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, #0x0081
	ld	(_params), hl
	ld	bc, #___str_5+0
00237$:
	ld	de, (_params)
	ld	a, (de)
	ld	-1 (ix), a
	or	a, a
	jr	NZ, 00236$
	ld	a, (_paramlen+0)
	or	a, a
	jp	NZ, 00183$
00236$:
;smram.c:398: if (*params != ' ')
	ld	a, -1 (ix)
	sub	a, #0x20
	jp	Z,00238$
;smram.c:400: if (*params == '/')
	ld	a, -1 (ix)
	sub	a, #0x2f
	jp	NZ,00176$
;smram.c:402: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:403: if (to_upper(*params) == 'R') {
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x52
	jr	NZ, 00169$
;smram.c:404: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:405: if (*params == '6')
	cp	a, #0x36
	jr	NZ, 00121$
;smram.c:406: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00238$
00121$:
;smram.c:408: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00118$
;smram.c:409: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00238$
00118$:
;smram.c:411: if (*params == '1')
	cp	a, #0x31
	jr	NZ, 00115$
;smram.c:412: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00238$
00115$:
;smram.c:414: if (*params == '3')
	sub	a, #0x33
	jr	NZ, 00112$
;smram.c:415: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00238$
00112$:
;smram.c:417: megaram_type = TYPE_UNK;                    
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00238$
00169$:
;smram.c:419: else if (to_upper(*params) == 'K')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x4b
	jr	NZ, 00166$
;smram.c:421: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:422: if (*params == '5')
	cp	a, #0x35
	jr	NZ, 00127$
;smram.c:423: megaram_type = TYPE_K5;
	ld	hl, #0x0005
	ld	(_megaram_type), hl
	jp	00238$
00127$:
;smram.c:425: if (*params == '4')
	sub	a, #0x34
	jr	NZ, 00124$
;smram.c:426: megaram_type = TYPE_K4;
	ld	hl, #0x0004
	ld	(_megaram_type), hl
	jp	00238$
00124$:
;smram.c:428: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00238$
00166$:
;smram.c:430: else if (to_upper(*params) == 'A')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x41
	jr	NZ, 00163$
;smram.c:432: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	a, (hl)
;smram.c:433: if (*params == '8')
	cp	a, #0x38
	jr	NZ, 00136$
;smram.c:434: megaram_type = TYPE_A8;
	ld	hl, #0x0008
	ld	(_megaram_type), hl
	jp	00238$
00136$:
;smram.c:436: if (*params == '1')
	sub	a, #0x31
	jr	NZ, 00133$
;smram.c:438: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:439: if (*params == '6')
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x36
	jr	NZ, 00130$
;smram.c:440: megaram_type = TYPE_A16;
	ld	hl, #0x0016
	ld	(_megaram_type), hl
	jp	00238$
00130$:
;smram.c:442: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00238$
00133$:
;smram.c:445: megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
	jp	00238$
00163$:
;smram.c:447: else if (to_upper(*params) == 'Y')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x59
	jr	NZ, 00160$
;smram.c:449: presAB = TRUE;
	ld	hl, #_presAB
	ld	(hl), #0x01
	jp	00238$
00160$:
;smram.c:451: else if (to_upper(*params) == 'V')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x56
	jp	NZ,00157$
;smram.c:453: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:454: uchar param = to_upper(*params++);
	ld	hl, (_params)
	ld	e, (hl)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
;smram.c:455: switch(param)
	cp	a, #0x4f
	jr	Z, 00140$
	cp	a, #0x50
	jr	Z, 00139$
	sub	a, #0x53
	jr	NZ, 00141$
;smram.c:458: scc_vol = hexToNum(to_upper(*params));
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	call	_hexToNum
	pop	bc
	ld	(_scc_vol+0), a
;smram.c:459: printf("SCC+ volume %d\n\r", (int)scc_vol);
	ld	a, (_scc_vol+0)
	ld	d, #0x00
	push	bc
	ld	e, a
	push	de
	ld	hl, #___str_3
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;smram.c:460: break;
	jp	00238$
;smram.c:461: case 'P': 
00139$:
;smram.c:462: psg_vol = hexToNum(to_upper(*params));
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	call	_hexToNum
	pop	bc
	ld	(_psg_vol+0), a
;smram.c:463: printf("PSG volume %d\n\r", (int)psg_vol);
	ld	a, (_psg_vol+0)
	ld	d, #0x00
	push	bc
	ld	e, a
	push	de
	ld	hl, #___str_4
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	bc
;smram.c:464: break;
	jp	00238$
;smram.c:465: case 'O': 
00140$:
;smram.c:466: opll_vol = hexToNum(to_upper(*params));
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	call	_hexToNum
	pop	bc
	ld	(_opll_vol+0), a
;smram.c:467: printf("OPLL volume %d\n\r", (int)opll_vol);
	ld	a, (_opll_vol+0)
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	e, c
	ld	d, b
	push	bc
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	push	de
	call	_printf
	pop	af
	pop	af
	pop	bc
;smram.c:468: break;
	jp	00238$
;smram.c:469: default:
00141$:
;smram.c:471: printf("ERROR: wrong device volume...\n\r");
	ld	hl, #___str_6
	push	hl
	call	_printf
	pop	af
;smram.c:472: return 0;
	ld	de, #0x0000
	jp	00243$
;smram.c:475: }
00157$:
;smram.c:477: else if (to_upper(*params) == 'Z')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x5a
	jr	NZ, 00154$
;smram.c:479: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	e, (hl)
;smram.c:480: if (*params >= '0' && *params <= '3')
	ld	a, e
	sub	a, #0x30
	jr	C, 00238$
	ld	a, #0x33
	sub	a, e
	jr	C, 00238$
;smram.c:481: cpumode = *params - '0';
	ld	a, e
	ld	hl, #_cpumode
	add	a, #0xd0
	ld	(hl), a
	jr	00238$
00154$:
;smram.c:483: else if (to_upper(*params) == '?')
	ld	hl, (_params)
	ld	e, (hl)
	push	bc
	ld	a, e
	call	_to_upper
	pop	bc
	sub	a, #0x3f
	jr	NZ, 00147$
;smram.c:485: help = TRUE;
	ld	hl, #_help
	ld	(hl), #0x01
	jr	00238$
;smram.c:490: while(*params++ != 0 && *params != ' ');
00147$:
	ld	hl, (_params)
	ld	e, (hl)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	a, e
	or	a, a
	jr	Z, 00238$
	ld	hl, (_params)
	ld	a, (hl)
	sub	a, #0x20
	jr	Z, 00238$
	jr	00147$
00176$:
;smram.c:495: filename = params;
	ld	(_filename), de
;smram.c:496: while(*params != 0 && *params != ' ') {
00172$:
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	ld	c, (hl)
;smram.c:496: while(*params != 0 && *params != ' ') {
	ld	a, c
	or	a, a
	jr	Z, 00183$
	ld	a, c
	sub	a, #0x20
	jr	Z, 00183$
;smram.c:497: *params = to_upper(*params);
	push	hl
	ld	a, c
	call	_to_upper
	pop	hl
	ld	(hl), a
;smram.c:498: params++;
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	jr	00172$
;smram.c:501: break;
00238$:
;smram.c:396: for(params = (char*)0x81; *params != 0 || paramlen == 0; ++params, paramlen--)
	ld	hl, (_params)
	inc	hl
	ld	(_params), hl
	ld	iy, #_paramlen
	dec	0 (iy)
	jp	00237$
00182$:
;smram.c:506: } else megaram_type = TYPE_UNK;
	ld	hl, #0x00ff
	ld	(_megaram_type), hl
00183$:
;smram.c:508: if (!found) 
	ld	a, (_found+0)
	or	a, a
	jr	NZ, 00188$
;smram.c:510: printf("ERROR: WonderTANG! not found...\n\r");
	ld	hl, #___str_7
	push	hl
	call	_printf
	pop	af
;smram.c:511: return 0;
	ld	de, #0x0000
	jp	00243$
00188$:
;smram.c:514: if (help == TRUE || megaram_type == TYPE_UNK)
	ld	a, (_help+0)
	dec	a
	jr	Z, 00184$
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	NZ, 00189$
00184$:
;smram.c:533: );
	ld	hl, #___str_8
	push	hl
	call	_printf
	pop	af
;smram.c:534: return 0;
	ld	de, #0x0000
	jp	00243$
00189$:
;smram.c:537: printf("\r\nMapper Type: ");
	ld	hl, #___str_9
	push	hl
	call	_printf
	pop	af
;smram.c:538: switch(megaram_type)
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00190$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00191$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00193$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00192$
	jr	00194$
;smram.c:540: case TYPE_K4:
00190$:
;smram.c:541: printf("Konami (/R6 or /K4)\n\r");
	ld	hl, #___str_10
	push	hl
	call	_printf
	pop	af
;smram.c:542: break;
	jr	00194$
;smram.c:543: case TYPE_K5:
00191$:
;smram.c:544: printf("Konami SCC (/R5 or /K5)\n\r");
	ld	hl, #___str_11
	push	hl
	call	_printf
	pop	af
;smram.c:545: break;
	jr	00194$
;smram.c:546: case TYPE_A16:
00192$:
;smram.c:547: printf("ASCII16 (/R1 or /A16)\n\r");
	ld	bc, #___str_12+0
	push	bc
	call	_printf
	pop	af
;smram.c:548: break;
	jr	00194$
;smram.c:549: case TYPE_A8:
00193$:
;smram.c:550: printf("ASCII8 (/R3 or /A8)\n\r");
	ld	bc, #___str_13+0
	push	bc
	call	_printf
	pop	af
;smram.c:552: }
00194$:
;smram.c:554: MEGA_PORT1 = 0xF0 | scc_vol;
	ld	a, (_scc_vol+0)
	or	a, #0xf0
	out	(_MEGA_PORT1), a
;smram.c:555: MEGA_PORT1 = 0xE0 | psg_vol;
	ld	a, (_psg_vol+0)
	or	a, #0xe0
	out	(_MEGA_PORT1), a
;smram.c:556: MEGA_PORT1 = 0xD0 | opll_vol;
	ld	a, (_opll_vol+0)
	or	a, #0xd0
	out	(_MEGA_PORT1), a
;smram.c:558: if (filename == 0) {        
	ld	a, (_filename+1)
	ld	hl, #_filename
	or	a, (hl)
	jr	NZ, 00198$
;smram.c:559: if (megaram_type != TYPE_UNK)
	ld	a, (_megaram_type+0)
	inc	a
	ld	hl, #_megaram_type + 1
	or	a, (hl)
	jr	Z, 00196$
;smram.c:560: MEGA_PORT1 = megaram_type;    
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
00196$:
;smram.c:561: return 0;
	ld	de, #0x0000
	jp	00243$
00198$:
;smram.c:564: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	hl, (_filename)
	ld	(_t), hl
00241$:
;smram.c:370: if (*s++ != *t++) break;
	ld	hl, (_t)
;smram.c:564: for(t = filename; *t != ' ' && *t != 0; t++);
	ld	a, (hl)
	cp	a, #0x20
	jr	Z, 00199$
	or	a, a
	jr	Z, 00199$
	ld	hl, (_t)
	inc	hl
	ld	(_t), hl
	jr	00241$
00199$:
;smram.c:565: *t = 0;
	ld	(hl), #0x00
;smram.c:566: handle = dos2_open(0, filename);
	ld	de, (_filename)
	xor	a, a
	call	_dos2_open
	ld	(_handle+0), a
;smram.c:568: MEGA_PORT1 = TYPE_K4;
	ld	a, #0x04
	out	(_MEGA_PORT1), a
;smram.c:570: if (handle)
	ld	a, (_handle+0)
	or	a, a
	jp	Z, 00209$
;smram.c:572: printf("Loading ROM file: %s - ", filename);
	ld	bc, #___str_14
	ld	hl, (_filename)
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:574: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt+0)
	call	_enaslt
;smram.c:575: page = 0;
	ld	hl, #_page
	ld	(hl), #0x00
;smram.c:576: romsize = 0;
	xor	a, a
	ld	(_romsize+0), a
	ld	(_romsize+1), a
	ld	(_romsize+2), a
	ld	(_romsize+3), a
;smram.c:577: printf("%04dKB", 0);
	ld	bc, #___str_15
	ld	hl, #0x0000
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:579: do {
00205$:
;smram.c:581: MEGA_PORT0 = 0; // enable paging
	ld	a, #0x00
	out	(_MEGA_PORT0), a
;smram.c:582: *((uchar *)0x4000) = page++;
	ld	a, (_page+0)
	ld	c, a
	ld	hl, #_page
	inc	(hl)
	ld	hl, #0x4000
	ld	(hl), c
;smram.c:583: b = MEGA_PORT0; (b); // enable ram
	in	a, (_MEGA_PORT0)
	ld	(_b+0), a
;smram.c:584: bytes_read = dos2_read(handle, (void*)0x8000, 0x2000);
	ld	h, #0x20
	push	hl
	ld	de, #0x8000
	ld	a, (_handle+0)
	call	_dos2_read
	ex	de, hl
	ld	(_bytes_read), hl
;smram.c:585: if (presAB == FALSE && romsize == 0) 
	ld	a, (_presAB+0)
	or	a, a
	jr	NZ, 00201$
	ld	a, (_romsize+3)
	ld	iy, #_romsize
	or	a, 2 (iy)
	or	a, 1 (iy)
	or	a, 0 (iy)
	jr	NZ, 00201$
;smram.c:586: *((uchar*)(0x8000)) = 0;
	ld	hl, #0x8000
	ld	(hl), #0x00
00201$:
;smram.c:587: romsize += bytes_read;
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
;smram.c:588: memcpy((void*)0x4000, (void*)0x8000, bytes_read);
	ld	de, #0x4000
	ld	hl, #0x8000
	ld	bc, (_bytes_read)
	ld	a, b
	or	a, c
	jr	Z, 00777$
	ldir
00777$:
;smram.c:589: if (page == 0)
	ld	a, (_page+0)
	or	a, a
	jr	NZ, 00204$
;smram.c:590: romstart = *((uint*)0x8002);
	ld	hl, #0x8002
	ld	a, (hl)
	inc	hl
	ld	(_romstart+0), a
	ld	a, (hl)
	ld	(_romstart+1), a
00204$:
;smram.c:591: MEGA_PORT0 = 0; // enable paging
	ld	a, #0x00
	out	(_MEGA_PORT0), a
;smram.c:592: printf("\b\b\b\b\b\b%04dKB", (uint)(romsize >> 10));
	ld	hl, (_romsize + 1)
	ld	a, (#_romsize + 3)
	ld	e, a
	ld	b, #0x02
00778$:
	srl	e
	rr	h
	rr	l
	djnz	00778$
	ld	bc, #___str_16
	push	hl
	push	bc
	call	_printf
	pop	af
	pop	af
;smram.c:594: } while (bytes_read > 0);
	ld	a, (_bytes_read+1)
	ld	hl, #_bytes_read
	or	a, (hl)
	jp	NZ, 00205$
;smram.c:596: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:598: dos2_close(handle);
	ld	a, (_handle+0)
	call	_dos2_close
	jr	00210$
00209$:
;smram.c:602: printf("ERROR: Failed loading %s\n\r", filename);
	ld	hl, (_filename)
	push	hl
	ld	hl, #___str_17
	push	hl
	call	_printf
	pop	af
	pop	af
;smram.c:603: return 0;
	ld	de, #0x0000
	jp	00243$
00210$:
;smram.c:605: *t = ' '; // restore space
	ld	hl, (_t)
	ld	(hl), #0x20
;smram.c:606: MEGA_PORT1 = megaram_type;
	ld	a, (_megaram_type+0)
	out	(_MEGA_PORT1), a
;smram.c:608: enaslt(sslt, 0x4000);
	ld	de, #0x4000
	ld	a, (_sslt+0)
	call	_enaslt
;smram.c:609: romstart = 0x4002;
	ld	hl, #0x4002
	ld	(_romstart), hl
;smram.c:615: printf("\n\r\n\rStart address: 0x%04x (page %d)\n\r", romstart, page2 == TRUE ? 2 : 1);
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00245$
	ld	bc, #0x0002
	jr	00246$
00245$:
	ld	bc, #0x0001
00246$:
	push	bc
	ld	hl, #0x4002
	push	hl
	ld	hl, #___str_18
	push	hl
	call	_printf
	pop	af
	pop	af
	pop	af
;smram.c:617: switch(megaram_type)
	ld	a, (_megaram_type+0)
	sub	a, #0x04
	ld	iy, #_megaram_type
	or	a, 1 (iy)
	jr	Z, 00214$
	ld	a, (_megaram_type+0)
	sub	a, #0x05
	or	a, 1 (iy)
	jr	Z, 00214$
	ld	a, (_megaram_type+0)
	sub	a, #0x08
	or	a, 1 (iy)
	jr	Z, 00220$
	ld	a, (_megaram_type+0)
	sub	a, #0x16
	or	a, 1 (iy)
	jr	Z, 00217$
	jr	00224$
;smram.c:620: case TYPE_K5:
00214$:
;smram.c:621: *((uchar *)0x4000) = 0;
	ld	hl, #0x4000
	ld	(hl), #0x00
;smram.c:622: *((uchar *)0x6000) = 1;
	ld	h, #0x60
	ld	(hl), #0x01
;smram.c:623: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00224$
;smram.c:625: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:626: *((uchar *)0xA000) = 1;
	ld	h, #0xa0
	ld	(hl), #0x01
;smram.c:628: break;
	jr	00224$
;smram.c:629: case TYPE_A16:
00217$:
;smram.c:630: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:631: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00224$
;smram.c:632: *((uchar *)0x8000) = 0;
	ld	h, #0x80
	ld	(hl), #0x00
;smram.c:633: break;
	jr	00224$
;smram.c:634: case TYPE_A8:
00220$:
;smram.c:635: *((uchar *)0x6000) = 0;
	ld	hl, #0x6000
	ld	(hl), #0x00
;smram.c:636: *((uchar *)0x6800) = 1;
	ld	h, #0x68
	ld	(hl), #0x01
;smram.c:637: if (page2)
	ld	a, (_page2+0)
	or	a, a
	jr	Z, 00224$
;smram.c:639: *((uchar *)0x7000) = 0;
	ld	h, #0x70
	ld	(hl), #0x00
;smram.c:640: *((uchar *)0x7800) = 1;
	ld	h, #0x78
	ld	(hl), #0x01
;smram.c:645: }
00224$:
;smram.c:647: if (page2 == TRUE)
	ld	a, (_page2+0)
	dec	a
	jr	NZ, 00226$
;smram.c:648: memcpy((void*)0xC000, &runROM_page2, ((uint)&runROM_page2_end - (uint)&runROM_page2));
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
	jr	Z, 00227$
	ldir
	jr	00227$
00226$:
;smram.c:650: memcpy((void*)0xC000, &runROM_page1, ((uint)&runROM_page1_end - (uint)&runROM_page1));
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
	jr	Z, 00789$
	ldir
00789$:
00227$:
;smram.c:652: if (cpumode != 0)
	ld	a, (_cpumode+0)
	or	a, a
	jr	Z, 00229$
;smram.c:653: chgcpu(cpumode == 1 ? Z80_ROM : cpumode == 2 ? R800_ROM : R800_DRAM);
	ld	a, (_cpumode+0)
	dec	a
	jr	NZ, 00247$
	ld	c, a
	jr	00248$
00247$:
	ld	a, (_cpumode+0)
	sub	a, #0x02
	ld	c, #0x81
	jr	Z, 00250$
	ld	c, #0x82
00250$:
00248$:
	ld	a, c
	call	_chgcpu
00229$:
;smram.c:656: printf("\n\rPress any key to proceed...\n\r");
	ld	hl, #___str_19
	push	hl
	call	_printf
	pop	af
;smram.c:657: c = getchar();
	call	_getchar
	ld	hl, #_c
	ld	(hl), e
;smram.c:659: jump(0xC000);
	ld	hl, #0xc000
	call	_jump
;smram.c:661: return 1; // make sdcc happy
	ld	de, #0x0001
00243$:
;smram.c:662: }
	inc	sp
	pop	ix
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
	.ascii "v2.00"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_3:
	.ascii "SCC+ volume %d"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_4:
	.ascii "PSG volume %d"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_5:
	.ascii "OPLL volume %d"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_6:
	.ascii "ERROR: wrong device volume..."
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_7:
	.ascii "ERROR: WonderTANG! not found..."
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_8:
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
	.ascii " /Vxy: Set volume for"
	.db 0x0a
	.db 0x0d
	.ascii "   S: SCC+"
	.db 0x0a
	.db 0x0d
	.ascii "   P: PSG"
	.db 0x0a
	.db 0x0d
	.ascii "   O: OPLL"
	.db 0x0a
	.db 0x0d
	.ascii "   y: 0-9"
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
___str_9:
	.db 0x0d
	.db 0x0a
	.ascii "Mapper Type: "
	.db 0x00
___str_10:
	.ascii "Konami (/R6 or /K4)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_11:
	.ascii "Konami SCC (/R5 or /K5)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_12:
	.ascii "ASCII16 (/R1 or /A16)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_13:
	.ascii "ASCII8 (/R3 or /A8)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_14:
	.ascii "Loading ROM file: %s - "
	.db 0x00
___str_15:
	.ascii "%04dKB"
	.db 0x00
___str_16:
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.db 0x08
	.ascii "%04dKB"
	.db 0x00
___str_17:
	.ascii "ERROR: Failed loading %s"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_18:
	.db 0x0a
	.db 0x0d
	.db 0x0a
	.db 0x0d
	.ascii "Start address: 0x%04x (page %d)"
	.db 0x0a
	.db 0x0d
	.db 0x00
___str_19:
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
	.area _CABS (ABS)
