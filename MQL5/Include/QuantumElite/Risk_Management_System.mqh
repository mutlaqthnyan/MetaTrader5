//+------------------------------------------------------------------+
//|                                           Risk_Management_System.mqh |
//|                                  Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Session Risk Profile Structure                                   |
//+------------------------------------------------------------------+
struct SessionRiskProfile
{
   double asianMultiplier;      // مخاطرة أقل
   double londonMultiplier;     // مخاطرة أعلى  
   double nyMultiplier;         // مخاطرة عادية
   double overlapMultiplier;    // مخاطرة عالية
   double newsMultiplier;       // مخاطرة منخفضة جداً
   
   SessionRiskProfile()
   {
      asianMultiplier = 0.7;
      londonMultiplier = 1.2;
      nyMultiplier = 1.0;
      overlapMultiplier = 1.5;
      newsMultiplier = 0.3;
   }
};

//+------------------------------------------------------------------+
//| Trade History Structure                                          |
//+------------------------------------------------------------------+
struct TradeHistory
{
   double profit;
   bool isWin;
   datetime closeTime;
   string symbol;
};

//+------------------------------------------------------------------+
//| Capital Protection Class                                         |
//+------------------------------------------------------------------+
class CCapitalProtection
{
private:
   double m_dailyLossLimit;
   double m_weeklyDrawdownLimit;
   int m_maxConsecutiveLosses;
   int m_currentConsecutiveLosses;
   double m_dailyStartBalance;
   double m_weeklyStartBalance;
   datetime m_lastResetDate;
   datetime m_lastWeeklyResetDate;
   
public:
   CCapitalProtection();
   ~CCapitalProtection();
   
   bool CheckDailyLimit();
   bool CheckWeeklyDrawdown();
   bool CheckConsecutiveLosses();
   void AdjustRiskParameters();
   void UpdateTradeResult(bool isWin);
   void ResetDailyCounters();
   void ResetWeeklyCounters();
};

//+------------------------------------------------------------------+
//| Risk Management System Class                                    |
//+------------------------------------------------------------------+
class CRiskManagementSystem
{
private:
   CCapitalProtection* m_capitalProtection;
   SessionRiskProfile m_sessionProfile;
   TradeHistory m_tradeHistory[];
   int m_historySize;
   double m_baseRiskPercent;
   double m_maxKellyPercent;
   double m_minKellyPercent;
   double m_maxCurrencyExposure;
   double m_maxCorrelationThreshold;
   
   // Private methods
   double CalculateWinRate(int lookbackPeriods);
   double CalculateAverageWin();
   double CalculateAverageLoss();
   double GetSessionMultiplier();
   bool IsNewsTime();
   void LoadTradeHistory();
   void UpdateTradeHistory(double profit, bool isWin, string symbol);
   
public:
   CRiskManagementSystem();
   ~CRiskManagementSystem();
   
   // Kelly Criterion Implementation
   double CalculateKellySize(string symbol);
   
   // Correlation Management
   double CheckCorrelationRisk(string symbol);
   double CalculateCurrencyExposure(string baseCurrency);
   
   // Position Sizing
   double CalculatePositionSize(string symbol, double stopLoss);
   
   // Risk Validation
   bool ValidateTradeRisk(string symbol, double lotSize);
   
   // Settings
   void SetBaseRiskPercent(double riskPercent) { m_baseRiskPercent = riskPercent; }
   void SetKellyLimits(double minPercent, double maxPercent);
   void SetCorrelationThreshold(double threshold) { m_maxCorrelationThreshold = threshold; }
   void SetMaxCurrencyExposure(double exposure) { m_maxCurrencyExposure = exposure; }
   
