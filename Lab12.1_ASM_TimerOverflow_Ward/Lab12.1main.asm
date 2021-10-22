;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/18/2021
; Timer Overflow
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
			bis.w	#TBSSEL__ACLK, &TB0CTL	; choose clock (f = 32.768 kHz)
			bis.w	#MC__CONTINUOUS, &TB0CTL; choose mode

			bis.w	#CNTL_1, &TB0CTL		; choose counter length (2^n, N = 2^12)
			bis.w	#ID__8, &TB0CTL			; choose divider for D1 (D1 = 8)
			bis.w	#TBIDEX__1, &TB0EX0		; choose divider for D2 (D2 = 1)

			; setup timer TB1: delta-t = 2sec
			bis.w	#TBCLR, &TB1CTL			; clear timers and dividers
			bis.w	#TBSSEL__ACLK, &TB1CTL	; choose clock (f = 32.768 kHz)
			bis.w	#MC__CONTINUOUS, &TB1CTL; choose mode

			bis.w	#CNTL_1, &TB1CTL		; choose counter length (2^n, N = 2^12)
			bis.w	#ID__2, &TB1CTL			; choose divider for D1 (D1 = 2)
			bis.w	#TBIDEX__8, &TB1EX0		; choose divider for D2 (D2 = 8)

			; TB0 interrupt
			bic.w	#TBIFG, &TB0CTL
			bis.w	#TBIE, &TB0CTL

			; TB1 interrupt
			bic.w	#TBIFG, &TB1CTL
			bis.w	#TBIE, &TB1CTL

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
; Memory Allocation
;-------------------------------------------------------------------------------

			.data									; allocate variables in data memory
			.retain									; keep these statements even if not used
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
            
            .sect	".int42"
            .short	TimerB0_1s

            .sect	".int40"
            .short	TimerB1_2s
