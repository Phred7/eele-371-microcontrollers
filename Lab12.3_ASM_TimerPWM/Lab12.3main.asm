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
			bis.b	#BIT6, &P6DIR			; set P6.6 as output - LED2 (green)
			bic.b	#BIT6, &P6OUT			; set init val to 0
			bic.b	#BIT6, &P6REN			; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1 (red)
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			; TIMER for PWM
			bis.w	#TBCLR, &TB0CTL			; clear timers and dividers
			bis.w	#TBSSEL__ACLK, &TB0CTL	; choose clock (f = 32.768 kHz)
			bis.w	#MC__UP, &TB0CTL		; choose mode (UP)
			bis.w	#CNTL_0, &TB1CTL		; choose counter length (2^n, N = 2^16)

			mov.w	#32768, &TB0CCR0		; period (1 sec)
			mov.w	#3277, &TB0CCR1			; 10% duty cycle

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
			nop
                                            
;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
TimerB0_EndLow:
			bic.b	#BIT0, &P1OUT
			bis.b	#BIT6, &P6OUT
			bic.w	#CCIFG, &TB0CCTL1
			reti
;-------------- END TimerB0_EndLow --------------

TimerB0_EndHigh:
			bis.b	#BIT0, &P1OUT
			bic.b	#BIT6, &P6OUT
			bic.w	#CCIFG, &TB0CCTL0
			reti
;-------------- END TimerB0_EndHigh --------------

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
            .short	TimerB0_EndHigh

            .sect	".int42"
            .short	TimerB0_EndLow
