// Generates a sine wave Signal on AD Channel 0
SIGNAL void AIN0_Sin (void) 
{
	float x;
	char i;
	while (1) 
	{
		for(i=0; i<100; i++) 
		{
			AIN0 = __sin(x) * 2.5 + 2.5;
			twatch(100);
			x = x + 0.062;
		}
	}
} 
DEFINE BUTTON "AIN0 Sin","AIN0_sin()"