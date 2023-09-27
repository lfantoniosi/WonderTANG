#include<stdio.h>
#include<string.h>
#include "types.h"


#define BDOS                5
#define BDOS_C_WRITE		2
#define BDOS_C_RAWIO		6

#define TYPE_K4  0x00
#define TYPE_K5  0x05
#define TYPE_A16 0x16
#define TYPE_A8  0x08
#define TYPE_UNK 0xFF

#define FHANDLE     uchar
#define DOS2_OPEN	0x43
#define DOS2_CLOSE	0x45
#define DOS2_READ	0x48


#define RDSLT               0x000C
#define CALSLT				0x001C
#define EXPTBL				0xFCC1
#define ENASLT              0x0024
#define HTIMI               0xFD9A
#define HKEYI               0xFD9F
#define CHGCPU	            0x0180

#define Z80_ROM   0x00
#define R800_ROM  0x81
#define R800_DRAM 0x82

void bdos() __naked
{
	__asm
	push	ix
	push	iy
	call	BDOS
	pop		iy
	pop		ix
	ret
	__endasm;
}

void bdos_c_write(uchar c) __naked
{
	c;
	__asm

	ld 		e,a
	ld		c,#BDOS_C_WRITE
	call	_bdos

	ret
	__endasm;
}

uchar bdos_c_rawio() __naked
{
	__asm

	ld		e,#0xFF;
	ld		c,#BDOS_C_RAWIO
	call	_bdos

	ret
	__endasm;
}

int putchar(int c) 
{
	if (c >= 0)
		bdos_c_write((char)c);
	return c;
}

int getchar()
{
	uchar c;
	do {
		c = bdos_c_rawio();
	} while(c == 0);
	return (int)c;
}

void fputs(const char *s)
{
	while(*s != NULL)
		putchar(*s++);
}

char to_upper(char c)
{
    if (c >= 'a' && c <= 'z')
        c = c - ('a'-'A');
    return c;
}

void enaslt(uchar slotid, uint addr) __naked
{
    slotid; addr;
    __asm
    push    af
    push    bc
    push    de
    push    hl
    push    ix
    push    iy

    ex      de,hl
    call    #ENASLT

    pop     iy
    pop     ix
    pop     hl
    pop     de
    pop     bc
    pop     af

    ret
    __endasm;
}

uchar rdslt(uchar slotid, uint addr) __naked
{
    slotid; addr;
    __asm
    push    bc
    push    de
 
    ex      de,hl
    call    #RDSLT
    ex      de,hl
 
    pop     de
    pop     bc

    ret
    __endasm;
}

void chgcpu(uchar mode) __naked
{
    mode;
    __asm
    push    bc
    push    de
    push    af

    ld      a,(EXPTBL)
    ld      hl,#CHGCPU
    call    #RDSLT

    cp      #0xC3
    jr      nz,__no_turbo
    ld      a,b

    pop     af

    ld      iy,(EXPTBL-1)
    ld      ix,#CHGCPU
    call    #CALSLT

    push    af

__no_turbo:

    pop     af
    pop     de
    pop     bc
    ret
    __endasm;
}

__sfr __at (0x8E) MEGA_PORT0;
__sfr __at (0x8F) MEGA_PORT1;
__sfr __at (0xA8) PPIA;

#define ENABLE_INT   \
         __asm       \
            ei       \
        __endasm

#define DISABLE_INT  \
         __asm       \
            di       \
        __endasm


FHANDLE dos2_open(uchar mode, const char* filepath) __naked
{
	 filepath; mode;
	__asm
		push	bc
		push	de
		push	hl
		ld 		c,#DOS2_OPEN
		call	BDOS
        or      a
        jr      z,__open_no_err    
        ld      b,#0
__open_no_err:
		ld		a,b
        pop     hl
		pop 	de
		pop     bc
		ret
	__endasm;
}

void dos2_close(FHANDLE hnd) __naked
{
	hnd;
	__asm
		push	bc
		ld   	a,b
		ld 		c,#DOS2_CLOSE
		call	BDOS
		pop     bc
		ret
	__endasm;
}

uint dos2_read(FHANDLE hnd, void *dst, uint size) __naked
{
	hnd; dst; size;
	__asm
		push	ix
		ld		ix,#0
		add		ix,sp
		push	bc

		ld 		b,a
		ld		l, 4 (ix)
		ld		h, 5 (ix)

		ld		c,#DOS2_READ
		call	BDOS

		pop		bc
		pop		ix
		ex 		de,hl
		ret
	__endasm;	
}

