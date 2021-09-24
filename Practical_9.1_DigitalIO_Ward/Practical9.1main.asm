;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; Walker Ward
; EELE371
; 09/24/2021
; Digital IO
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
			mov.w	#000h, R5
			mov.w	#000h, R6

			bis.b	#BIT3, &P5DIR			; set P1.0 as output - led
			bic.b	#BIT3, &P5OUT			; set init val of led to 0

			bic.b	#BIT7, &P3DIR			; set P4.1 as in - jumper
			bis.b	#BIT7, &P3REN			; EN pull up/down
			bic.b	#BIT7, &P3OUT			; pull-down res.

			bic.b	#LOCKLPM5, &PM5CTL0		; disable DIO low-power default

main:
			bis.b	#BIT3, &P5OUT			; enable led
			mov.w	P3IN, R5
			bic.b	#BIT3, &P5OUT			; disable led
			mov.w	P3IN, R6

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
            
