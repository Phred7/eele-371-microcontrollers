;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
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


			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bis.b	#BIT6, &P6DIR			; set P6.6 as output - LED2
			bic.b	#BIT6, &P6OUT			; set init val to 0
			bic.b	#BIT6, &P6REN			; ensures REN disabled
			mov.b	#0000h, &P6SEL0			; ensures default selection
			mov.b	#0000h, &P6SEL1			; ensures default selection

			mov.w	#0000h, &P5SEL0
			mov.w	#0000h, &P5SEL1
			mov.w	#0000h, &P5DIR
			bis.b	#00001111b, &P5REN
			bic.b	#00001111b, &P5OUT

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default
main:
			bic.b	#BIT6, &P6OUT			; turn off LED2 (Green)
			bis.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			mov.w	#0FFFFh, R6
			jmp		whileDelayOn

whileDelayOn:
			dec		R6
			jnz		whileDelayOn			; if R6 is not =0  jump to whileDelayOn
			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			bic.b	#BIT0, &P1OUT			; turn off LED1 (Red)
			mov.w	#0FFFFh, R6
			jmp		whileDelayOff

whileDelayOff:
			dec		R6
			jnz		whileDelayOff			; if R6 is not =0 jmp to whileDelayOff
			jmp		main

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
            
