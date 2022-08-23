void OrdersSet(){
   int ticket;   double TradeRisk=0;  string str;
   if (SetBUY>0){ 
      char repeat=3; // три попытки у тебя  
      
      while (repeat && BUY==0 && BUYSTOP==0 && BUYLIMIT==0){ // чтобы исключить повторное выставление при ошибке 128
         if (Real){
            TerminalHold(); // ждем 60сек освобождения терминала
            MARKET_UPDATE();
            Print("OrdersSet(): SetBUY=",S4(SetBUY),"/",S4(SetSTOP_BUY),"/",S4(SetPROFIT_BUY)," Lot=",Lot," Magic=",Magic," Exp=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
            TradeRisk=RiskChecker(Lot,SetBUY-SetSTOP_BUY,SYMBOL); 
            if (TradeRisk>MaxRisk) {REPORT("RiskChecker="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(SetBUY-SetSTOP_BUY)+" SYMBOL="+SYMBOL); return;}
            }
         if (SetBUY-ASK>StopLevel)  {str="Set BuyStp ";   ticket=OrderSend(SYMBOL,OP_BUYSTOP, Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,Expiration,CornflowerBlue);}   else
         if (ASK-SetBUY>StopLevel)  {str="Set BuyLim ";   ticket=OrderSend(SYMBOL,OP_BUYLIMIT,Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,Expiration,CornflowerBlue);}   else
                      {SetBUY=ASK;   str="Set Buy ";      ticket=OrderSend(SYMBOL,OP_BUY,     Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,    0        ,CornflowerBlue);}
         REPORT(str+S4(SetBUY)+"/"+S4(SetSTOP_BUY)+"/"+S4(SetPROFIT_BUY)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
         ORDER_CHECK();
         if (ticket>0) break; // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
         if (ERROR_CHECK("SetBUY")) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }  }
   if (SetSELL>0){ 
      char repeat=3; // три попытки у тебя 
      
      while (repeat &&  SELL==0 && SELLSTOP==0 && SELLLIMIT==0){
         if (Real){
            TerminalHold(); // ждем 60сек освобождения терминала
            MARKET_UPDATE();
            Print("OrdersSet(): SetSELL=",S4(SetSELL),"/",S4(SetSTOP_BUY),"/",S4(SetPROFIT_BUY)," Lot=",Lot," Magic=",Magic," Exp=",Expiration," ASK/BID=",S4(ASK),"/",S4(BID));
            TradeRisk=RiskChecker(Lot,SetSTOP_SELL-SetSELL,SYMBOL);
            if (TradeRisk>MaxRisk) {REPORT("RiskChecker="+S2(TradeRisk)+"% too BIG!!! Lot="+S2(Lot)+" Balance="+S0(AccountBalance())+" Stop="+S4(SetSTOP_SELL-SetSELL)+" SYMBOL="+SYMBOL); return;}
            }
         if (BID-SetSELL>StopLevel) {str="Set SellStp ";   ticket=OrderSend(SYMBOL,OP_SELLSTOP, Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,Expiration,Tomato);}   else
         if (SetSELL-BID>StopLevel) {str="Set SellLim ";   ticket=OrderSend(SYMBOL,OP_SELLLIMIT,Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,Expiration,Tomato);}   else
                      {SetSELL=BID;  str="Set Sell ";      ticket=OrderSend(SYMBOL,OP_SELL,     Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,      0       ,Tomato);}
         REPORT(str+S4(SetSELL)+"/"+S4(SetSTOP_SELL)+"/"+S4(SetPROFIT_SELL)+"/"+S2(Lot)+"x"+S1(TradeRisk)+"%");
         ORDER_CHECK();
         if (ticket>0) break;  // Ордеру назначен номер тикета. В случае неудачи ticket=-1   
         if (ERROR_CHECK("SetBUY")) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции
      }  }
   TerminalFree();
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void Modify(){   // Похерим необходимые стоп/лимит ордера: удаление если Buy/Sell=0       
   double LEVEL, POINT=1*MarketInfo(SYMBOL,MODE_POINT); 
   bool ReSelect=true;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      ReSelect=false; int Orders=OrdersTotal();
      for(int Ord=0; Ord<Orders; Ord++){ 
         if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
            Order=OrderType();
            bool make=true;  
            uchar repeat=3;  
            while (repeat){// повторяем операции над ордером, пока не более 3 раз
               TerminalHold();
               MARKET_UPDATE();
               LEVEL=StopLevel+Spred; // Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
               switch(Order){
                  case OP_SELL:        //  C L O S E     S E L L  
                     if (SELL==0){
                        make=OrderClose(OrderTicket(),OrderLots(),ASK,3,Tomato); 
                        REPORT("Close SELL/"+S4(OrderOpenPrice())); 
                        break;
                        }               //  M O D I F Y     S E L L  
                     if (STOP_SELL==OrderStopLoss() && PROFIT_SELL==OrderTakeProfit()) break; // если не требуестся модификация, идем дальше
                     if (STOP_SELL!=OrderStopLoss() && STOP_SELL-ASK<LEVEL){
                        STOP_SELL=ASK+LEVEL;   
                        if (STOP_SELL>=OrderStopLoss())   STOP_SELL=OrderStopLoss(); 
                        }  
                     if (PROFIT_SELL!=OrderTakeProfit() && ASK-PROFIT_SELL<LEVEL){
                        PROFIT_SELL=ASK-LEVEL; 
                        if (PROFIT_SELL<=OrderTakeProfit())  PROFIT_SELL=OrderTakeProfit();
                        }  
                     if (MathAbs(STOP_SELL-OrderStopLoss()) + MathAbs(PROFIT_SELL-OrderTakeProfit())>=POINT){  // модификация всетаки не потребовалась 
                        make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_SELL, PROFIT_SELL,OrderExpiration(),Tomato);   //Print(" ord=",ord," STOP_SELL=",STOP_SELL," OrderStopLoss=",OrderStopLoss()," PROFIT_SELL=",PROFIT_SELL," OrderTakeProfit=",OrderTakeProfit());
                        REPORT("ModifySell/"+S4(STOP_SELL)+"/"+S4(PROFIT_SELL));
                        }
                     break; 
                  case OP_SELLSTOP:    //  D E L   S E L L S T O P  //
                     if (SELLSTOP==0){ 
                        if (BID-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),Tomato); REPORT("Del SellStop/"+S4(OrderOpenPrice()));}
                        else REPORT("Can't Del SELLSTOP near market! BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                     break;
                  case OP_SELLLIMIT:   //  D E L   S E L L L I M I T  //
                     if (SELLLIMIT==0){
                        if (OrderOpenPrice()-BID>StopLevel){   make=OrderDelete(OrderTicket(),Tomato); REPORT("Del SellLimit/"+S4(OrderOpenPrice()));}
                        else REPORT("Can't Del SELLLIMIT! near market, BID="+S5(BID)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}   
                     break;
                  case OP_BUY:   //  C L O S E    B U Y  //////////////////////////////////////////////////////////////
                     if (BUY==0){
                        make=OrderClose(OrderTicket(),OrderLots(),BID,3,CornflowerBlue); 
                        REPORT("Close BUY/"+S4(OrderOpenPrice()));  
                        break;
                        }        // M O D I F Y      B U Y
                     if (STOP_BUY==OrderStopLoss() && PROFIT_BUY==OrderTakeProfit()) break;
                     if (STOP_BUY!=OrderStopLoss() && BID-STOP_BUY<LEVEL){
                        STOP_BUY=BID-LEVEL;   
                        if (STOP_BUY<OrderStopLoss())       STOP_BUY=OrderStopLoss();
                        } 
                     if (PROFIT_BUY!=OrderTakeProfit() && PROFIT_BUY-BID<LEVEL){
                        PROFIT_BUY=BID+LEVEL; 
                        if (PROFIT_BUY>OrderTakeProfit())   PROFIT_BUY=OrderTakeProfit();
                        }
                     if (MathAbs(STOP_BUY-OrderStopLoss()) + MathAbs(PROFIT_BUY-OrderTakeProfit())>=POINT){
                        make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_BUY, PROFIT_BUY,OrderExpiration(),CornflowerBlue);   //Print(" ord=",ord," STOP_BUY=",STOP_BUY," OrderStopLoss=",OrderStopLoss()," PROFIT_BUY=",PROFIT_BUY," OrderTakeProfit=",OrderTakeProfit());
                        REPORT("ModifyBuy/"+S4(STOP_BUY)+"/"+S4(PROFIT_BUY));
                        }
                     break; 
                  case OP_BUYSTOP:  //  D E L  B U Y S T O P  //
                     if (BUYSTOP==0){
                        if (OrderOpenPrice()-ASK>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue); REPORT("Del BuyStop/"+S4(OrderOpenPrice()));}
                        else REPORT("Can't Del BUYSTOP near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                     break; 
                  case OP_BUYLIMIT: //  D E L  B U Y L I M I T  //
                     if (BUYLIMIT==0){
                        if (ASK-OrderOpenPrice()>StopLevel){   make=OrderDelete(OrderTicket(),CornflowerBlue); REPORT("Del BuyLimit/"+S4(OrderOpenPrice()));}
                        else REPORT("Can't Del BUYLIMIT near market! ASK="+S5(ASK)+" OpenPrice="+S5(OrderOpenPrice())+" StopLevel="+S5(StopLevel));}
                     break;
                  }// switch(Order)  
               if (make) break; //  true при успешном завершении, или false в случае ошибки  
               if (ERROR_CHECK("Modify "+OrdToStr(Order)+" Ticket="+S0(OrderTicket())+" repeat="+S0(repeat))) repeat--; else repeat=0; // ERROR_CHECK() возвращает необходимость повтора торговой операции            
               }  //while(repeat)
            }//if (OrderSelect...   
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }// for(Ord=0; Ord<Orders; Ord++){    
      }// while(ReSelect)     
   TerminalFree();
   ERROR_CHECK("Modify");  
   }  
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
void MARKET_UPDATE(){
   RefreshRates(); 
   ASK      =MarketInfo(SYMBOL,MODE_ASK); 
   BID      =MarketInfo(SYMBOL,MODE_BID);    // в функции GlobalOrdersSet() ордера ставятся с одного графика на разные пары, поэтому надо знать данные пары выставляемого ордера     
   DIGITS   =int(MarketInfo(SYMBOL,MODE_DIGITS)); // поэтому надо знать данные пары выставляемого ордера
   StopLevel=MarketInfo(SYMBOL,MODE_STOPLEVEL)*MarketInfo(SYMBOL,MODE_POINT);  
   Spred    =MarketInfo(SYMBOL,MODE_SPREAD)   *MarketInfo(SYMBOL,MODE_POINT);
   }      
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void ORDER_CHECK(){   // ПАРАМЕТРЫ ОТКРЫТЫХ И ОТЛОЖЕННЫХ ПОЗ
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0;  STOP_BUY=0; PROFIT_BUY=0; STOP_SELL=0; PROFIT_SELL=0;
   for (int i=0; i<OrdersTotal(); i++){ 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
         if (OrderType()==6) continue; // ролловеры не записываем
         switch(OrderType()){
            case OP_BUYSTOP:  BUYSTOP=(float)OrderOpenPrice();  STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUYLIMIT: BUYLIMIT=(float)OrderOpenPrice(); STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_BUY:      BUY=(float)OrderOpenPrice();      STOP_BUY=(float)OrderStopLoss();  PROFIT_BUY=(float)OrderTakeProfit();   BuyTime=OrderOpenTime();    break;
            case OP_SELLSTOP: SELLSTOP=(float)OrderOpenPrice(); STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELLLIMIT:SELLLIMIT=(float)OrderOpenPrice();STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
            case OP_SELL:     SELL=(float)OrderOpenPrice();     STOP_SELL=(float)OrderStopLoss(); PROFIT_SELL=(float)OrderTakeProfit();  SellTime=OrderOpenTime();   break;
   }  }  }  }
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
void ORDERS_COLLECT(){// Запишем ордера для выставления в массив. 
   if (SetBUY>0){ // запланировано открытие лонга
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetBUY",         SetBUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSTOP_BUY",    SetSTOP_BUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetPROFIT_BUY",  SetPROFIT_BUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"BuyExpiration",  Expiration);
      Print(Magic,": ",Symbol(),Period()," ORDERS_COLLECT: SetBUY=",S4(SetBUY),"/",S4(SetSTOP_BUY),"/",S4(SetPROFIT_BUY)," Expir=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES)); 
      }
   if (SetSELL>0){
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSELL",        SetSELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSTOP_SELL",   SetSTOP_SELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetPROFIT_SELL", SetPROFIT_SELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SellExpiration", Expiration);
      Print(Magic,": ",Symbol(),Period()," ORDERS_COLLECT: SetSell=",S4(SetSELL),"/",S4(SetSTOP_SELL),"/",S4(SetPROFIT_SELL)," Expir=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES));   
   }  }// 
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
struct ORDER_DATA{// данные эксперта
   int      Magic, Type, Per, HistDD, LastTestDD, BackTest;
   datetime Expir, Bar, TestEndTime, ExpMemory; 
   string   Sym, Coment;
   double   Price, Stop, Profit, Risk, Lot, NewLot, RevBUY, RevSELL;   
   };  
ORDER_DATA ORD[100], TMP;  
   
void GlobalOrdersSet(){ // выставление ордеров с учетом риска остальных экспертов //ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return;  // mode=0 режим выставления своих ордеров,  mode=1 режим проверки рисков
   if (!GlobalVariableCheck("GlobalOrdersSet")) GlobalVariableSet("GlobalOrdersSet",0);
   while (!GlobalVariableSetOnCondition("GlobalOrdersSet",Magic,0))  Sleep(1000);
   double   NewRisk=0,  Stop=0, OpenLongRisk=0, OpenShortRisk=0,  OpenOrdMargNeed=0, LongRisk=0, ShortRisk=0, MargNeed=0, LotDecrease=1, LongDecrease=1, ShortDecrease=1;
   int Ord=0, Exp, Orders=100;
   Print(Magic,": ",Symbol(),Period(),"       *   G L O B A L   O R D E R S   S E T   B E G I N   *"); 
   // перепишем из глобальных переменных в массивы ПАРАМЕТРЫ НОВЫХ ОРДЕРОВ
   for (Exp=0; Exp<ExpTotal; Exp++){            // перебор массива с параметрами всех экспертов
      if (CSV[Exp].Name==ExpertName && CSV[Exp].Sym==Symbol() && CSV[Exp].Per==Period()){
         if (GlobalVariableCheck(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY")){// есть ордер для выставления
            Ord++;
            ORD[Ord].Magic  =CSV[Exp].Magic;
            ORD[Ord].Type   =10; // значит SetBUY
            ORD[Ord].Lot=0;   // лот расчитается ниже, исходя из индивидуального риска
            ORD[Ord].Price  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY");         GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY"); // тут же  
            ORD[Ord].Stop   =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_BUY");    GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_BUY"); // удаляем
            ORD[Ord].Profit =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_BUY");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_BUY"); // считанный
            ORD[Ord].Expir  =datetime(GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"BuyExpiration"));  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"BuyExpiration"); // глобал
            }      
         if (GlobalVariableCheck(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL")){// есть ордер для выставления
            Ord++;
            ORD[Ord].Magic  =CSV[Exp].Magic;
            ORD[Ord].Type   =11; // значит SetSELL
            ORD[Ord].Lot=0;   // лот расчитается ниже, исходя из индивидуального риска
            ORD[Ord].Price  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL");         GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL"); // тут же  
            ORD[Ord].Stop   =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_SELL");    GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_SELL"); // удаляем
            ORD[Ord].Profit =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_SELL");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_SELL"); // считанный
            ORD[Ord].Expir  =datetime(GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SellExpiration"));  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SellExpiration"); // глобал
      }  }  }
   // запишем в массивы параметры имеющихся ордеров  (рыночных и отложенных) 
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета и дописываем их в массив ORD. Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue; // ролловеры не записываем
         Ord++; // Print("Отложенные ордера = ",Ord," OrderType()=",OrderType());
         ORD[Ord].Type   =OrderType();             
         ORD[Ord].Sym    =OrderSymbol();
         ORD[Ord].Price  =OrderOpenPrice();
         ORD[Ord].Stop   =OrderStopLoss();
         ORD[Ord].Profit =OrderTakeProfit();
         ORD[Ord].Lot    =OrderLots();
         ORD[Ord].Magic  =OrderMagicNumber();
         ORD[Ord].Coment =OrderComment();
         ORD[Ord].Expir  =OrderExpiration();   //Print("CurrentOrder-",Ord," ",ORD[Ord].Magic,": ",OrdToStr(ORD[Ord].Type)," ",ORD[Ord].Sym," ",S4(ORD[Ord].Price),"/",S4(ORD[Ord].Stop),"/",S4(ORD[Ord].Profit)," Expir=",TimeToStr(ORD[Ord].Expir,TIME_DATE|TIME_MINUTES)," CurLot=",S2(ORD[Ord].Lot));                   
      }  }  // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров
   if (Ord==0){
      Print("No Orders"); 
      GlobalVariableSet("GlobalOrdersSet",0);
      Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   E N D   *      GlobalOrdersSet=",GlobalVariableGet("GlobalOrdersSet"));
      return;}  
   Orders=Ord; 
   TMP.Magic   =Magic;              TMP.TestEndTime=TestEndTime;
   TMP.Per     =Per;                TMP.LastTestDD =LastTestDD;
   TMP.Bar     =BarTime;            TMP.Risk       =Risk;
   TMP.RevBUY  =RevBUY;             TMP.BackTest   =BackTest;
   TMP.HistDD  =HistDD;             TMP.RevSELL    =RevSELL;
   TMP.Sym     =SYMBOL;             TMP.ExpMemory  =ExpMemory;
   TMP.Coment  =ExpID;              
   // Пересчитаем РЕАЛЬНЫЙ РИСК КАЖДОГО ЭКСПЕРТА ЧЕРЕЗ MM(), с учетом нового баланса 
   for (Ord=1; Ord<=Orders; Ord++){
      for (Exp=0; Exp<ExpTotal; Exp++){            // из массива с параметрами всех экспертов
         if (ORD[Ord].Magic==CSV[Exp].Magic){      // пропишем риски и др. необходимую инфу
            ORD[Ord].Risk        =CSV[Exp].Risk;        // во все имеющиеся ордера
            ORD[Ord].HistDD      =CSV[Exp].HistDD;     
            ORD[Ord].LastTestDD  =CSV[Exp].LastTestDD;
            ORD[Ord].TestEndTime =CSV[Exp].TestEndTime;
            ORD[Ord].Sym         =CSV[Exp].Sym;
            ORD[Ord].Per         =CSV[Exp].Per; // период потребуется в TesterFileCreate() при отправке ErrorLog()
         }  } 
      SYMBOL=ORD[Ord].Sym;
      Stop=MathAbs(ORD[Ord].Price-ORD[Ord].Stop);
      if (ORD[Ord].Type<2){// открытый ордер
         OpenOrdMargNeed+=ORD[Ord].Lot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия лотов
         if (ORD[Ord].Type==0 && ORD[Ord].Price-ORD[Ord].Stop>0)  OpenLongRisk +=RiskChecker(ORD[Ord].Lot,Stop,SYMBOL); // если стоп еще не ушел в безубыток, считаем риск. В противном случае риск позы равен нулю
         if (ORD[Ord].Type==1 && ORD[Ord].Stop-ORD[Ord].Price>0)  OpenShortRisk+=RiskChecker(ORD[Ord].Lot,Stop,SYMBOL); // суммарный риск открытых ордеров на продажу
         Print("Order-",Ord," ",ORD[Ord].Magic,": ",OrdToStr(ORD[Ord].Type)," ",ORD[Ord].Sym," ",S4(ORD[Ord].Price),"/",S4(ORD[Ord].Stop),"/",S4(ORD[Ord].Profit)," Expir=",TimeToStr(ORD[Ord].Expir,TIME_DATE|TIME_MINUTES)," Lot=",S2(ORD[Ord].Lot));
         continue;// считать лот для открытых ордеров не надо
         }
      Risk        =ORD[Ord].Risk*Aggress; // умножаем на агрессивность торговли, определяемую при загрузке эксперта: if (Risk>0)  Aggress=Risk; else  Aggress=1
      HistDD      =ORD[Ord].HistDD;
      LastTestDD  =ORD[Ord].LastTestDD;
      TestEndTime =ORD[Ord].TestEndTime;
      Magic       =ORD[Ord].Magic; 
      ORD[Ord].NewLot =MoneyManagement(Stop);
      Print("Order-",Ord," ",ORD[Ord].Magic,": ",OrdToStr(ORD[Ord].Type)," ",ORD[Ord].Sym," ",S4(ORD[Ord].Price),"/",S4(ORD[Ord].Stop),"/",S4(ORD[Ord].Profit)," Expir=",TimeToStr(ORD[Ord].Expir,TIME_DATE|TIME_MINUTES)," Lot=",S2(ORD[Ord].Lot)," NewLot=",S2(ORD[Ord].NewLot)," RiskChecker=",RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL));      
      if (ORD[Ord].Type==2 || ORD[Ord].Type==4 || ORD[Ord].Type==10)// счиаем риск для лонгов
         LongRisk+=RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL); // найдем суммарный риск всех новых и отложенных ордеров
      if (ORD[Ord].Type==3 || ORD[Ord].Type==5 || ORD[Ord].Type==11)// счиаем риск для шортов
         ShortRisk+=RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL); // найдем суммарный риск всех новых и отложенных ордеров
      MargNeed+=ORD[Ord].NewLot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия новых и отложенных ордеров
      }  //Print ("GlobalOrdersSet()/ РИСКИ:  Маржа открытых = ",OpenOrdMargNeed/AccountFreeMargin()*100,",  Маржа отложников и новых = ",MargNeed/AccountFreeMargin()*100,", LongRisk=",LongRisk,"%, OpenLongRisk=",OpenLongRisk,"%, ShortRisk=",ShortRisk,"%, OpenShortRisk=",OpenShortRisk,"%, Orders=",Orders);   
   // П Р О В Е Р К А   Р И С К О В  /
   if (OpenLongRisk+LongRisk>MaxRisk && LongRisk!=0){// проверка Лонгов 
      if (MaxRisk>OpenLongRisk){
         LongDecrease=0.95*(MaxRisk-OpenLongRisk)/LongRisk;   
      }else{
         LongDecrease=0; // т.е. удаляем все отложники, т.к. риск открытых поз не позволяет
         REPORT("Open LongOrders Risk="+DoubleToStr(OpenLongRisk,1)+"%, delete another pending LongOrders!"); // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      }  }
   if (OpenShortRisk+ShortRisk>MaxRisk && ShortRisk!=0){// проверка Шортов
      if (MaxRisk>OpenShortRisk){
         ShortDecrease=0.95*(MaxRisk-OpenShortRisk)/ShortRisk;
      }else{
         ShortDecrease=0;  // т.е. удаляем все отложники, т.к. риск открытых поз не позволяет
         REPORT("Open ShortOrders Risk="+DoubleToStr(OpenShortRisk,1)+"% , delete another pending ShortOrders!"); // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      }  }    
   MargNeed=0; // придется пересчитать маржу в связи с уменьшением лотов 
   for (Ord=1; Ord<=Orders; Ord++){// пересчитаем все лоты
      if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
      if (ORD[Ord].Type==2 || ORD[Ord].Type==4 || ORD[Ord].Type==10) // счиаем риск для лонгов  
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*LongDecrease,LotDigits);// на всех лонговых отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в максимальный риск на все лонги  
      if (ORD[Ord].Type==3 || ORD[Ord].Type==5 || ORD[Ord].Type==11)// счиаем риск для шортов
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*ShortDecrease,LotDigits);// на всех шортовых отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в максимальный риск на все шорты
      MargNeed+=ORD[Ord].NewLot*MarketInfo(ORD[Ord].Sym,MODE_MARGINREQUIRED); // заново пересчитываем кол-во маржи, необходимой для открытия ордеров
      }
   // П Р О В Е Р К А   М А Р Ж И  ///
   if (OpenOrdMargNeed+MargNeed>AccountFreeMargin()*MaxMargin && MargNeed!=0){// перегрузили маржу 
      if (AccountFreeMargin()*MaxMargin>OpenOrdMargNeed){
         LotDecrease=0.95*(AccountFreeMargin()*MaxMargin-OpenOrdMargNeed)/MargNeed;} // расчитаем коэффициент уменьшения риска/лота отложенных и новых ордеров (умножаеам на 0.95 для гистерезиса)
      else  LotDecrease=0; // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      for (Ord=1; Ord<=Orders; Ord++){// пересчитаем все лоты
         if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*LotDecrease,LotDigits);// на всех отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в маржу
      }  }
   // В Ы С Т А В Л Е Н И Е   О Р Д Е Р О В  
   for (Ord=1; Ord<=Orders; Ord++){
      if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
      SYMBOL      =ORD[Ord].Sym;
      if (MathAbs(ORD[Ord].Lot-ORD[Ord].NewLot)<MarketInfo(SYMBOL,MODE_LOTSTEP)) continue; 
      Per         =ORD[Ord].Per; // период потребуется в TesterFileCreate() при отправке ErrorLog()
      Risk        =ORD[Ord].Risk;
      HistDD      =ORD[Ord].HistDD;
      LastTestDD  =ORD[Ord].LastTestDD;
      TestEndTime =ORD[Ord].TestEndTime;
      Magic       =ORD[Ord].Magic; 
      Expiration  =ORD[Ord].Expir; 
      ExpID       =ORD[Ord].Coment;
      Stop=MathAbs(ORD[Ord].Price-ORD[Ord].Stop);// т.к. ордера ставятся с одного графика на разные пары,
      DIGITS=int(MarketInfo(SYMBOL,MODE_DIGITS)); // поэтому надо знать данные пары выставляемого ордера
      StopLevel = MarketInfo(SYMBOL,MODE_STOPLEVEL)*MarketInfo(SYMBOL,MODE_POINT);  
      Spred     = MarketInfo(SYMBOL,MODE_SPREAD)   *MarketInfo(SYMBOL,MODE_POINT);
      ORDER_CHECK();
      SetBUY=0;  SetSTOP_BUY =ORD[Ord].Stop; SetPROFIT_BUY =ORD[Ord].Profit; 
      SetSELL=0; SetSTOP_SELL=ORD[Ord].Stop; SetPROFIT_SELL=ORD[Ord].Profit;
      switch(ORD[Ord].Type){
         case 2:  SetBUY=ORD[Ord].Price;  BUYLIMIT=0;  break; // выбираем тип
         case 3:  SetSELL=ORD[Ord].Price; SELLLIMIT=0; break; // ордера
         case 4:  SetBUY=ORD[Ord].Price;  BUYSTOP=0;   break; // который
         case 5:  SetSELL=ORD[Ord].Price; SELLSTOP=0;  break; // нужно удалить
         case 10: SetBUY=ORD[Ord].Price;               break;
         case 11: SetSELL=ORD[Ord].Price;              break;
         } 
      Lot  =ORD[Ord].NewLot;    
      if (ORD[Ord].Type<6){// Удаление отложников
         Modify(); 
         ORDER_CHECK();} 
      if (Lot>0){ Print("GlobalOrdersSet ",Ord,". ",Magic,"/",OrdToStr(ORD[Ord].Type)," ",SYMBOL," ",S4(ORD[Ord].Price),"/",S4(ORD[Ord].Stop),"/",S4(ORD[Ord].Profit),"  Risk=",Risk,"  Lot=",Lot,"  Expir=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES));
         OrdersSet();  // выставление заново 
      }  }  
   Magic    =TMP.Magic;       TestEndTime =TMP.TestEndTime;
   BackTest =TMP.BackTest;    ExpMemory   =TMP.ExpMemory;
   BarTime  =TMP.Bar;         Risk        =TMP.Risk;
   Per      =TMP.Per;         RevBUY      =TMP.RevBUY;
   HistDD   =TMP.HistDD;      RevSELL     =TMP.RevSELL;
   SYMBOL   =TMP.Sym;         LastTestDD  =TMP.LastTestDD;
   ExpID    =TMP.Coment;
   GlobalVariableSet("LastBalance",AccountBalance()); // для ф. CHECK_OUT()
   GlobalVariableSet("GlobalOrdersSet",0);
   GlobalVariableSet("CHECK_OUT_Time",TimeCurrent());
   Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   E N D   *      GlobalOrdersSet=",GlobalVariableGet("GlobalOrdersSet"));
   }
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void CHECK_OUT(){// Проверка недавних ордеров и состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок) ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   if (TimeCurrent()-GlobalVariableGet("CHECK_OUT_Time")<600) return;
   if (GlobalVariableGet("CanTrade")!=Magic && !GlobalVariableSetOnCondition("CanTrade",Magic,0)) return; // попытка захватат флага доступа к терминалу    
   GlobalVariableSet("CHECK_OUT_Time",TimeCurrent());
   datetime LastOrdTime=0;
   bool NeedToCheckOrders=false;
   string LastOrd;
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета и дописываем их в массив ORD. Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false) continue; 
      if (OrderType()==6) continue; // ролловеры пропускаем
      if (OrderOpenTime()>LastOrdTime){ 
         LastOrdTime=OrderOpenTime(); //Print("Order ",OrdToStr(OrderType())," time=",TimeToStr(OrderOpenTime(),TIME_DATE | TIME_MINUTES), " LastOrdTime=",TimeToStr(LastOrdTime,TIME_DATE | TIME_MINUTES));
         LastOrd=S0(OrderMagicNumber())+"/"+OrdToStr(OrderType())+"/"+TIME(LastOrdTime);
      }  }
   if (GlobalVariableGet("LastOrdTime")!=LastOrdTime){
      GlobalVariableSet("LastOrdTime",LastOrdTime); 
      REPORT("CHECK_OUT(): Time of LastOrd "+LastOrd+" changed to "+TIME(LastOrdTime)+", recount orders");
      NeedToCheckOrders=true;
      }  
   double BalanceChange=(GlobalVariableGet("LastBalance")-AccountBalance())*100/AccountBalance();
   if (MathAbs(BalanceChange)>5){
      REPORT("CHECK_OUT(): BalanceChange="+ S0(BalanceChange) +"%, recount orders");
      NeedToCheckOrders=true;
      }
   GlobalVariableSet("CanTrade",0); // сбрасываем глобал
   if (NeedToCheckOrders) GlobalOrdersSet(); // расставляем ордера
   else Print(Magic,": CHECK_OUT(): Time of LastOrd ",LastOrd," not changed ("+TIME(LastOrdTime)+"), BalanceChange=",S1(BalanceChange),"%"); 
   } 
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
string OrdToStr(int Type){ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 10: return ("SetBUY");
      case 11: return ("SetSELL");
      default: return ("-");
   }  }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
   

