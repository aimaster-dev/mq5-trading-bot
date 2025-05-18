#ifndef __CONTROLPANEL_MQH__
#define __CONTROLPANEL_MQH__

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\CheckBox.mqh>

//+------------------------------------------------------------------+
//| Control Panel Class                                             |
//+------------------------------------------------------------------+
class CControlPanel : public CAppDialog
{
private:
   CComboBox m_timeframe;  // Timeframe selection
   CComboBox m_lotSize;    // Lot size selection
   CComboBox m_stopLoss;   // Stop loss selection
   CComboBox m_takeProfit[5]; // Take profit selection
   CCheckBox m_buy, m_sell;
   CButton m_closeAllButton,m_tradeStartButton;
   CLabel m_timeframeN,m_lotSizeN,m_stopLossN,m_takeProfitN[5];
public:
   CControlPanel();
   ~CControlPanel();
   virtual bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) override;
   virtual bool Create(const long chart_id, const string name, const int subwindow, const int x1, const int y1, const int x2, const int y2);
   int getBtnClick(string name);
   string getTimeFrame();
   double getLotSize();
   int getStopLoss();
   string getTakeProfit(int i);
   bool IsBuy();
   bool IsSell();
protected:
   bool CreateUI();
};
#endif