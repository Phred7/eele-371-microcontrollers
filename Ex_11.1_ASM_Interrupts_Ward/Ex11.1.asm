;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/12/2021
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
			bis.b	#BIT0, &P1DIR
			bic.b	#BIT0, &P1OUT

			bic.b	#BIT1, &P4DIR
			bis.b	#BIT1, &P4REN
			bis.b	#BIT1, &P4OUT
			bis.b	#BIT1, &P4IES

			bic.b	#LOCKLPM5, &PM5CTL0

			bic.b	#BIT1, &P4IFG
			bis.b	#BIT1, &P4IE
			bis.w	#GIE, SR

main:
			jmp		main
			nop
;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
ISR_S1:
			xor.b	#BIT0, &P1OUT
			bic.b	#BIT1, &P4IFG
			reti

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
            .short	ISR_S1

