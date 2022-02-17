;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 1/20/2022
; Project 1: LED Heartbeat
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
			bis.b	#BIT6, &P6DIR ; set green LED2 as out
			bic.b	#BIT6, &P6OUT ; set init val to 0

			bis.b	#BIT0, &P1DIR ; set red LED1 as out
			bic.b	#BIT0, &P1OUT ; set init val to 0

			; setup timber TB0: delta-5 = 1sec
			bis.w	#TBCLR, &TB0CTL 		; clears timers and dividers
			bis.w	#TBSSEL__SMCLK, &TB0CTL	; choose clock (f = 1 MHz)
			bis.w	#MC__UP, &TB0CTL		; choose mode (UP)

			bis.w	#CNTL_0, &TB0CTL		; choose counter length (N = 2^16)
			bis.w	#ID__4, &TB0CTL			; choose divider for D1 (D1 = 4)
			bis.w 	#TBIDEX__8, &TB0EX0		; choose divider for D2 (D2 = 8)

			; TB0 interrupt: Compare
			mov.w	#32992d, &TB0CCR0		; N = 15625: TB0 @ 0.5sec, N = 32992d for 1Hz
			bis.w	#CCIE, &TB0CCTL0
			bic.w	#CCIFG, &TB0CCTL0

			nop
			eint							; assert global interrupt flag
			nop

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			call #flash_red
			jmp main
			nop

flash_red:
				xor.b	#BIT0, &P1OUT
				mov.w	global_outer_delay, R4
				call 	#delay
				ret

delay:
				mov.w	global_inner_delay, R5	; sets inner loop delay
dec_inner:		dec		R5						; decrements inner delay reg
				jnz		dec_inner				; loop if R5 is not 0
				dec		R4						; decrements outer delay reg
				jnz		delay					; loop if R4 is not 0
				ret


;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

; Service TB0
TimerB0_ISR:
			xor.b	#BIT6, &P6OUT
			bic.w	#TBIFG, &TB0CTL
			reti
;-------------- END service_TB0 --------------

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

					.data
					.retain

global_outer_delay:		.short	00BD3h
global_inner_delay:		.short  00072h

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
            .short	TimerB0_ISR

