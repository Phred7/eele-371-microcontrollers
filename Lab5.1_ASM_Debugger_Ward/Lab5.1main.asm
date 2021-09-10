;-------------------------------------------------------------------------------
; Walker Ward
; EELE371
; 08/30/2021
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Breakpoints and Stepping
;-------------------------------------------------------------------------------
;init:
;		bic.w	#0001h, PM5CTL0				; Disable the GPIO power-on default
;		bis.b	#01h, P1DIR					; Set P1.0 as an output.
;		bic.b	#01h, P1OUT					; Clear P1.0 to turn the LED off

;main:
;		bis.b	#01h, P1OUT					; Set P1.0 to turn LED on
;		bic.b	#01h, P1OUT					; Clear

;		jmp		main						; Repeat loop

;init:
;		mov.w	#0AAAAh, R4						; put AAAA (hex) into R4
;		mov.w	#0BBBBh, R8						; put BBBB (hex) into R8

;main:
;		mov.w	R4, R5							; copy R4 (src) into R5 (dst)
;		mov.w 	R5, R6							; copy R5 (src) into R6 (dst)
;		mov.w 	R6, R7							; copy R6 (src) into R7 (dst)
;
;		mov.w	R8, R9							; copy R8 (src) into R9 (dst)
;		mov.w	R9, R10							; copy R9 (src) into R10 (dst)
;		mov.w	R10, R11						; copy R10 (scr) into R11 (dst)
;
;		inv.w	R4								; invert all bits of R4
;		inv.w	R8								; invert all bits of R8
;
;		jmp		main							; repeat loop
;		nop										; no operation

;-- Demo Code
init:
		bic.w	#0001h, PM5CTL0				; Disable the GPIO power-on default
		bis.b	#01h, P1DIR					; Set P1.0 as an output.
		bic.b	#01h, P1OUT					; Clear P1.0 to turn the LED off

main:
		mov.w	&2002h, R4					; Bring the data at memory location 2002h into R4
		dec		R4							; Decrememnt R4

		mov.w	R4, R5						; copy R4 into all other GP CPU Registers
		mov.w 	R4, R6
		mov.w 	R4, R7
		mov.w	R4, R8
		mov.w	R4, R9

		mov.w	R4, &2002h					; Put value in R4 into memory location 2002h

		xor.b	#01h, P1OUT					; Toggle LED1

		jmp main							; Repeat Main Loop
		nop									; No Operation
                                            
;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

		.data									; allocate variables in data memory
		.retain									; keep these statements even if not used

Block1:	.short	00000h, 01111h, 02222h, 03333h, 04444h, 05555h, 06666h, 07777h, 08888h, 09999h, 0AAAAh, 0BBBBh, 0CCCCh, 0DDDDh, 0EEEEh, 0FFFFh	; Initializes sixteen 16-bit words at the beginning of data mem.

Block2: .space	32								; reserve 32 bytes (256 bits) as sixteen 16-bit words following the prior initialization in data mem.

Block3: .byte	023h, 001h, 067h, 045h, 0ABh, 089h, 0EFh, 0CDh	; Initializes eigth 8-bit bytes after the prior reservation
		.space	16								; Reserves 16 bytes of mem. after the prior reservation

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
