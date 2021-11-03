#include <msp430.h> 


/** W. Ward
 *  11/1/2021
 *  Practical C Lang.
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	// Ports
    P1DIR |= BIT0;              // Config P1.0 LED1 (Red) as out
    P1OUT &= ~BIT0;             // Init val = 0

    P6DIR |= BIT6;              // Config P6.6 LED2 (Green) as out
    P6OUT &= ~BIT6;             // Init val = 0

    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES |= BIT1;              // Config IRQ H->L

    PM5CTL0 &= ~LOCKLPM5;       // Enable GPIO

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag
    P2IE |= BIT3;               // Enable P2.3 IRQ

    __enable_interrupt();       // EN maskable IRQ

	while(1){}
	return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    P1OUT ^= BIT0;      // Toggle LED1
    P6OUT ^= BIT6;      // Toggle LED2
    P4IFG &= ~BIT1;
}
//-- END ISR_Port4_SW1