   // Getters
   double GetCurrentRiskLevel();
   string GetRiskStatus();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCapitalProtection::CCapitalProtection()
{
   m_dailyLossLimit = 0.05;  // 5% daily loss limit
   m_weeklyDrawdownLimit = 0.10;  // 10% weekly drawdown limit
   m_maxConsecutiveLosses = 5;
   m_currentConsecutiveLosses = 0;
   m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_weeklyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_lastResetDate = TimeCurrent();
   m_lastWeeklyResetDate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCapitalProtection::~CCapitalProtection()
{
}

//+------------------------------------------------------------------+
//| Check Daily Loss Limit                                          |
//+------------------------------------------------------------------+
bool CCapitalProtection::CheckDailyLimit()
{
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);
   
   MqlDateTime lastResetStruct;
   TimeToStruct(m_lastResetDate, lastResetStruct);
   
   // Reset daily counters if new day
   if(timeStruct.day != lastResetStruct.day)
   {
      ResetDailyCounters();
   }
   
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyLoss = (m_dailyStartBalance - currentBalance) / m_dailyStartBalance;
   
   if(dailyLoss > m_dailyLossLimit)
   {
      Print("⚠️ Daily loss limit exceeded: ", DoubleToString(dailyLoss * 100, 2), "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check Weekly Drawdown                                           |
//+------------------------------------------------------------------+
bool CCapitalProtection::CheckWeeklyDrawdown()
{
   datetime currentTime = TimeCurrent();
   
   // Check if a week has passed
   if(currentTime - m_lastWeeklyResetDate > 7 * 24 * 3600)
   {
      ResetWeeklyCounters();
   }
   
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double weeklyDrawdown = (m_weeklyStartBalance - currentEquity) / m_weeklyStartBalance;
   
   if(weeklyDrawdown > m_weeklyDrawdownLimit)
   {
      Print("⚠️ Weekly drawdown limit exceeded: ", DoubleToString(weeklyDrawdown * 100, 2), "%");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check Consecutive Losses                                        |
//+------------------------------------------------------------------+
bool CCapitalProtection::CheckConsecutiveLosses()
{
   if(m_currentConsecutiveLosses >= m_maxConsecutiveLosses)
   {
      Print("⚠️ Maximum consecutive losses reached: ", m_currentConsecutiveLosses);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Adjust Risk Parameters                                          |
//+------------------------------------------------------------------+
void CCapitalProtection::AdjustRiskParameters()
{
   // Implementation for dynamic risk adjustment
   // This will be called by the main risk management system
}

//+------------------------------------------------------------------+
//| Update Trade Result                                             |
//+------------------------------------------------------------------+
void CCapitalProtection::UpdateTradeResult(bool isWin)
{
   if(isWin)
   {
      m_currentConsecutiveLosses = 0;
   }
   else
   {
      m_currentConsecutiveLosses++;
   }
}

//+------------------------------------------------------------------+
//| Reset Daily Counters                                           |
//+------------------------------------------------------------------+
void CCapitalProtection::ResetDailyCounters()
{
   m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_lastResetDate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Reset Weekly Counters                                          |
//+------------------------------------------------------------------+
void CCapitalProtection::ResetWeeklyCounters()
{
   m_weeklyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_lastWeeklyResetDate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Risk Management System Constructor                              |
//+------------------------------------------------------------------+
CRiskManagementSystem::CRiskManagementSystem()
{
   m_capitalProtection = new CCapitalProtection();
   m_historySize = 100;
   m_baseRiskPercent = 0.02;  // 2% base risk
   m_maxKellyPercent = 0.25;  // 25% max Kelly
   m_minKellyPercent = 0.005; // 0.5% min Kelly
   m_maxCurrencyExposure = 0.30; // 30% max currency exposure
   m_maxCorrelationThreshold = 0.8; // 80% correlation threshold
   
   ArrayResize(m_tradeHistory, m_historySize);
   LoadTradeHistory();
}

//+------------------------------------------------------------------+
//| Risk Management System Destructor                              |
//+------------------------------------------------------------------+
CRiskManagementSystem::~CRiskManagementSystem()
{
   if(m_capitalProtection != NULL)
   {
      delete m_capitalProtection;
      m_capitalProtection = NULL;
   }
}

//+------------------------------------------------------------------+
//| Calculate Kelly Criterion Size                                  |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateKellySize(string symbol)
{
   // Validate account balance
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double margin = AccountInfoDouble(ACCOUNT_MARGIN);
   
   if(balance <= 0)
   {
      Print("⚠️ Invalid balance: ", balance);
      return 0;
   }
   
   if(equity < balance * 0.5)
   {
      Print("⚠️ Equity < 50% of balance!");
      return 0;
   }
   
   // Calculate from last 100 trades
   double winRate = CalculateWinRate(100);
   double avgWin = CalculateAverageWin();
   double avgLoss = CalculateAverageLoss();
   
   // Avoid division by zero
   if(avgLoss == 0) avgLoss = 0.0001;
   
   // Kelly formula: f = (p × b - q) / b
   // where: p = win rate, q = 1-p, b = win/loss ratio
   double winLossRatio = avgWin / MathAbs(avgLoss);
   double lossRate = 1.0 - winRate;
   
   double kellyPercent = (winRate * winLossRatio - lossRate) / winLossRatio;
   
   // Validate Kelly calculation
   if(kellyPercent > 1.0 || kellyPercent < 0)
   {
      Print("Kelly calculation error: ", kellyPercent);
      return m_baseRiskPercent;
   }
   
   // Apply safety limits
   kellyPercent = MathMax(kellyPercent, m_minKellyPercent);
   kellyPercent = MathMin(kellyPercent, m_maxKellyPercent);
   
   // Adjust for market conditions
   double sessionMultiplier = GetSessionMultiplier();
   kellyPercent *= sessionMultiplier;
   
   return kellyPercent;
}

//+------------------------------------------------------------------+
//| Calculate Win Rate                                              |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateWinRate(int lookbackPeriods)
{
   if(ArraySize(m_tradeHistory) == 0) return 0.5; // Default 50% if no history
   
   int wins = 0;
   int totalTrades = MathMin(lookbackPeriods, ArraySize(m_tradeHistory));
   
   for(int i = 0; i < totalTrades; i++)
   {
      if(m_tradeHistory[i].isWin) wins++;
   }
   
   return totalTrades > 0 ? (double)wins / totalTrades : 0.5;
}

//+------------------------------------------------------------------+
//| Calculate Average Win                                           |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateAverageWin()
{
   double totalWins = 0;
   int winCount = 0;
   
   for(int i = 0; i < ArraySize(m_tradeHistory); i++)
   {
      if(m_tradeHistory[i].isWin && m_tradeHistory[i].profit > 0)
      {
         totalWins += m_tradeHistory[i].profit;
         winCount++;
      }
   }
   
   return winCount > 0 ? totalWins / winCount : 1.0;
}

//+------------------------------------------------------------------+
//| Calculate Average Loss                                          |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateAverageLoss()
{
   double totalLosses = 0;
   int lossCount = 0;
   
   for(int i = 0; i < ArraySize(m_tradeHistory); i++)
   {
      if(!m_tradeHistory[i].isWin && m_tradeHistory[i].profit < 0)
      {
         totalLosses += MathAbs(m_tradeHistory[i].profit);
         lossCount++;
      }
   }
   
   return lossCount > 0 ? totalLosses / lossCount : 1.0;
}

//+------------------------------------------------------------------+
//| Get Session Multiplier                                         |
//+------------------------------------------------------------------+
double CRiskManagementSystem::GetSessionMultiplier()
{
   if(IsNewsTime()) return m_sessionProfile.newsMultiplier;
   
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(), timeStruct);
   int hour = timeStruct.hour;
   
   // Asian Session (23:00-08:00 GMT)
   if(hour >= 23 || hour < 8) return m_sessionProfile.asianMultiplier;
   
   // London Session (08:00-17:00 GMT)
   if(hour >= 8 && hour < 17) return m_sessionProfile.londonMultiplier;
   
   // NY Session (13:00-22:00 GMT)
   if(hour >= 13 && hour < 22) return m_sessionProfile.nyMultiplier;
   
   // Overlap periods get higher multiplier
   if((hour >= 8 && hour < 12) || (hour >= 13 && hour < 17))
      return m_sessionProfile.overlapMultiplier;
   
   return 1.0;
}

//+------------------------------------------------------------------+
//| Check if News Time                                             |
//+------------------------------------------------------------------+
bool CRiskManagementSystem::IsNewsTime()
{
   // This should be implemented with a news calendar
   // For now, return false as placeholder
   return false;
}

//+------------------------------------------------------------------+
//| Check Correlation Risk                                          |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CheckCorrelationRisk(string symbol)
{
   // Get all open positions
   int totalPositions = PositionsTotal();
   double maxCorrelation = 0.0;
   
   for(int i = 0; i < totalPositions; i++)
   {
      string positionSymbol = PositionGetSymbol(i);
      if(positionSymbol == symbol) continue;
      
      // Calculate correlation between symbols
      // This is a simplified implementation
      double correlation = CalculateSymbolCorrelation(symbol, positionSymbol);
      maxCorrelation = MathMax(maxCorrelation, correlation);
   }
   
   if(maxCorrelation > m_maxCorrelationThreshold)
   {
      Print("⚠️ High correlation risk detected: ", DoubleToString(maxCorrelation, 3));
      return 0.0; // Reject trade
   }
   
   return 1.0 - (maxCorrelation * 0.5); // Reduce position size based on correlation
}

//+------------------------------------------------------------------+
//| Calculate Symbol Correlation                                   |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateSymbolCorrelation(string symbol1, string symbol2)
{
   // Simplified correlation calculation
   // In a real implementation, this would calculate price correlation
   // over a specific period using historical data
   
   string base1 = StringSubstr(symbol1, 0, 3);
   string quote1 = StringSubstr(symbol1, 3, 3);
   string base2 = StringSubstr(symbol2, 0, 3);
   string quote2 = StringSubstr(symbol2, 3, 3);
   
   // High correlation if same base or quote currency
   if(base1 == base2 || quote1 == quote2 || base1 == quote2 || quote1 == base2)
      return 0.8;
   
   // Medium correlation for related currencies (example: EUR/GBP correlation)
   if((base1 == "EUR" && base2 == "GBP") || (base1 == "GBP" && base2 == "EUR"))
      return 0.6;
   
   return 0.2; // Low default correlation
}

//+------------------------------------------------------------------+
//| Calculate Currency Exposure                                    |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculateCurrencyExposure(string baseCurrency)
{
   double totalExposure = 0.0;
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   int totalPositions = PositionsTotal();
   
   for(int i = 0; i < totalPositions; i++)
   {
      string positionSymbol = PositionGetSymbol(i);
      string positionBase = StringSubstr(positionSymbol, 0, 3);
      string positionQuote = StringSubstr(positionSymbol, 3, 3);
      
      if(positionBase == baseCurrency || positionQuote == baseCurrency)
      {
         double positionVolume = PositionGetDouble(POSITION_VOLUME);
         double positionValue = positionVolume * SymbolInfoDouble(positionSymbol, SYMBOL_TRADE_TICK_VALUE);
         totalExposure += positionValue;
      }
   }
   
   double exposurePercent = totalExposure / accountBalance;
   
   if(exposurePercent > m_maxCurrencyExposure)
   {
      Print("⚠️ Currency exposure limit exceeded for ", baseCurrency, ": ", 
            DoubleToString(exposurePercent * 100, 2), "%");
      return 0.0;
   }
   
   return 1.0 - (exposurePercent / m_maxCurrencyExposure);
}

//+------------------------------------------------------------------+
//| Calculate Position Size                                         |
//+------------------------------------------------------------------+
double CRiskManagementSystem::CalculatePositionSize(string symbol, double stopLoss)
{
   // Check capital protection first
   if(!m_capitalProtection.CheckDailyLimit() || 
      !m_capitalProtection.CheckWeeklyDrawdown() || 
      !m_capitalProtection.CheckConsecutiveLosses())
   {
      return 0.0;
   }
   
   // Calculate Kelly size
   double kellySize = CalculateKellySize(symbol);
   
   // Check correlation risk
   double correlationMultiplier = CheckCorrelationRisk(symbol);
   if(correlationMultiplier == 0.0) return 0.0;
   
   // Check currency exposure
   string baseCurrency = StringSubstr(symbol, 0, 3);
   double exposureMultiplier = CalculateCurrencyExposure(baseCurrency);
   if(exposureMultiplier == 0.0) return 0.0;
   
   // Calculate final position size
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = accountBalance * kellySize * correlationMultiplier * exposureMultiplier;
   
   // Calculate lot size based on stop loss
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   if(stopLoss <= 0 || tickValue <= 0 || pointValue <= 0)
   {
      Print("⚠️ Invalid parameters for position size calculation");
      return 0.0;
   }
   
   double stopLossPoints = stopLoss / pointValue;
   double lotSize = riskAmount / (stopLossPoints * tickValue);
   
   // Apply minimum and maximum lot size limits
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);
   
   // Round to lot step
   lotSize = MathRound(lotSize / lotStep) * lotStep;
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Validate Trade Risk                                             |
//+------------------------------------------------------------------+
bool CRiskManagementSystem::ValidateTradeRisk(string symbol, double lotSize)
{
   // Final validation before trade execution
   if(lotSize <= 0) return false;
   
   // Check margin requirements
   double marginRequired = 0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY, symbol, lotSize, 
                       SymbolInfoDouble(symbol, SYMBOL_ASK), marginRequired))
   {
      Print("⚠️ Cannot calculate margin for ", symbol);
      return false;
   }
   
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(marginRequired > freeMargin * 0.8) // Use max 80% of free margin
   {
      Print("⚠️ Insufficient margin. Required: ", marginRequired, 
            ", Available: ", freeMargin);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Load Trade History                                              |
//+------------------------------------------------------------------+
void CRiskManagementSystem::LoadTradeHistory()
{
   // Load historical trades from account history
   // This is a simplified implementation
   int historyTotal = HistoryDealsTotal();
   int loadedTrades = 0;
   
   for(int i = historyTotal - 1; i >= 0 && loadedTrades < m_historySize; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
      {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         datetime closeTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         
         m_tradeHistory[loadedTrades].profit = profit;
         m_tradeHistory[loadedTrades].isWin = profit > 0;
         m_tradeHistory[loadedTrades].closeTime = closeTime;
         m_tradeHistory[loadedTrades].symbol = symbol;
         
         loadedTrades++;
      }
   }
}

//+------------------------------------------------------------------+
//| Update Trade History                                            |
//+------------------------------------------------------------------+
void CRiskManagementSystem::UpdateTradeHistory(double profit, bool isWin, string symbol)
{
   // Shift array and add new trade
   for(int i = ArraySize(m_tradeHistory) - 1; i > 0; i--)
   {
      m_tradeHistory[i] = m_tradeHistory[i-1];
   }
   
   m_tradeHistory[0].profit = profit;
   m_tradeHistory[0].isWin = isWin;
   m_tradeHistory[0].closeTime = TimeCurrent();
   m_tradeHistory[0].symbol = symbol;
   
   // Update capital protection
   m_capitalProtection.UpdateTradeResult(isWin);
}

//+------------------------------------------------------------------+
//| Set Kelly Limits                                               |
//+------------------------------------------------------------------+
void CRiskManagementSystem::SetKellyLimits(double minPercent, double maxPercent)
{
   m_minKellyPercent = MathMax(minPercent, 0.001); // Minimum 0.1%
   m_maxKellyPercent = MathMin(maxPercent, 0.5);   // Maximum 50%
}

//+------------------------------------------------------------------+
//| Get Current Risk Level                                          |
//+------------------------------------------------------------------+
double CRiskManagementSystem::GetCurrentRiskLevel()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double margin = AccountInfoDouble(ACCOUNT_MARGIN);
   
   if(balance <= 0) return 0.0;
   
   double riskLevel = (margin / equity) * 100;
   return riskLevel;
}

//+------------------------------------------------------------------+
//| Get Risk Status                                                 |
//+------------------------------------------------------------------+
string CRiskManagementSystem::GetRiskStatus()
{
   double riskLevel = GetCurrentRiskLevel();
   
   if(riskLevel < 20) return "LOW";
   else if(riskLevel < 50) return "MEDIUM";
   else if(riskLevel < 80) return "HIGH";
   else return "CRITICAL";
}

//+------------------------------------------------------------------+
