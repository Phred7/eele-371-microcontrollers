#include <msp430.h> 

/** W. Ward
 *  11/17/2021
 *  Project 2.2
 */

unsigned int ADC_Value;

int configADCA4(void) {
    // from lab 15.1
    // ADC config
    ADCCTL0 &= ~ADCSHT;             // Clear ADCSHT from def. of ADCSHT=01
    ADCCTL0 |= ADCSHT_2;            // Conversion Cycles = 16 (ADCSHT=10)
    ADCCTL0 |= ADCON;               // Turn on ADC

    ADCCTL1 |= ADCSSEL_2;           // ADC Clock Src = SMCLK
    ADCCTL1 |= ADCSHP;              // Sample signal source = sampling timer

    ADCCTL2 &= ~ADCRES;             // Clear ADCRES from def. of ADCRES=01
    ADCCTL2 |= ADCRES_2;            // Resolution = 12-bit (ADCRES=10)

//    ADCMCTL0 |= ADCINCH_4;          // ADC Input Channel = A2 (P1.2)
    ADCMCTL0 |= ADCINCH_6;          // ADC Input Channel = A2 (P1.2)

    ADCIE |= ADCIE0;                // Enable ADC Conv Complete IRQ
    return 0;
}
//-- END configADCA4

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // port config
    P1DIR |= BIT0;                  // Config P1.0 (LED1) as output

    // Config P1.4 Pin for A4
//    P1SEL1 |= BIT4;
//    P1SEL0 |= BIT4;

    P1SEL1 |= BIT6;                 // Config P1.2 Pin for A2
    P1SEL0 |= BIT6;

    // Clear high-z
    PM5CTL0 &= ~LOCKLPM5;

    configADCA4();

    // IRQs

    __enable_interrupt();

    while(1) {
        ADCCTL0 |= ADCENC | ADCSC;      // Enable and Start conversion
        // __bis_SR_register(GIE | LPM0_bits);     // put CPU to sleep???

        while((ADCIFG & ADCIFG0) == 0) {}; // wait for conv. complete

        if (ADC_Value <= 2925) {  // less than or equal to 2.3v 2854 (expected) error: ~+/- 50... ~.05v
            P1OUT &= ~BIT0;             // LED1 = OFF
        }else if (ADC_Value > 2925) {   // greater than 2.2v
            P1OUT |= BIT0;              // LED1 = ON
        }
    }
    return 0;
}
//-- END main

//-- Interrupt Service Routines -------------------------
// Service ADC
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    // __bic_SR_register(GIE | LPM0_bits);     // wake up CPU
    ADC_Value = ADCMEM0;               // Read ADC value
}
