;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/12/2021
; bic, bis, tst, cmp, bit
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

_bis_bic:
			mov.b	#00000000b, R4

			bis.b	#10000001b, R4
			bis.b	#01000010b, R4
			bis.b	#00100100b, R4
			bis.b	#00011000b, R4

			bic.b	#00011000b, R4
			bic.b	#00100100b, R4
			bic.b	#01000010b, R4
			bic.b	#10000001b, R4

_test:
			mov.b	#00010000b, R4
			bit.b	#10000000b, R4
			bit.b	#00010000b, R4

			mov.b	#99, R5
			cmp.b	#99, R5
			cmp.b	#77, R5

			mov.b	#-99, R6
			tst.b	R6

			jmp		main
                                            

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
            
