#include <msp430.h> 

/** W. Ward
 *  11/1/2021
 *  UART
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	//-- 1. Put eUSCI_A1 into software reset
    UCA1CTLW0 |= UCSWRST;

    //--2. Config eUSCI_A1
    //--Baud Rate: 9600
//    UCA1CTLW0 |= UCSSEL__SMCLK;
//    UCA1BRW = 6;
//    UCA1MCTLW |= 0x2080 + UCOS16;

    //--Baud Rate: 115200
    UCA1CTLW0 |= UCSSEL__SMCLK;
    UCA1BRW = 8;
    UCA1MCTLW |= 0xD600;

    //--3. Config Ports
    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES |= BIT1;              // Config IRQ H->L

    //--3.1. Tx
    P4SEL1 &= ~BIT3;
    P4SEL0 |= BIT3;

    //--4. Take eUSCU_A1 out of software reset
    UCA1CTLW0 &= ~UCSWRST;

    PM5CTL0 &= ~LOCKLPM5;

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    __enable_interrupt();       // EN maskable IRQ

    int i;

    while(1){
//        UCA1TXBUF = 'E';
//        // lower case a: 0x61
//        // data stream: 10000110
//        for(i=0; i<10000; i++){}
    }

    return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void) {
    position = 0;
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;
    UCA1TXBUF = message[position];

    P4IFG &= ~BIT1;
}
//

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
