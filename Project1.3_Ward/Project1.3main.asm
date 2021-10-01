;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/01/2021
; Project 1.3
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
			mov.w	#00h, R10				; counter
			mov.w	#00h, R11				; total scoop count
			mov.w	#00h, R13				; keep track of addrs and other vars

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
			mov.w	#Block1, R13
			mov.w	@R13+, R9
			mov.w	@R13+, R9
			mov.w	@R13+, R9

			mov.w	#Block1, R13
			mov.w	P5IN, 32(R13)

			mov.w	#Block1, R13
			mov.b	@R13+, &P6OUT
			inc		R13
			mov.b	@R13+, &P6OUT
			inc		R13
			mov.b	@R13+, &P6OUT
			inc		R13
			mov.b	@R13+, &P6OUT 		; binary counting issue makes P6OUT = 0011
			inc		R13
			mov.b	@R13+, &P6OUT
			inc		R13

			swpb	R4					; from instruction set
			swpb	R4

			jmp		main
			nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data
			.retain

Block1:		.short	0000h, 0001h, 0002h, 0003h, 0004h, 0005h, 0006h, 0007h, 0008h, 0009h, 000Ah, 000Bh, 000Ch, 000Dh, 000Eh, 000Fh
Block2: 	.space	32

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
            
