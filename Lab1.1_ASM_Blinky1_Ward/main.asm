;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
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
		bic.w   #0001h, PM5CTL0 ; Diable the GPIO power -on defult high-z mode
		bis.b   #01h, P1DIR		; Set P1.0 as an output. P1.0 is LED1
main:
        xor.b   #01h, P1OUT		; Toggle P1.0 (LED1)
        mov.w   #04FFFh, R4		; Put a big number into R4 ;#04FFFh ;#0FFFFh
delay:
		dec.w	R4				; Decrement R4
		jnz		delay			; Repeat until R4 is 0
main_2:
		xor.b   #01h, P1OUT		; Toggle P1.0 (LED1)
        mov.w   #0FFFFFh, R5		; Put a big number into R4
delay_2:
		dec.w	R5				; Decrement R4
		jnz		delay_2			; Repeat until R4 is 0

		jmp		main			; Repeat main loop forever
                                            

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
            
