;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/13/2021
; Interrupts
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
			mov.w	#00h, R4
			mov.w	#00h, R5
			mov.w	#00h, R6
			mov.w	#00h, R7

			bic.b	#BIT1, &P4DIR			; set P4.1 as input - SW1
			bis.b	#BIT1, &P4REN			; EN pull up/down
			bis.b	#BIT1, &P4OUT			; pull-up res.

			bic.b	#BIT3, &P2DIR			; set P2.3 as input - SW2
			bis.b	#BIT3, &P2REN			; EN pull up/down
			bis.b	#BIT3, &P2OUT			; pull-up res.

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

			bis.b	#00001111b, &P3DIR		; set P3.0:P3.3 as output. Ident.
			bic.b	#00001111b, &P3OUT		; set init vals to 0
			bic.b	#00001111b, &P3REN		; ensures REN disabled
			mov.b	#0000h, &P3SEL0			; ensures default selection
			mov.b	#0000h, &P3SEL1			; ensures default selection

			bic.b	#11111111b, &P4IFG		; clear interrupt flags on P4
			bic.b   #BIT1, &P4IES			; set as rising edge (low->high)
			bis.b	#BIT1, &P4IE			; assert local interrupt enable

			bic.b	#11111111b, &P2IFG		; clear interrupt flags on P2
			bic.b   #BIT3, &P2IES			; set as rising edge (low->high)
			bis.b	#BIT3, &P2IE			; assert local interrupt enable

			nop
			eint							; assert global interrupt flag
			nop

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default
			bic.b	#00001111b, &P3OUT

main:
			xor.b	#BIT6, &P6OUT			; toggle on LED2 (Green)
			call	#long_delay
			jmp 	main
			nop
;-------------- END MAIN --------------

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------

blink_red:
			bis.b	#BIT0, &P1OUT
			call	#delay
			bic.b	#BIT0, &P1OUT
			ret

long_delay:
			mov.w	#06h, R5
long_for:
			dec		R5
			call	#delay
			cmp		#00h, R5				; compare R5 to 0
			jnz		long_for				; if R5 is not 0 then continue iterating
			ret
;-------------- END delay --------------

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

; Service SW1
SW_1_inc_counter:
			mov.b	&P3OUT, R6
			cmp.b	#1111b, R6
			jl		SW_1_con				; if R6 is less than 1111b then do not blink red
			mov.w	R5, R12
			call	#blink_red
			mov.w	R12, R5
			jmp		SW_1_end
SW_1_con:	inc		R6
			mov.b	R6, &P3OUT
SW_1_end:	bic.b	#BIT1, &P4IFG
     		reti
;-------------- END SW_1_inc_counter --------------

; Service SW2
SW_2_dec_counter:
			mov.b	&P3OUT, R6
			cmp.b	#02h, R6
			jge		SW_2_con				; if R6 is less than 0010b then do not blink red
			mov.w	R5, R12
			call	#blink_red
			mov.w	R12, R5
			jmp		SW_2_end
SW_2_con:	decd	R6
			mov.b	R6, &P3OUT
SW_2_end:	bic.b	#BIT3, &P2IFG
			reti
;-------------- END SW_2_dec_counter --------------

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data									; allocate variables in data memory
			.retain									; keep these statements even if not used

DataBlock:	.short	00000h, 01111h, 02222h, 03333h, 04444h, 05555h, 06666h, 07777h, 08888h, 09999h, 0AAAAh, 0BBBBh, 0CCCCh, 0DDDDh, 0EEEEh, 0FFFFh	; Initializes sixteen 16-bit words at the beginning of data mem.
			.space	32

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
            
            .sect 	".int22"
            .short	SW_1_inc_counter

            .sect 	".int24"
            .short	SW_2_dec_counter
