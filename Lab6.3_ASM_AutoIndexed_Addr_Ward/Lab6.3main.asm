;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/09/2021
; AutoIncrement and Indexed Mode Addressing
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
; Initialization
;-------------------------------------------------------------------------------
init:
		mov.w	#0, R4			; sets R4-R15 to 0d
		mov.w	#0, R5
		mov.w	#0, R6
		mov.w	#0, R7
		mov.w	#0, R8
		mov.w	#0, R9
		mov.w	#0, R10
		mov.w	#0, R11
		mov.w	#0, R12
		mov.w	#0, R13
		mov.w	#0, R14
		mov.w	#0, R15


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
main:
		mov.w	#Const5, R7		; load R7 witrh the addr of 0FADEh

		mov.w	@R7+, R8		; Contents of mem block into R8-R13
		mov.w	@R7+, R9
		mov.w	@R7+, R10
		mov.w	#Const0, R7		; Re-init R7
		mov.w	@R7+, R11
		mov.w	@R7+, R12
		mov.w	@R7+, R13

		; end demo 1

		mov.w	#Const0, R4		; init R4 with addr of 0DEADh
		mov.w	#Var0, R5		; inti R5 with addr of Var0

		mov.w	0(R4), 0(R5)	; Copy Block1 to Block2
		mov.w	2(R4), 2(R5)
		mov.w	4(R4), 4(R5)
		mov.w	6(R4), 6(R5)

		mov.w	#0, 0(R5)		; Clear Block2
		mov.w	#0, 2(R5)
		mov.w	#0, 4(R5)
		mov.w	#0, 6(R5)

		mov.w	0(R4), 6(R5)	; Copy Block1 to Block2 in reverse order
		mov.w	2(R4), 4(R5)
		mov.w	4(R4), 2(R5)
		mov.w	6(R4), 0(R5)

		mov.w	#0, 0(R5)		; Clear Block2
		mov.w	#0, 2(R5)
		mov.w	#0, 4(R5)
		mov.w	#0, 6(R5)

		; end demo 2

		jmp		main
		nop

;-------------------------------------------------------------------------------
; Memory allocation
;-------------------------------------------------------------------------------

		.data				; goto data mem
		.retain				; keep the selection

Const0:	.short	0DEADh		; Initializes eight 16-bit words at the beginning of data mem.
Const1:	.short	0BEEFh
Const2:	.short	0BABEh
Const3:	.short	0FACEh
Const4:	.short	0DEAFh
Const5:	.short	0FADEh
Const6:	.short	0DEEDh
Const7:	.short	0ACEDh

Var0:	.space	2			; Initializes eigth 16-bit words
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
            
