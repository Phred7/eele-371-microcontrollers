#include <msp430.h> 


/**
 *  W. Ward
 *  11/03/2021
 *  Practical 15.1: ADC
 */

unsigned int ADC_Value;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	// port config
    P1DIR |= BIT0;                  // Config P1.0 (LED1) as output
    P6DIR |= BIT6;                  // Config P6.0 (LED2) as output

    P1SEL1 |= BIT2;                 // Config P1.2 Pin for A2... P1.1 can be configured to A1, P1.4 can be configured to A4
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

        while((ADCIFG & ADCIFG0) == 0); // wait for conv. complete

        if (ADC_Value < 1750) {         // less than 1v
            P1OUT &= ~BIT0;             // LED1 = OFF
            P6OUT &= ~BIT6;             // LED2 = OFF
        }else {
            P1OUT |= BIT0;              // LED1 = ON
            P6OUT |= BIT6;              // LED2 = ON
        }
    }

	return 0;
}
//-- END main

//--------------- ISRs ----------------------
#pragma vector=ADC_VECTOR
__interrupt void ADC_ISR(void){
    ADC_Value = ADCMEM0 - 15;               // Read ADC value
}
