#include <msp430.h> 


/** W. Ward
 *  10/24/2021
 *  DIO Timers PWM Dimmer
 */


int period_T = 1049;
int duty_cycle = 250;
static const int min_duty_cycle = 100;
static const int max_duty_cycle = 500;
static const int step_size_duty_cycle = 50;


int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    // Ports
    P1DIR |= BIT0;              // Config P1.0 LED1 (Red) as out
    P1OUT |= BIT0;             // Init val = 1

    P6DIR |= BIT6;              // Config P6.6 LED2 (Green) as out
    P6OUT &= ~BIT6;             // Init val = 0

    P4DIR &= ~BIT1;             // Clear P4.1 (SW1) dir = in
    P4REN |= BIT1;              // Enable pull up/down res
    P4OUT |= BIT1;              // Make res pull up
    P4IES |= BIT1;              // Config IRQ H->L

    P2DIR &= ~BIT3;             // Clear P2.3 (SW2) dir = in
    P2REN |= BIT3;              // Enable pull up/down res
    P2OUT |= BIT3;              // Make res pull up
    P2IES |= BIT3;              // Config IRQ H->L

    PM5CTL0 &= ~LOCKLPM5;       // Enable GPIO

    // Timers
    // TB0
    TB0CTL |= TBCLR;            // Clear timer and divs
    TB0CTL |= TBSSEL__SMCLK;    // SRC = SMCLK
    TB0CTL |= MC__UP;           // Mode = UP
    TB0CTL |= CNTL_0;           // Length = 16-bit
    TB0CCR0 = period_T;         // CCR0 = 1000 (1 ms)
    TB0CCR1 = duty_cycle;       // CCR1 = 250 (25%)

    // IRQs
    // Ports
    P4IFG &= ~BIT1;             // Clear P4.1 IRQ flag
    P4IE |= BIT1;               // Enable P4.1 IRQ

    P2IFG &= ~BIT3;             // Clear P2.3 IRQ flag
    P2IE |= BIT3;               // Enable P2.3 IRQ

    // Timer Compare IRQ
    TB0CCTL0 |= CCIE;           // Enable TB0 CCR0 overflow IRQ
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
    TB0CCTL1 |= CCIE;           // Enable TB0 CCR1 overflow IRQ
    TB0CCTL1 &= ~CCIFG;         // Clear CCR1 flag

    __enable_interrupt();       // EN maskable IRQ

    while (1) {
    }
    return 0;
}

//-- Interrupt Service Routines -------------------------
// Service CCR0
#pragma vector = TIMER0_B0_VECTOR
__interrupt void ISR_TB0CCR0(void) {
    P1OUT |= BIT0;
    TB0CCTL0 &= ~CCIFG;         // Clear CCR0 flag
}
// Service CCR1
#pragma vector = TIMER0_B1_VECTOR
__interrupt void ISR_TB0CCR1(void) {
    TB0CCR1 = duty_cycle;
    P1OUT &= ~BIT0;
    TB0CCTL1 &= ~CCIFG;         // Clear CCR1 flag
}

// Service SW1
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_SW1(void) {
    if (duty_cycle < 500) {
        duty_cycle += 50;
    }
    P4IFG &= ~BIT1;
}

// Service SW2
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_SW2(void) {
    if (duty_cycle > 100) {
        duty_cycle -= 50;
    }
    P2IFG &= ~BIT3;
}
