#include <msp430.h> 

/** W. Ward
 *  11/19/2021
 *  Project 2.4
 */

char messageOpen[] = "\n\rGate is OPEN\r\n";//"OPEN ";
char messageClosed[] = "\n\rGate is CLOSED\r\n";//"CLOSED ";
char* message;
int sw1Trigger = 0;
int sw2Trigger = 0;
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

//    //--Baud Rate: 115200
//    UCA1CTLW0 |= UCSSEL__SMCLK;
//    UCA1BRW = 8;
//    UCA1MCTLW |= 0xD600;

    //--Baud Rate: 57600
    UCA1CTLW0 |= UCSSEL__SMCLK;
    UCA1BRW = 17;
    UCA1MCTLW |= 0x4A00;

    //--3. Config Ports
    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES |= BIT1;              // Config IRQ H->L

    P2DIR &= ~BIT3;             // Clear P2.3 (SW2) dir = in
    P2REN |= BIT3;              // Enable pull up/down res
    P2OUT |= BIT3;              // Make res pull up
    P2IES |= BIT3;              // Config IRQ H->L

    //--3.1. Tx
    P4SEL1 &= ~BIT3;
    P4SEL0 |= BIT3;

    //--4. Take eUSCU_A1 out of software reset
    UCA1CTLW0 &= ~UCSWRST;

    PM5CTL0 &= ~LOCKLPM5;

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag
    P2IE |= BIT3;               // Enable P2.3 IRQ

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
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;

    if(position == 0){
        message = messageClosed;
        UCA1TXBUF = message[position];
        sw1Trigger = 1;
    }

    P4IFG &= ~BIT1;
}
//-- End ISR_Port4_SW1

// Service SW2
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;

    if(position == 0){
        message = messageOpen;
        UCA1TXBUF = message[position];
        sw2Trigger = 1;
    }

    P2IFG &= ~BIT3;
}
//-- End ISR_Port2_SW2

#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_A1(void) {
//    if (position == 0) {
//        if(sw1Trigger == 1){
//            UCA1TXBUF = message[position];
//        }else if (sw2Trigger == 1) {
//            UCA1TXBUF = message[position];
//        }
//    }
    if(sw1Trigger == 1){
        if(position+1 == sizeof(messageClosed)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            int i;
            for(i=0; i<20000; i++){}
            sw1Trigger = 0;
            sw2Trigger = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    } else if (sw2Trigger == 1) {
        if(position+1 == sizeof(messageOpen)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            int i;
            for(i=0; i<20000; i++){}
            sw1Trigger = 0;
            sw2Trigger = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    }

    UCA1IFG &= ~UCTXCPTIFG;
}
//-- END ISR_EUSCI_A1
