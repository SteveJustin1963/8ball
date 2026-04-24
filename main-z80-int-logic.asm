;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module main_z80_int_logic
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _update_display
	.globl _angle_idx
	.globl _cue
	.globl _sin_lut
	.globl _cos_lut
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_PORT_ROW	=	0x0001
_PORT_COL	=	0x0002
_PORT_KBD	=	0x0003
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_cos_lut::
	.ds 8
_sin_lut::
	.ds 8
_cue::
	.ds 6
_angle_idx::
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
;main-z80-int-logic.c:25: void update_display(uint8_t x, uint8_t y) {
;	---------------------------------
; Function update_display
; ---------------------------------
_update_display::
	ld	b, a
;main-z80-int-logic.c:27: PORT_ROW = (1 << y);
	ld	a, #0x01
	inc	l
	jr	00104$
00103$:
	add	a, a
00104$:
	dec	l
	jr	NZ,00103$
	out	(_PORT_ROW), a
;main-z80-int-logic.c:28: PORT_COL = (1 << x);
	ld	a, #0x01
	inc	b
	jr	00106$
00105$:
	add	a, a
00106$:
	djnz	00105$
	out	(_PORT_COL), a
;main-z80-int-logic.c:29: }
	ret
;main-z80-int-logic.c:31: void main(void) {
;	---------------------------------
; Function main
; ---------------------------------
_main::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl, #-5
	add	hl, sp
	ld	sp, hl
;main-z80-int-logic.c:35: while(1) {
00132$:
;main-z80-int-logic.c:37: key = PORT_KBD;
	in	a, (_PORT_KBD)
;main-z80-int-logic.c:40: if (key == '4') cue.x -= 1; 
	ld	c, a
	sub	a, #0x34
	jr	NZ, 00102$
	ld	de, (#_cue + 0)
	dec	de
	ld	(_cue), de
00102$:
;main-z80-int-logic.c:41: if (key == '6') cue.x += 1; 
	ld	a, c
	sub	a, #0x36
	jr	NZ, 00104$
	ld	de, (#_cue + 0)
	inc	de
	ld	(_cue), de
00104$:
;main-z80-int-logic.c:42: if (key == '8') cue.y -= 1; 
	ld	a, c
	sub	a, #0x38
	jr	NZ, 00106$
	ld	de, (#(_cue + 2) + 0)
	dec	de
	ld	((_cue + 2)), de
00106$:
;main-z80-int-logic.c:43: if (key == '2') cue.y += 1; 
	ld	a, c
	sub	a, #0x32
	jr	NZ, 00108$
	ld	de, (#(_cue + 2) + 0)
	inc	de
	ld	((_cue + 2)), de
00108$:
;main-z80-int-logic.c:45: if (key == '5') {
	ld	a, c
	sub	a, #0x35
	jr	NZ, 00110$
;main-z80-int-logic.c:46: cue.dx = cos_lut[angle_idx];
	ld	bc, #_cos_lut+0
	ld	hl, (_angle_idx)
	ld	h, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(#(_cue + 4)),a
;main-z80-int-logic.c:47: cue.dy = sin_lut[angle_idx];
	ld	bc, #_sin_lut+0
	ld	hl, (_angle_idx)
	ld	h, #0x00
	add	hl, bc
	ld	a, (hl)
	ld	(#(_cue + 5)),a
00110$:
;main-z80-int-logic.c:51: if (cue.dx != 0 || cue.dy != 0) {
	ld	hl, #(_cue + 4)
	ld	c, (hl)
	ld	de, #_cue + 5
;main-z80-int-logic.c:53: cue.y += (int16_t)cue.dy;
;main-z80-int-logic.c:51: if (cue.dx != 0 || cue.dy != 0) {
	ld	a, c
	or	a, a
	jr	NZ, 00127$
	ld	a, (de)
	or	a, a
	jp	Z, 00128$
00127$:
;main-z80-int-logic.c:52: cue.x += (int16_t)cue.dx;
	ld	hl, (#_cue + 0)
	ld	a, c
	rlca
	sbc	a, a
	ld	b, a
	add	hl, bc
	ex	(sp), hl
	ld	hl, #_cue
	ld	a, -5 (ix)
	ld	(hl), a
	inc	hl
	ld	a, -4 (ix)
	ld	(hl), a
;main-z80-int-logic.c:53: cue.y += (int16_t)cue.dy;
	ld	hl, (#(_cue + 2) + 0)
	ld	a, (de)
	ld	c, a
	rlca
	sbc	a, a
	ld	b, a
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	((_cue + 2)), bc
;main-z80-int-logic.c:56: if (cue.x <= 0 || cue.x >= MAX_COORD) cue.dx *= -1;
	ld	hl, (#_cue + 0)
	pop	bc
	push	bc
	xor	a, a
	cp	a, c
	sbc	a, b
	jp	PO, 00236$
	xor	a, #0x80
00236$:
	jp	P, 00111$
	ld	bc, #0x8070
	add	hl, hl
	ccf
	rr	h
	rr	l
	sbc	hl, bc
	jr	C, 00112$
00111$:
	ld	a, (#(_cue + 4) + 0)
	neg
	ld	(#(_cue + 4)),a
00112$:
;main-z80-int-logic.c:53: cue.y += (int16_t)cue.dy;
	ld	hl, (#(_cue + 2) + 0)
;main-z80-int-logic.c:57: if (cue.y <= 0 || cue.y >= MAX_COORD) cue.dy *= -1;
	ld	c, l
	ld	b, h
	xor	a, a
	cp	a, c
	sbc	a, b
	jp	PO, 00237$
	xor	a, #0x80
00237$:
	jp	P, 00114$
	ld	bc, #0x8070
	add	hl, hl
	ccf
	rr	h
	rr	l
	sbc	hl, bc
	jr	C, 00115$
00114$:
	ld	a, (de)
	neg
	ld	(de), a
00115$:
;main-z80-int-logic.c:51: if (cue.dx != 0 || cue.dy != 0) {
	ld	hl, #(_cue + 4)
	ld	c, (hl)
;main-z80-int-logic.c:60: if (cue.dx > 0) cue.dx--; else if (cue.dx < 0) cue.dx++;
	xor	a, a
	sub	a, c
	jp	PO, 00238$
	xor	a, #0x80
00238$:
	jp	P, 00120$
	dec	c
	ld	hl, #(_cue + 4)
	ld	(hl), c
	jr	00121$
00120$:
	bit	7, c
	jr	Z, 00121$
	inc	c
	ld	hl, #(_cue + 4)
	ld	(hl), c
00121$:
;main-z80-int-logic.c:53: cue.y += (int16_t)cue.dy;
	ld	a, (de)
	ld	c, a
;main-z80-int-logic.c:61: if (cue.dy > 0) cue.dy--; else if (cue.dy < 0) cue.dy++;
	xor	a, a
	sub	a, c
	jp	PO, 00239$
	xor	a, #0x80
00239$:
	jp	P, 00125$
	ld	a, c
	dec	a
	ld	(de), a
	jr	00128$
00125$:
	bit	7, c
	jr	Z, 00128$
	ld	a, c
	inc	a
	ld	(de), a
00128$:
;main-z80-int-logic.c:65: update_display((uint8_t)(cue.x / SCALE), (uint8_t)(cue.y / SCALE));
	ld	de, (#(_cue + 2) + 0)
	ld	c, e
	ld	h, d
;	spillPairReg hl
;	spillPairReg hl
	bit	7, d
	jr	Z, 00139$
	ld	hl, #0x000f
	add	hl, de
	ld	c, l
00139$:
	sra	h
	rr	c
	sra	h
	rr	c
	sra	h
	rr	c
	sra	h
	rr	c
	ld	-1 (ix), c
	ld	bc, (#_cue + 0)
	ld	e, c
	ld	d, b
	bit	7, b
	jr	Z, 00140$
	ld	hl, #0x000f
	add	hl, bc
	ex	de, hl
00140$:
	sra	d
	rr	e
	sra	d
	rr	e
	sra	d
	rr	e
	sra	d
	rr	e
	ld	l, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	a, e
	call	_update_display
;main-z80-int-logic.c:68: for(i = 0; i < 500; i++); 
	xor	a, a
	ld	-3 (ix), a
	ld	-2 (ix), a
00135$:
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a, c
	sub	a, #0xf4
	ld	a, b
	sbc	a, #0x01
	jp	NC, 00132$
	pop	hl
	pop	bc
	push	bc
	push	hl
	inc	bc
	ld	-3 (ix), c
	ld	-2 (ix), b
;main-z80-int-logic.c:70: }
	jr	00135$
	.area _CODE
	.area _INITIALIZER
__xinit__cos_lut:
	.db #0x08	;  8
	.db #0x06	;  6
	.db #0x00	;  0
	.db #0xfa	; -6
	.db #0xf8	; -8
	.db #0xfa	; -6
	.db #0x00	;  0
	.db #0x06	;  6
__xinit__sin_lut:
	.db #0x00	;  0
	.db #0x06	;  6
	.db #0x08	;  8
	.db #0x06	;  6
	.db #0x00	;  0
	.db #0xfa	; -6
	.db #0xf8	; -8
	.db #0xfa	; -6
__xinit__cue:
	.dw #0x0020
	.dw #0x0040
	.db #0x00	;  0
	.db #0x00	;  0
__xinit__angle_idx:
	.db #0x00	; 0
	.area _CABS (ABS)
