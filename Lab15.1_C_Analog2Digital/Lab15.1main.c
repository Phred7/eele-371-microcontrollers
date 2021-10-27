#include <msp430.h> 


/** W. Ward
 *  10/27/2021
 *  ADC
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	return 0;
}
