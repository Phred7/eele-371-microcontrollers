#include <msp430.h> 

/** W. Ward
 *  11/17/2021
 *  Project 2.1
 */

int ADC_Value = 0;
int running = 0;
int count = 0;
int led = 0;
int direction = 0;
int switch_triggered = 0;

int configSW1(void) {
    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES |= BIT1;              // Config IRQ H->L
    return 0;
}
//-- END configSW1

int configSW2(void) {
    P2DIR &= ~BIT3;             // Clear P2.3 (SW2) dir = in
    P2REN |= BIT3;              // Enable pull up/down res
    P2OUT |= BIT3;              // Make res pull up
    P2IES |= BIT3;              // Config IRQ H->L
    return 0;
}
//-- END configSW2

int configLEDs(void) { // Green
    P3DIR |= BIT0;              // Config P6.6 LED2 (Green) as out
    P3OUT &= ~BIT0;             // Init val = 0
    P3DIR |= BIT1;              // Config P6.6 LED2 (Green) as out
    P3OUT &= ~BIT1;             // Init val = 0
    P3DIR |= BIT2;              // Config P6.6 LED2 (Green) as out
    P3OUT &= ~BIT2;             // Init val = 0
    P3DIR |= BIT3;              // Config P6.6 LED2 (Green) as out
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}
//-- END configLEDs

int ledsOff(void) {
    P3OUT &= ~BIT0;             // Init val = 0
    P3OUT &= ~BIT1;             // Init val = 0
    P3OUT &= ~BIT2;             // Init val = 0
    P3OUT &= ~BIT3;             // Init val = 0
    return 0;
}

int configADCA2(void) {
    // from lab 15.1
    // ADC config
    ADCCTL0 &= ~ADCSHT;             // Clear ADCSHT from def. of ADCSHT=01
    ADCCTL0 |= ADCSHT_2;            // Conversion Cycles = 16 (ADCSHT=10)
    ADCCTL0 |= ADCON;               // Turn on ADC

    ADCCTL1 |= ADCSSEL_2;           // ADC Clock Src = SMCLK
    ADCCTL1 |= ADCSHP;              // Sample signal source = sampling timer

    ADCCTL2 &= ~ADCRES;             // Clear ADCRES from def. of ADCRES=01
    ADCCTL2 |= ADCRES_2;            // Resolution = 12-bit (ADCRES=10)

    ADCMCTL0 |= ADCINCH_2;          // ADC Input Channel = A2 (P1.2)

    ADCIE |= ADCIE0;                // Enable ADC Conv Complete IRQ
    return 0;
}
//-- END configADCA2

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

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    configLEDs();

    configSW1();
    configSW2();

    // Config P1.2 Pin for A2
    P1SEL1 |= BIT2;
    P1SEL0 |= BIT2;

    // Clear high-z
    PM5CTL0 &= ~LOCKLPM5;

    configADCA2();
    configTimerB0();

    // IRQs
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag (SW1)
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag (SW2)
    P2IE |= BIT3;               // Enable P2.3 IRQ

    configTimerB0CompareIRQ();  // Overflow IRQ for CCR0 and CCR1

    __enable_interrupt();

    while(1) {
        if(switch_triggered == 1){
            if(count < 12){
                ledsOff();
               switch(led){
               case 0:
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
               case 4:
                   break;
               }
            } else {
                switch_triggered = 0;
                count = 0;
            }
        }else{
            ledsOff();
        }
    }

    return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
// Service CCR0 L13.2 PWM
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

// Service ADC A2 L15.1
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    ADC_Value = ADCMEM0 - 15;               // Read ADC value
}

// Service SW1
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    if(switch_triggered == 0){
        TB0CCR0 = 18732;
        count = 0;
        led = 0;
        direction = 0;
        switch_triggered = 1;
    }

    P4IFG &= ~BIT1;             // Clear SW1 flag
}

// Service SW2
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {
    if(switch_triggered == 0){
        TB0CCR0 = 9366;
        count = 0;
        led = 4;
        switch_triggered = 1;
        direction = 1;
    }
    P2IFG &= ~BIT3;             // Clear SW2 flag
}
