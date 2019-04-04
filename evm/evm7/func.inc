SIGNAL void pwm (unsigned int Time) {
	char i;
	while(1)
	{        // формирование диаграммы кода 10101010 
		do{
			P3 = 0; twatch (3* Time); 
			P3 = 0x3f; twatch (2*Time); //0
			P3 = 0; twatch (1*Time); 
			P3 = 0x3f; twatch (1*Time); //1
			P3 = 0; twatch (2* Time); 
			P3 = 0x3f; twatch (2*Time); //0
			P3 = 0; twatch (1* Time); 
			P3 = 0x3f; twatch (1*Time); //1
			P3 = 0; twatch (2* Time); 
			P3 = 0x3f; twatch (2*Time); //0
			P3 = 0; twatch (1*Time); 
			P3 = 0x3f; twatch (1*Time); //1
			P3 = 0; twatch (2* Time); 
			P3 = 0x3f; twatch (2*Time); //0
			P3 = 0; twatch (1* Time); 
			P3 = 0x3f; twatch (1*Time); //1
			P3 = 0; twatch (2* Time); 
		} while(i--); 
		P3 = 0;

	}   
}
pwm(33)                  //запуск программы SIGNAL
La port3
