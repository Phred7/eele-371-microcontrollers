;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/03/2021
; Addressing
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
		mov.w	#04444h, R4		; put val 4444h into R4
		mov.w	#05555h, R5		; put val 5555h into R5
		mov.w	#06666h, R6		; put val 6666h into R6

		mov.w	#00000, R4		; clear R4
		mov.w	#00000, R5		; clear R5
		mov.w	#00000, R6		; clear R6

		mov.b	#077h, R7		; copy 77h of PC into R7
		mov.b	#088h, R8		; copy 88h of R7 into R8
		mov.b	#099h, R9		; copy 99h of R8 into R9

		mov.b	R7, R10		; copy LB of R7 into R10
		mov.b	R8, R11		; copy LB of R8 into R11
		mov.b	R9, R12		; copy LB of R9 into R12

		mov.w	PC, R13	; copy PC into R13
		mov.w	SP, R14	; copy SP into R14

		mov.w	&2002h, &2022h ; copy 1111h into 2022h
		mov.w	&2004h, &2024h ; copy 2222h into 2024h
		mov.w	&2006h, &2026h ; copy 3333h into 2026h
		mov.w	&2008h, &2028h ; copy 4444h into 2028h
		mov.w	&200ah, &202ah ; copy 5555h into 202ah

		mov.b	&2040h, &204bh ; copy from addr to addr
		mov.b	&2043h, &204ah
		mov.b	&2042h, &204dh
		mov.b	&2045h, &204ch
		mov.b	&2046h, &204fh

		jmp		main
		nop

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

		.data									; allocate variables in data memory
		.retain									; keep these statements even if not used

Block1:	.short	00000h, 01111h, 02222h, 03333h, 04444h, 05555h, 06666h, 07777h, 08888h, 09999h, 0AAAAh, 0BBBBh, 0CCCCh, 0DDDDh, 0EEEEh, 0FFFFh	; Initializes sixteen 16-bit words at the beginning of data mem.

Block2: .space	32								; reserve 32 bytes (256 bits) as sixteen 16-bit words following the prior initialization in data mem.

Block3: .byte	023h, 001h, 067h, 045h, 0ABh, 089h, 0EFh, 0CDh	; Initializes eigth 8-bit bytes after the prior reservation
Block4:	.space	4								; Reserves 4 bytes of mem. after the prior reservation
                                            

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
            
