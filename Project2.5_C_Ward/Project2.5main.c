#include <msp430.h> 
//#include <stdio.h>

/** W. Ward
 *  11/22/2021
 *  Project 2.5
 *
 *  2052 steps per rev. accoding to tech. details of product listing on adafruit.com
 */

unsigned int ADC_Value;
int dataCnt = 0;
int writeFlag = 1;
int packet_in_index = 0;
char packet_in[] = { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
char packet[] = { 0x03, 0x15, 0x26, 0x12, 0x19, 0x05, 0x11, 0x21 }; // 12:26:15 Friday 11/19/'21
char messageOpen[] = "\n\rGate was OPENED at: ";//"OPEN ";
char messageClosed[] = "\n\rGate was CLOSED at: ";//"CLOSED ";
char* message;
int openTrigger = 0;
int closedTrigger = 0;
int seconds = 0;
int sec_len = 0;
unsigned int position;
unsigned int message_length;
int running = 0;
int count = 0;
int led = 0;
int direction = 0;
int switch_triggered = 0;

int delay(int delay){
    int zzz;
    for(zzz=0; zzz<delay; zzz++){}
    return 0;
}

int initStepperDriverPorts(void){
    P3DIR |= BIT0;              // Config P3.0 as out
    P3OUT &= ~BIT0;             // Init val = 0
    P3DIR |= BIT1;              // Config P3.1 as out
    P3OUT &= ~BIT1;             // Init val = 0
    P3DIR |= BIT2;              // Config P3.2 as out
    P3OUT &= ~BIT2;             // Init val = 0
    P3DIR |= BIT3;              // Config P3.3 as out
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}
//-- END initStepperDriverPorts

int stepperPortsOff(void) {
    P3OUT &= ~BIT0;             // Init val = 0
    P3OUT &= ~BIT1;             // Init val = 0
    P3OUT &= ~BIT2;             // Init val = 0
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}
//-- END stepperPortsOff

int configTimerB0(void) {
    // TB0
    TB0CTL |= TBCLR;            // Clear timer and divs
    TB0CTL |= TBSSEL__SMCLK;    // SRC = SMCLK
    TB0CTL |= MC__UP;           // Mode = UP
    TB0CTL |= CNTL_0;           // Length = 16-bit
    TB0CTL |= ID__8;        // ste d1 to 8
    TB0EX0 |= TBIDEX__7;    // set d2 to 7
    TB0CCR0 = 18732;         // CCR0 = (1 s) w/ d2 = 7 1sec: 18732, .5sec = 9366 From pg 297 or TB
    return 0;
}
//-- END configTimerB0

int configTimerB0CompareIRQ(void) {
    // Timer Compare IRQ
    TB0CCTL0 |= CCIE;           // Enable TB0 CCR0 overflow IRQ
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
    return 0;
}
//-- END configTimerB0CompareIRQ

int configADCA6(void) {
    // ADC config
    ADCCTL0 &= ~ADCSHT;             // Clear ADCSHT from def. of ADCSHT=01
    ADCCTL0 |= ADCSHT_2;            // Conversion Cycles = 16 (ADCSHT=10)
    ADCCTL0 |= ADCON;               // Turn on ADC

    ADCCTL1 |= ADCSSEL_2;           // ADC Clock Src = SMCLK
    ADCCTL1 |= ADCSHP;              // Sample signal source = sampling timer

    ADCCTL2 &= ~ADCRES;             // Clear ADCRES from def. of ADCRES=01
    // ADCCTL2 |= ADCRES_0;            // Resolution = 8-bit (ADCRES=00)
    ADCCTL2 |= ADCRES_2;            // Resolution = 12-bit (ADCRES=10)

    ADCMCTL0 |= ADCINCH_6;          // ADC Input Channel = A4 (P1.6)

    ADCIE |= ADCIE0;                // Enable ADC Conv Complete IRQ
    return 0;
}
//-- END configADCA6

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
    return 0;
}
//-- END configSetDateTime

