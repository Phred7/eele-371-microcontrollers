;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/07/2021
; Symbolic and Indeirect Register Mode Addressing
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

sym:
		mov.w	Const1, R4		; copy contents at addr label Const1 into r4
		mov.w	R4, Var1		; copy contents from R4 into addr label Var1

		mov.w	Const2, R5		; copy contents at addr label Const2 into R5
		mov.w	R5, Var2		; copy contents from R5 into addr label Var2

imd:
		mov.w	#2004h, R4		; put 2000h into R4 to be used as addr
		mov.w	@R4, R5			; copy the contents located at the addr held in R4 into R5

		mov.w	#Const3, R6		; put absilute address of label Const3 into R6
		mov.w	@R6, R7			; copy the contents located at the addr held in R6 into R7

		jmp		main
		nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

		.data					; go to data memory (2000h)
		.retain					; keep this section even if unused

Const1:	.short	01234h			; init 1st word to 1234h
Const2:	.short	0CAFEh			; init 2nd word to CAFEh
Const3:	.short	0DEADh			; init 3rd word to DEADh
Const4:	.short	0BEEFh			; init 4th word to BEEFh

Var1:	.space	2				; reserve 5rd word
Var2:	.space	2				; reserve 6th word
                                            

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
            
