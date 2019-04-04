#include <reg515.h>

int avg;
unsigned int T, i, start, current;
unsigned char max,min;
float fmax;

unsigned char adc(void) 
{
	DAPR=0xA0;
	while(BSY);
	P2 = ADDAT;
	return P2;
} 

void main()
{
	max = 0; min = 0x70; // initialization of min/max values
	
	//find max and min on one period
	start = adc();
	while(i != 2) 
	{
		current = adc();
		if (start == current) i++;	//Y value is repeated twice on one period
		if (current > max) max = P2;
		if (current < min) min = P2;
	}

	avg = (max + min)/2; 
	/*----------------------------------------*/
	TMOD = 1;				// allow timer 0
	TH0 = TL0 = 0;	// reset timer
	TR0 = 0; 				// stop timer
	
	while(adc() >= avg); // wait until avg == increase
	while(adc() <= avg); // wait until avg == decrease

	TR0 = 1;	//start timer (1 mcs)
	while(adc() >= avg); // wait until avg == increase
	TR0 = 0;
	T = ((TH0 << 8) + TL0) << 1; // save period time

	fmax = max*5.0/0x100;
	while(1);
}