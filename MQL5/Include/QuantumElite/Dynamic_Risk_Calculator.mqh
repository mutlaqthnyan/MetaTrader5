//+------------------------------------------------------------------+
//|                                        Dynamic_Risk_Calculator.mqh |
//|                                  Copyright 2024, Quantum Trading Systems |
//|                                             https://quantumelite.trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Volatility Profile Structure                                    |
//+------------------------------------------------------------------+
struct VolatilityProfile
{
   double currentATR;           // متوسط المدى الحقيقي الحالي
   double historicalATR;        // متوسط المدى الحقيقي التاريخي
   double volatilityRatio;      // نسبة التقلب
   double adjustmentFactor;     // عامل التعديل
   
   VolatilityProfile()
   {
      currentATR = 0.0;
      historicalATR = 0.0;
      volatilityRatio = 1.0;
      adjustmentFactor = 1.0;
   }
};

//+------------------------------------------------------------------+
//| News Impact Structure                                            |
//+------------------------------------------------------------------+
struct NewsImpact
{
   datetime newsTime;           // وقت الخبر
   int impactLevel;            // مستوى التأثير (1-3)
   string currency;            // العملة المتأثرة
   double riskReduction;       // تقليل المخاطرة
   
   NewsImpact()
   {
      newsTime = 0;
      impactLevel = 0;
      currency = "";
      riskReduction = 0.3;
   }
};

//+------------------------------------------------------------------+
//| Dynamic Risk Calculator Class                                   |
//+------------------------------------------------------------------+
class CDynamicRiskCalculator
{
private:
   VolatilityProfile m_volatilityProfile;
   NewsImpact m_newsImpacts[];
   double m_baseStopLoss;
   double m_baseTakeProfit;
   double m_maxVolatilityMultiplier;
   double m_minVolatilityMultiplier;
   int m_atrPeriod;
   int m_lookbackPeriod;
   
   // Private methods
   double CalculateATR(string symbol, int period);
   double GetHistoricalATR(string symbol, int lookbackDays);
   double CalculateVolatilityRatio(string symbol);
   bool IsNewsTime(string currency);
   double GetNewsImpactFactor(string symbol);
   double GetSessionVolatilityMultiplier();
   
public:
   CDynamicRiskCalculator();
   ~CDynamicRiskCalculator();
   
   // Dynamic SL/TP calculations - حسابات SL/TP الديناميكية
   double CalculateDynamicStopLoss(string symbol, double entryPrice, int orderType);
   double CalculateDynamicTakeProfit(string symbol, double entryPrice, int orderType);
   
   // Volatility adjustments
   double AdjustForVolatility(string symbol, double baseValue);
   VolatilityProfile GetVolatilityProfile(string symbol);
   
   // Session-based modifications
   double ApplySessionAdjustment(double baseValue);
   
   // News impact calculations
   void AddNewsEvent(datetime newsTime, int impact, string currency);
   double CalculateNewsImpact(string symbol);
   
   // Settings
   void SetBaseStopLoss(double stopLoss) { m_baseStopLoss = stopLoss; }
   void SetBaseTakeProfit(double takeProfit) { m_baseTakeProfit = takeProfit; }
   void SetVolatilityLimits(double minMult, double maxMult);
   void SetATRPeriod(int period) { m_atrPeriod = period; }
   
