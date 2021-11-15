#include <msp430.h> 

/** W. Ward
 *  11/08/2021
 *  SPI
 */

int Rx_Data;

int main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//-- Put eUSCI_A0 into sw reset
	UCA0CTLW0 |= UCSWRST;

	//-- Config eUSCI_A0
	UCA0CTLW0 |= UCSSEL__SMCLK; // eUSCI clk is 1MHz
	UCA0BRW = 10;               // Prescaler=10 to make SCLK=100kHz

	UCA0CTLW0 |= UCSYNC;        // put eUSCI_A0 into SPI 3pin mode
	UCA0CTLW0 |= UCMST;         // Put into master mode

	//-- Config Ports
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

	P2IFG &= ~BIT3;             // Clear SW2 flag
	P2IE |= BIT3;

	UCA0IFG &= ~UCRXIFG;        // Clear RxFLG Flag
	UCA0IE |= UCRXIE;           // Enable RxIFG IRQ

	__enable_interrupt();

	while(1){}

	return 0;
}
//-- END main



//-- Interrupt Service Routines -------------------------
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {

    UCA0TXBUF = 0x10;            // send 0x10 over SPI Tx
    P4IFG &= ~BIT1;             // CLear SW1 flag

}

#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {

    UCA0TXBUF = 0x66;            // send 0x66 over SPI Tx
    P2IFG &= ~BIT3;             // CLear SW2 flag

}

#pragma vector = EUSCI_A0_VECTOR // Data in Rx Buffer
__interrupt void ISR_EUSCI_A0(void) {

    Rx_Data = UCA0RXBUF;        // Read Rx Buffer

    if (Rx_Data == 0x10) {
        P1OUT ^= BIT0;          // Toggle LED1 if 0x10
    } else if (Rx_Data == 0x66) {
        P6OUT ^= BIT6;          // Toggle LED2 if 0x66
    }
}
