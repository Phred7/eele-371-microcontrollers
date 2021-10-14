;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/10/2021
; Stack and Subroutines
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

stack:
			mov.w	#0AAAAh, R4
			mov.w	#0BBBBh, R5

			push 	R4
			push	R5

			mov.w	#0CCCCh, R4
			mov.w	#0DDDDh, R5

			push	R4
			push	R5

			pop		R6
			pop		R7

subroutine:
			mov.w	#0AAAAh, R4
			call	#complement_it

			mov.w	#0BBBBh, R4
			call 	#complement_it

			mov.w	#0CCCCh, R4
			call	#complement_it

			jmp		main
			nop

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------
complement_it:
			inv.w	R4
			ret

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
            
