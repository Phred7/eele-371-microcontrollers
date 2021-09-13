;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/02/2021
; Register, Immediate and Absolute Mode Addressing
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
main:

reg:
		mov.w	PC, R4		; copy PC into R4
		mov.w	R4, R5		; copy R4 to R5
		mov.w	R5, R6		; copy R5 to R6

		mov.b	PC, R7		; copy LSB of PC into R7
		mov.b	R7, R8		; copy LSB of R7 into R8
		mov.b	R8, R9		; copy LSB of R8 into R9

		mov.w	SP, R10		; copy SP into R10
		mov.w	R10, R11	; copy R10 into R11
		mov.w	R11, R12	; copy R11 into R12

		mov.b	SP, R13		; copy LSB of SP into R13
		mov.b	R13, R14	; copy LSB of R13 into R14
		mov.b	R14, R15	; copy LSB of R14 into R15

imm:
		mov.w	#01234h, R4		; put val 1234h into R4
		mov.w	#0FACEh, R5		; put val FACEh into R5

		mov.b	#099h, R6		; put val 99h into R6
		mov.b	#0EEh, R7		; put val EEh into R7

		mov.w	#371d, R8		; 371 decm into R8
		mov.b	#10101010b, R9	; 10101010 bin into R9
		mov.b	#'B', R10		; ASCII for B (42h) into R10

abs:
		mov.w	&2000h, R4	; copy from addr 2000h into R4
		mov.w	R4, &2004h	; copy from R4 to addr 2004h

		mov.w	&2002h, R5	; copy from addr 2002h into R5
		mov.w	R5, &2006h	; copy from R% into addr 2006h

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
            
