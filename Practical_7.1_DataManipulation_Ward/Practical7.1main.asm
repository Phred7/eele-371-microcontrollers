;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/22/2021
; Practical 7.1 - Data Manipulation
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
			mov.w	#0000h, R3					; init R3:R5
			mov.w	#0000h, R4
			mov.w	#0000h, R5

main:
			add.w	#0FFFFh, R4					; c flag = 1 means overflow, c=0 means no overflow

			sub.w	#0FFFDh, R4					; carry: c=1 means no borrow, c=0 means borrows required for sub

			xor.w	#1000000000000000b, R4		; toggle bit 15

			bis.w	#0000000000000010b, R4		; set bit 2

			bit.w	#0100000000000000b, R4		; test if bit 14 is 0; if z=1 bit in dst is 0 otherwise not 0 (bit 14)

			tst.w	R4							; n=1 if R4 is negative, z=1 if dst is 0

			clrc								; clears the carry flag in SR

			rra.w	R4
			rra.w	R4
			mov.w	R4, R5


			jmp main
			nop
                                            

;-------------------------------------------------------------------------------
; Memory Allocation
;-------------------------------------------------------------------------------

			.data
			.retain

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
            
