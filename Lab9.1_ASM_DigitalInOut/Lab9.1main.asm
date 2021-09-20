;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/19/2021
; Digital In/Out
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
			bis.b	#BIT6, &P6DIR			; set P6.6 as output - LED2
			bic.b	#BIT6, &P6OUT			; set init val to 0
			bic.b	#BIT6, &P6REN			; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bic.b	#BIT1, &P4DIR			; set P4.1 as input - SW1
			bis.b	#BIT1, &P4REN			; EN pull up/down
			bis.b	#BIT1, &P4OUT			; pull-up res.

			bic.b	#BIT3, &P2DIR			; set P2.3 as input - SW2
			bis.b	#BIT3, &P2REN			; EN pull up/down
			bis.b	#BIT3, &P2OUT			; pull-up res.

			bis.b	#BIT6, &P1DIR			; set P1.6 as output
			bic.b	#BIT6, &P1OUT			; set init val to 0
			bic.b	#BIT6, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bic.b	#BIT4, &P1DIR			; set P1.4 as input
			bis.b	#BIT4, &P1REN			; EN pull up/down
			bic.b	#BIT4, &P1OUT			; pull-down res.

			mov.w	#00h, R4				; init regs R4:R6 to 00h
			mov.w	#00h, R5
			mov.w	#00h, R6

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			bis.b	#BIT6, &P1OUT			; enable output pin

			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			bic.b	#BIT6, &P6OUT			; turn off LED2 (Green)

			bis.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			bic.b	#BIT0, &P1OUT			; turn off LED1 (Red)

			mov.b	P4IN, R4				; update R4 with state of SW1	1 is not pressed (pull-up), 0 is pressed
			mov.b	P2IN, R5				; update R5 with state of SW2	1 is not pressed (pull-up), 0 is pressed
			mov.b	P1IN, R6				; update R6 with state of P1
			mov.b	P4IN, R4
			mov.b	P2IN, R5
			mov.b	P1IN, R6
			mov.b	P4IN, R4
			mov.b	P2IN, R5
			mov.b	P1IN, R6
			mov.b	P4IN, R4
			mov.b	P2IN, R5
			mov.b	P1IN, R6

			bic.b	#BIT6, &P1OUT			; disable output pin

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
            
