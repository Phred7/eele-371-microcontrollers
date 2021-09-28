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
			jmp		main_delay_on

main_delay_on:
			dec		R4
			jnz		main_delay_on				; if R4 is not zero repeat
			bic.b	#BIT0, &P1OUT
			mov.w	#0FFFFh, R4

main_delay_off:
			dec		R4
			jnz		main_delay_off				; if R4 is not zero repeat

if:
			mov.b	P5IN, R5
			cmp.w	#01h, R5
			jnz		else_if_1					; if R5 is equal not equal to 01h, jump to elif_1

			bic.b	#BIT0, &P1OUT				; disable LED1 (Red)
			bis.b	#BIT6, &P6OUT				; turn on LED2 (Green)
			mov.w	global_delay, R6
			jmp		green_on_delay

else_if_1:
			cmp.w	#02h, R5
			jnz		else_if_2					; if R5 is equal not equal to 02h, jump to elif_1

			bis.b	#BIT0, &P1OUT				; enable  LED1 (Red)
			bic.b	#BIT6, &P6OUT				; disable LED2 (Green)
			mov.w	global_delay, R6
			jmp		red_on_delay

else_if_2:
			cmp.w	#04h, R5
			jnz		else					; if R5 is equal not equal to 02h, jump to elif_1

			bis.b	#BIT0, &P1OUT				; enable LED1 (Red)
			bis.b	#BIT6, &P6OUT				; enable LED2 (Green)
			mov.w	global_delay, R6
			jmp		both_on_delay
else:
			bic.b	#BIT0, &P1OUT
			bic.b	#BIT6, &P6OUT
			jmp		end_if

end_if:
			jmp		if

green_on_delay:
			dec		R6
			jnz		green_on_delay			; if R6 is not 0 continue decrementing
			mov.w	global_delay, R6
			bic.b	#BIT6, &P6OUT			; turn off LED2 (Green)
			jmp		green_off_delay			; jump to green_off_delay

green_off_delay:
			dec		R6
			jnz		green_off_delay			; if R6 is not 0 continue decrementing
			jmp		end_if					; jmp to end_if

red_on_delay:
			dec		R6
			jnz		red_on_delay			; if R6 is not 0 continue decrementing
			mov.w	global_delay, R6
			bic.b	#BIT0, &P1OUT
			jmp		red_off_delay			; jump to red_off_delay

red_off_delay:
			dec		R6
			jnz		red_off_delay			; if R6 is not 0 continue decrementing
			jmp		end_if					; jmp to end_if

both_on_delay:
			dec		R6
			jnz		both_on_delay			; if R6 is not 0 continue decrementing
			mov.w	global_delay, R6
			bic.b	#BIT0, &P1OUT
			bic.b	#BIT6, &P6OUT
			jmp		both_off_delay			; jump to both_off_delay

both_off_delay:
			dec		R6
			jnz		both_off_delay			; if R6 is not 0 continue decrementing
			jmp		end_if					; jmp to end_if


			nop
;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

					.data
					.retain

global_delay:		.short	08888h

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
            
