;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/08/2021
; Practical 5.1 Debug
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
; Initialization here
;-------------------------------------------------------------------------------
init:
		bic.w	#0001h, PM5CTL0		; setup LED1
		bis.b	#01h, P1DIR
		mov.w	#0, R4				; init R4 to 0

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
main:
		inc		R4					; incriment R4
		mov.w	R4, &2000h			; store to addr loc 2000h
		xor.b	#01h, P1OUT			; toggle LED1
		jmp main		; loop to main
		nop				; no operation


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
            
