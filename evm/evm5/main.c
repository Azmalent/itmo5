#include <reg51.h>

unsigned char bdata mem;
sbit x1 = mem ^ 3;
sbit x2 = mem ^ 2; 
sbit y1 = mem ^ 1;
sbit y2 = mem ^ 0;

unsigned char rx1, rx2, ry1, ry2, qx1, qx2;
unsigned char res1, res2;

unsigned short vec1, vec2;

main()
{   
	for (mem = 0x00; mem < 0x10; mem++)
	{
		rx1 = (char) x1;
		rx2 = (char) x2;
		ry1 = (char) y1;
		ry2 = (char) y2;
		qx1 = 1 - rx1;
		qx2 = 1 - rx2;
		
		res1 = ((!x1) & y1 | x2 & y2) & ((!y1) | x2);
		res2 = (1 - (1 - ry1*qx1)*(1 - ry2*rx2)) * (1 - ry1*qx2);
		
		vec1 = (vec1 << 1) | res1;
		vec2 = (vec2 << 1) | res2;
	}
	while(1);
}