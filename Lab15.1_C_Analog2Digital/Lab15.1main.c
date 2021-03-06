#include <msp430.h> 


/**
 *  W. Ward
 *  10/27/2021
 *  ADC
 */

unsigned int ADC_Value;

/**
 * main
 *      Expected    Actual
 * 0v   0d          25d
 * .5v  621d        632d
 * 1v   1241d       1260d
 * 2v   2482d       2517d
 * 3v   3723d       3751d
 *
 * Low range: less than 1V
 * Mid range: between 1V and 1.6V
 * High range: between 1.6V and 2.2V
 * Extreme range: greater than 2.2V
 *
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	// port config
    P1DIR |= BIT0;                  // Config P1.0 (LED1) as output
    P6DIR |= BIT6;                  // Config P6.0 (LED2) as output

    P1SEL1 |= BIT2;                 // Config P1.2 Pin for A2
    P1SEL0 |= BIT2;

    PM5CTL0 &= ~LOCKLPM5;           // Clear high-z

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

    __enable_interrupt();           // Enable Maskable IRQs

    while(1) {
        ADCCTL0 |= ADCENC | ADCSC;      // Enable and Start conversion
        // __bis_SR_register(GIE | LPM0_bits);     // put CPU to sleep???

        while((ADCIFG & ADCIFG0) == 0); // wait for conv. complete

        if (ADC_Value < 1250) {         // less than 1v
            P1OUT &= ~BIT0;             // LED1 = OFF
            P6OUT &= ~BIT6;             // LED2 = OFF
        }else if (ADC_Value < 1980) {   // less than 1.6v
            P1OUT &= ~BIT0;             // LED1 = OFF
            P6OUT |= BIT6;              // LED2 = ON
        }else if (ADC_Value <= 2745) {  // less than or equal to 2.2v
            P1OUT |= BIT0;              // LED1 = ON
            P6OUT &= ~BIT6;             // LED2 = OFF
        }else if (ADC_Value > 2745) {   // greater than 2.2v
            P1OUT |= BIT0;              // LED1 = ON
            P6OUT |= BIT6;              // LED2 = ON
        }
    }

    return 0;
}

//--------------- ISRs ----------------------
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    // __bic_SR_register(GIE | LPM0_bits);     // wake up CPU
    ADC_Value = ADCMEM0 - 15;               // Read ADC value
}
