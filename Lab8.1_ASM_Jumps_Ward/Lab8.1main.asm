;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/24/2021
; Jump and Branch Instructions
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

main:
			mov.w	#0AAAAh, R4				; move into R4 then jump to add1
			jmp		add1

sub1:
			sub.w	#0000Fh, R4				; sub from R4 then jump to toggleAll
			jmp		toggleAll

rotateLeft:
			rla.w	R4						; rotate bits left once then jump to done
			jmp		done

toggleAll:
			xor.w	#0FFFFh, R4				; use xor to set all bits in R4 then jump to rotateLeft
			jmp		rotateLeft

add1:
			add.w	#00005h, R4				; add to R4 then jump to sub1
			jmp		sub1

done:
			jmp		main					; jump to main
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
            
