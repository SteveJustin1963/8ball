;--------------------------------------------------------
; Z80 8-Ball Game - Standalone Assembly
; Target: Z80 SBC (No SDCC Runtime)
;--------------------------------------------------------

; Memory Map (Adjust for your specific hardware)
ROM_START   EQU 0x0000
RAM_START   EQU 0x8000
STACK_PTR   EQU 0xFFFF

; I/O Ports
PORT_ROW    EQU 0x01
PORT_COL    EQU 0x02
PORT_KBD    EQU 0x03

; Constants
SCALE       EQU 16
MAX_COORD   EQU 112 ; (7 * 16)

    ORG ROM_START

_start:
    ld sp, STACK_PTR        ; Initialize Stack Pointer
    call init_data          ; Copy variables to RAM

;--------------------------------------------------------
; Main Loop
;--------------------------------------------------------
main_loop:
    in a, (PORT_KBD)        ; Get Key
    ld c, a

    ; Input Handling (ASCII Check)
    cp '4'
    jr nz, check_6
    ld hl, (cue_x)
    dec hl
    ld (cue_x), hl
check_6:
    ld a, c
    cp '6'
    jr nz, check_8
    ld hl, (cue_x)
    inc hl
    ld (cue_x), hl
check_8:
    ld a, c
    cp '8'
    jr nz, check_2
    ld hl, (cue_y)
    dec hl
    ld (cue_y), hl
check_2:
    ld a, c
    cp '2'
    jr nz, check_5
    ld hl, (cue_y)
    inc hl
    ld (cue_y), hl
check_5:
    ld a, c
    cp '5'
    jr nz, physics
    ; Load Velocity from LUT
    ld a, (angle_idx)
    ld e, a
    ld d, 0
    ld hl, cos_lut_ram
    add hl, de
    ld a, (hl)
    ld (cue_dx), a
    ld hl, sin_lut_ram
    add hl, de
    ld a, (hl)
    ld (cue_dy), a

;--------------------------------------------------------
; Physics Logic
;--------------------------------------------------------
physics:
    ld a, (cue_dx)
    ld b, a
    ld a, (cue_dy)
    or b
    jr z, render            ; If dx and dy are 0, skip physics

    ; Update Position
    ld hl, (cue_x)
    ld a, (cue_dx)
    ld e, a
    rla
    sbc a, a
    ld d, a                 ; Sign extend dx to 16-bit
    add hl, de
    ld (cue_x), hl

    ld hl, (cue_y)
    ld a, (cue_dy)
    ld e, a
    rla
    sbc a, a
    ld d, a                 ; Sign extend dy to 16-bit
    add hl, de
    ld (cue_y), hl

    ; Simple Bounce (Check boundaries)
    ; [Logic omitted for brevity, similar to C logic]

    ; Friction (Linear decay)
    ld a, (cue_dx)
    cp 0
    jr z, fric_y
    jp p, dec_dx
    inc a                   ; Negative, so increase toward 0
    jr store_dx
dec_dx:
    dec a                   ; Positive, so decrease toward 0
store_dx:
    ld (cue_dx), a

fric_y:
    ; [Repeat for cue_dy]

;--------------------------------------------------------
; Render Logic
;--------------------------------------------------------
render:
    ; Calculate X bitmask
    ld hl, (cue_x)
    ld b, 4
div_x:
    srl h                   ; Shift right 4 times (divide by 16)
    rr l
    djnz div_x
    ld a, l
    call get_mask
    out (PORT_COL), a

    ; Calculate Y bitmask
    ld hl, (cue_y)
    ld b, 4
div_y:
    srl h
    rr l
    djnz div_y
    ld a, l
    call get_mask
    out (PORT_ROW), a

    ; Busy Wait Delay
    ld de, 500
delay:
    dec de
    ld a, d
    or e
    jr nz, delay

    jr main_loop

;--------------------------------------------------------
; Helper: Convert index (0-7) to bitmask (1, 2, 4... 128)
;--------------------------------------------------------
get_mask:
    and 0x07                ; Keep only 0-7
    ld b, a
    ld a, 1
    ret z
mask_loop:
    add a, a
    djnz mask_loop
    ret

;--------------------------------------------------------
; Data Initialization (Copy ROM to RAM)
;--------------------------------------------------------
init_data:
    ld hl, rom_data_start
    ld de, RAM_START
    ld bc, data_size
    ldir
    ret

;--------------------------------------------------------
; ROM Data (Templates)
;--------------------------------------------------------
rom_data_start:
cos_lut: .db 8, 6, 0, -6, -8, -6, 0, 6
sin_lut: .db 0, 6, 8, 6, 0, -6, -8, -6
initial_cue: .dw 32, 64, 0 ; x, y, dx/dy
initial_angle: .db 0
data_size EQU $ - rom_data_start

;--------------------------------------------------------
; RAM Variables
;--------------------------------------------------------
    ORG RAM_START
cos_lut_ram: .ds 8
sin_lut_ram: .ds 8
cue_x:       .ds 2
cue_y:       .ds 2
cue_dx:      .ds 1
cue_dy:      .ds 1
angle_idx:   .ds 1
