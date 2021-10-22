#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	P1DIR |= BIT0;              // Set P1.0 (LED1) direction = out
	P1OUT &= ~BIT0;             // Clear P1.0 (LED1) to start

	P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
	P4REN |= BIT1;              // Enable pull up/down res
	P4OUT |= BIT1;              // Make res pull up

	PM5CTL0 &= ~LOCKLPM5;       // Enable GPIO

	int i;
	int SW1;

	while(1) {
	    SW1 = P4IN;             // Read P4 and into SW1
	    SW1 &= BIT1;            // Clear bits in SW1 except BIT1

	    if (SW1 == 0) {
	        P1OUT ^= BIT0;      // Toggle LED1
	    }

	    for (i = 0; i < 10000; i++) {   // delay loop
	    }
	}

	return 0;
}
