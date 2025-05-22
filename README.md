# SEW_Trade Expert Advisor (MT5)

**SEW_Trade** is a fully automated Expert Advisor (EA) for MetaTrader 5 (MT5), designed to identify trade entries based on SMA/EMA crossover strategies and confirm them using the Waddah Attar Explosion (WAE) indicator. It includes a custom-built interactive trade panel for flexible user control over trade parameters.

---

## 📦 Features

- **Interactive Trade Panel**:
  - Select timeframe (15m, 1H, 4H, Daily)
  - Adjustable Lot Size, Stop Loss, and up to 5 Take Profits
  - Enable/Disable Buy and Sell independently
  - Buttons to Start Trade or Close All Orders

- **Indicators Used**:
  - **SMA(13)** – Simple Moving Average
  - **EMA(21)** – Exponential Moving Average
  - **Waddah Attar Explosion** – Custom momentum and volatility confirmation

- **Trade Logic**:
  - Entry signal: SMA/EMA crossover (bearish only as coded)
  - Confirmation: Explosion line > Signal line & green vector from WAE
  - Multi-target Take Profit system (up to 5 levels)
  - Adjustable Stop Loss
  - Optional dual-direction (Buy/Sell) or single-side trades

- **Other Highlights**:
  - Real-time chart annotations (cross lines)
  - Timeframe auto-switching for analysis vs. trade execution
  - Full MQL5 integration with robust error handling and logging

---

## 🚀 Getting Started

### Prerequisites
- MetaTrader 5 terminal
- Waddah Attar Explosion (`waddah_attar_explosion.ex5`) placed in `Indicators` folder

### Installation
1. Place the files in appropriate directories:
   - `SEW_Trade.mq5` → `/MQL5/Experts/`
   - `panel.mqh` and related UI code → `/MQL5/Include/SEW_Trade/`
2. Compile `SEW_Trade.mq5` in MetaEditor.
3. Attach the EA to a chart in MT5.
4. Enable AutoTrading.

---

## 🧠 How It Works

1. **Initialization**:
   - The EA loads SMA, EMA, and WAE indicators.
   - UI panel is rendered on the chart.

2. **Signal Detection**:
   - Monitors price data every tick.
   - If bearish SMA/EMA crossover is detected and WAE confirms it, trade is triggered.

3. **Trade Execution**:
   - Uses market orders with TP/SL based on user input.
   - Multiple TP levels allow scaling out positions.

4. **Controls**:
   - Use the panel to change parameters anytime.
   - `StartTrade` button triggers a manual signal check.
   - `CloseAll` exits all open positions for the symbol.

---

## 🛠 Parameters

| Parameter           | Description                                |
|---------------------|--------------------------------------------|
| `SMA_Period`        | Period for Simple Moving Average (default: 13) |
| `EMA_Period`        | Period for Exponential Moving Average (default: 21) |
| `MagicNumber`       | Magic number for identifying EA's orders   |
| `Deviation`         | Maximum slippage allowed                   |
| `Fast_MA`, `Slow_MA`| WAE fast and slow MA settings              |
| `BBPeriod`          | Bollinger Band period for WAE             |
| `BBDeviation`       | Bollinger Band deviation                  |
| `Sensetive`, `DeadZonePip`, `ExplosionPower`, `TrendPower` | Advanced WAE tuning parameters |
| `Alert*` flags      | WAE alert controls (not used directly in EA) |

---

## 📊 Panel Layout

The panel allows real-time control over:

- Timeframe (`TF`)
- Lot Size
- Stop Loss
- Take Profits (TP1–TP5)
- Buy/Sell checkboxes
- Trade/Close buttons

---

## 📌 Notes

- Currently, only **bearish crossovers** (SMA above EMA) trigger trades. You can expand `IsCrossover()` to handle bullish entries.
- Multi-TP logic uses separate market orders for each target.
- Indicator handle errors and buffer copying are validated with `Print` debug logs.

---

## ✅ To-Do

- [ ] Add bullish crossover support
- [ ] Improve UI spacing and layout
- [ ] Add trailing stop or break-even logic
- [ ] Implement risk-based lot sizing
- [ ] Add trade history logging to file

---

## 🙌 Acknowledgments

- MetaQuotes (MT5)
- Waddah Attar for the Explosion Indicator