uchar dos2_getenv(char *var, char *buf) __naked
{
    var; buf;
	__asm
        ld      b,#255
		ld		c,#0x6B
		call	BDOS
		ret
	__endasm;	
}

void jump(uint addr) __naked
{
    addr;
    __asm

    ld      sp,(#__himem)
    jp      (hl)

    __endasm;
}

void copyandrun() __naked
{
	__asm
    ld      bc,#0x4000
    or      a
    sbc     hl,bc
    ld      b,h
    ld      c,l
    ld      hl,#0x4000
    ld      de,#0x0100
    ldir
    jp      0x0100
	__endasm;
}

void copyandrun_end() __naked {}

void runROM() __naked
{
	__asm
    di
    ld      sp,#0xCFFF
    ld      hl,#HTIMI
    ld      a,#0xC9
    ld      (hl),a
    ld      hl,#HKEYI
    ld      (hl),a

    ld      a,(EXPTBL)
    ld      hl,#0
    call    #ENASLT
    ld      hl,(0x4002)
    jp      (hl)
	__endasm;
}

void runROM_end() __naked {}

bool found = FALSE;
char* filename = NULL;
int megaram_type = TYPE_K4;
uchar curslt, cursslt, sslt, b;
const uchar *s;
uchar *t;
char* params;
FHANDLE handle;
uint bytes_read;
int i;
uint addr;
uchar page;
ulong romsize;
uchar slotid;
bool presAB = FALSE;
char path[256];
char cpumode = 1; // defaults to Z80_ROM

int main(void)
{
    curslt = (PPIA & 0x0C) >> 2;
    cursslt = (~(*((uchar*)0xFFFF)) & 0x0C) | *((uchar*)EXPTBL+curslt);

    for(i = 1; i < 4; i++)
    {
        slotid = *((uchar*)EXPTBL+i);

        if (slotid & 0x80) {    // expanded ?

            enaslt(i | 0x80, 0x4000); // looking for BIOS, sslot 0
            
            b = *(uchar*)(0x6000); // it might be RAM
            *((uchar*)0x6000) = 7;
            s = "WonderTANG! uSD Driver";
            t = (uchar*)0x4110;
            for(int j=0; j<22; j++)
            {
                if (*s++ != *t++) break;

                if (j == 21) 
                {
                    found = TRUE;
                    break;
                }
            }

            *((uchar*)0x6000) = b; // return whatever was there

            enaslt(curslt | cursslt, 0x4000);
            
            if (found) break;
        }
    }

    //if (!found)  { i = 1; found = TRUE; }
    
    sslt = 0;

    if (found)
    {
        printf("WonderTANG! Super MegaRAM SCC+\r\n");

        sslt = 0x80 | (2 << 2) | i;

        for(params = (char*)0x81; *params != 0; ++params)
        {
            if (*params != ' ')
            {
                if (*params == '/')
                {
                    params++;
                    if (to_upper(*params) == 'R') {
                        params++;
                        if (*params == '6')
                            megaram_type = TYPE_K4;
                        else
                        if (*params == '5')
                            megaram_type = TYPE_K5;
                        else
                        if (*params == '1')
                            megaram_type = TYPE_A16;
                        else
                        if (*params == '3')
                            megaram_type = TYPE_A8;
                        else 
                            megaram_type = TYPE_UNK;                    
                    } 
                    else if (to_upper(*params) == 'Y')
                    {
                        presAB = TRUE;
                    }
                    else if (to_upper(*params) == 'Z')
                    {
                        params++;
                        if (*params >= '0' && *params <= '3')
                            cpumode = *params - '0';
                    }
                    else
                    {
                        // ignore option
                        while(*params++ != 0 && *params != ' ');
                    }
                } 
                else {
                    // should be filename
                    filename = params;
                    while(*params != 0 && *params != ' ') {
                            *params = to_upper(*params);
                            params++;
                    }

                     break;
                }
            }
        }

    } else megaram_type = TYPE_UNK;

    if (megaram_type != TYPE_UNK)
    {
        if (filename == NULL)
        {
            printf("\r\nUSAGE: SMROM [/Rx /Zx] filename\r\n\r\n"
                   " /Rx: Set MegaROM type\r\n   1: ASCII16\r\n   3: ASCII8\r\n   5: Konami SCC\r\n   6: Konami\r\n\r\n"
                   " /Zx: Set cpu mode\r\n   0: current\r\n   1: Z80\r\n   2: R800 ROM\r\n   3: R800 DRAM\r\n\r\n"
            );
            return 0;
        }

        printf("\r\nMapper Type: ");
        switch(megaram_type)
        {
            case TYPE_K4:
                 printf("Konami (/R6)\r\n");
                 break;
            case TYPE_K5:
                 printf("Konami SCC (/R5)\r\n");
                 break;
            case TYPE_A16:
                 printf("ASCII16 (/R1)\r\n");
                 break;
            case TYPE_A8:
                 printf("ASCII8 (/R3)\r\n");
                 break;
        }

        for(t = filename; *t != ' ' && *t != 0; t++);
        *t = 0;
        handle = dos2_open(0, filename);

        if (handle)
        {
                printf("Loading ROM file: %s - ", filename);
                
                enaslt(sslt, 0x4000);
                page = 0;
                romsize = 0;
                printf("%04dKB", 0);

                do {

                    MEGA_PORT0 = 0; // enable paging
                    *((uchar *)0x4000) = page++;
                    b = MEGA_PORT0; (b); // enable ram
                    bytes_read = dos2_read(handle, (void*)0x8000, 0x2000);
                    if (presAB == FALSE && romsize == 0) 
                        *((uchar*)(0x8000)) = 0;
                    romsize += bytes_read;
                    memcpy((void*)0x4000, (void*)0x8000, bytes_read);
                    MEGA_PORT0 = 0; // enable paging
                    printf("\b\b\b\b\b\b%04dKB", (uint)(romsize >> 10));

                } while (bytes_read > 0);
                
                dos2_close(handle);
        } 
        else 
        {
            printf("ERROR: Failed loading %s\r\n", filename);
            return 0;
        }
        *t = ' '; // restore space
        MEGA_PORT1 = megaram_type;
        
        enaslt(sslt, 0x4000);
        //enaslt(sslt, 0x8000);

        switch(megaram_type)
        {
            case TYPE_K4:
            case TYPE_K5:
                *((uchar *)0x4000) = 0;
                *((uchar *)0x6000) = 1;
                //*((uchar *)0x8000) = 2;
                //*((uchar *)0xA000) = 3;
                break;
            case TYPE_A16:
                *((uchar *)0x6000) = 0;
                //*((uchar *)0x8000) = 1;
                break;
            case TYPE_A8:
                *((uchar *)0x6000) = 0;
                //*((uchar *)0x6800) = 1;
                //*((uchar *)0x7000) = 2;
                //*((uchar *)0x7800) = 3;
                break;
            default:
                break;
        }

        memcpy((void*)0xC000, &runROM, ((uint)&runROM_end - (uint)&runROM));
        
        if (cpumode != 0)
            chgcpu(cpumode == 1 ? Z80_ROM : cpumode == 2 ? R800_ROM : R800_DRAM);
        
        jump(0xC000);

    } 
    else
    {
        //if (found)
        //{
        //    printf("WARNING: MegaROM mapper not supported by Super MegaRAM SCC+\r\n");
        //}
        if (dos2_getenv("PROGRAM", path) == 0)
        {
            for(t = path; *t != '.' && *t != 0; t++);
            if (*t != 0)
            {
                *t++ = '2';
                *t++ = '.';
                *t++ = 'C';
                *t++ = 'O';
                *t++ = 'M';
                *t++ = 0;
            }          
            handle = dos2_open(0, path);
            if (handle)
            {  
                printf("Redirecting to SROM.COM...\r\n"); 

                addr = 0x4000;
                do {
                    bytes_read = dos2_read(handle, (void*)addr, 0x2000);
                    addr += bytes_read;
                } while(bytes_read > 0);
                dos2_close(handle);
                MEGA_PORT1 = TYPE_K4;
                memcpy((void*)addr, &copyandrun, ((uint)&copyandrun_end - (uint)&copyandrun));
                jump(addr);

            } else 
            {
                if (!found) printf("ERROR: Super MegaRAM SCC+ not found...\r\n");
            }
        }
    }

    return 1;
}

