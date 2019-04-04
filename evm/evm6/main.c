#include <reg51.h>
unsigned short sec;
unsigned short count;
unsigned int min;

void intt0(void) interrupt 1 
{
	TR0 = 0;
	TH0 = (65535 - 50000) >> 8;
	TL0 = (65535 - 50000) & 0xFF;
	TR0 = 1;
	
	count++;
	if(count == 20) 
	{
		sec++;
		count = 0;
	} 
	if(sec == 60) 
	{
		min++;
		sec = 0;
	} 
	P1 = sec;
	P2 = min;
} 

void main() 
{
	TMOD = 1; 
	ET0 = 1;
	TR0 = 1;
	EA = 1;
	while(1);
}