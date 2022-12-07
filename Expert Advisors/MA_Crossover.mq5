// Include
#include <Trade\Trade.mqh>

// Input Variables
input int InpFastPeriod = 14; // Fast Period
input int InpSlowPeriod = 21; // Slow Period
input int InpStopLoss = 100; //Stop Loss
input int InpTakeProfit = 100; //Take Profit
input double InpLots = 1.0; // LotSize

// Global Variables
int fastHandle;
int slowHandle;
double fastbuffer[];
double slowbuffer[];
datetime openTimeBuy = 0;
datetime openTimeSell = 0;
CTrade trade;

//Initialization
int OnInit(){
   
   // Check User Input
   if(InpFastPeriod <= 0){
      Alert("Fast Period <= 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpSlowPeriod <= 0){
      Alert("Slow Period <= 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpFastPeriod >= InpSlowPeriod){
      Alert("Fast Period >= Slow Period");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // create handles
   fastHandle = iMA(_Symbol,PERIOD_CURRENT,InpFastPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(fastHandle == INVALID_HANDLE){
      Alert("Failed to create fast handle");
      return INIT_FAILED;
   }
   slowHandle = iMA(_Symbol,PERIOD_CURRENT,InpSlowPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(slowHandle == INVALID_HANDLE){
      Alert("Failed to create slow handle");
      return INIT_FAILED;
   }
   return(INIT_SUCCEEDED);
   
   // Create Series
   ArraySetAsSeries(fastbuffer,true);
   ArraySetAsSeries(slowbuffer,true);
  }

//Deinitialization
void OnDeinit(const int reason){
   if(fastHandle != INVALID_HANDLE){IndicatorRelease(fastHandle);}
   if(slowHandle != INVALID_HANDLE){IndicatorRelease(slowHandle);}
     }

//On every price change
void OnTick(){

   int values = CopyBuffer(fastHandle,0,0,2,fastbuffer);
   if(values != 2){
      Print("Not enough data for fast ma");
      return;
   }
   values = CopyBuffer(slowHandle,0,0,2,slowbuffer);
   if(values != 2){
      Print("Not enough data for slow ma");
      return;
   }
   
   Comment("fast[0]:",fastbuffer[0],"\n",
           "fast[1]:",fastbuffer[1],"\n",
           "slow[0]:",slowbuffer[0],"\n",
           "slow[1]:",slowbuffer[1]);
   
   // Check for Buy Signal
   if(fastbuffer[1] <= slowbuffer[1] && fastbuffer[0] > slowbuffer[0] && openTimeBuy != iTime(_Symbol,PERIOD_CURRENT,0)){
      openTimeBuy = iTime(_Symbol,PERIOD_CURRENT,0);
      double ask  = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double sl   = ask - InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp   = ask + InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,InpLots,ask,sl,tp,"Cross EA");
   }
   
   // Check for Sell Signal
   if(fastbuffer[1] >= slowbuffer[1] && fastbuffer[0] < slowbuffer[0] && openTimeSell != iTime(_Symbol,PERIOD_CURRENT,0)){
      openTimeSell = iTime(_Symbol,PERIOD_CURRENT,0);
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double sl   = bid + InpStopLoss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
      double tp   = bid - InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);

      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,InpLots,bid,sl,tp,"Cross EA");
   }

}