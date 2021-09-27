;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/24/2021
; C Constructs
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
			mov.w	#0000h, &P5SEL0
			mov.w	#0000h, &P5SEL1
			mov.w	#0000h, &P5DIR
			bis.b	#00001111b, &P5REN
			bic.b	#00001111b, &P5OUT

			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			bis.b	#BIT6, &P6DIR			; set P6.6 as output - LED2
			bic.b	#BIT6, &P6OUT			; set init val to 0
			bic.b	#BIT6, &P6REN			; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

			mov.w	#00h, R5

main:
			bis.b	#BIT0, &P1OUT
			mov.w	#0FFFFh, R4

mainDelayOn:
			dec		R4
			jnz		mainDelayOn				; if R4 is not zero repeat
			bic.b	#BIT0, &P1OUT
			mov.w	#0FFFFh, R4

mainDelayOff:
			dec		R4
			jnz		mainDelayOff			; if R4 is not zero repeat

while:
			mov.b	P5IN, R5
			cmp 	#0001b, R5				; check to see if R5 is equal to 0001b
			jnz		endWhile				; if R5 (P5IN) is not equal to 0001b
			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			mov.w	#0FFFFh, R6
			jmp		whileDelayOn

whileDelayOn:
			dec		R6
			jnz		whileDelayOn			; if R6 is not =0  jump to whileDelayOn
			bic.b	#BIT6, &P6OUT			; turn off LED2 (Green)
			mov.w	#0FFFFh, R6

whileDelayOff:
			dec		R6
			jnz		whileDelayOff			; if R6 is not =0 jmp to whileDelayOff
			jmp		while

endWhile:
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
            
