#include <msp430.h> 

/** W. Ward
 *  12/02/2021
 *  Project 2.5.3
 *
 *  516.096 steps per rev. accoding to tech. details of product listing on adafruit.com
 *  therefore to rotate 4 revolutions in 20 seconds requires:
 *  steps: 2064
 *  step-T: (18732*20sec)/2064steps: CCR0 = 181
 *  therefore to rotate 4 revolutions in 8 seconds requires:
 *  step-T: (18732*8sec)/2064steps: CCR0 = 73
 *
 *  Voltage Threshold:
 *  80mv <= person < 754mv
 *  754mv <= vehicle <= 2000mv
 *
 *
 */

// ADC
unsigned int ADC_Value;

// I2C
int dataCnt = 0;
int writeFlag = 1;
int packet_in_index = 0;
char packet_in[] = { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
char packet[] = { 0x03, 0x15, 0x26, 0x12, 0x19, 0x05, 0x11, 0x21 }; // 12:26:15 Friday 11/19/'21

// TimerB0 and StepperDriver
int gate_trigger = 0;
int open_gate = 0;
int close_gate = 0;
int active_coil = 0;
int timer_helper_counter = 0;
int gate_direction = 0;

// UART
char messageOpen[] = "\n\rGate was OPENED at: ";//"OPEN ";
char messageClosed[] = "\n\rGate was CLOSED at: ";//"CLOSED ";
char* message;
int seconds = 0;
unsigned int position;


int delay(int delay){
    int zzz;
    for(zzz=0; zzz<delay; zzz++){P1OUT |= BIT0; }
    P1OUT &= ~BIT0;
    return 0;
}
//-- END delay

int stepperPortsOff(void) {
    P3OUT &= ~BIT0;             // Init val = 0
    P3OUT &= ~BIT1;             // Init val = 0
    P3OUT &= ~BIT2;             // Init val = 0
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}
//-- END stepperPortsOff

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

int setDateTime(void){
    //-- Transmit data time to rtc via I2C
    while(writeFlag) {
        UCB0CTLW0 |= UCTXSTT;   // Genearte START condition
        delay(100);
    }
    return 0;
}
//-- END setDateTime

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

    //-- Take eUSCI_B0 out of SW reset
    UCB0CTLW0 &= ~UCSWRST;

    //-- Enable Interrupts
    UCB0IE |= UCTXIE0;          // Enable I2C Tx0 IRQ
    UCB0IE |= UCRXIE0;          // Enable I2C Rx0 IRQ
    // __enable_interrupt();       // Enable Maskable IRQs

    delay(1000);
    return 0;
}
//-- END configI2CRx

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

