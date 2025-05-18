//+------------------------------------------------------------------+
//|                                                    SEW_Trade.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#property strict
#include "..\SEW_Trade\panel.mqh"
// Input parameters
input int SMA_Period = 13;
input int EMA_Period = 21;
input int MagicNumber = 123456;
input int Deviation = 50;

//Waddah input parameters
input int Fast_MA = 20;       // Period of the fast MACD moving average
input int Slow_MA = 40;       // Period of the slow MACD moving average
input int BBPeriod=20;        // Bollinger period
input double BBDeviation=2.0; // Number of Bollinger deviations
input int  Sensetive=150;
input int  DeadZonePip=400;
input int  ExplosionPower=15;
input int  TrendPower=150;
input bool AlertWindow=false;
input int  AlertCount=2;
input bool AlertLong=false;
input bool AlertShort=false;
input bool AlertExitLong=false;
input bool AlertExitShort=false;
// WAE Settings
input int FastMA = 20;
input int SlowMA = 40;
input int ChannelPeriod = 15;
input double Multiplier = 2.0;

// Indicator Handles
int hSMA, hEMA, hWAE;

// Define arrays to store the indicator buffer data

bool tradeInProgress = false;
datetime lastTradeTime = 0;
int tradeCooldown = 60;
int barsToCheck = 1000;
int Tradeflag = 0;
ENUM_TIMEFRAMES AnalyzePeriod=PERIOD_M1;
int cnt = 0;

