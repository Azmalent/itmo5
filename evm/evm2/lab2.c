#include <reg51.h>

//#define INDIRECT

#define LENGTH 43	//not including null terminator
#define FALSE 0
#define TRUE  1

char code  input[LENGTH+1] = "The quick brown fox jumps over the lazy dog";
char xdata output[LENGTH+1];

char timer, i, temp, swapped;

int main() 
{	
	for (i=0; i < LENGTH+1; i++)
	{
    output[i] = input[i];
	}

	timer = 80;
	do 
	{
		swapped = FALSE;
		for (i = 0; i < LENGTH-1; i++)
		{	
			#ifdef INDIRECT
			if (*(output + i+1) < *(output + i))
			{
				temp = *(output + i);
				*(output + i) = *(output + i+1);
				*(output + i+1) = temp;
				
				swapped = TRUE;
			}
			#else
			if (output[i+1] < output[i])
			{
				temp = output[i];
				output[i] = output[i+1];
				output[i+1] = temp;
				
				swapped = TRUE;
			}
			#endif
			
		}
		P2 = 0;
	} while(swapped);
	
	return 0;
}