#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	// Ports
	P1DIR |= BIT0;              // Config P1.0 LED1 as out
	P1OUT |= BIT0;              // LED1 high for PWM
	PM5CTL0 &= ~LOCKLPM5;       // Enable GPIO

	// TB0
	TB0CTL |= TBCLR;            // Clear timer and divs
	TB0CTL |= TBSSEL__ACLK;     // SRC = ACLK
	TB0CTL |= MC__UP;           // Mode = UP
	TB0CCR0 = 32768;            // CCR0 = 32768
	TB0CCR1 = 1638;             // CCR1 = 1638

	// Timer Compare IRQ
	TB0CCTL0 |= CCIE;           // Enable TB0 CCR0 overflow IRQ
	TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
	TB0CCTL1 |= CCIE;           // Enable TB0 CCR1 overflow IRQ
	TB0CCTL1 &= ~CCIFG;         // Clear CCR1 flag
	__enable_interrupt();       // enable maskable IRQs

	// main
	while(1) {}

	return 0;
}

//-- Interrupt Service Routines -------------------------
#pragma vector = TIMER0_B0_VECTOR
__interrupt void ISR_TB0_CCR0(void) {
    P1OUT |= BIT0;              // LED1 = 1
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
}

#pragma vector = TIMER0_B1_VECTOR
__interrupt void ISR_TB0_CCR1(void) {
    P1OUT &= ~BIT0;             // LED1 = 0
    TB0CCTL1 &= ~CCIFG;         // Clear CCR1 flag
}
