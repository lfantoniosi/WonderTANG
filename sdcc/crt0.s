	.module 	crt0	
    .globl		_main
	.globl 		l__DATA
	.globl 		s__DATA
	.globl 		l__INITIALIZER
	.globl 		s__INITIALIZED
	.globl 		s__INITIALIZER

	.area		_HEADER (ABS)
	
	.org		0x0100
init:: 
    ;; Set stack pointer below BDOS
    ld      sp,(0x0006)

	call    gsinit

    ;; build argv / argc 
    ;; split command line and store each individual strings on stack
    
param_init:

    ld      hl,#0
    add     hl,sp

    ld      de,#0x0080
    ld      a,(de)  ; nr of characters
    
    ld      d,#0
    ld      e,a
    inc     e       ; include the null termination
    xor     a
    
    push    hl
    sbc     hl,de   ; reserve stack room for strings
    pop     de
    
    ld      sp,hl   ; set new stack under the param strings
    ld      b,h
    ld      c,l
    
    ex      de,hl
    dec     hl
    xor     a
    ld      (hl),a ; string termination    
    
    ld      de,#0x0080
    ld      a,(de)  ; nr of characters
    or      a
    jr      z,param_start
    
    push    hl
    ld      h,#0
    ld      l,a
    add     hl,de
    ex      de,hl
    pop     hl

    ; trim right spaces
    ld      a,(de)
    cp      #32
    jr      z,while_space
    
next_char:    
    ld      a,#0x80
    cp      e
    jr      nz,not_start
    ld      a,d
    or      a
    jr      nz,not_start

    jr      param_start
    
not_start:
    ld      a,(de)
    cp      #32
    jr      nz,not_space

    push    hl     ; store string addr
    xor     a      ; make string termination
not_space:
    dec     hl
    dec     de
    ld      (hl),a ; store string char

    or      a
    jr      nz,next_char

while_space:
    ld      a,#0x80
    cp      e
    jr      nz,next_space
    ld      a,d
    or      a
    jr      nz,next_space
    jr      param_start
next_space:
    ld      a,(de)
    cp      #32
    jr      nz,not_space
    dec     de
    jr      while_space

param_start:
    push    hl     ; store string addr

    or      a
    ld      h,b
    ld      l,c    ; restore orignal stack pointer
    sbc     hl,sp
	srl		h
	rr		l
    ex      de,hl
    
    ld      hl,#0
    add     hl,sp

    ex      de,hl
	; de      ; argv
	; hl      ; argc
    
    call    _main
    jp      _exit

	.area	_SLOT
	.area	_HOME
	.area	_CODE	
    
_exit::
    jp      0x0000

	.area	_INITIALIZER
	.area   _GSINIT
	.area   _GSFINAL

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _GSINIT
gsinit::
	; Default-initialized global variables.
	ld      bc, #l__DATA
	ld      a, b
	or      a, c
	jr      Z, zeroed_data
	ld      hl, #s__DATA
	ld      (hl), #0x00
	dec     bc
	ld      a, b
	or      a, c
	jr      Z, zeroed_data
	ld      e, l
	ld      d, h
	inc     de
	ldir
zeroed_data:
	; Explicitly initialized global variables.
	ld		bc, #l__INITIALIZER
	ld		a, b
	or		a, c
	jr		Z, gsinit_next
	ld		de, #s__INITIALIZED
	ld		hl, #s__INITIALIZER
	ldir

gsinit_next:

	.area   _GSFINAL
	ret

	.area	_HEAP	

