;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/19/2021
; Timers: PWM
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
			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1 (red)
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bis.w	#TBCLR, &TB0CTL
			bis.w	#TBSSEL__ACLK, &TB0CTL
			bis.w	#MC__UP, &TB0CTL

			mov.w	#32768, &TB0CCR0		; period
			mov.w	#16384, &TB0CCR1			; 5% duty cycle: 1638

			bis.w	#CCIE, &TB0CCTL0
			bic.w	#CCIFG, &TB0CCTL0

			bis.w	#CCIE, &TB0CCTL1
			bic.w	#CCIFG, &TB0CCTL1

			nop
			eint							; assert global interrupt flag
			nop

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			jmp 	main
                                            
;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
ISR_TB0_CCR0:
			bis.b	#BIT0, &P1OUT
			bic.w	#CCIFG, &TB0CCTL0
			reti

ISR_TB0_CCR1:
			bic.b	#BIT0, &P1OUT
			bic.w	#CCIFG, &TB0CCTL1
			reti

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
            
            .sect	".int43"
            .short	ISR_TB0_CCR0

            .sect	".int42"
            .short	ISR_TB0_CCR1
