;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/19/2021
; Timers: PWM LED dimmer
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
; 	R4 – DelayOnce counter
; 	R6 – PWM time period (T)
; 	R7 – PWM duty cycle (delta-t)
;	R8 – minimum duty cycle allowed
; 	R9 – maximum duty cycle allowed
; 	R10 – duty cycle step size.
;-------------------------------------------------------------------------------
init:
			mov.w	#00h, R4
			mov.w	#1000d, R6
			mov.w	#100d, R7
			mov.w	#100d, R8		; 10%
			mov.w	#500d, R9		; 50%
			mov.w	#25d, R10		; 2.5%

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


			bic.b	#BIT1, &P4DIR			; set P4.1 as input - SW1
			bis.b	#BIT1, &P4REN			; EN pull up/down
			bis.b	#BIT1, &P4OUT			; pull-up res.
			bic.b	#11111111b, &P4IFG		; clear interrupt flags on P4
			bic.b   #BIT1, &P4IES			; set as rising edge (low->high)
			bis.b	#BIT1, &P4IE			; assert local interrupt enable

			bic.b	#BIT3, &P2DIR			; set P2.3 as input - SW2
			bis.b	#BIT3, &P2REN			; EN pull up/down
			bis.b	#BIT3, &P2OUT			; pull-up res.
			bic.b	#11111111b, &P2IFG		; clear interrupt flags on P2
			bic.b   #BIT3, &P2IES			; set as rising edge (low->high)
			bis.b	#BIT3, &P2IE			; assert local interrupt enable

			; TIMER for PWM
			bis.w	#TBCLR, &TB0CTL			; clear timers and dividers
			bis.w	#TBSSEL__SMCLK, &TB0CTL	; choose clock (f = 1 MHz)
			bis.w	#MC__UP, &TB0CTL		; choose mode (UP)
			bis.w	#CNTL_0, &TB1CTL		; choose counter length (2^n, N = 2^16)
			bis.w	#ID__1, &TB0CTL			; choose divider for D1 (D1 = 1)
			bis.w	#TBIDEX__1, &TB0EX0		; choose divider for D2 (D2 = 1)

			mov.w	R6, &TB0CCR0
			mov.w	R7, &TB0CCR1

			; TIMER interrupts
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
;-------------- END MAIN --------------

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------

delay:
			mov.w	#0FFFFh, R4
delay_dec:	dec		R4
			cmp		#00h, R4
			jnz		delay_dec
			ret
;-------------- END delay --------------


;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
TimerB0_EndLow:
			bic.b	#BIT0, &P1OUT
			bic.w	#CCIFG, &TB0CCTL1
			reti
;-------------- END TimerB0_EndLow --------------

TimerB0_EndHigh:
			mov.w	R7, &TB0CCR1
			bis.b	#BIT0, &P1OUT
			bic.w	#CCIFG, &TB0CCTL0
			reti
;-------------- END TimerB0_EndHigh --------------

; Service SW1
SW_1_inc_delta_t:
			cmp.w	R9, R7
			jl		SW_1_con				; if R7 is less than R9 then dont increase duty cycle
			bis.b	#BIT6, &P6OUT
			call	#delay
			bic.b	#BIT6, &P6OUT
			jmp		SW_1_end
SW_1_con:	add.w	R10, R7
SW_1_end:	bic.b	#BIT1, &P4IFG
     		reti
;-------------- END SW_1_inc_counter --------------

; Service SW2
SW_2_dec_delta_t:
			cmp.w	R8, R7
			jge		SW_2_con				; if R7 is g|e than R8 then dont decrease duty cycle
			bis.b	#BIT6, &P6OUT
			call	#delay
			bic.b	#BIT6, &P6OUT
			jmp		SW_2_end
SW_2_con:	sub.w	R10, R7
SW_2_end:	bic.b	#BIT3, &P2IFG
 			reti
;-------------- END SW_2_dec_counter --------------

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

            .sect 	".int22"
            .short	SW_1_inc_delta_t

            .sect 	".int24"
            .short	SW_2_dec_delta_t
