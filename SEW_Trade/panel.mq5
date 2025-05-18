
#include "..\SEW_Trade\panel.mqh"

//+------------------------------------------------------------------+
//| Constructor & Destructor                                        |
//+------------------------------------------------------------------+
CControlPanel::CControlPanel() {}
CControlPanel::~CControlPanel() {}

//+------------------------------------------------------------------+
//| Create UI Elements                                              |
//+------------------------------------------------------------------+
bool CControlPanel::Create(const long chart_id, const string name, const int subwindow, const int x1, const int y1, const int x2, const int y2)
{
   if(!CAppDialog::Create(chart_id, name, subwindow, x1, y1, x2, y2))
      return false;

   if(!CreateUI())
      return false;

   return true;
}

//+------------------------------------------------------------------+
//| Create UI Elements                                              |
//+------------------------------------------------------------------+
bool CControlPanel::CreateUI()
{
   int x = 50, y = 10, width = 120, height = 20, gap = 5;

   // Timeframe Dropdown
   if(!m_timeframe.Create(m_chart_id, "Timeframe", m_subwin, x, y, x+width, y+height))
      return false;
   if(!Add(m_timeframe))
      return(false);
   m_timeframeN.Create(m_chart_id, "TF:", m_subwin, 30, y, 40, y+height);
   m_timeframeN.Text("TF:");
   Add(m_timeframeN);
   m_timeframe.ItemAdd("15m");
   m_timeframe.ItemAdd("1H");
   m_timeframe.ItemAdd("4H");
   m_timeframe.ItemAdd("Daily");
   m_timeframe.Select(0);
   y += height + gap;

   // Lot Size Dropdown
   if(!m_lotSize.Create(m_chart_id, "LotSize", m_subwin, x, y, x+width, y+height))
      return false;
   m_lotSizeN.Create(m_chart_id, "LotSize:", m_subwin, 3, y, 40, y+height);
   m_lotSizeN.Text("LotSize:");
   Add(m_lotSizeN);
   for(double lot = 0.01; lot <= 1.0; lot += 0.01)
      m_lotSize.ItemAdd(DoubleToString(lot, 2));
   Add(m_lotSize);
   m_lotSize.Select(0);
   y += height + gap;

   // Stop Loss Dropdown
   if(!m_stopLoss.Create(m_chart_id, "StopLoss", m_subwin, x, y, x+width, y+height))
      return false;
   m_stopLossN.Create(m_chart_id, "SL:", m_subwin, 30, y, 40, y+height);
   m_stopLossN.Text("SL:");
   Add(m_stopLossN);
   for(int sl = 10; sl <= 1000; sl += 10)
         m_stopLoss.ItemAdd(IntegerToString(sl));
   Add(m_stopLoss);
   m_stopLoss.Select(4);
   y += height + gap;

   // Take Profit Dropdown
   for(int i=1 ; i<=5 ; i++)
   {
      string tp_name = "TakeProfit" + IntegerToString(i);
      if(!m_takeProfit[i-1].Create(m_chart_id, tp_name, m_subwin, x, y, x+width, y+height))
         return false;
      for(int tp = 0; tp <= 1000; tp += 10)
      {
         if(tp==0)
            m_takeProfit[i-1].ItemAdd("Disable");
         else
            m_takeProfit[i-1].ItemAdd(IntegerToString(tp));
      }
      Add(m_takeProfit[i-1]);
      if(i==1)
         m_takeProfit[i-1].Select(2);
      else
         m_takeProfit[i-1].Select(0);         
      string ttp_name = "TP" + IntegerToString(i) + ":";
      m_takeProfitN[i-1].Create(m_chart_id, ttp_name, m_subwin, 22, y, 40, y+height);
      m_takeProfitN[i-1].Text(ttp_name);
      Add(m_takeProfitN[i-1]);
      
      y += height + gap;   
   }
   

   // buy Checkbox
   if(!m_buy.Create(m_chart_id, "Buy?", m_subwin, x, y, x+width, y+height))
      return false;
   m_buy.Text("Buy?");
   Add(m_buy);

   y += height + gap;

   // sell Checkbox
   if(!m_sell.Create(m_chart_id, "Sell?", m_subwin, x, y, x+width, y+height))
      return false;
   m_sell.Text("Sell?");
   Add(m_sell);

   y += height + gap;

   // Start Trades Button
   if(!m_tradeStartButton.Create(m_chart_id, "StartTrade", m_subwin, x-30, y, x+width, y+height))
      return false;
   m_tradeStartButton.Text("StartTrade");
   m_tradeStartButton.ColorBackground(clrSkyBlue);
   Add(m_tradeStartButton);
   y += height + gap;
   
   // Close All Trades Button
   if(!m_closeAllButton.Create(m_chart_id, "CloseAll", m_subwin, x-30, y, x+width, y+height))
      return false;
   m_closeAllButton.Text("CloseAll");
   m_closeAllButton.ColorBackground(clrOrange);
   Add(m_closeAllButton);

   return true;
}

//+------------------------------------------------------------------+
//| Event Handling                                                  |
//+------------------------------------------------------------------+
bool CControlPanel::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    return CAppDialog::OnEvent(id, lparam, dparam, sparam); // Call parent class event handler
}
//+-----------define functin-------------------------------------+
int CControlPanel::getBtnClick(string name)
{
   if(name=="CloseAll")
      return 2;
   else if(name=="StartTrade")
      return 1;
   return 0;
}
string CControlPanel::getTimeFrame()
{
   return m_timeframe.Select();
}
double CControlPanel::getLotSize()
{
   return StringToDouble(m_lotSize.Select());
}
int CControlPanel::getStopLoss()
{
   return StringToInteger(m_stopLoss.Select());
}
string CControlPanel::getTakeProfit(int i)
{
   return m_takeProfit[i].Select();
}
bool CControlPanel::IsBuy()
{
   return m_buy.Checked();
}
bool CControlPanel::IsSell()
{
   return m_sell.Checked();
}