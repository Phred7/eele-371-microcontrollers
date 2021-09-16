;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/15/2021
; Practical 6.1: Addressing
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
			mov.w	#02000h, R4		; use immediate to init R4 with val
			mov.w	R4, R5			; init R5 with val of R4
			mov.w	#Var1, R6		; init R6 with addr of Var1

main:
			mov.w	&02000h, R7		; use absolute to put the val at the addr 2000h into R7
			mov.w	Con2, R8		; use symbolic to put contents of Con2 into R8
			mov.w	0(R4), R9		; use indexed to copy val of Con1 into R9 using R4
			mov.w	@R5+, R10		; use auto-incriment to copy Con1 into R10
			mov.w	@R5+, R11		; use auto-increment to copy Con2 into R11
			mov.w	2(R4), 4(R6)	; use indexed to copy Con2 into 3rd word of Var1 using R4 and R6 which contain addrs to Con1 and Var1 respectively

			jmp		main
			nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data									; allocate variables in data memory
			.retain									; keep these statements even if not used

Con1:		.short	0ACEDh
Con2:		.short	0BEEFh
Var1:		.space	28

                                            

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
            
