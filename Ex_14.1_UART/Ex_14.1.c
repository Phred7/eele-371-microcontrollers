#include <msp430.h> 


/** W. Ward
 *  10/31/2021
 *  UART
 */

char message[] = "Hello World ";
unsigned int position;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//-- 1. Put eUSCI_A1 into software reset
	UCA1CTLW0 |= UCSWRST;

	//--2. Config eUSCI_A1
	UCA1CTLW0 |= UCSSEL__SMCLK;
	UCA1BRW = 8;
	UCA1MCTLW |= 0xD600;

	//--3. Config Ports
	P4DIR &= ~BIT1;
	P4REN |= BIT1;
	P4OUT |= BIT1;
	P4IES |= BIT1;

	P4SEL1 &= ~BIT3;
	P4SEL0 |= BIT3;

	//--4. Take eUSCU_A1 out of SW reset
    UCA1CTLW0 &= ~UCSWRST;

	PM5CTL0 &= ~LOCKLPM5;

	//--5. Enable IRQs
	P4IFG &= ~BIT1;
	P4IE |= BIT1;

	__enable_interrupt();

	while(1){}
	return 0;
}

//-- ISRs
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void) {
    position = 0;
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;
    UCA1TXBUF = message[position];

    P4IFG &= ~BIT1;
}

#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_AL(void) {
    if(position == sizeof(message)) {
        UCA1IE &= ~UCTXCPTIE;
    } else {
        position++;
        UCA1TXBUF = message[position];
    }
    UCA1IFG &= ~UCTXCPTIFG;
}