int configI2CRx(void) {
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
//-- END configI2CRx

int enableI2C(void){
    UCB0IE |= UCTXIE0;          // Enable I2C Tx0 IRQ
    UCB0IE |= UCRXIE0;          // Enable I2C Rx0 IRQ
    return 0;
}

int disableI2C(void){
    UCB0IE &= ~UCTXIE0;          // Enable I2C Tx0 IRQ
    UCB0IE &= ~UCRXIE0;          // Enable I2C Rx0 IRQ
    return 0;
}

int recieveI2C(void) {
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
//-- END recieveI2C

int configUART(void){
    //-- 1. Put eUSCI_A1 into software reset
    UCA1CTLW0 |= UCSWRST;

    //--Baud Rate: 57600
    UCA1CTLW0 |= UCSSEL__SMCLK;
    UCA1BRW = 17;
    UCA1MCTLW |= 0x4A00;

    //-- Config UART Tx
    P4SEL1 &= ~BIT3;
    P4SEL0 |= BIT3;

    //--4. Take eUSCU_A1 out of software reset
    UCA1CTLW0 &= ~UCSWRST;
    return 0;
}
//-- END configUART

int setDateTime(void){
    //-- Transmit data time to rtc via I2C
    while(writeFlag) {
        UCB0CTLW0 |= UCTXSTT;   // Genearte START condition
        delay(100);
    }
    return 0;
}
//-- END setDateTime

int openGate(void){
    switch_triggered = 1;
    stepperPortsOff();
    while(1) {
        if(count < 4){
           switch(led){
           case 0:
               stepperPortsOff();
               P3OUT |= BIT0;
               break;
           case 1:
               P3OUT &= ~BIT0;             // Init val = 0
               P3OUT |= BIT1;
               break;
           case 2:
               P3OUT &= ~BIT1;             // Init val = 0
               P3OUT |= BIT2;
               break;
           case 3:
               P3OUT &= ~BIT2;             // Init val = 0
               P3OUT |= BIT3;             // Init val = 0
               break;
           }
        } else {
            stepperPortsOff();
            switch_triggered = 0;
            break;
        }
    }
    return 0;
}

int convertSecCharToInt(char sec){
    return 10;
}
//-- END convertSecCharToInt

int sendSecondsViaUART(void){
    seconds = 1;
    UCA1TXBUF = ((packet_in[0] & 0xF0)>>4) + '0';    // Prints the 10s digit
    delay(500);
    seconds = 1;
    UCA1TXBUF = (packet_in[0] & 0x0F) + '0';     // Prints the 1s digit
    delay(500);
    seconds = 1;
    UCA1TXBUF = '\n';                           //  Newline character
    delay(500);
    seconds = 1;
    UCA1TXBUF = '\r';                           // Carriage return (align-L)
    delay(500);
    return 0;
}
//-- END sendSecondsViaUART

//-- END openGate
int closeGate(void){
    // make it so that close counts backwards and and open counts forward.
    return 0;
}

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	// port config
	P1DIR |= BIT0;                  // Config P1.0 (LED1) as output

    // Config P1.6 Pin for A6
    P1SEL1 |= BIT6;
    P1SEL0 |= BIT6;

    initStepperDriverPorts();
    configUART();

    // Clear high-z
    PM5CTL0 &= ~LOCKLPM5;

    configADCA6();
    configTimerB0();

    // IRQs
    configTimerB0CompareIRQ();  // Overflow IRQ for CCR0 and CCR1
    configSetDateTime();
    __enable_interrupt();

    setDateTime();              // Transmit initial date/time

    configI2CRx();

    delay(1000);

    // If ADC senses a car
    // Open Gate:
    //      Get time via I2C
    //      Send to security via UART
    //      Run stepper driver until open
    //      Wait for car no longer be sensed by ADC
    //      Run stepper driver until closed
    //      Get time via I2C
    //      Send to security via UART

    while(1) {
        disableI2C();
        while(1){

            ADCCTL0 |= ADCENC | ADCSC;      // Enable and Start conversion

            while((ADCIFG & ADCIFG0) == 0); // wait for conv. complete

            if (ADC_Value <= 2925) {  // less than or equal to 2.3v 2854 (expected) error: ~+/- 50... ~.05v
                P1OUT |= BIT0; // ON
                // does not detect car
            }else if (ADC_Value > 2925) {   // greater than 2.3v
                // detects car
                P1OUT &= ~BIT0;
            }
        }
        enableI2C();
            // get time and date
//            recieveI2C();
//
//            // send gate open to security    (only send if gate was closed)
//            UCA1IE |= UCTXCPTIE;
//            UCA1IFG &= ~UCTXCPTIFG;
//            message = messageOpen;
//            UCA1TXBUF = message[position];
//            openTrigger = 1;
//            while(openTrigger){  delay(500); }
//            sendSecondsViaUART();
//
//
//            // open gate
//            openGate();         // if opening and car is no longer detected stop opening and close the gate.
//
//            // wait for car to not be there anymore
//            while(1){
//                ADCCTL0 |= ADCENC | ADCSC;      // Enable and Start conversion
//                //__bic_SR_register(GIE | LPM0_bits);
//
//                while((ADCIFG & ADCIFG0) == 0); // wait for conv. complete
//
//                if (ADC_Value <= 2925) {  // less than or equal to 2.3v 2854 (expected) error: ~+/- 50... ~.05v
//                    // does not detect car
//                    P1OUT &= ~BIT0;
//                    break;
//                }else if (ADC_Value > 2925) {   // greater than 2.3v
//                    // detects car
//                    P1OUT |= BIT0;
//                }
//            }
//
//            // close gate
//            closeGate();    // (only send if gate was open (at all))
//
//            // get time and date
//            recieveI2C();
//
//            // send gate closed to security
//            UCA1IE |= UCTXCPTIE;
//            UCA1IFG &= ~UCTXCPTIFG;
//            message = messageClosed;
//            UCA1TXBUF = message[position];
//            closedTrigger = 1;
//            while(closedTrigger){ delay(500); }
//            sendSecondsViaUART();
        delay(20000);
    }

	return 0;

}
//-- END main

//-- Interrupt Service Routines -------------------------
// Service ADC
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    //__bic_SR_register(GIE | LPM0_bits);
    ADC_Value = ADCMEM0;               // Read ADC value+
    __bic_SR_register_on_exit(LPM0_bits | GIE); // Exit CPU, clear interrupts
}
//-- END ADC_ISR

