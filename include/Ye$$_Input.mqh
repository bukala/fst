struct SIG{    // Buy, Sell  СИГНАЛЫ 
   double New,Stp,Prf;  // цена сигнала, цены ордеров
   }; 
SIG Sel,Buy;

void Input(){ // Ф И Л Ь Т Р Ы    В Х О Д А    ///////////////////////////////////////////////////////
   if (BUY && SELL) return;
   Signal(1,TR,TRk,1); // Signal (int SigMode, int SigType, int Sk, int bar) = Расчет направления тренда
   if (TR<0)   {int k=Up; Up=Dn; Dn=k;} // реверснем сигналы
   SIG_LINES(Up, "TrUp", Dn, "TrDn", clrGreen);
   bool TrUp=(Up && !BUY);  
   bool TrDn=(Dn && !SELL);
   if (!TrUp && !TrDn) return;  
   
   Signal(2,IN,Ik,1); // Signal (int SigMode, int SigType, int Sk, int bar) // Обработка сигналов входа  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   if (IN<0)   {int k=Up; Up=Dn; Dn=k;} // реверснем сигналы
   SIG_LINES(Up, "SigUp", Dn, "SigDn", clrMediumSeaGreen);
   Up=(Up && TrUp); 
   Dn=(Dn && TrDn);  
   if (!Up && !Dn) return; // Print(" Up=",Up," Dn=",Dn);   
   double STOP=0, PROFIT=0, DELTA=0, 
      OrdLim=NormalizeDouble(ATR*7,Digits),
      StpLim=NormalizeDouble(ATR*8,Digits); // максимальный стоп ограничим в 7.5 часовых ATR. 60/Period()-нормализация ATR к часовкам, чтобы на всех ТФ максимальный стоп был примерно одинаковым
   switch (Iprice){  // расчет цены входов: 
      case  1:  // по рынку, все расчеты через ATR          
         STOP  =NormalizeDouble(ATR*MathPow((S+2),1.8)*0.1,Digits);  // 0.7ATR  1.2ATR  1.8ATR  2.5ATR  3.3ATR  4.2ATR  5.2ATR  6.3ATR  7.5ATR
         PROFIT=NormalizeDouble(ATR*MathPow((P+2),1.8)*0.1,Digits);  // 0.7ATR  1.2ATR  1.8ATR  2.5ATR  3.3ATR  4.2ATR  5.2ATR  6.3ATR  7.5ATR 
         if (D!=0) DELTA=NormalizeDouble(ATR*MathPow((MathAbs(D)+2),1.8)*0.1,Digits);  // 0.7ATR  1.2ATR  1.8ATR  2.5ATR  3.3ATR 
         if (D<0) DELTA*=-1; 
         if (Up>0) {Buy.New =Open[0]+Spred+DELTA;   Buy.Stp =Buy.New-STOP;    if (P>0 && P<10) Buy.Prf =Buy.New +PROFIT;}  // ask и bid формируем из Open[0],
         if (Dn>0) {Sel.New=Open[0]-DELTA;         Sel.Stp=Sel.New+STOP;   if (P>0 && P<10) Sel.Prf=Sel.New-PROFIT;} // чтоб отложники не зависели от шустрых движух   
      break;
      case  2: // по ФИБО уровням       
         if (Up>0){
            Buy.New =Fibo( D);  
            Buy.Stp =Fibo( D-S); 
            if (MathAbs(Buy.New-Open[0])>OrdLim) Buy.New=0; // чтобы ордер не уходил далеко
            if (Buy.New-Buy.Stp>StpLim) Buy.Stp=Buy.New-StpLim; // проверка стопа на дальность
            if (P>0 && P<10){
               Buy.Prf =Fibo( D+P);
               if (Buy.Prf-Buy.New>StpLim) Buy.Prf=Buy.New+StpLim;  // проверка профита на дальность
            }  }   
         if (Dn>0){
            Sel.New=Fibo(-D);  
            Sel.Stp=Fibo(-D+S); //Print("Sel.New=",Sel.New," Sel.Stp=",Sel.Stp, " OrdLim=",OrdLim," Sel.New-Open[0]=",Sel.New-Open[0]," Open[0]-Sel.New=",Open[0]-Sel.New);
            if (MathAbs(Sel.New-Open[0])>OrdLim) Sel.New=0; // чтобы ордер не уходил далеко
            if (Sel.Stp-Sel.New>StpLim) Sel.Stp=Sel.New+StpLim; // проверка стопа на дальность  
            if (P>0 && P<10){
               Sel.Prf=Fibo(-D-P);
               if (Sel.New-Sel.Prf>StpLim) Sel.Prf=Sel.New-StpLim;  // проверка профита на дальность
            }  }    
      break;
      }             
   if (Buy.New>0){  // 
      if (Del==1){   // при появлении нового сигнала удаляем старый ордер;       Print("Buy=",Buy," BUYSTOP=",BUYSTOP," Buy-BUYSTOP=",Buy-BUYSTOP," StopLevel=",StopLevel);
         if (BUYSTOP>0  && MathAbs(Buy.New-BUYSTOP)>StopLevel && BUYSTOP!=RevBUY)  BUYSTOP=0;     // если старый ордер далеко от нового
         if (BUYLIMIT>0 && MathAbs(Buy.New-BUYLIMIT)>StopLevel)                    BUYLIMIT=0;     // то удаляем его, если нет, оставим
         }
      if (Del==2){   // при появлении нового сигнала удаляем противоположный или если ордер остался один;
         if (SELL>0 && Ask<SELL-Present) SELL=0; // если есть селл, и он достаточно прибылен, закрываем его
         if (Sel.New==0 && SELLSTOP>0 && SELLSTOP!=RevSELL)   SELLSTOP=0;   // если есть противоположный отложник и сигналы не одновременные, т.е. чтоб не пришлось тут же его восстанавливать 
         if (Sel.New==0 && SELLLIMIT>0)                       SELLLIMIT=0; 
      }  }
   if (Sel.New>0){  // 
      if (Del==1){//Print("SELLSTOP=",SELLSTOP," SELLLIMIT=",SELLLIMIT);
         if (SELLSTOP>0  && MathAbs(Sel.New-SELLSTOP)>StopLevel && SELLSTOP!=RevSELL)   SELLSTOP=0; 
         if (SELLLIMIT>0 && MathAbs(Sel.New-SELLLIMIT)>StopLevel)                       SELLLIMIT=0;  
         }
      if (Del==2){
         if (BUY>0 && Bid>BUY+Present) BUY=0;
         if (Buy.New==0 && BUYSTOP>0  && BUYSTOP!=RevBUY)  BUYSTOP=0;  
         if (Buy.New==0 && BUYLIMIT>0)                     BUYLIMIT=0;   
      }  }
   if (BUY!=0  || BUYSTOP!=0  || BUYLIMIT!=0)   Buy.New=0;  // если остались старые ордера, новые не выставляем 
   if (SELL!=0 || SELLSTOP!=0 || SELLLIMIT!=0)  Sel.New=0; 
   ERROR_CHECK("Input");
   }

