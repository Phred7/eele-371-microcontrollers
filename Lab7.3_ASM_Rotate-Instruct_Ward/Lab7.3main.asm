;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/16/2021
; Rotate Instructions
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
			mov.w	#00000h, R4				; initialize R's
			mov.w	#0FFFFh, R5
			mov.w	#0F0F0h, R6
			mov.w	#0BEEFh, R7
			mov.w	#0DEEDh, R8
			mov.w	#00ECEh, R9
			mov.w	#00000h, R10
			mov.w	#01000h, R11

main:
			clrc							; clear's C

			rla.w	R11						; rotate left
			rla.w	R11
			rla.w	R11
			rla.w	R11

			rrc.w	R11						; rotate right where added bit is from carry

			rra.w	R11						; rotate right
			rra.w	R11
			rra.w	R11

			rla.w	R11

			rlc.w	R11						; rotate left where added bit is from carry
			rlc.w	R11
			rlc.w	R11
			rlc.w	R11

			rrc.w	R11						; rotate right where added bit is from carry
			rrc.w	R11
			rrc.w	R11
			rrc.w	R11
			rrc.w	R11

			mov.w	#08h, R12				; sum 8 + 50 + 78 + 40
			add.w	#032h, R12
			add.w	#04Eh, R12
			add.w	#028h, R12

			rra.w	R12						; divide by 2
			rra.w	R12

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
            