//controlpanel data
bool EnableBuy = true;
bool EnableSell = true;
double lot_size = 0.01;
string time_frame = "15M";
int tp_cnt=1;
int take_profit[5] = {20,0,0,0,0};
int stop_loss = 50;
CControlPanel ControlPanel;
int OnInit()
  {
  //----
   EventSetTimer(1);
//---
   if(!ControlPanel.Create(0, "TradePanel_ver2.0", 0, 10, 30, 200, 380))
      return INIT_FAILED;
   ControlPanel.Run();
//---
   //.......................MainStart.......................
   hWAE = iCustom(Symbol(), PERIOD_CURRENT, "waddah_attar_explosion", Fast_MA, Slow_MA, BBPeriod, BBDeviation, Sensetive, DeadZonePip, ExplosionPower, TrendPower, AlertWindow, AlertCount, AlertLong, AlertShort, AlertExitLong, AlertExitShort);
   //.......................Initialize and Draw SMA(13) and EMA(21).Start...............................
   hSMA = iMA(Symbol(), PERIOD_CURRENT, SMA_Period, 0, MODE_SMA, PRICE_CLOSE);
   hEMA = iMA(Symbol(), PERIOD_CURRENT, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   
   datetime timeBuffer[];
   if (CopyTime(Symbol(), PERIOD_CURRENT, 0, barsToCheck, timeBuffer) <= 0) {
       Print("Error fetching time data: ", GetLastError());
       return INIT_FAILED;
   }
   if (hSMA == INVALID_HANDLE || hEMA == INVALID_HANDLE) {
        Print("Error: Unable to create SMA/EMA handles!");
        return INIT_FAILED;
   }
   ChartIndicatorAdd(0, 0, hSMA);
   ChartIndicatorAdd(0, 0, hEMA);
   Print("SMA(13) and EMA(21) added to chart."); 
   //.......................Initialize and Draw SMA(13) and EMA(21).End...............................
      // Initialize WAE indicator
    //hWAE = iCustom(Symbol(), PERIOD_CURRENT, "waddah_attar_explosion", FastMA, SlowMA, ChannelPeriod, Multiplier);
    if (hWAE == INVALID_HANDLE) {
        Print("Error: Unable to load WAE indicator!");
        return INIT_FAILED;
    }  
    Print("SMA, EMA, and WAE indicators initialized successfully.");
    
    //History first cross ~ New cross trade process
    double smaBuffer[], emaBuffer[],signalBuffer[],explosionBuffer[],vectorBuffer[];
    CopyBuffer(hSMA, 0, 0, barsToCheck, smaBuffer);
    CopyBuffer(hEMA, 0, 0, barsToCheck, emaBuffer);
    CopyBuffer(hWAE, 0, 0, barsToCheck, explosionBuffer);
    CopyBuffer(hWAE, 1, 0, barsToCheck, vectorBuffer);
    CopyBuffer(hWAE, 2, 0, barsToCheck, signalBuffer);
    for (int i = barsToCheck-1 ; i >=1; i--) 
    {
       if (IsCrossover(smaBuffer[i - 1], smaBuffer[i], emaBuffer[i - 1], emaBuffer[i])==1) 
       {
            datetime crossTime = timeBuffer[i];
            string cross_type = "StartCross";
            DrawCrossLine(crossTime, cross_type);
            Print("explosion:",explosionBuffer[i], "color:",vectorBuffer[i], "signal:",signalBuffer[i]);
            Print("SMA/EMA Crossover with WAE confirmed: ", crossTime, "index: ", i);
            break;
       }
    }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   EventKillTimer();
   ControlPanel.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double sma_vals[2], ema_vals[2], explosion_vals[2], vector_vals[2], signal_vals[2];
void OnTick()
  {
//---
    
    // Copy SMA & EMA buffers
    if (CopyBuffer(hSMA, 0, 0, 2, sma_vals) <= 0 || CopyBuffer(hEMA, 0, 0, 2, ema_vals) <= 0) {
        Print("Error: Unable to fetch SMA/EMA data!");
        return;
    }

    // Copy WAE Buffers
    if (CopyBuffer(hWAE, 2, 0, 2, signal_vals) <= 0 || CopyBuffer(hWAE, 0, 0, 2, explosion_vals) <= 0 || CopyBuffer(hWAE, 1, 0, 2, vector_vals) <= 0) {
        Print("Error: Unable to fetch WAE data!");
        return;
    }
    if(IsCrossover(sma_vals[1], sma_vals[0], ema_vals[1], ema_vals[0])==1)
    {
      
      CheckForSignals();
    }
  }
void CheckForSignals()
{
    OrderCloseAll();
    ChangeTF(PERIOD_CURRENT);
    //----------when explosion line is above signal line and explosion line color is green
    if(explosion_vals[0]>signal_vals[0] && vector_vals[0]==1.0)
    {
      //+---------show at the 1min--------------------
      ChangeTF(AnalyzePeriod);
      StartTrade();
    }
}
//+------------------------------------------------------------------+
//| TimerEvent Function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
   tp_cnt=0;
   lot_size = ControlPanel.getLotSize();
   time_frame = ControlPanel.getTimeFrame();
   SetAnalyzePeriod(time_frame);
   for(int i=0;i<5;i++)
   {
      if(ControlPanel.getTakeProfit(i)!="Disable")
      {
         take_profit[tp_cnt] = StringToInteger(ControlPanel.getTakeProfit(i));
         tp_cnt++;
      }
   }
   stop_loss = ControlPanel.getStopLoss();
   EnableBuy = ControlPanel.IsBuy();
   EnableSell = ControlPanel.IsSell();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   ControlPanel.ChartEvent(id, lparam, dparam, sparam);
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      if(ControlPanel.getBtnClick(sparam)==1)
      {
         Print("StartTrade");
         StartTrade();
         //example();
      }
      else if(ControlPanel.getBtnClick(sparam)==2)
      {
         Print("CloseAll");
         OrderCloseAll();
      }
   }
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Function to draw a vertical line on the chart                    |
//+------------------------------------------------------------------+
void DrawCrossLine(datetime time, string label) {
    string line_name = "CrossLine_" + label + "_" + IntegerToString(time);
    if (!ObjectCreate(0, line_name, OBJ_VLINE, 0, time, 0)) {
        Print("Failed to create vertical line: ", GetLastError());
    } else {
        ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DASH);
    }
}
bool IsCrossover(double smaPrev, double smaCurr, double emaPrev, double emaCurr) {
    bool bullish = (smaPrev < emaPrev && smaCurr > emaCurr);
    bool bearish = (smaPrev > emaPrev && smaCurr < emaCurr);
    return bearish;
}

