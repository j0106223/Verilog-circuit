# Servo Motor(SG90) Control
控制伺服馬達 型號為SG90
參數皆可調

parameter miniPluse 	= 500;			//500us 	0.5ms
parameter maxPluse 	= 2400;			//2400us	2.4ms 
parameter cycle		= 20000;       //20000us 20ms
parameter clkValue 	= 100_000_000;	//100MHZ would choose Avalon salve interfac's system clk
parameter usValue    = 1_000_000;
parameter cycleCnt			= clkValue / usValue * cycle; 		//200w 	clk
parameter miniPluseCnt 		= clkValue / usValue * miniPluse;	//5w	   clk
parameter angelPluseUnit 	= clkValue / usValue * (maxPluse - miniPluse) / 180;// 1055 clk


miniPluse為最小脈波寬度單位為us

maxPluse為最大脈波寬度單位為us

cycle為伺服馬達的控制週期應為20ms 換成us就是20000us

clkValue為石英震盪器輸入的時脈

usValue為10^-6 取倒數

cycleCnt給clk計算週期脈波寬度的

miniPluseCnt給clk計算最小脈波寬度

angelPluseUnit給clk計算該角度到底該輸出多寬的脈波

最後Control為pwm輸出腳位
