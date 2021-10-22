;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/18/2021
; Timer Compares
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

			; setup timer TB0: delta-t = 1sec
			bis.w	#TBCLR, &TB0CTL			; clear timers and dividers
			bis.w	#TBSSEL__SMCLK, &TB0CTL	; choose clock (f = 1 MHz)
			bis.w	#MC__UP, &TB0CTL		; choose mode (UP)

			bis.w	#CNTL_0, &TB0CTL		; choose counter length (2^n, N = 2^16)
			bis.w	#ID__4, &TB0CTL			; choose divider for D1 (D1 = 4)
			bis.w	#TBIDEX__8, &TB0EX0		; choose divider for D2 (D2 = 8)

			; setup timer TB1: delta-t = 2sec
			bis.w	#TBCLR, &TB1CTL			; clear timers and dividers
			bis.w	#TBSSEL__SMCLK, &TB1CTL	; choose clock (f = 1 MHz)
			bis.w	#MC__UP, &TB1CTL		; choose mode (UP)

			bis.w	#CNTL_0, &TB1CTL		; choose counter length (2^n, N = 2^16)
			bis.w	#ID__8, &TB1CTL			; choose divider for D1 (D1 = 8)
			bis.w	#TBIDEX__4, &TB1EX0		; choose divider for D2 (D2 = 8) D2 = 4: TB0 @ 1sec

			; TB0 interrupt: Compare
			mov.w	#15625d, &TB0CCR0 		; N = 31250: TB0 @ 1sec, N = 15625: TB0 @ 0.5sec
			bis.w	#CCIE, &TB0CCTL0
			bic.w	#CCIFG, &TB0CCTL0

			; TB1 interrupt: Compare
			mov.w	#31250d, &TB1CCR0 		; N = 31250: TB0 @ 2sec
			bis.w	#CCIE, &TB1CCTL0
			bic.w	#CCIFG, &TB1CCTL0

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

; Service TB0
TimerB0_1s:
			xor.b	#BIT6, &P6OUT
			bic.w	#TBIFG, &TB0CTL
			reti
;-------------- END service_TB0 --------------

; Service TB1
TimerB1_2s:
			xor.b	#BIT0, &P1OUT
			bic.w	#TBIFG, &TB1CTL
			reti
;-------------- END service_TB1 --------------
                                            

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
            
            .sect	".int43"				; TB0CCR0
            .short	TimerB0_1s

            .sect	".int41"				; TB1CCR0
            .short	TimerB1_2s
