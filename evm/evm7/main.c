//#include <reg51.h>
///typedef unsigned char uchar;
//uchar z, S;
///int i;
//uchar inv_x3;

//uchar computeS(uchar x1, uchar x2, uchar x3, uchar x4){
//		inv_x3 = 1-x3;
//    return (1-(1-inv_x3*x2)*(1-x4*(1-x1*x2)));
//}

//uchar computeZ(uchar x1, uchar x2, uchar x3, uchar x4){
//		return (!x3&x2|x4&(!x1|!x2));
//}

//void main() {
//    for(i = 0; i <16; i++) {
//			uchar x1 = i>>3&0x01;
//      uchar x2 = i>>2&0x01;
//      uchar x3 = i>>1&0x01;
//      uchar x4 = i>>0&0x01;
//		S = computeS(x1,x2,x3,x4);
//		z = computeZ(x1,x2,x3,x4);
//	}

//    while(1);
//}


#include <reg51.h>

char d[10];

char count;

unsigned int period,Pi0 = 0, Pi1; 

intt0() interrupt 0 

{ 
	TR1 = 0;
	Pi1 = (TH1<<8)| TL1;

	TR1 = 1; period = Pi1-Pi0; Pi0 = Pi1;  

	//if (count == 7) count = 0;
	if(TL0 <48) 
		d[count++] = '0';  

	if(TL0 >= 48) 
		d[count++] = '1';
	
	TL0 = 0; 
	TH0 = 0; 
	TR0 = 1;

}

void main(){
	count = 0;

	TMOD = 0x19;          

	P3=0;

	IT0 = 1;                     

	EX0 =1;                  

	EA = 1;                   

	TL1 = 0; TH1 = 0; TL0 = 0; TH0 = 0;

	TR0 = TR1 = 1;        		

	while( 1 );

}