int openGate(void){

    // send gate open to security via UART
    recieveI2C();
    // send gate open to security    (only send if gate was closed)
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;
    message = messageOpen;
    UCA1TXBUF = message[position];
    open_gate = 1;
    while(open_gate){  delay(500); }
    sendSecondsViaUART();

    // drive stepper to open
    gate_trigger = 1;
    timer_helper_counter = 0;
    TB0CCR0 = 181;
    stepperPortsOff();
    while(1) {
        //timer_helper_counter = 2064;
        if(timer_helper_counter < 2064/4){ // change 12 to 1/4 # of steps to full
           switch(active_coil){
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
            gate_trigger = 0;
            TB0CCR0 = 18732;
            return 0;
        }
    }
}
//-- END openGate

int closeGate(void){

    // drive stepper to close
    gate_trigger = 1;
    timer_helper_counter = 0;
    TB0CCR0 = 73;
    stepperPortsOff();
    while(1) {
        //timer_helper_counter = 2064;
        if(timer_helper_counter < 2064/4){ // change 12 to 1/4 # of steps to full
           switch(active_coil){
           case 0:
               stepperPortsOff();
               P3OUT |= BIT3;
               break;
           case 1:
               P3OUT &= ~BIT3;
               P3OUT |= BIT2;
               break;
           case 2:
               P3OUT &= ~BIT2;
               P3OUT |= BIT1;
               break;
           case 3:
               P3OUT &= ~BIT1;
               P3OUT |= BIT0;
               break;
           }
        } else {
            stepperPortsOff();
            TB0CCR0 = 18732;
            gate_trigger = 0;
            return 0;
        }
    }
}
//-- END closeGate

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	    // stop watchdog timer

	//-- IO configuration

    // port config
    P1DIR |= BIT0;                  // Config P1.0 (LED1) as output RED
    P6DIR |= BIT6;                  // Config P6.0 (LED2) as output GRN
	
	// Config Stepper ports
    P3DIR |= BIT0;                  // Config P3.0 as out
    P3OUT &= ~BIT0;                 // Init val = 0
    P3DIR |= BIT1;                  // Config P3.1 as out
    P3OUT &= ~BIT1;                 // Init val = 0
    P3DIR |= BIT2;                  // Config P3.2 as out
    P3OUT &= ~BIT2;                 // Init val = 0
    P3DIR |= BIT3;                  // Config P3.3 as out
    P3OUT &= ~BIT3;                 // Init val = 0

    // Config P1.4 Pin for ADC A4
    P1SEL1 |= BIT4;
    P1SEL0 |= BIT4;

    // UART
    // Put eUSCI_A1 into software reset
    UCA1CTLW0 |= UCSWRST;

    // Baud Rate: 57600
    UCA1CTLW0 |= UCSSEL__SMCLK;
    UCA1BRW = 17;
    UCA1MCTLW |= 0x4A00;

    // Config UART Tx
    P4SEL1 &= ~BIT3;
    P4SEL0 |= BIT3;

    // Take eUSCU_A1 out of software reset
    UCA1CTLW0 &= ~UCSWRST;
    // END UART

    // I2C
    // Put eUSCI_B0 into sw reset
    UCB0CTLW0 |= UCSWRST;

    // Config eUSCI_B0
    UCB0CTLW0 |= UCSSEL_3;          // eUSCI clk is 1MHz
    UCB0BRW = 10;                   // Prescaler=10 to make SCLK=100kHz

    UCB0CTLW0 |= UCMODE_3;          // put into I2C mode
    UCB0CTLW0 |= UCMST;             // put into master mode
    UCB0CTLW0 |= UCTR;              // Put into Tx mode
    UCB0I2CSA = 0x0068;             // secondary 0x68 RTC

    UCB0CTLW1 |= UCASTP_2;          // Auto STOP when UCB0TBCNT reached
    UCB0TBCNT = sizeof(packet);     // # of Bytes in Packet

    // Config Ports
    P1SEL1 &= ~BIT3;                // P1.3 = SCL
    P1SEL0 |= BIT3;

    P1SEL1 &= ~BIT2;                // P1.2 = SDA
    P1SEL0 |= BIT2;
    // END I2C

    // Clear high-z
    PM5CTL0 &= ~LOCKLPM5;

    // Take eUSCI_B0 out of SW reset (I2C)
    UCB0CTLW0 &= ~UCSWRST;

	// TB0
    TB0CTL |= TBCLR;                // Clear timer and divs
    TB0CTL |= TBSSEL__SMCLK;        // SRC = SMCLK
    TB0CTL |= MC__UP;               // Mode = UP
    TB0CTL |= CNTL_0;               // Length = 16-bit
    TB0CTL |= ID__8;                // ste d1 to 8
    TB0EX0 |= TBIDEX__7;            // set d2 to 7
    TB0CCR0 = 18732;                // CCR0 = (1 s) w/ d2 = 7 1sec: 18732, .5sec = 9366 From pg 297 or TB

    // ADC config
    ADCCTL0 &= ~ADCSHT;             // Clear ADCSHT from def. of ADCSHT=01
    ADCCTL0 |= ADCSHT_2;            // Conversion Cycles = 16 (ADCSHT=10)
    ADCCTL0 |= ADCON;               // Turn on ADC

    ADCCTL1 |= ADCSSEL_2;           // ADC Clock Src = SMCLK
    ADCCTL1 |= ADCSHP;              // Sample signal source = sampling timer

    ADCCTL2 &= ~ADCRES;             // Clear ADCRES from def. of ADCRES=01
    ADCCTL2 |= ADCRES_0;            // Resolution = 8-bit (ADCRES=00)

    ADCMCTL0 |= ADCINCH_4;          // ADC Input Channel = A4 (P1.4)



    // IRQs
    // Timer Compare IRQ
    TB0CCTL0 |= CCIE;               // Enable TB0 CCR0 overflow IRQ
    TB0CCTL0 &= ~CCIFG;             // Clear CCR0 flag

    // ADC IRQ
    ADCIE |= ADCIE0;                // Enable ADC Conv Complete IRQ

    // I2C IRQ
    UCB0IE |= UCTXIE0;          // Enable I2C Tx0 IRQ

    __enable_interrupt();           // EN maskable IRQ

    //-- END IO configuration

    //-- main functionality

    setDateTime();                              // send initial date time to RTC via I2C

    configI2CRx();                              // config I2C to recieve via I2C after initial transmission

    while(1) {
        ADCCTL0 |= ADCENC | ADCSC;              // Enable and Start conversion
        __bis_SR_register(GIE | LPM0_bits);     // enable maskable interrupts and turn of cpu for LPM

        if (ADC_Value < 61) {                   // is there a person? x < 754mV
            P6OUT &= ~BIT6;                     // LED2 = OFF
        }else if (ADC_Value >= 61) {            // is there a car? x >= 754mV
            P6OUT |= BIT6;                      // LED2 = ON
            break;
        }
    }
    openGate();
    delay(20000);

    while(1) {
        ADCCTL0 |= ADCENC | ADCSC;              // Enable and Start conversion
        __bis_SR_register(GIE | LPM0_bits);     // enable maskable interrupts and turn of cpu for LPM

        if (ADC_Value < 61) {                   // is there a person?
            P6OUT &= ~BIT6;                     // LED2 = OFF
            break;
        }else if (ADC_Value >= 61) {            // is there a car?
            P6OUT |= BIT6;                      // LED2 = ON
        }
    }
    closeGate();

    // send gate closed to security via UART
    configI2CRx();
    recieveI2C();
    // send gate closed to security    (only send if gate was closed)
    UCA1IE |= UCTXCPTIE;
    UCA1IFG &= ~UCTXCPTIFG;
    message = messageClosed;
    UCA1TXBUF = message[position];
    close_gate = 1;
    while(close_gate){ delay(500); }
    sendSecondsViaUART();

    delay(20000);

    //-- END main functionality

	return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
// Service CCR0
#pragma vector = TIMER0_B0_VECTOR
__interrupt void ISR_TB0CCR0(void) {
    if(gate_trigger == 1){
        if(active_coil >= 3){
            active_coil = 0;
            timer_helper_counter++;
        } else {
            active_coil++;
        }
    }
    TB0CCTL0 &= ~CCIFG;                         // Clear CCR0 flag
}
//-- END ISR_TB0CCR0

// Service ADC
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    ADC_Value = ADCMEM0;                        // Read ADC value // 2.1v == 166 //3.0 == 236 @8-bit
    __bic_SR_register_on_exit(LPM0_bits);       // Wake up CPU
}

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
//-- END EUSCI_B0_I2C_ISR

//-- Service UART
#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_A1(void) {
    if(close_gate == 1){
        if(position+1 == sizeof(messageClosed)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            delay(20000);
            close_gate = 0;
            open_gate = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    } else if (open_gate == 1) {
        if(position+1 == sizeof(messageOpen)) { // dependent on sizeof(messsage) and name length/string
            UCA1IE &= ~UCTXCPTIE;
            delay(20000);
            close_gate = 0;
            open_gate = 0;
            position = 0;
        } else {
            position++;
            UCA1TXBUF = message[position];
        }
    } else if (seconds == 1) {
        UCA1IE &= ~UCTXCPTIE;
    }

    UCA1IFG &= ~UCTXCPTIFG;
}
//-- END ISR_EUSCI_A1
