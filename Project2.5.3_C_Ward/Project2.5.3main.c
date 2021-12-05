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

unsigned int ADC_Value;

int packet_in_index = 0;
char packet_in[] = { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };
char packet[] = { 0x03, 0x15, 0x26, 0x12, 0x19, 0x05, 0x11, 0x21 }; // 12:26:15 Friday 11/19/'21

int gate_trigger = 0;
int open_gate = 0;
int close_gate = 0;
int active_coil = 0;
int timer_helper_counter = 0;
int gate_direction = 0;

char messageOpen[] = "\n\rGate was OPENED at: ";//"OPEN ";
char messageClosed[] = "\n\rGate was CLOSED at: ";//"CLOSED ";
char* message;

int delay(int delay){
    int zzz;
    for(zzz=0; zzz<delay; zzz++){P1OUT |= BIT0; }
    P1OUT &= ~BIT0;
    return 0;
}

int stepperPortsOff(void) {
    P3OUT &= ~BIT0;             // Init val = 0
    P3OUT &= ~BIT1;             // Init val = 0
    P3OUT &= ~BIT2;             // Init val = 0
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}
//-- END stepperPortsOff

int openGate(void){
    gate_trigger = 1;
    gate_direction = 0;
    timer_helper_counter = 0;
    TB0CCR0 = 181;
    stepperPortsOff();
    while(1) {
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
            //TB0CCR0 = 18732;
            return 0;
        }
    }
}
//-- END openGate

int closeGate(void){
    gate_trigger = 1;
    gate_direction = 0;
    timer_helper_counter = 0;
    TB0CCR0 = 73;
    stepperPortsOff();
    while(1) {
        if(timer_helper_counter < 2064/4){ // change 12 to 1/4 # of steps to full
           switch(active_coil){
           case 0:
               stepperPortsOff();
               P3OUT |= BIT3;
               break;
           case 1:
               P3OUT &= ~BIT3;             // Init val = 0
               P3OUT |= BIT2;
               break;
           case 2:
               P3OUT &= ~BIT2;             // Init val = 0
               P3OUT |= BIT1;
               break;
           case 3:
               P3OUT &= ~BIT1;             // Init val = 0
               P3OUT |= BIT0;             // Init val = 0
               break;
           }
        } else {
            stepperPortsOff();
            //TB0CCR0 = 18732;
            gate_trigger = 0;
            return 0;
        }
    }
}
//-- END closeGate

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

    // port config
    P1DIR |= BIT0;                  // Config P1.0 (LED1) as output RED
    P6DIR |= BIT6;                  // Config P6.0 (LED2) as output GRN
	
	// Config Stepper ports
    P3DIR |= BIT0;              // Config P3.0 as out
    P3OUT &= ~BIT0;             // Init val = 0
    P3DIR |= BIT1;              // Config P3.1 as out
    P3OUT &= ~BIT1;             // Init val = 0
    P3DIR |= BIT2;              // Config P3.2 as out
    P3OUT &= ~BIT2;             // Init val = 0
    P3DIR |= BIT3;              // Config P3.3 as out
    P3OUT &= ~BIT3;             // Init val = 0

    // Config P1.4 Pin for A4
    P1SEL1 |= BIT4;
    P1SEL0 |= BIT4;

    // Clear high-z
    PM5CTL0 &= ~LOCKLPM5;

	// TB0
    TB0CTL |= TBCLR;            // Clear timer and divs
    TB0CTL |= TBSSEL__SMCLK;    // SRC = SMCLK
    TB0CTL |= MC__UP;           // Mode = UP
    TB0CTL |= CNTL_0;           // Length = 16-bit
    TB0CTL |= ID__8;        // ste d1 to 8
    TB0EX0 |= TBIDEX__7;    // set d2 to 7
    TB0CCR0 = 18732;         // CCR0 = (1 s) w/ d2 = 7 1sec: 18732, .5sec = 9366 From pg 297 or TB

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
    TB0CCTL0 |= CCIE;           // Enable TB0 CCR0 overflow IRQ
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag

    //ADC IRQ
    ADCIE |= ADCIE0;                // Enable ADC Conv Complete IRQ

    __enable_interrupt();       // EN maskable IRQ

    while(1) {
        ADCCTL0 |= ADCENC | ADCSC;      // Enable and Start conversion
        __bis_SR_register(GIE | LPM0_bits);     // enable maskable interrupts and turn of cpu for LPM

        if (ADC_Value < 61) {  // less than or equal to 2.3v 2854 (expected) error: ~+/- 50... ~.05v
            P1OUT &= ~BIT0;             // LED1 = OFF
        }else if (ADC_Value >= 61) {   // greater than 2.2v
            P1OUT |= BIT0;              // LED1 = ON
        }
    }

//    openGate();
//    delay(20000);
//    closeGate();

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
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
}
//-- END ISR_TB0CCR0

// Service ADC
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    ADC_Value = ADCMEM0;               // Read ADC value // 2.1v == 166 //3.0 == 236
    __bic_SR_register_on_exit(LPM0_bits);
}
