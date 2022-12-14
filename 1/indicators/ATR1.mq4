#property copyright "Hohla"
#property link      "mail@hohla.ru"
#property version   "181.212" // yym.mdd
#property description "ATR_single"
#property strict // Указание компилятору на применение особого строгого режима проверки ошибок 
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrBlack
#property indicator_color2 clrWhite

extern int Per=14;   // ATR Period
double ATR[],HL[];
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int OnInit(){
   string short_name="ATR("+DoubleToStr(Per,0)+")";
   IndicatorBuffers(2); // 
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexBuffer(0,ATR);
   SetIndexBuffer(1,HL); 
   IndicatorShortName(short_name);
   SetIndexDrawBegin(1,Bars);
   SetIndexLabel(0,short_name);
   CHART_SETTINGS();
   if (Per<1){
      Print("ATR: Wrong input parameter, Period=",Per);
      return(INIT_FAILED);
      }
   SetIndexDrawBegin(0,Per);
   return(INIT_SUCCEEDED);  
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
int start(){
   int CountBars=Bars-IndicatorCounted()-1;
   for (int bar=CountBars; bar>0; bar--) HL[bar]=High[bar]-Low[bar];
   for (int bar=CountBars; bar>0; bar--){
      if (bar>Bars-Per){
         //Print("Not anougth bars for ATR: bar=",bar," Bars=",Bars," Per=",Per);  
         ATR[bar]=0;} // 
      else 
         ATR[bar]=iMAOnArray(HL,0,Per,0,MODE_SMA,bar); 
      }
   return(0);   
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
void CHART_SETTINGS(){// НАСТРОЙКИ ВНЕНШЕГО ВИДА ГРАФИКА
   //if (!Real) return;
   // Элементы
   ChartSetInteger(0,CHART_MODE,CHART_BARS);       // способ отображения ценового графика (CHART_BARS, CHART_CANDLES, CHART_LINE)
   ChartSetInteger(0,CHART_SHOW_GRID, false);      // Отображение сетки на графике
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP, false); // Отображение вертикальных разделителей между соседними периодами
   ChartSetInteger(0,CHART_SHOW_OHLC, false);      // Режим отображения значений OHLC в левом верхнем углу графика
   ChartSetInteger(0,CHART_FOREGROUND, true);      // Ценовой график на переднем плане
   ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,true);// Всплывающие описания графических объектов
   ChartSetInteger(0,CHART_SHOW_VOLUMES,false);    // Отображение объемов не нужно
   ChartSetInteger(0,CHART_SHOW_BID_LINE,true);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   // BLACK COLORS
   //ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);   // Цвет фона графика
   //ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrDimGray); // Цвет осей, шкалы и строки OHLC
   //ChartSetInteger(0,CHART_COLOR_GRID,clrDimGray);       // Цвет сетки
   //ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);      // Бар вверх
   //ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrLime);    // Бар вниз
   //ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);    // Линия
   //ChartSetInteger(0,CHART_COLOR_BID,clrDimGray);
   //ChartSetInteger(0,CHART_COLOR_ASK,clrDimGray);
   // WHITE COLORS
   color BARS_COLOR=clrWhite;
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrSilver);   // Цвет фона графика
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrBlack);      // Цвет осей, шкалы и строки OHLC
   ChartSetInteger(0,CHART_COLOR_GRID,clrSilver);           // Цвет сетки
   ChartSetInteger(0,CHART_COLOR_CHART_UP,BARS_COLOR);      // Бар вверх
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,BARS_COLOR);    // Бар вниз
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,BARS_COLOR);    // Линия
   ChartSetInteger(0,CHART_COLOR_BID,clrSilver);
   ChartSetInteger(0,CHART_COLOR_ASK,clrSilver);
   }   

