;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/19/2021
; I/O
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
			bis.b	#BIT0, &P1DIR			; set P1.0 as outpuit - led1
			bic.b	#BIT0, &P1OUT			; set init val of LED1 to 0

			bic.b	#BIT1, &P4DIR			; set P4.1 as in (SW1)
			bis.b	#BIT1, &P4REN			; EN pull up/down
			bis.b	#BIT1, &P4OUT			; pull-up res.

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:

poll_S1:
			bit.b	#BIT1, &P1IN			; test P4.1 if z=0 (no press) stay in loop
			jnz		poll_S1

toggle_LED1:
			xor.b	#BIT0, &P1OUT			; toggle P1.1 by xor'ing w/ a 1

			mov.w	#0FFFFh, R4				;delay

delay:
			dec.w	R4
			jnz		delay

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
            
