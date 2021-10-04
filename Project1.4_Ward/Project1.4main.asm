;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/01/2021
; Project 1.4
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
;
; R4 as R/L indicator
; R5 as Scoop Count
; R6 as Error Code Addr
; R7 as Delay Counter
; R8 as Delay Counter
; R9 as Error Code Display
; R10 as Counter
; R11 as Total Scoop Count
; R12 as
; R13 to keep track of other vals
;-------------------------------------------------------------------------------
init:

			mov.w	#000FFh, R4				; def R4 as R/L indicator
			mov.w	#00h, R5				; def R5 as Scoop Count
			mov.w	#error_codes, R6				; def R6 as Error Code Addr
			mov.w	#00h, R7				; def Rx as Delay Counter
			mov.w	#00h, R8
			mov.w	#0AAAAh, R9				; mov AAAAh into R9
			mov.w	#00h, R10				; counter
			mov.w	#00h, R11				; total scoop count
			mov.w	#00h, R12				; keep track of vars
			mov.w	#00h, R13				; keep track of addrs and other vars

			bic.b	#BIT1, &P4DIR			; set P4.1 as input - SW1
			bis.b	#BIT1, &P4REN			; EN pull up/down
			bis.b	#BIT1, &P4OUT			; pull-up res.

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

			bis.b	#00001111b, &P6DIR		; set P6.0:P6.3 as output. Ident. TB pins from course Text pg246, MSP430 pin out
			bic.b	#00001111b, &P6OUT		; set init vals to 0
			bic.b	#00001111b, &P6REN		; ensures REN disabled
			mov.b	#000h, &P6SEL0			; ensures default selection
			mov.b	#000h, &P6SEL1			; ensures default selection

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			bis.b	#BIT1, R7

while:
			mov.b	P2IN, R13
			bit.b 	#BIT3, R13				; tests if the third bit in P2 (SW2) is asserted
			jz		end_while				; if SW2 is not asserted then SW2 is pressed
			jmp		if_sw1					; jump to if statements
w_cont:		jmp 	while					; jump to next iteration

if_sw1:
			mov.b	P4IN, R13
			bit.b	#BIT1, R13				; tests if the first bit in P4 (SW1) is asserted... does sw1 == 1? if true z=0
			jnz		if_not_sw1				; if SW1 is not pressed, jump to elif
			jmp 	if_not_r7

if_not_r7:
			bit.b	#BIT1, R7				; tests if the first bit of R7 is asserted. does R7==1? if true z=0
			jz		w_cont					; if R7.1 is 1 it follows that the last state of SW1 was not pressed, so Z=0 => R7.1=1
			bic.b	#BIT1, R7
			jmp 	if_r5

if_r5:
			cmp.w	#09d, R5				; is R5 greater than or equal to 9 decimal
			jge		w_cont					; R5 cannot be greater than 9 dec. Iterate until SW2 is pressed
			inc		R5
			jmp		w_cont					; iterate

if_not_sw1:									; SW1 is not pressed

if_r7:
			bit.b	#BIT1, R7				; tests if the first bit of R7 is asserted.
			jnz		w_cont					; if R7.1 is 0 it follows that the last state of SW1 was pressed, so Z=1 => R7.1=0. If R7.1=1 iterate
			bis.b	#BIT1, R7
			jmp		w_cont

w_else:
			jmp		w_cont

end_while:
			mov.w	#00h, R7

blink_for:
			dec		R5
			bis.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			mov.w	global_delay, R13
			jmp		green_on_delay
for_mid:	cmp		#00h, R5				; compare R5 to 0
			jnz		blink_for				; if R5 is not 0 then continue iterating
end_for:	jmp		func_1





func_1:

f1_while:
			cmp 	#0001b, P5IN			; check to see if P5IN is equal to 0001b
			jnz		f1_while				; if R5 (P5IN) is not equal to 0001b
			jmp		end_f1_while

end_f1_while:
			mov.w	#04h, R10
			mov.w	#01h, R12
f1_for:
			dec		R10
			bis.b	R12, &P6OUT
			mov.w	actuator_fwd, R7
f1_delay:   dec 	R7
			cmp		#00h, R7
			jnz		f1_delay				; if R7 is not 0 jump back to f1_delay
			mov.w	actuator_fwd, R7
f1_delay_1: dec 	R7
			cmp		#00h, R7
			jnz		f1_delay_1				; if R7 is not 0 jump back to f1_delay_1
			cmp		#00h, R10				; compare R10 to 0
			jz		end_f1_for				; if R10 is not 0 then continue iterating
			bic.b	R12, &P6OUT
			rla		R12
			jmp		f1_for
end_f1_for:	jmp		end_func_1

end_func_1:





func_2:

f2_while:
			cmp.b 	#0011b, P5IN			; check to see if P5IN is equal to 0011b
			jnz		f2_while				; if R5 (P5IN) is not equal to 0011b
			jmp		end_f2_while

end_f2_while:
			mov.w	#04h, R10
			mov.b	#1000b, R12
f2_for:
			dec		R10
			bis.b	R12, &P6OUT
			mov.w	actuator_bkd, R7
f2_delay:   dec 	R7
			cmp		#00h, R7
			jnz		f2_delay				; if R7 is not 0 jump back to f2_delay
			mov.w	actuator_bkd, R7
f2_delay_1: dec 	R7
			cmp		#00h, R7				; if R7 is not 0 jump back to f2_delay_1
			jnz		f2_delay_1
			bic.b	R12, &P6OUT
			rra		R12
			cmp		#00h, R10				; compare R10 to 0
			jnz		f2_for					; if R10 is not 0 then continue iterating
end_f2_for:	jmp		end_func_2

end_func_2:





func_3:

f3_while:
			cmp.b 	#0111b, P5IN			; check to see if P5IN is equal to 0111b
			jnz		f3_while				; if R5 (P5IN) is not equal to 0111b
			jmp		end_f3_while

end_f3_while:
			mov.w	#error_codes, R11
			add.w	R5, 32(R11)
			swpb	R4						; from instruction set
			jmp 	func_4


func_4:
			bit.b 	#BIT3, P5IN			;	 check to see if P5IN.3 is equal to 1
			jnz		main				; if R5 (P5IN) is not equal to 0011b
			mov.w	@R6+, R9
			mov.w	#00h, 32(R11)
			jmp		main

green_on_delay:
			dec		R13
			jnz		green_on_delay			; if R6 is not 0 continue decrementing
			mov.w	global_delay, R13
			bic.b	#BIT0, &P1OUT			; turn on LED1 (Red)
			jmp		green_off_delay			; jump to green_off_delay

green_off_delay:
			dec		R13
			jnz		green_off_delay			; if R6 is not 0 continue decrementing
			bic.b	#BIT0, &P1OUT			; turn off LED1 (Red)
			jmp		for_mid					; jmp to for_mid (for condition evaluation)
			nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

					.data
					.retain

error_codes:		.short	0000h, 0001h, 0002h, 0003h, 0004h, 0005h, 0006h, 0007h, 0008h, 0009h, 000Ah, 000Bh, 000Ch, 000Dh, 000Eh, 000Fh
Block2: 			.space	32
global_delay:		.short	0FFFFh
actuator_fwd:		.short	0FFFFh
actuator_bkd:		.short	08888h
                                            

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
            
