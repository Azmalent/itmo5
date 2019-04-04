#include <reg51.h>

unsigned int mul(char a, char b)
{
	int r;
	char m, i, j;
	int s = 0; // S = A*B
	
	m = 0x80; // m = 1000 0000

	for(i = 1; i <= 8; i++)
	{
		r = 0; // r = A*Bi*2^(i)

		if ((b&m) != 0)
		{
			r = a;
			r <<= 8;

			for (j = 0; j < i; j++)
			{
				r = (r>>1)&0x7FFF; // R = A*2^(i)
			}
		}
		
		s = s + r; // Si+1 = Si + A*Bi*2^(i)
		m = (m>>1)&0x7F; // for next bit
	}
	return s;
}

char div(unsigned int s, char a)
{
	int r;
	char b, m, j, i;

	b = 0x0; // B = S/A
	m = 0x80; 
	
	for(i = 1; i <= 8; i++)
	{
		r = a; 
		r <<= 8;
		for (j = 0; j < i; j++) 
		{
			r = (r>>1)&0x7FFF; // R = A*2^(-i)
		}

		if (s >= r) 
		{
			b += m; //Bi = 1
			P0 = b;
			s -= r; // S = S - A*2^(-i)
			
			if (s == 0) break;
		}
		m = (m>>1)&0x7F; // for next bit
	}
	return b;
}

void main() 
{
	int s;
	char a, b;

	a = P1; // A = 0001 1000
	b = P2; // B = 0110 0000
	s = mul(a, b);// S = 0000 1001
	b = div(s, a);
	P0 = b;
} 