#include <msp430.h> 

/** W. Ward
 *  11/14/2021
 *  I2C Tx
 */

int dataCnt = 0;
char packet[] = { 0x03, 0x15, 0x26, 0x10, 0x14, 0x00, 0x11, 0x21 }; // 10:26:15 Sunday 11/14/'21//{ 0x03, 0x31, 0x10, 0x08, 0x14, 0x00, 0x11, 0x21 }; // 8:10:31 Sunday 11/14/'21

int main(void){

	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//-- Put eUSCI_B0 into sw reset
	UCB0CTLW0 |= UCSWRST;

	//-- Config eUSCI_B0
    UCB0CTLW0 |= UCSSEL_3;       // eUSCI clk is 1MHz
    UCB0BRW = 10;               // Prescaler=10 to make SCLK=100kHz

    UCB0CTLW0 |= UCMODE_3;      // put into I2C mode
    UCB0CTLW0 |= UCMST;         // put into master mode
    UCB0CTLW0 |= UCTR;           // Put into Tx mode
    UCB0I2CSA = 0x0068;         // secondary 0x68

    UCB0CTLW1 |= UCASTP_2;      // Auto STOP when UCB0TBCNT reached
    UCB0TBCNT = sizeof(packet); // # of Bytes in Packet

    //-- Config Ports
    P1SEL1 &= ~BIT3;            // P1.3 = SCL
    P1SEL0 |= BIT3;

    P1SEL1 &= ~BIT2;            // P1.2 = SDA
    P1SEL0 |= BIT2;

    PM5CTL0 &= ~LOCKLPM5;       // disable LPM

    //-- Take eUSCI_B0 out of SW reset
    UCB0CTLW0 &= ~UCSWRST;

    //-- Enable Interrupts
    UCB0IE |= UCTXIE0;          // Enable I2C Tx0 IRQ
    __enable_interrupt();       // Enable Maskable IRQs

    int i;
    while(1) {
        UCB0CTLW0 |= UCTXSTT;   // Genearte START condition
        // UCB0IFG |= UCTXIFG0;
        for(i=0; i<100; i=i+1){} //delay loop
    }

	return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
#pragma vector = EUSCI_B0_VECTOR
__interrupt void  EUSCI_B0_I2C_ISR(void){
    if (dataCnt == (sizeof(packet) - 1)) {
        UCB0TXBUF = packet[dataCnt];
        UCB0IFG &= ~UCTXIFG0;
        dataCnt = 0;
    } else {
        UCB0TXBUF = packet[dataCnt];
        dataCnt++;
    }
}
