;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/09/2021
; Inderect Autoincrement and Indexed Mode Addressing
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

ind_auto:
		mov.w	#Block1, R4		; put the value 2000h into R6 to be used as addr

		mov.w	@R4+, R5		; copy data at addr held in R4 into R5, then R4+2-->R4
		mov.w	@R4+, R6
		mov.w	@R4+, R7

		mov.b	@R4+, R8		; copy data at addr held in R4 into R8, then R4+1-->R4
		mov.b	@R4+, R9
		mov.b	@R4+, R10

ind:
		mov.w	#Block1, R4

		mov.w	0(R4), 8(R4)	; copy 1st word in Block1 into 1st word into Block2
		mov.w	2(R4), 10(R4)
		mov.w	4(R4), 12(R4)
		mov.w	6(R4), 14(R4)

		jmp		main
		nop

;-------------------------------------------------------------------------------
; Memory allocation
;-------------------------------------------------------------------------------

		.data				; goto data mem
		.retain				; keep the selection

Block1:	.short	01122h, 03344h, 05566h, 07788h, 099AAh
Block2:	.space	8

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
            
