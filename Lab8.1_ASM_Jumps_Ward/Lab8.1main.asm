;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/24/2021
; Jump and Branch Instructions
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

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			mov.w	#0AAAAh, R4				; move into R4 then jump to add1
			jmp		add1

sub1:
			sub.w	#0000Fh, R4				; sub from R4 then jump to toggleAll
			jmp		toggleAll

rotateLeft:
			rla.w	R4						; rotate bits left once then jump to done
			jmp		done

toggleAll:
			xor.w	#0FFFFh, R4				; use xor to set all bits in R4 then jump to rotateLeft
			jmp		rotateLeft

add1:
			add.w	#00005h, R4				; add to R4 then jump to sub1
			jmp		sub1

done:
			mov.b	P5IN, R5
			cmp.b	#00h, R5				; if R5 is equal to 00h
			jz		SolidGreen				; jmp to SolidGreen
			cmp.b	#00h, R5				; if R5 is not equal to 00h
			jnz		SolidRed				; jmp to SolidRed

			jmp		main					; jump to main

;-------------------------------------------------------------------------------
; Blinky LED Subroutines here (DEMO 2)
;-------------------------------------------------------------------------------
SolidGreen:
			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			bic.b	#BIT0, &P1OUT			; turn off LED1 (Red)
			jmp		done

SolidRed:
			bis.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			bic.b	#BIT6, &P6OUT			; turn off LED2 (Green)
			cmp.b	#04h, R5				; is 04h greater than or equal to R5?
			jge		SlowBlink				; if so jmp to SlowBlink (R5 >= 04h)
			cmp.b	#04h, R5				; is 04h less than R5?
			jl		FastBlink				; then jmp to FastBlink (R5 < 04h)

SlowBlink:
			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			mov.w	#0FFFFh, R6

SlowDelayOn:
			dec		R6
			jnz		SlowDelayOn				; if R6 is not =0  jump to SlowDelayOn
			bic.b	#BIT6, &P6OUT
			mov.w	#0FFFFh, R6

SlowDelayOff:
			dec		R6
			jnz		SlowDelayOff			; if R6 is not =0 jmp to SlowDelayOff
			jmp		done

FastBlink:
			bis.b	#BIT6, &P6OUT			; turn on LED2 (Green)
			mov.w	#01111h, R6

FastDelayOn:
			dec		R6
			tst		R6						; tst R6 to see if it is negative or = 0
			jn		ContinueOn				; if R6 is negative jmp to ContinueOn
			jmp		FastDelayOn

ContinueOn:
			bic.b	#BIT6, &P6OUT
			mov.w	#01111h, R6

FastDelayOff:
			dec		R6
			tst		R6						; tst R6 to see if it is negative or = 0
			jn		ContinueOff				; if R6 is negative jmp to ContinueOff
			jmp		FastDelayOff

ContinueOff:
			jmp		done

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
            
