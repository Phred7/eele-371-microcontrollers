#include <msp430.h> 

/** W. Ward
 *  11/9/2021
 *  SPI Main Tx.
 */

char packet[] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x11, 0x22};
unsigned int position;

int main(void) {

	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//-- Put eUSCI_A0 into sw reset
    UCA0CTLW0 |= UCSWRST;

    //-- Config eUSCI_A0
    UCA0CTLW0 |= UCSSEL__SMCLK; // eUSCI clk is 1MHz
    UCA0BRW = 20;               // Prescaler=20 to make SCLK=50kHz

    UCA0CTLW0 |= UCSYNC;        // put eUSCI_A0 into SPI 3pin mode
    UCA0CTLW0 |= UCMST;         // Put into master mode

    //-- Config Ports
    P4DIR &= ~BIT1;             // Config SW1
    P4REN |= BIT1;
    P4OUT |= BIT1;
    P4IES |= BIT1;

    P1SEL1 &= ~BIT5;            // P1.5 SCLK
    P1SEL0 |= BIT5;

    P1SEL1 &= ~BIT7;            // P1.7 SIMO
    P1SEL0 |= BIT7;

    P1SEL1 &= ~BIT6;            // P1.6 SOMI
    P1SEL0 |= BIT6;

    PM5CTL0 &= ~LOCKLPM5;       // Disable I/O

    //-- Take eUSCI_A0 out of SW reset
    UCA0CTLW0 &= ~UCSWRST;

    //-- Enable IRQs
    P4IFG &= ~BIT1;             // Clear SW1 flag
    P4IE |= BIT1;

    UCA0IFG &= ~UCTXIFG;
    UCA0IE |= UCTXIE;

    __enable_interrupt();

    while(1){}

	return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
//Service SW1
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    position = 0;
    UCA0TXBUF = packet[position];

    P4IFG &= ~BIT1;
}
//-- END ISR_Port4_SW1

//Service Tx
#pragma vector = EUSCI_A0_VECTOR
__interrupt void ISR_EUSCI_A0(void) {
    position++;

    if (position < sizeof(packet)) {
        UCA0TXBUF = packet[position];
    } else {
        UCA0IFG &= ~UCTXIFG;
    }
}
//-- END ISR_EUSCI_A0
