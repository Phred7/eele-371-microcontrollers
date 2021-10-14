;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 10/15/2021
; Stack and Subroutines
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

			mov.w	#00000h, R4
			mov.w	#02000h, R5
main:

			mov.w	#010h, R4				; init R6 to 16d in hex
push_loop:
			dec		R4
			push 	@R5+
			cmp		#00h, R4				; compare R4 to 0
			jnz		push_loop				; if R4 is not 0 then continue iterating
push_loop_end:
			mov.w	#010h, R4				; init R6 to 16d in hex
			mov.w	#02000h, R5
			jmp		pop_loop
pop_loop:
			dec		R4
			pop 	0(R5)
			call	#add_3
			incd	R5
			cmp		#00h, R4				; compare R4 to 0
			jnz		pop_loop				; if R4 is not 0 then continue iterating
pop_loop_end:
			mov.w	#00000h, R4
			mov.w	#02000h, R5
			jmp		end_main
end_main:
			jmp		main
			nop

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------
add_3:
			add.w	#03h, 0(R5)
			ret


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
            