   // Getters
   double GetCurrentVolatilityLevel(string symbol);
   string GetRiskAdjustmentStatus(string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDynamicRiskCalculator::CDynamicRiskCalculator()
{
   m_baseStopLoss = 50.0;
   m_baseTakeProfit = 100.0;
   m_maxVolatilityMultiplier = 2.0;
   m_minVolatilityMultiplier = 0.5;
   m_atrPeriod = 14;
   m_lookbackPeriod = 30;
   
   ArrayResize(m_newsImpacts, 100);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDynamicRiskCalculator::~CDynamicRiskCalculator()
{
}

//+------------------------------------------------------------------+
//| Calculate Dynamic Stop Loss                                     |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::CalculateDynamicStopLoss(string symbol, double entryPrice, int orderType)
{
   if(entryPrice <= 0) return 0.0;
   
   // Get base stop loss in points
   double baseStopPoints = m_baseStopLoss;
   
   // Apply volatility adjustment
   double volatilityAdjusted = AdjustForVolatility(symbol, baseStopPoints);
   
   // Apply session adjustment
   double sessionAdjusted = ApplySessionAdjustment(volatilityAdjusted);
   
   // Apply news impact
   double newsImpact = CalculateNewsImpact(symbol);
   double finalStopPoints = sessionAdjusted * newsImpact;
   
   // Convert to price
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double stopLossPrice;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      stopLossPrice = entryPrice - (finalStopPoints * point);
   }
   else
   {
      stopLossPrice = entryPrice + (finalStopPoints * point);
   }
   
   return NormalizeDouble(stopLossPrice, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Calculate Dynamic Take Profit                                   |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::CalculateDynamicTakeProfit(string symbol, double entryPrice, int orderType)
{
   if(entryPrice <= 0) return 0.0;
   
   // Get base take profit in points
   double baseTpPoints = m_baseTakeProfit;
   
   // Apply volatility adjustment (opposite effect for TP)
   double volatilityProfile = GetVolatilityProfile(symbol).volatilityRatio;
   double volatilityAdjusted = baseTpPoints * volatilityProfile;
   
   // Apply session adjustment
   double sessionAdjusted = ApplySessionAdjustment(volatilityAdjusted);
   
   // Convert to price
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double takeProfitPrice;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      takeProfitPrice = entryPrice + (sessionAdjusted * point);
   }
   else
   {
      takeProfitPrice = entryPrice - (sessionAdjusted * point);
   }
   
   return NormalizeDouble(takeProfitPrice, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Adjust for Volatility                                          |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::AdjustForVolatility(string symbol, double baseValue)
{
   VolatilityProfile profile = GetVolatilityProfile(symbol);
   
   double adjustedValue = baseValue * profile.adjustmentFactor;
   
   // Apply limits
   double maxValue = baseValue * m_maxVolatilityMultiplier;
   double minValue = baseValue * m_minVolatilityMultiplier;
   
   adjustedValue = MathMax(adjustedValue, minValue);
   adjustedValue = MathMin(adjustedValue, maxValue);
   
   return adjustedValue;
}

//+------------------------------------------------------------------+
//| Get Volatility Profile                                         |
//+------------------------------------------------------------------+
VolatilityProfile CDynamicRiskCalculator::GetVolatilityProfile(string symbol)
{
   VolatilityProfile profile;
   
   profile.currentATR = CalculateATR(symbol, m_atrPeriod);
   profile.historicalATR = GetHistoricalATR(symbol, m_lookbackPeriod);
   
   if(profile.historicalATR > 0)
   {
      profile.volatilityRatio = profile.currentATR / profile.historicalATR;
   }
   else
   {
      profile.volatilityRatio = 1.0;
   }
   
   // Calculate adjustment factor
   if(profile.volatilityRatio > 1.2)
   {
      profile.adjustmentFactor = 1.5; // High volatility - increase stops
   }
   else if(profile.volatilityRatio < 0.8)
   {
      profile.adjustmentFactor = 0.7; // Low volatility - tighten stops
   }
   else
   {
      profile.adjustmentFactor = 1.0; // Normal volatility
   }
   
   return profile;
}

//+------------------------------------------------------------------+
//| Calculate ATR                                                   |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::CalculateATR(string symbol, int period)
{
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   
   int handle = iATR(symbol, PERIOD_CURRENT, period);
   if(handle == INVALID_HANDLE) return 0.0;
   
   if(CopyBuffer(handle, 0, 0, 1, atrArray) <= 0) return 0.0;
   
   IndicatorRelease(handle);
   return atrArray[0];
}

//+------------------------------------------------------------------+
//| Get Historical ATR                                             |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::GetHistoricalATR(string symbol, int lookbackDays)
{
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   
   int handle = iATR(symbol, PERIOD_D1, 14);
   if(handle == INVALID_HANDLE) return 0.0;
   
   if(CopyBuffer(handle, 0, 0, lookbackDays, atrArray) <= 0) return 0.0;
   
   double sum = 0.0;
   for(int i = 0; i < lookbackDays; i++)
   {
      sum += atrArray[i];
   }
   
   IndicatorRelease(handle);
   return sum / lookbackDays;
}

//+------------------------------------------------------------------+
//| Apply Session Adjustment                                       |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::ApplySessionAdjustment(double baseValue)
{
   double sessionMultiplier = GetSessionVolatilityMultiplier();
   return baseValue * sessionMultiplier;
}

//+------------------------------------------------------------------+
//| Get Session Volatility Multiplier                             |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::GetSessionVolatilityMultiplier()
{
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(), timeStruct);
   int hour = timeStruct.hour;
   
   // Asian Session (23:00-08:00 GMT) - Lower volatility
   if(hour >= 23 || hour < 8) return 0.8;
   
   // London Session (08:00-17:00 GMT) - Higher volatility
   if(hour >= 8 && hour < 17) return 1.2;
   
   // NY Session (13:00-22:00 GMT) - Normal volatility
   if(hour >= 13 && hour < 22) return 1.0;
   
   // Overlap periods - Highest volatility
   if((hour >= 8 && hour < 12) || (hour >= 13 && hour < 17))
      return 1.4;
   
   return 1.0;
}

//+------------------------------------------------------------------+
//| Add News Event                                                 |
//+------------------------------------------------------------------+
void CDynamicRiskCalculator::AddNewsEvent(datetime newsTime, int impact, string currency)
{
   int size = ArraySize(m_newsImpacts);
   for(int i = 0; i < size; i++)
   {
      if(m_newsImpacts[i].newsTime == 0)
      {
         m_newsImpacts[i].newsTime = newsTime;
         m_newsImpacts[i].impactLevel = impact;
         m_newsImpacts[i].currency = currency;
         
         // Set risk reduction based on impact level
         switch(impact)
         {
            case 1: m_newsImpacts[i].riskReduction = 0.9; break; // Low impact
            case 2: m_newsImpacts[i].riskReduction = 0.6; break; // Medium impact
            case 3: m_newsImpacts[i].riskReduction = 0.3; break; // High impact
            default: m_newsImpacts[i].riskReduction = 0.8; break;
         }
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate News Impact                                          |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::CalculateNewsImpact(string symbol)
{
   string baseCurrency = StringSubstr(symbol, 0, 3);
   string quoteCurrency = StringSubstr(symbol, 3, 3);
   
   datetime currentTime = TimeCurrent();
   double impactFactor = 1.0;
   
   for(int i = 0; i < ArraySize(m_newsImpacts); i++)
   {
      if(m_newsImpacts[i].newsTime == 0) continue;
      
      // Check if news is within 2 hours
      if(MathAbs(currentTime - m_newsImpacts[i].newsTime) <= 2 * 3600)
      {
         if(m_newsImpacts[i].currency == baseCurrency || 
            m_newsImpacts[i].currency == quoteCurrency)
         {
            impactFactor = MathMin(impactFactor, m_newsImpacts[i].riskReduction);
         }
      }
   }
   
   return impactFactor;
}

//+------------------------------------------------------------------+
//| Set Volatility Limits                                         |
//+------------------------------------------------------------------+
void CDynamicRiskCalculator::SetVolatilityLimits(double minMult, double maxMult)
{
   m_minVolatilityMultiplier = MathMax(minMult, 0.1);
   m_maxVolatilityMultiplier = MathMin(maxMult, 5.0);
}

//+------------------------------------------------------------------+
//| Get Current Volatility Level                                  |
//+------------------------------------------------------------------+
double CDynamicRiskCalculator::GetCurrentVolatilityLevel(string symbol)
{
   return GetVolatilityProfile(symbol).volatilityRatio;
}

//+------------------------------------------------------------------+
//| Get Risk Adjustment Status                                    |
//+------------------------------------------------------------------+
string CDynamicRiskCalculator::GetRiskAdjustmentStatus(string symbol)
{
   VolatilityProfile profile = GetVolatilityProfile(symbol);
   double newsImpact = CalculateNewsImpact(symbol);
   
   string status = "Normal";
   
   if(profile.volatilityRatio > 1.5)
      status = "High Volatility - Increased Stops";
   else if(profile.volatilityRatio < 0.6)
      status = "Low Volatility - Tightened Stops";
   
   if(newsImpact < 0.8)
      status += " | News Impact Active";
   
   return status;
}
