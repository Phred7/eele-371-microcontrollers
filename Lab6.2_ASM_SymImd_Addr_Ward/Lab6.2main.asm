;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/08/2021
; Symbolic and Indeirect Mode Addressing
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
init:							; initialization routine
		mov.w	#Const0, R5
		mov.w	#Const1, R6
		mov.w	#Const2, R7
		mov.w	#Const3, R8

main:
		mov.w	Const0, Var0
		mov.w	Const2, Var1
		mov.w	Const3, Var2

		mov.w	Const0, Var7
		mov.w	Const2, Var6
		mov.w	Const3, Var5

		mov.w	Const1, R4
		mov.w	PC, Var3

		mov.w	#0, Const0
		mov.w	#0, Const2
		mov.w	#0, Const4

		mov.w	@R5, R9
		mov.w	@R6, R10
		mov.w	@R7, R11
		mov.w	@R8, R12

		mov.w	#Const4, R5
		mov.w	#Const5, R6
		mov.w	#Const6, R7
		mov.w	#Const7, R8

		mov.w	@R5, R9
		mov.w	@R6, R10
		mov.w	@R7, R11
		mov.w	@R8, R12

		jmp		main
		nop
                                            
;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

		.data									; allocate variables in data memory
		.retain									; keep these statements even if not used

Const0:	.short	0DEADh
Const1:	.short	0BEEFh
Const2:	.short	0BABEh
Const3:	.short	0FACEh
Const4:	.short	0DEAFh
Const5:	.short	0FADEh
Const6:	.short	0DEEDh
Const7:	.short	0ACEDh	; Initializes eight 16-bit words at the beginning of data mem.

Var0:	.space	2
Var1:	.space	2
Var2:	.space	2
Var3:	.space	2
Var4:	.space	2
Var5:	.space	2
Var6:	.space	2
Var7:	.space	2



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
            
