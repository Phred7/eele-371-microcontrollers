#include <msp430.h> 

/** W. Ward
 *  11/11/2021
 *  I2C - Reading from specific secondary
 */

int dataIn = 0;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
    //-- Put eUSCI_B0 into sw reset
    UCB0CTLW0 |= UCSWRST;

    //-- Config eUSCI_B0
    UCB0CTLW0 |= UCSSEL_3;       // eUSCI clk is 1MHz
    UCB0BRW = 10;               // Prescaler=10 to make SCLK=100kHz

    UCB0CTLW0 |= UCMODE_3;      // put into I2C mode
    UCB0CTLW0 |= UCMST;         // put into master mode
    UCB0I2CSA = 0x0068;         // secondary 0x68

    UCB0TBCNT = 0x01;           // send 1 byte of data
    UCB0CTLW1 |= UCASTP_2;      // Auto STOP when UCB0TBCNT reached

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
    UCB0IE |= UCRXIE0;          // Enable I2C Rx0 IRQ
    __enable_interrupt();       // Enable Maskable IRQs

    while(1){

        //-- Transmit Reg Addr with Write MSG
        UCB0CTLW0 |= UCTR;      // put into Tx mode
        UCB0CTLW0 |= UCTXSTT;   // generate START cond.

        while ((UCB0IFG & UCSTPIFG) == 0 ); // wait for STOP
            UCB0IFG &= ~UCSTPIFG;           // clear STOP flag

        //--Recieve data from Rx
        UCB0CTLW0 &= ~UCTR;     // Put into Rx mode
        UCB0CTLW0 |= UCTXSTT;   // Generate START cond.

        while ((UCB0IFG & UCSTPIFG) == 0 ); //wait for STOP
            UCB0IFG &= ~UCSTPIFG;           // clear STOP flag
    }

	return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
#pragma vector = EUSCI_B0_VECTOR
__interrupt void  EUSCI_B0_I2C_ISR(void){

    switch(UCB0IV){
    case 0x16:                  // Id 16 rxifg0
        dataIn = UCB0RXBUF;     // retrieve data
        break;
    case 0x18:                  // id 18 txifg0
        UCB0TXBUF = 0x03;       // send reg addr
        break;
    default:
        break;
    }
}
