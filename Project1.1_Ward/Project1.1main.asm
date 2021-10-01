;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/29/2021
; Project 1.1
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

			mov.w	#000FFh, R4				; def R4 as R/L indicator
			mov.w	#00h, R5				; def R5 as Scoop Count
			mov.w	#02000h, R6				; def R6 as Error Code Addr
			mov.w	#00h, R7				; def Rx as Delay Counter
			mov.w	#00h, R8
			mov.w	#0AAAAh, R9				; mov AAAAh into R9
			mov.w	#00h, R10				; to keep track input vals

			bic.b	#BIT3, &P2DIR			; set P2.3 as input - SW2
			bis.b	#BIT3, &P2REN			; EN pull up/down
			bis.b	#BIT3, &P2OUT			; pull-up res.

			bis.b	#BIT0, &P1DIR			; set P1.0 as output - LED1
			bic.b	#BIT0, &P1OUT			; set init val to 0
			bic.b	#BIT0, &P1REN			; ensures REN disabled
			mov.b	#000h, &P1SEL0			; ensures default selection
			mov.b	#000h, &P1SEL1			; ensures default selection

			mov.w	#0000h, &P5SEL0			; def P5.0:P5.3 as input
			mov.w	#0000h, &P5SEL1
			mov.w	#0000h, &P5DIR
			bis.b	#00001111b, &P5REN
			bic.b	#00001111b, &P5OUT

			bis.b	#00001111b, &P6DIR		; set P6.0:P6.3 as output. Ident. TB pins from course TB pg246
			bic.b	#00001111b, &P6OUT		; set init vals to 0
			bic.b	#00001111b, &P6REN		; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:

while:
			mov.b	P2IN, R10
			cmp.b	#BIT3, R10				; check the value of bit3 in R10 which is the value of SW2
			jz		end_while				; if SW2 is not pressed exit the loop
			bis.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			jmp		end


c_while:	jmp		while

end_while:
			bic.b	#BIT0, &P1OUT			; turn off LED1 (Red)
			jmp main
end:
			mov.b	P5IN, R10
			cmp.b	#0000b, R10				; check if any of P5.0:P5.3 is high
			jz		_nop	 				; if none of P5.0:P5.3 is high skip enabling bit
			bis.b	#BIT0, &P6OUT			; write a high to P6.0
_nop:		nop


;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data
			.retain
                                            

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
            
