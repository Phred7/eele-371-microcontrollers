#include <msp430.h> 

/** W. Ward
 *  12/02/2021
 *  Project 2.5.3
 */

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	return 0;
}