//
void StartTrade()
{
   if(EnableBuy==1 && EnableSell==1)
   {
      OrderBuy();
      OrderSell();
      Print("1");
   }
   else if(EnableBuy==1)
   {
      OrderBuy();
      Print("2");
   }   
   else if(EnableSell==1)
   {
      OrderSell();
      Print("3");
   }
   else
      Print("Error buy/sell status");
}
//-----------2.24---Update---Sell.Buy.CloseAllTrade-----------------
void OrderBuy(){
   double entryPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double sl = entryPrice - stop_loss * _Point;
   //double tp = entryPrice + 50 * _Point;
   double tp[5];
   Print("tp_cnt",tp_cnt);
   for(int i=0 ; i<tp_cnt ; i++)
   {
      tp[i] = entryPrice + take_profit[i] * _Point;
      Print("value ",take_profit[i]);
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      ZeroMemory(result);
      request.action       = TRADE_ACTION_DEAL;
      request.magic        = 123456;
      request.symbol       = Symbol();
      request.volume       = lot_size;
      request.price        = entryPrice;
      request.type_filling = ORDER_FILLING_IOC;
      request.type_time = ORDER_TIME_GTC;
      request.deviation    = 10;
      request.type         = ORDER_TYPE_BUY;
      
      MqlTick mTick;
      if(SymbolInfoTick(_Symbol,mTick)){
         if(sl > 0) request.sl = NormalizeDouble(mTick.ask - sl*_Point,_Digits);
         if(tp[i] > 0) request.tp = NormalizeDouble(mTick.ask + tp[i]*_Point,_Digits);
      }
      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
    
}

void OrderSell(){
   double entryPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double sl = entryPrice + stop_loss * _Point;
   double tp[5];
   //double tp = entryPrice - 50 * _Point;
   //Print("1 pip: ", _Point);
   for(int i=0 ; i<tp_cnt ; i++)
   {
      tp[i] = entryPrice + take_profit[i] * _Point;
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      ZeroMemory(result);
      request.action       = TRADE_ACTION_DEAL;
      request.magic        = 123456;
      request.symbol       = Symbol();
      request.volume       = lot_size;
      request.price        = entryPrice;
      request.type_filling = ORDER_FILLING_IOC;
      request.type_time = ORDER_TIME_GTC;
      request.deviation    = 10;
      request.type         = ORDER_TYPE_SELL;
      MqlTick mTick;
      if(SymbolInfoTick(_Symbol,mTick)){
         if(sl > 0) request.sl = NormalizeDouble(mTick.bid + sl*_Point,_Digits);
         if(tp[i] > 0) request.tp = NormalizeDouble(mTick.bid - tp[i]*_Point,_Digits);
      }
      Print("digits", _Digits);
      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
    
}
void OrderCloseAll(void){
   MqlTradeRequest request;
   MqlTradeResult  result;
   for(int i=PositionsTotal()-1; i>=0; i--){
      ulong  position_ticket = PositionGetTicket(i);
      string position_symbol = PositionGetString(POSITION_SYMBOL);
      int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
      ulong  mMagic = 123456;
      double volume = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      ZeroMemory(request);
      ZeroMemory(result);
      request.action    = TRADE_ACTION_CLOSE_BY;
      request.magic     = mMagic;
      request.position  = position_ticket;
      request.symbol    = position_symbol;      
      request.volume    = volume;                                    
      
      if(type==POSITION_TYPE_BUY && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type   = ORDER_TYPE_SELL;
         request.type_filling = ORDER_FILLING_FOK;
      }
      else if(type==POSITION_TYPE_SELL && position_symbol==_Symbol){
         request.price  = SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         request.type   = ORDER_TYPE_BUY;
         request.type_filling = ORDER_FILLING_FOK;
      }
      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   }
}
//+-----------------------TimeFrame Change----------------
void ChangeTF(ENUM_TIMEFRAMES period)
{  // Get the current chart ID
    long chartID = ChartID();
    
    // Change the timeframe of the current chart to M1
    if (!ChartSetSymbolPeriod(chartID, _Symbol, period)) {
        Print("Failed to change timeframe to M1. Error: ", GetLastError());
    } else {
        Print("Timeframe changed to M1 successfully.");
    }
}
//+--------------------Set Changed TimeFrame------------------------   
void SetAnalyzePeriod(string timeframe)
{
   if(time_frame=="15m")
   {
      AnalyzePeriod=PERIOD_M1;
   }
   else if(time_frame=="1H")
   {
      AnalyzePeriod=PERIOD_M15;
   }
   else if(time_frame=="4H")
   {
      AnalyzePeriod=PERIOD_H1;
   }
   else if(time_frame=="Daily")
   {
      AnalyzePeriod=PERIOD_H4;
   }
}


//+-------------------------send testa
void example()
{
   double entryPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double sl = entryPrice + stop_loss * _Point;
   double tp = entryPrice + 50 * _Point;
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   request.action       = TRADE_ACTION_DEAL;
   request.magic        = 123456;
   request.symbol       = Symbol();
   request.volume       = lot_size;
   request.price        = entryPrice;
   request.type_filling = ORDER_FILLING_IOC;
   request.type_time = ORDER_TIME_GTC;
   request.deviation    = 10;
   request.type         = ORDER_TYPE_SELL;
   MqlTick mTick;
   if(SymbolInfoTick(_Symbol,mTick)){
      if(sl > 0) request.sl = NormalizeDouble(mTick.bid + sl*_Point,_Digits);
      if(tp > 0) request.tp = NormalizeDouble(mTick.bid - tp*_Point,_Digits);
   }
   Print("digits", _Digits);
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
}