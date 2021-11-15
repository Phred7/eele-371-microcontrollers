#include <msp430.h> 


/** W. Ward
 *  11/08/2021
 *  SPI Tx + Rx
 */

int Rx_Data;

int main(void) {

	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//— Put eUSCI_A0 into software reset
	UCA0CTLW0 |= UCSWRST;

	//— Config eUSCI_A0
	UCA0CTLW0 |= UCSSEL__SMCLK;
	UCA0BRW = 20;

	UCA0CTLW0 |= UCSYNC;
	UCA0CTLW0 |= UCMST;

	//— Config ports
    P1DIR |= BIT0;              // Config LED1
    P1OUT &= ~BIT0;

    P6DIR |= BIT6;              // Config LED2
    P6OUT &= ~BIT6;

	P4DIR &= ~BIT1;             // Config SW1
	P4REN |= BIT1;
	P4OUT |= BIT1;
	P4IES |= BIT1;

    P2DIR &= ~BIT3;             // Config SW2
    P2REN |= BIT3;
    P2OUT |= BIT3;
    P2IES |= BIT3;

	P1SEL1 &= ~BIT5;
	P1SEL0 |= BIT5;

	P1SEL1 &= ~BIT7;
	P1SEL0 |= BIT7;

	P1SEL1 &= ~BIT6;
	P1SEL0 |= BIT6;

	PM5CTL0 &= ~LOCKLPM5;

	//-- Take eUSCI_A0 out of SW reset
	UCA0CTLW0 &= ~UCSWRST;

	//— Enable IRQs
    P4IFG &= ~BIT1;             // Clear SW1 flag
    P4IE |= BIT1;

    P2IFG &= ~BIT3;             // Clear SW2 flag
    P2IE |= BIT3;

	UCA0IFG &= ~UCRXIFG;
	UCA0IE |= UCRXIE;

    UCA0IFG &= ~UCTXIFG;
    UCA0IE |= UCTXIE;

	__enable_interrupt();

	while(1){}

	return 0;
}
//— END main

//— Interrupt Service Routines
// Service SW1
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {

    UCA0TXBUF = 0xEE;
    P4IFG &= ~BIT1;

}
//-- End ISR_Port4_SW1

// Service SW2
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {

    UCA0TXBUF = 0x37;

    P2IFG &= ~BIT3;

}
//-- End ISR_Port2_SW2

#pragma vector = EUSCI_A0_VECTOR // Data in Rx Buffer
__interrupt void ISR_EUSCI_A0(void) {

    Rx_Data = UCA0RXBUF;        // Read Rx Buffer

    if (Rx_Data == 0xEE) {
        P1OUT |= BIT0;
        P6OUT ^= BIT6;
    } else if (Rx_Data == 0x37) { //Invert LEDs
        int led1;
        led1 = P1OUT;
        led1 &= BIT0;
        if (led1 == 0) {
            P6OUT &= ~BIT6;
        } else {
            P6OUT |= BIT6;
        }

        P1OUT ^= BIT0;
    }
    UCA0TXBUF = 0x0;
    UCA0IFG &= ~UCTXIFG;
    UCA0IFG &= ~UCRXIFG;
}
//-- End ISR_EUSCI_A0
