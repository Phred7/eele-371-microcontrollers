/** W. Ward
 *  10/20/2021
 *  DIO Polling w/ Interrupts
 */

#include <msp430.h> 


int count = 0;

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

    P2DIR &= ~BIT3;             // Clear P2.3 (SW2) dir = in
    P2REN |= BIT3;              // Enable pull up/down res
    P2OUT |= BIT3;              // Make res pull up
    P2IES |= BIT3;              // Config IRQ H->L

    PM5CTL0 &= ~LOCKLPM5;       // Enable GPIO

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag
    P2IE |= BIT3;               // Enable P2.3 IRQ

    __enable_interrupt();       // EN maskable IRQ

//    int SW1;
//    int SW2;
//    int i;

    // main
    while (1) {
//        SW1 = P4IN;             // Read P4 and into SW1
//        SW1 &= BIT1;            // Clear bits in SW1 except BIT1
//
//        SW2 = P2IN;             // Read P2 and into SW2
//        SW2 &= BIT3;            // Clear bits in SW2 except BIT3
//
//        if (SW1 == 0 && count != 3) {
//            count++;
//        }
//
//        if (SW2 == 0 && count != 0) {
//            count--;
//        }

        switch (count) {        // MSB: LED1
        case 0:
            P1OUT &= ~BIT0;             // LED1 = 0
            P6OUT &= ~BIT6;             // LED2 = 0
            break;
        case 1:
            P1OUT &= ~BIT0;             // LED1 = 0
            P6OUT |= BIT6;              // LED2 = 1
            break;
        case 2:
            P1OUT |= BIT0;              // LED1 = 1
            P6OUT &= ~BIT6;             // LED2 = 0
            break;
        case 3:
            P1OUT |= BIT0;              // LED1 = 1
            P6OUT |= BIT6;              // LED2 = 1
            break;
        }

//        for (i = 0; i < 200000; i++) {   // delay loop
//        }
    }

	return 0;
}

//-- Interrupt Service Routines -------------------------
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    if (count != 3) {
        count++;
    }
    P4IFG &= ~BIT1;
}

#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {
    if (count != 0) {
        count--;
    }
    P2IFG &= ~BIT3;
}
