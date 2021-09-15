;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/14/2021
; SetClearTest Instructions
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
init:
			mov.w	#00000h, R4
			mov.w	#0FFFFh, R5
			mov.w	#0F0F0h, R6
			mov.w	#0BEEFh, R7
			mov.w	#0DEEDh, R8
			mov.w	#00ECEh, R9
			mov.w	#00000h, R10
			mov.w	#01000h, R11

main:
			bis.w	#0000100000010000b, R4		; set 11, 4
			bis.w	#0000000000000011b, R4		; set 1, 0

			bic.w	#0000010000100000b, R5		; clear 10, 5
			bic.w	#0000000000000011b, R5		; clear 1, 0

			bit.w	#0000000000000001b, R6		; cleared
			bit.w	#1000000000000000b, R6		; set
			bit.w	#0000000000001111b, R6		; cleared
			bit.w	#1111000000000000b, R6		; set

			cmp.w	#0DEEDh, R7
			cmp.w	#0DEEDh, R8					; z=1
			cmp.w	#0DEEDh, R9

			tst.w	R7							; n=1 z=0
			tst.w	R8							; n=1 z=0
			tst.w	R9							; n=0 z=0
			tst.w	R10							; n=0 z=1

			jmp		main
			nop
                                            

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
            