//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

double Fibo(int FiboLevel){ // Считаем ФИБУ:  Разбиваем диапазон HL   0   11.8   23.6   38.2  50  61.8   76.4  88.2   100 
   double Fib=0;
   switch(FiboLevel){
      case 16: Fib= (H-L)*2.500; break;
      case 15: Fib= (H-L)*2.382; break;
      case 14: Fib= (H-L)*2.236; break;
      case 13: Fib= (H-L)*2.118; break;
      case 12: Fib= (H-L)*2.000; break;
      case 11: Fib= (H-L)*1.882; break;
      case 10: Fib= (H-L)*1.764; break;
      case  9: Fib= (H-L)*1.618; break;
      case  8: Fib= (H-L)*1.500; break;
      case  7: Fib= (H-L)*1.382; break;
      case  6: Fib= (H-L)*1.236; break;
      case  5: Fib= (H-L)*1.118; break;
      case  4: Fib= (H-L)*1.000; break; // Hi
      case  3: Fib= (H-L)*0.882; break;
      case  2: Fib= (H-L)*0.764; break; 
      case  1: Fib= (H-L)*0.618; break; // Золотое сечение
      case  0: Fib= (H-L)*0.500; break; 
      case -1: Fib= (H-L)*0.382; break; // Золотое сечение 
      case -2: Fib= (H-L)*0.236; break;
      case -3: Fib= (H-L)*0.118; break; 
      case -4: Fib= (H-L)*0;     break; // Lo   
      case -5: Fib=-(H-L)*0.118; break; 
      case -6: Fib=-(H-L)*0.236; break;
      case -7: Fib=-(H-L)*0.382; break; 
      case -8: Fib=-(H-L)*0.500; break; 
      case -9: Fib=-(H-L)*0.618; break; 
      case-10: Fib=-(H-L)*0.764; break;
      case-11: Fib=-(H-L)*0.882; break;
      case-12: Fib=-(H-L)*1.000; break;
      case-13: Fib=-(H-L)*1.118; break;
      case-14: Fib=-(H-L)*1.236; break;
      case-15: Fib=-(H-L)*1.382; break;
      case-16: Fib=-(H-L)*1.500; break;
      }
   return( NormalizeDouble(L+Fib,Digits) );
   }


   
   
         
         
         
         
         
         
         
         
      

