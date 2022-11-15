//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>


//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
input int openHour;
input int closeHour;
bool isTradeOpen = false;
CTrade trade;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   if(openHour == closeHour){
      Alert("Open hour and Close hour must differ! Do you even want to trade???");
      return INIT_PARAMETERS_INCORRECT;
   }
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason){

}

void OnTick(){
   
   // get current time
   MqlDateTime timeNow;
   TimeToStruct(TimeCurrent(), timeNow);
   
   // check for trade open
   if(openHour == timeNow.hour && !isTradeOpen){
            
      // open position
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,1,SymbolInfoDouble(_Symbol,SYMBOL_ASK),0,0);
      
      //set flag
      isTradeOpen = true;
      }
      
   // check for trade close
   if(closeHour == timeNow.hour && isTradeOpen){
            
      // open position
      trade.PositionClose(_Symbol);
      
      //set flag
      isTradeOpen = false;

   }

}