//-- Service TB0 CCR0
#pragma vector = TIMER0_B0_VECTOR
__interrupt void ISR_TB0CCR0(void) {
    if(switch_triggered == 1){
        if(direction == 0){
            if(led >= 3){
                led = 0;
                count++;
            } else {
                led++;
            }
        } else {
            if(led <= 0){
               led = 4;
               count++;
           } else {
               led--;
           }
        }


    }
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
}
//-- END ISR_TB0CCR0

//-- Service I2C
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

//-- Service UART
#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_A1(void) {
    if(closedTrigger == 1){
        if(position+1 == sizeof(messageClosed)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            delay(20000);
            closedTrigger = 0;
            openTrigger = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    } else if (openTrigger == 1) {
        if(position+1 == sizeof(messageOpen)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            delay(20000);
            closedTrigger = 0;
            openTrigger = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    } else if (seconds == 1) {
        UCA1IE &= ~UCTXCPTIE;
    }
//        if(position+1 == sec_len) { // dependent on sizeof(messsage) and name length/string
//            UCA1IE &= ~UCTXCPTIE;
//            delay(20000);
//            seconds = 0;
//            position = 0;
//        } else {
//            position++;
//            UCA1TXBUF = message[position];
//        }

    UCA1IFG &= ~UCTXCPTIFG;
}
//-- END ISR_EUSCI_A1

