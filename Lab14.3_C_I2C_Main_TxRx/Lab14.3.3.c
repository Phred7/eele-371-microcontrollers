#include <msp430.h> 

/** W. Ward
 *  11/14/2021
 *  I2C Main Tx + Rx.
 */

int dataCnt = 0;
int writeFlag = 1;
int packet_in_index = 0;
char packet_in[] = { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
char packet[] = { 0x03, 0x15, 0x26, 0x10, 0x14, 0x00, 0x11, 0x21 }; // 10:26:15 Sunday 11/14/'21


//-- functions
int configSetDateTime(void) {

    //-- Put eUSCI_B0 into sw reset
    UCB0CTLW0 |= UCSWRST;

    //-- Config eUSCI_B0
    UCB0CTLW0 |= UCSSEL_3;       // eUSCI clk is 1MHz
    UCB0BRW = 10;               // Prescaler=10 to make SCLK=100kHz

    UCB0CTLW0 |= UCMODE_3;      // put into I2C mode
    UCB0CTLW0 |= UCMST;         // put into master mode
    UCB0CTLW0 |= UCTR;           // Put into Tx mode
    UCB0I2CSA = 0x0068;         // secondary 0x68 RTC

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
    return 0;
}

int configRx(void) {
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
    return 0;
}

int recieve(void) {
    //-- Transmit Reg Addr with Write MSG
    UCB0TBCNT = 0x01;       // send 1 byte of data
    UCB0CTLW0 |= UCTR;      // put int o Tx mode
    UCB0CTLW0 |= UCTXSTT;   // generate START cond.

    while ((UCB0IFG & UCSTPIFG) == 0 ); // wait for STOP
        UCB0IFG &= ~UCSTPIFG;           // clear STOP flag

    //--Recieve data from Rx
    UCB0TBCNT = 0x07;           // rx 8 bytes of data
    packet_in_index = 0;
    UCB0CTLW0 &= ~UCTR;     // Put into Rx mode
    UCB0CTLW0 |= UCTXSTT;   // Generate START cond.

    while ((UCB0IFG & UCSTPIFG) == 0 ); //wait for STOP
        UCB0IFG &= ~UCSTPIFG;           // clear STOP flag
    return 0;
}

int main(void) {

    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    configSetDateTime();

    int i;
    while(writeFlag) {
        UCB0CTLW0 |= UCTXSTT;   // Genearte START condition
        for(i=0; i<100; i=i+1){} //delay loop
    }

    configRx();

    int j;
    for(j=0; j<1000; j++){}

    while(1){
        recieve();
    }

    return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
#pragma vector = EUSCI_B0_VECTOR
__interrupt void  EUSCI_B0_I2C_ISR(void){
    if (writeFlag == 1) {
        if (dataCnt == (sizeof(packet) - 1)) {
            UCB0TXBUF = packet[dataCnt];
            UCB0IFG &= ~UCTXIFG0;
            dataCnt = 0;
            writeFlag = 0;
        } else {
            UCB0TXBUF = packet[dataCnt];
            dataCnt++;
        }
    } else if (writeFlag == 0) {
        switch(UCB0IV){
        case 0x16:                  // Id 16 rxifg0
            packet_in[packet_in_index] = UCB0RXBUF;     // retrieve data
            packet_in_index++;
            break;
        case 0x18:                  // id 18 txifg0
            // for(int j = 0; j<(sizeof(packet) - 1))
            UCB0TXBUF = 0x03;       // send reg addr (ask 2ndary for num seconds)
            break;
        default:
            break;
        }
    }
}
