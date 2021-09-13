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
;-------------------------------------------------------------------------------
main:

_addc:
			mov.w	#Var1, R4		; load regs with addrs of data to add and loc for sum
			mov.w	#Var2, R5
			mov.w	#Sum12, R6

			mov.w	0(R4), R7		; add lower 16 bit words using add. Lower 16 get put in mem before the upper 16
			mov.w	0(R5), R8
			add.w	R7, R8
			mov.w	R8, 0(R6)

			mov.w	2(R4), R7		; add upper 16 bit words using addc. Considers the Carry (C) flag. mov DOES NOT alter the SR (status register; contains flags)
			mov.w	2(R5), R8
			addc.w	R7, R8
			mov.w	R8, 2(R6)

_subc:
			mov.w	#Var1, R4		; load regs with addrs of data to add and loc for sum
			mov.w	#Var2, R5
			mov.w	#Diff12, R6

			mov.w	0(R4), R7		; sub lower 16 bits using sub.
			mov.w	0(R5), R8
			sub.w	R8, R7
			mov.w	R7, 0(R6)

			mov.w	2(R4), R7		; sub upper 16 bits using subc. Considers Carry flag. (C=0) causes borrow.
			mov.w	2(R5), R8
			subc.w	R8, R7
			mov.w	R7, 2(R6)

_inc:
			mov.w	#0, R4			; puts 0d in R4

			inc		R4				; inc R4 by 1 or 2
			inc		R4
			incd	R4
			incd	R4

			dec		R4				; dec R4 by 1 or 2
			dec		R4
			decd	R4
			decd	R4

			mov.w	#Consts, R5		; put the addr of Consts into R5 (use as ptr)

			mov.b	@R5, R6			; puts the data at addr in R5 into R6

			inc		R5				; inc addr in R5

			mov.b	@R5, R7			; puts the data at addr in R5 into R7

			inc		R5				; inc addr in R5

			mov.w	@R5, R8			; puts the data at addr in R5 into R8

			incd	R5				; inc addr in R5 by 2

			mov.w	@R5, R9			; puts the data at addr in R5 into R9

_logical:
			mov.b	#10101010b, R4	; inverts the bits in R4
			inv.b	R4

			mov.b	#11110000b, R5	; uses AND to clear bits 7:6
			and.b	#00111111b, R5

			mov.b	#00010000b, R6	; uses AND to test if bit 7 is 1
			and.b	#10000000b, R6

			mov.b	#00010000b, R7	; uses AND to test if bit 4 i
			and.b	#00010000b, R7

			mov.b	#11000001b, R8	; uses OR to set bits 5:0
			or.b	#00011111b, R8

			mov.b	#01010101b, R9	; uses XOR to toggle bits 7:4. Then uses XOR to toggle bits 3:0
			xor.b	#11110000b, R9
			xor.b	#00001111b, R9

			jmp		main
			nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data
			.retain

Var1:		.long	0E371FFFFh
Var2:		.long	011112222h

Sum12:		.space	4
Diff12: 	.space	4

Consts:		.short	01234h
			.short	05678h
			.short	09ABCh
                                            

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
            
