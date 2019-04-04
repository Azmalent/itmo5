#include <reg51.h>

typedef unsigned char uchar;

main()
{
	uchar a1, a0, b;
	
	a0 = P0 & 0x0F;
	a1 = P0 >> 4;
		
	b = (a1 << 3) + (a1 << 1) + a0;
	
	P1 = ((b/10) << 4) | (b % 10);
}