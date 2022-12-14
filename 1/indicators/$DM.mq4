// Вот теперь может и сбудется...
#property copyright "Hohla"
#property link      "hohla@mail.ru"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Gray
#property indicator_color3 Gray
#property indicator_color4 Gray

extern int MODE=0; // MODE=0..3
extern int Per=10; // Per=1..10
double DM[],Buf[],MAX[],MIN[];
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int OnInit(void){
   string Name="DM "+DoubleToStr(MODE,0)+"-";
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);   SetIndexBuffer(0,DM);   SetIndexLabel(0,"DM");
   SetIndexStyle(1,DRAW_LINE);   SetIndexBuffer(1,Buf);  SetIndexLabel(1,"0");
   SetIndexStyle(2,DRAW_LINE);   SetIndexBuffer(2,MAX);  SetIndexLabel(2,"MAX");
   SetIndexStyle(3,DRAW_LINE);   SetIndexBuffer(3,MIN);  SetIndexLabel(3,"MIN");
   switch (MODE){
         case 0:  Name=Name+"DM_Classic ("   +DoubleToStr(Per,0)+")"; break;
         case 1:  Name=Name+"Signal/Noise (" +DoubleToStr(Per,0)+")"; break; 
         case 2:  Name=Name+"Delta_S ("      +DoubleToStr(Per,0)+")"; break; 
         case 3:  Name=Name+"Momentum ("     +DoubleToStr(Per,0)+")"; break;
         }
   IndicatorShortName(Name);
   SetIndexLabel(0,Name);
   if (Per<1 || MODE<0 || MODE>3){
      Print("Wrong input parameters"); return(INIT_FAILED);}
   return (INIT_SUCCEEDED); // "0"-Успешная инициализация.
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
int start(){
   int CountBars=Bars-IndicatorCounted()-1;
   for (int bar=CountBars; bar>0; bar--){
      if (bar>Bars-Per-1) continue;
      int b=0;
      double Noise=0, Line=0, Delta=0, UP=0, DN=0, MO=0; 
      switch (MODE){
         case 0: // Classic
            DM[bar]=0;
            for (b=bar; b<bar+Per; b++){ 
               if (High[b]>High[b+1]) DM[bar]+=(High[b]-High[b+1]);
               if (Low[b] <Low [b+1]) DM[bar]+=(Low [b]-Low [b+1]); 
               }
         break;
         case 1: // Signal / Noise
            b=bar-1; 
            for (b=bar; b<bar+Per; b++)  Noise+=MathAbs((High[b]+Low[b]+Close[b])/3 - (High[b+1]+Low[b+1]+Close[b+1])/3); 
            if (Noise>0) DM[bar] = ((High[bar]+Low[bar]+Close[bar])/3 - (High[b]+Low[b]+Close[b])/3) / Noise;  
         break;
         case 2: // UpIntegral - DnIntegral
            b=bar-1; 
            MO=(Close[bar]-Close[bar+Per])/Per; // Momentum
            for (b=bar; b<bar+Per; b++){ 
               Line=Close[bar]-MO*(b-bar); // расчетное значение цены на прямой bar..(bar+Per) знак "-", т.к. считаем с зада на перед
               Delta=Close[b]-Line;
               if (Delta>0) DN+=Delta; else UP-=Delta;
               }
            DM[bar]=UP-DN;
         break;
         case 3: // Momentum
            b=bar-1; 
            for (b=bar; b<bar+Per; b++)  // считаем b, т.е. bar+per
            DM[bar]=Open[bar]-Open[b];
         break;
         }
      if ((DM[bar]>=0 && DM[bar+1]<0) || (DM[bar]<=0 && DM[bar+1]>0)) {MAX[bar]=0; MIN[bar]=0;}
      if (DM[bar]>MAX[bar]) MAX[bar]=DM[bar];
      if (DM[bar]<MIN[bar]) MIN[bar]=DM[bar];     
      Buf[bar]=0;
      }
   return(0);
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  