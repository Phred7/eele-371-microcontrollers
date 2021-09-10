;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/03/2021
; Absolute Mode Addressing
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
		mov.w	&2000h, R4	; copy from addr 2000h into R4
		mov.w	R4, &2004h	; copy from R4 to addr 2004h

		mov.w	&2002h, R5	; copy from addr 2002h into R5
		mov.w	R5, &2006h	; copy from R% into addr 2006h

		jmp		main
		nop

;-------------------------------------------------------------------------------
; Memory allocation
;-------------------------------------------------------------------------------

		.data				; goto data mem
		.retain				; keep the selection

Const1:	.short	01234h		; init 1st word to 1234h
Const2: .short	0CAFEh		; init 2nd word to CAFEh

Var1:	.space	2			; reserve 3rd word
Var2:	.space	2			; reserve 4th word

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
            
