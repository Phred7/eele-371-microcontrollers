#include <msp430.h> 

/** W. Ward
 *  11/1/2021
 *  UART
 */

char message[] = "Walker Ward ";
unsigned const int last = 7;
unsigned int position;
unsigned int message_length;

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

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
    P1DIR |= BIT0;              // Config P1.0 LED1 (Red) as out
    P1OUT &= ~BIT0;             // Init val = 0


    P6DIR |= BIT6;              // Config P6.6 LED2 (Green) as out
    P6OUT &= ~BIT6;             // Init val = 0

    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES &= ~BIT1;              // Config IRQ H->L

    P2DIR &= ~BIT3;             // Clear P2.3 (SW2) dir = in
    P2REN |= BIT3;              // Enable pull up/down res
    P2OUT |= BIT3;              // Make res pull up
    P2IES &= ~BIT3;              // Config IRQ H->L

    //--3.1. UART A1 Tx
    P4SEL1 &= ~BIT3;
    P4SEL0 |= BIT3;

    //--3.2. UART A1 Rx
    P4SEL1 &= ~BIT2;
    P4SEL0 |= BIT2;

    //--4. Take eUSCU_A1 out of software reset
    UCA1CTLW0 &= ~UCSWRST;

    PM5CTL0 &= ~LOCKLPM5;

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag
    P2IE |= BIT3;               // Enable P2.3 IRQ

    //-- A1 RXIFG
    UCA1IE |= UCRXIE;           // local enable for A1 Rx

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

// Service SW1
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    position = 0;
    UCA1TXBUF = message[position];
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;


    P4IFG &= ~BIT1;
}
//-- END ISR_Port4_SW1

// Service SW2
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {
    position = last;
    UCA1TXBUF = message[position];
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;

    P2IFG &= ~BIT3;
}
//-- END ISR_Port2_SW2

#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_A1(void) {
    int transmit;
    transmit = UCA1IFG;
    transmit &= UCTXCPTIFG; //8 on Tx

    int recieve;
    recieve = UCA1IFG;
    recieve &= UCRXIFG;

    if(transmit == 8) {
        if(position+1 == sizeof(message) || position == 6) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            int i;
            for(i=0; i<10000; i++){}
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
        UCA1IFG &= ~UCTXCPTIFG;
    } else if (recieve == 1) {
        int reciever = UCA1RXBUF;
        if (UCA1RXBUF == '1') {
            P1OUT ^= BIT0;      // Toggle LED1
        } else if (UCA1RXBUF == '2') {
            P6OUT ^= BIT6;      // Toggle LED2
        }
        UCA1IFG &= ~UCRXIFG;
    }

}
//-- END ISR_EUSCI_A1
