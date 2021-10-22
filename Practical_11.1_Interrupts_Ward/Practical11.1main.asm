;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/20/2021
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
			bic.b	#BIT3, &P2DIR			; set P2.3 as input - SW2
			bis.b	#BIT3, &P2REN			; EN pull up/down
			bis.b	#BIT3, &P2OUT			; pull-up res.

			bis.b	#BIT6, &P6DIR			; set P6.6 as output - LED2 (green)
			bic.b	#BIT6, &P6OUT			; set init val to 0
			bic.b	#BIT6, &P6REN			; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1 (red)
			bis.b	#BIT0, &P1OUT			; set LED1 to HIGH
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bic.b	#11111111b, &P2IFG		; clear interrupt flags on P2
			bis.b   #BIT3, &P2IES			; set as falling edge (high->low)
			bis.b	#BIT3, &P2IE			; assert local interrupt enable

			nop
			eint							; assert global interrupt flag
			nop

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default



main:
			jmp 	main
			nop
;-------------- END MAIN --------------

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

; Service SW2
toggle_leds:
			xor.b	#BIT6, &P6OUT			; toggle on LED2 (Green)
			xor.b	#BIT0, &P1OUT			; toggle on LED1 (Red)
			bic.b	#BIT3, &P2IFG
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

            .sect 	".int24"
            .short	toggle_leds
