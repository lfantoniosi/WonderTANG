    output	"softboot.bin"

	org 04000h

	db "AB"		; ID for auto-executable ROM
	dw INIT		; Main program execution address.
	dw 0		; STATEMENT
	dw 0		; DEVICE
	dw 0		; TEXT
	dw 0,0,0	; Reserved

    ds 32,0FFh
INIT:

	di
    in      a,(0A8h)
    and     00Ch
    srl     a
    srl     a
    ld      HL,0FCC1h
    add     a,l
    ld      l,a
    ld      a,(HL)
    and     080h
;    jp      z,NON_EXP
    ret     nz

;    ds      64-3-($ - 8000h),0	
NON_EXP:
    jp      00000h

    end
