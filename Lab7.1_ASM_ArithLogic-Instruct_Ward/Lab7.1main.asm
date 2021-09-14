;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/12/2021
; ALU Instructions
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
; Main loop here
;
; Additions:
; #1: 1110h, C=1, V=0, N=0, Z=0
; #2: FFFEh, C=1, V=0, N=0, Z=0
; #3: AAAAh, C=0, V=0, N=0, Z=0
; #4: 0000h, C=1, V=0, N=0, Z=1
;
; Subtractions:
; #1: 6666h, C=1, V=0, N=0, Z=0
; #2: 999Ah, C=0, V=0, N=1, Z=0 		C is 0 because it did borrow
; #3: 0000h, C=1, V=0, N=0, Z=1
; #4: DDDEh, C=0, V=0, N=1, Z=1
;
; 32-bit:
; #1: 1111 1110h, C=1, V=0, N=0, Z=0
; #2: 8888 9777h, C=0, V=0, N=1, Z=0
;-------------------------------------------------------------------------------
main:
			mov.w	AddendA, R4			; add addends and move into sums
			mov.w	AddendB, R5
			mov.w	#SumAB, R6
			add.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	AddendC, R4
			mov.w	AddendD, R5
			mov.w	#SumCD, R6
			add.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	AddendE, R4
			mov.w	AddendF, R5
			mov.w	#SumEF, R6
			add.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	AddendG, R4
			mov.w	AddendH, R5
			mov.w	#SumGH, R6
			add.w	R4, R5
			mov.w	R5, 0(R6)





			mov.w	MinuendA, R5			; preform subs move into diffs
			mov.w	SubendB, R4
			mov.w	#DiffAB, R6
			sub.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	MinuendC, R5
			mov.w	SubendD, R4
			mov.w	#DiffCD, R6
			sub.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	MinuendE, R5
			mov.w	SubendF, R4
			mov.w	#DiffEF, R6
			sub.w	R4, R5
			mov.w	R5, 0(R6)

			mov.w	MinuendG, R5
			mov.w	SubendH, R4
			mov.w	#DiffGH, R6
			sub.w	R4, R5
			mov.w	R5, 0(R6)





			mov.w	#A32, R4		; 32-bit: load regs with addrs of data
			mov.w	#B32, R5
			mov.w	#SumAB32, R6
			mov.w	#DiffAB32, R7

			mov.w	0(R4), R8		; add lower 16 bit words using add. Lower 16 get put in mem before the upper 16
			mov.w	0(R5), R9
			add.w	R8, R9
			mov.w	R9, 0(R6)

			mov.w	2(R4), R8		; add upper 16 bit words using addc. Considers the Carry (C) flag. mov DOES NOT alter the SR (status register; contains flags)
			mov.w	2(R5), R9
			addc.w	R8, R9
			mov.w	R9, 2(R6)



			mov.w	0(R4), R9		; sub lower 16 bits using sub.
			mov.w	0(R5), R8
			sub.w	R8, R9
			mov.w	R9, 0(R7)

			mov.w	2(R4), R9		; sub upper 16 bits using subc. Considers Carry flag. (C=0) causes borrow.
			mov.w	2(R5), R8
			subc.w	R8, R9
			mov.w	R9, 2(R7)





			mov.w	#0, R3			; clear R3:R5
			mov.w	#0, R4
			mov.w	#0, R5

			mov.b	#0FFh, R4		; clear bits using a mask and AND op
			and.b	#11111110b, R4
			and.b	#01111111b, R4
			and.b	#11100111b, R4	; clear 3:4

			or.b	#00000001b, R4	; set bits using a mask and OR op
			or.b	#10000000b, R4
			or.b	#00011000b, R4	; set 3:4

			xor.b	#00001111b, R4	; toggle bits using a mask and XOR op
			xor.b	#00111100b, R4
			xor.b	#11110000b, R4





			jmp main
			nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data
			.retain

AddendA:	.short	05555h			; addends and sums
AddendB:	.short	0BBBBh
SumAB:		.space	2

AddendC:	.short	0FFFFh
AddendD:	.short	0FFFFh
SumCD:		.space	2

AddendE:	.short	05555h
AddendF:	.short	05555h
SumEF:		.space	2

AddendG:	.short	00002h
AddendH:	.short	00FFEh
SumGH:		.space	10


MinuendA:	.short	0BBBBh			; diffs and subtrahends and minuends
SubendB:	.short	05555h
DiffAB:		.space	2

MinuendC:	.short	05555h
SubendD:	.short	0BBBBh
DiffCD:		.space	2

MinuendE:	.short	05555h
SubendF:	.short	05555h
DiffEF:		.space	2

MinuendG:	.short	02222h
SubendH:	.short	04444h
DiffGH:		.space	10

A32:		.long	055555BBBh
B32:		.long	0BBBBB555h
SumAB32:	.space	4
DiffAB32:	.space	4
_32space:	.space	16

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
            
