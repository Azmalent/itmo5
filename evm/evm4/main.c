//(1+x)/(1-x)^2 ~ 1 + 3x + 5x^2 + 7x^3...
//(1+x)/(1-x)^2 ~ 1 + x(3 + x(5 + x(7)))
// S[0] = 7
// S[i] = a[i] + x * S[i-1]

#include <reg51.h>
#include <math.h>

typedef unsigned char uchar;

//1: float, 2: fixed with M = 100, 3: fixed with M = 2^8
#define MODE 3

#if MODE == 1
	float x, y;
#elif MODE == 2
	#define M 100
	uchar x, S;
	int Z;
	void Si(uchar ai)
	{
		S = ai + (x*S)/M;
	}
#elif MODE == 3
	#define M 0xFF
	uchar x, S;
	void Si(uchar ai)
	{
		S = ai + ((x * S) >> 8);
	}
#endif
	
main()
{
	while(1)
	{
		#if MODE == 1
			for(x = 0; x < 0.5; x += 0.01) 
			{
 				y = (1+x) / ((1-x)*(1-x));
			}
		#else
			for(x = 0; x < 50; x++)
			{
				S = 13*M;
				Si(11*M);
				Si(9*M);
				Si(7*M);
				Si(5*M);
				Si(3*M);
				Si(1*M);
				P0 = S;
			}
		#endif
	}
}