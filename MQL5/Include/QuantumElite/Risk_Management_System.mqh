//+------------------------------------------------------------------+
//|                       Risk Management System                     |
//|                    نظام إدارة المخاطر المتقدم                    |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Quantum Trading Systems"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

enum ENUM_RISK_LEVEL
{
   RISK_LOW,
   RISK_MEDIUM,
   RISK_HIGH,
   RISK_CRITICAL
};

struct RiskMetrics
{
   double            dailyPnL;
   double            weeklyPnL;
   double            monthlyPnL;
   double            maxDrawdown;
   double            currentDrawdown;
   double            portfolioHeat;
   double            correlationRisk;
   ENUM_RISK_LEVEL   riskLevel;
   datetime          lastUpdate;
};

struct PositionRisk
{
   ulong             ticket;
   string            symbol;
   double            riskAmount;
   double            riskPercent;
   double            correlation;
   datetime          openTime;
};

struct TradeRecord
{
   datetime          closeTime;
   double            profit;
   double            riskAmount;
   bool              isWin;
   string            symbol;
};

class CRiskManagementSystem
{
private:
   double            m_maxRiskPerTrade;
   double            m_maxDailyRisk;
   double            m_maxDrawdown;
   double            m_accountBalance;
   double            m_accountEquity;
   
   double            m_currentDailyRisk;
   double            m_currentDrawdown;
   double            m_currentPortfolioHeat;
   double            m_maxCorrelation;
   
   RiskMetrics       m_riskMetrics;
   PositionRisk      m_positionRisks[];
   
   TradeRecord       m_tradeHistory[100];
   int               m_tradeHistoryCount;
   int               m_consecutiveLosses;
   datetime          m_lastTradeTime;
   double            m_weeklyDrawdownStart;
   datetime          m_weeklyDrawdownTime;
   
   CPositionInfo     m_position;
   CAccountInfo      m_account;
   CTrade            m_trade;
   
   bool              m_emergencyMode;
   datetime          m_lastRiskCheck;

public:
                     CRiskManagementSystem();
                    ~CRiskManagementSystem();
   
   bool              Initialize(double maxRiskPerTrade, double maxDailyRisk, double maxDrawdown);
   void              Deinitialize();
   
   bool              IsTradeAllowed(string symbol, double riskAmount);
   int               CountPositionsForSymbol(string symbol);
   double            CalculatePositionSize(string symbol, double entryPrice, double stopLoss);
   double            CalculateRiskAmount(string symbol, double entryPrice, double stopLoss);
   
   bool              CheckRiskLimits();
   void              UpdateRiskMetrics();
   void              UpdatePortfolioHeat();
   double            CheckCorrelationRisk(string symbol);
   
   ENUM_RISK_LEVEL   GetCurrentRiskLevel();
   double            GetDailyPnL();
   double            GetCurrentDrawdown();
   double            GetPortfolioHeat();
   
   bool              EmergencyCloseAll();
   void              SetEmergencyMode(bool enabled) { m_emergencyMode = enabled; }
   bool              IsEmergencyMode() { return m_emergencyMode; }
   
   string            GenerateRiskReport();
   void              LogRiskEvent(string message);
   
   double            CalculateCorrelation(string symbol1, string symbol2);
   double            CalculateVolatilityAdjustment(string symbol);
   bool              ValidateRiskParameters();
   
   double            CalculateKellyCriterion();
   void              UpdateTradeHistory(double profit, double riskAmount, string symbol);
   bool              CheckCapitalProtection();
   void              CheckWeeklyDrawdown();
   double            CalculateCurrencyExposure(string currency);
   bool              CheckEnhancedCorrelationRisk(string symbol);
   double            GetSessionRiskMultiplier();
};

CRiskManagementSystem::CRiskManagementSystem()
{
   m_maxRiskPerTrade = 1.0;
   m_maxDailyRisk = 3.0;
   m_maxDrawdown = 10.0;
   m_accountBalance = 0;
   m_accountEquity = 0;
   
   m_currentDailyRisk = 0;
   m_currentDrawdown = 0;
   m_currentPortfolioHeat = 0;
   m_maxCorrelation = 0.7;
   
   m_tradeHistoryCount = 0;
   m_consecutiveLosses = 0;
   m_lastTradeTime = 0;
   m_weeklyDrawdownStart = 0;
   m_weeklyDrawdownTime = 0;
   
   m_emergencyMode = false;
   m_lastRiskCheck = 0;
   
   ZeroMemory(m_riskMetrics);
   ZeroMemory(m_tradeHistory);
}

CRiskManagementSystem::~CRiskManagementSystem()
{
   Deinitialize();
}

bool CRiskManagementSystem::Initialize(double maxRiskPerTrade, double maxDailyRisk, double maxDrawdown)
{
   m_maxRiskPerTrade = maxRiskPerTrade;
   m_maxDailyRisk = maxDailyRisk;
   m_maxDrawdown = maxDrawdown;
   
   // تحديث معلومات الحساب تلقائياً عند الاستعلام
   if(m_account.Balance() <= 0)
   {
      Print("فشل في الحصول على معلومات الحساب");
      return false;
   }
   
   m_accountBalance = m_account.Balance();
   m_accountEquity = m_account.Equity();
   
   ArrayResize(m_positionRisks, 0);
   
   UpdateRiskMetrics();
   
   Print("تم تهيئة نظام إدارة المخاطر بنجاح");
   return true;
}

void CRiskManagementSystem::Deinitialize()
{
   ArrayFree(m_positionRisks);
}

int CRiskManagementSystem::CountPositionsForSymbol(string symbol)
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetString(POSITION_SYMBOL) == symbol)
         {
            count++;
         }
      }
   }
   return count;
}

bool CRiskManagementSystem::IsTradeAllowed(string symbol, double riskAmount)
{
   if(!CheckCapitalProtection())
   {
      return false;
   }
   
   if(!CheckEnhancedCorrelationRisk(symbol))
   {
      return false;
   }
   
   if(m_emergencyMode)
   {
      Print("وضع الطوارئ نشط - لا يُسمح بصفقات جديدة");
      return false;
   }
   
   UpdateRiskMetrics();
   
   if(m_currentDailyRisk + (riskAmount / m_accountBalance * 100) > m_maxDailyRisk)
   {
      Print("تجاوز الحد الأقصى للمخاطرة اليومية");
      return false;
   }
   
   if(m_currentDrawdown > m_maxDrawdown)
   {
      Print("تجاوز الحد الأقصى للسحب");
      return false;
   }
   
   if(CheckCorrelationRisk(symbol) > m_maxCorrelation)
   {
      Print("مخاطرة الارتباط عالية جداً للرمز: ", symbol);
      return false;
   }
   
   if(PositionsTotal() >= 10)
   {
      Print("تم الوصول للحد الأقصى من الصفقات المتزامنة");
      return false;
   }
   
   // Note: InpMaxPositionsPerSymbol is defined in the main EA files
   // This check will be handled by the main EA's IsTradeAllowed function
   
   return true;
}

double CRiskManagementSystem::CalculatePositionSize(string symbol, double entryPrice, double stopLoss)
{
   if(entryPrice <= 0 || stopLoss <= 0 || MathAbs(entryPrice - stopLoss) < 0.00001)
   {
      return 0;
   }
   
   if(!CheckCapitalProtection()) return 0;
   if(!CheckEnhancedCorrelationRisk(symbol)) return 0;
   
   double kellyRisk = CalculateKellyCriterion();
   double sessionMultiplier = GetSessionRiskMultiplier();
   double adjustedRisk = kellyRisk * sessionMultiplier;
   
   double riskAmount = m_accountBalance * adjustedRisk / 100;
   double stopDistance = MathAbs(entryPrice - stopLoss);
   
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   
   if(tickValue <= 0 || tickSize <= 0 || contractSize <= 0)
   {
      Print("معلومات الرمز غير صحيحة: ", symbol);
      return 0;
   }
   
   double volume = riskAmount / (stopDistance / tickSize * tickValue);
   
   double volatilityAdjustment = CalculateVolatilityAdjustment(symbol);
   volume *= volatilityAdjustment;
   
   double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double stepVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   volume = MathMax(volume, minVolume);
   volume = MathMin(volume, maxVolume);
   volume = MathRound(volume / stepVolume) * stepVolume;
   
   return volume;
}

double CRiskManagementSystem::CalculateRiskAmount(string symbol, double entryPrice, double stopLoss)
{
   double volume = CalculatePositionSize(symbol, entryPrice, stopLoss);
   double stopDistance = MathAbs(entryPrice - stopLoss);
   
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   
   return volume * (stopDistance / tickSize) * tickValue;
}

bool CRiskManagementSystem::CheckRiskLimits()
{
   UpdateRiskMetrics();
   
   if(m_currentDailyRisk > m_maxDailyRisk)
   {
      LogRiskEvent("تجاوز الحد الأقصى للمخاطرة اليومية: " + DoubleToString(m_currentDailyRisk, 2) + "%");
      return false;
   }
   
   if(m_currentDrawdown > m_maxDrawdown)
   {
      LogRiskEvent("تجاوز الحد الأقصى للسحب: " + DoubleToString(m_currentDrawdown, 2) + "%");
      SetEmergencyMode(true);
      return false;
   }
   
   if(m_currentPortfolioHeat > 50.0)
   {
      LogRiskEvent("حرارة المحفظة عالية: " + DoubleToString(m_currentPortfolioHeat, 2) + "%");
      return false;
   }
   
   return true;
}

void CRiskManagementSystem::UpdateRiskMetrics()
{
   // تحديث معلومات الحساب تلقائياً عند الاستعلام
   m_accountBalance = m_account.Balance();
   m_accountEquity = m_account.Equity();
   
   m_currentDailyRisk = (m_accountBalance - m_accountEquity) / m_accountBalance * 100;
   if(m_currentDailyRisk < 0) m_currentDailyRisk = 0;
   
   double dailyPnL = GetDailyPnL();
   m_currentDrawdown = -dailyPnL / m_accountBalance * 100;
   if(m_currentDrawdown < 0) m_currentDrawdown = 0;
   
   UpdatePortfolioHeat();
   
   m_riskMetrics.dailyPnL = dailyPnL;
   m_riskMetrics.currentDrawdown = m_currentDrawdown;
   m_riskMetrics.portfolioHeat = m_currentPortfolioHeat;
   m_riskMetrics.riskLevel = GetCurrentRiskLevel();
   m_riskMetrics.lastUpdate = TimeCurrent();
   
   m_lastRiskCheck = TimeCurrent();
}

void CRiskManagementSystem::UpdatePortfolioHeat()
{
   m_currentPortfolioHeat = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position.SelectByIndex(i))
      {
         double positionRisk = MathAbs(PositionGetDouble(POSITION_PROFIT)) / m_accountBalance * 100;
         m_currentPortfolioHeat += positionRisk;
      }
   }
}

double CRiskManagementSystem::CheckCorrelationRisk(string symbol)
{
   double maxCorrelation = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position.SelectByIndex(i))
      {
         string posSymbol = PositionGetString(POSITION_SYMBOL);
         if(posSymbol != symbol)
         {
            double correlation = CalculateCorrelation(symbol, posSymbol);
            maxCorrelation = MathMax(maxCorrelation, correlation);
         }
      }
   }
   
   return maxCorrelation;
}

ENUM_RISK_LEVEL CRiskManagementSystem::GetCurrentRiskLevel()
{
   if(m_currentDrawdown > m_maxDrawdown * 0.8 || m_currentDailyRisk > m_maxDailyRisk * 0.8)
   {
      return RISK_CRITICAL;
   }
   else if(m_currentDrawdown > m_maxDrawdown * 0.6 || m_currentDailyRisk > m_maxDailyRisk * 0.6)
   {
      return RISK_HIGH;
   }
   else if(m_currentDrawdown > m_maxDrawdown * 0.3 || m_currentDailyRisk > m_maxDailyRisk * 0.3)
   {
      return RISK_MEDIUM;
   }
   
   return RISK_LOW;
}

double CRiskManagementSystem::GetDailyPnL()
{
   double dailyPnL = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(m_position.SelectByIndex(i))
      {
         datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
         MqlDateTime dt;
         TimeToStruct(TimeCurrent(), dt);
         dt.hour = 0; dt.min = 0; dt.sec = 0;
         datetime todayStart = StructToTime(dt);
         
         if(openTime >= todayStart)
         {
            dailyPnL += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   
   return dailyPnL;
}

double CRiskManagementSystem::GetCurrentDrawdown()
{
   return m_currentDrawdown;
}

double CRiskManagementSystem::GetPortfolioHeat()
{
   return m_currentPortfolioHeat;
}

bool CRiskManagementSystem::EmergencyCloseAll()
{
   Print("🚨 تفعيل إغلاق الطوارئ لجميع المراكز!");
   
   bool allClosed = true;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         string symbol = PositionGetString(POSITION_SYMBOL);
         
         if(!m_trade.PositionClose(ticket))
         {
            Print("فشل إغلاق المركز: ", ticket, " - الخطأ: ", GetLastError());
            allClosed = false;
         }
         else
         {
            Print("تم إغلاق المركز: ", ticket, " للرمز: ", symbol);
         }
      }
   }
   
   if(allClosed)
   {
      Print("✅ تم إغلاق جميع المراكز بنجاح");
      SetEmergencyMode(false);
   }
   
   return allClosed;
}

string CRiskManagementSystem::GenerateRiskReport()
{
   UpdateRiskMetrics();
   
   string report = "تقرير إدارة المخاطر\n";
   report += "═══════════════════════════════════\n";
   report += "رصيد الحساب: " + DoubleToString(m_accountBalance, 2) + "\n";
   report += "حقوق الملكية: " + DoubleToString(m_accountEquity, 2) + "\n";
   report += "المخاطرة اليومية: " + DoubleToString(m_currentDailyRisk, 2) + "%\n";
   report += "السحب الحالي: " + DoubleToString(m_currentDrawdown, 2) + "%\n";
   report += "حرارة المحفظة: " + DoubleToString(m_currentPortfolioHeat, 2) + "%\n";
   
   string riskLevelStr = "";
   switch(GetCurrentRiskLevel())
   {
      case RISK_LOW: riskLevelStr = "منخفض"; break;
      case RISK_MEDIUM: riskLevelStr = "متوسط"; break;
      case RISK_HIGH: riskLevelStr = "عالي"; break;
      case RISK_CRITICAL: riskLevelStr = "حرج"; break;
   }
   
   report += "مستوى المخاطرة: " + riskLevelStr + "\n";
   report += "عدد المراكز النشطة: " + IntegerToString(PositionsTotal()) + "\n";
   report += "وضع الطوارئ: " + (m_emergencyMode ? "نشط" : "غير نشط") + "\n";
   
   return report;
}

void CRiskManagementSystem::LogRiskEvent(string message)
{
   Print("⚠️ حدث مخاطرة: ", message);
}

double CRiskManagementSystem::CalculateCorrelation(string symbol1, string symbol2)
{
   double close1[], close2[];
   ArraySetAsSeries(close1, true);
   ArraySetAsSeries(close2, true);
   
   int periods = 50;
   
   if(CopyClose(symbol1, PERIOD_CURRENT, 0, periods, close1) != periods ||
      CopyClose(symbol2, PERIOD_CURRENT, 0, periods, close2) != periods)
   {
      return 0;
   }
   
   double returns1[50], returns2[50];
   
   for(int i = 0; i < periods - 1; i++)
   {
      returns1[i] = (close1[i] - close1[i+1]) / close1[i+1];
      returns2[i] = (close2[i] - close2[i+1]) / close2[i+1];
   }
   
   double mean1 = 0, mean2 = 0;
   for(int i = 0; i < periods - 1; i++)
   {
      mean1 += returns1[i];
      mean2 += returns2[i];
   }
   mean1 /= (periods - 1);
   mean2 /= (periods - 1);
   
   double numerator = 0, denominator1 = 0, denominator2 = 0;
   
   for(int i = 0; i < periods - 1; i++)
   {
      double diff1 = returns1[i] - mean1;
      double diff2 = returns2[i] - mean2;
      
      numerator += diff1 * diff2;
      denominator1 += diff1 * diff1;
      denominator2 += diff2 * diff2;
   }
   
   if(denominator1 == 0 || denominator2 == 0)
      return 0;
   
   return numerator / MathSqrt(denominator1 * denominator2);
}

double CRiskManagementSystem::CalculateVolatilityAdjustment(string symbol)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, 20, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, 20, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, 20, close);
   
   double atr = 0;
   for(int i = 1; i < 15; i++)
   {
      double tr = MathMax(high[i] - low[i], 
                  MathMax(MathAbs(high[i] - close[i+1]), 
                          MathAbs(low[i] - close[i+1])));
      atr += tr;
   }
   atr /= 14;
   
   double volatilityRatio = atr / close[0];
   
   if(volatilityRatio > 0.03)
   {
      return 0.5;
   }
   else if(volatilityRatio > 0.02)
   {
      return 0.7;
   }
   else if(volatilityRatio > 0.01)
   {
      return 0.9;
   }
   
   return 1.0;
}

bool CRiskManagementSystem::ValidateRiskParameters()
{
   if(m_maxRiskPerTrade <= 0 || m_maxRiskPerTrade > 10)
   {
      Print("مخاطرة الصفقة الواحدة غير صحيحة: ", m_maxRiskPerTrade);
      return false;
   }
   
   if(m_maxDailyRisk <= 0 || m_maxDailyRisk > 20)
   {
      Print("المخاطرة اليومية غير صحيحة: ", m_maxDailyRisk);
      return false;
   }
   
   if(m_maxDrawdown <= 0 || m_maxDrawdown > 50)
   {
      Print("حد السحب الأقصى غير صحيح: ", m_maxDrawdown);
      return false;
   }
   
   return true;
}

double CRiskManagementSystem::CalculateKellyCriterion()
{
    if(m_tradeHistoryCount < 20) 
    {
        Print("عدد الصفقات قليل للـ Kelly Criterion، استخدام المخاطرة الافتراضية");
        return m_maxRiskPerTrade;
    }
    
    int wins = 0;
    double totalWinAmount = 0, totalLossAmount = 0;
    
    for(int i = 0; i < m_tradeHistoryCount; i++)
    {
        if(m_tradeHistory[i].isWin)
        {
            wins++;
            totalWinAmount += m_tradeHistory[i].profit;
        }
        else
        {
            totalLossAmount += MathAbs(m_tradeHistory[i].profit);
        }
    }
    
    if(wins == 0 || wins == m_tradeHistoryCount)
    {
        Print("جميع الصفقات رابحة أو خاسرة، استخدام المخاطرة الافتراضية");
        return m_maxRiskPerTrade;
    }
    
    double p = (double)wins / m_tradeHistoryCount;
    double q = 1.0 - p;
    double avgWin = totalWinAmount / wins;
    double avgLoss = totalLossAmount / (m_tradeHistoryCount - wins);
    double b = avgWin / avgLoss;
    
    double f = (p * b - q) / b;
    
    f = MathMax(f, 0.005);
    f = MathMin(f, 0.25);
    
    Print("Kelly Criterion: p=", DoubleToString(p, 3), " b=", DoubleToString(b, 3), " f=", DoubleToString(f, 3));
    
    return f * 100;
}

bool CRiskManagementSystem::CheckCapitalProtection()
{
    double dailyPnL = GetDailyPnL();
    if(dailyPnL < -m_accountBalance * 0.05)
    {
        LogRiskEvent("تم تجاوز حد الخسارة اليومية 5%: " + DoubleToString(dailyPnL, 2));
        SetEmergencyMode(true);
        return false;
    }
    
    CheckWeeklyDrawdown();
    
    if(m_consecutiveLosses >= 5)
    {
        LogRiskEvent("تم الوصول لـ 5 خسائر متتالية - إيقاف مؤقت");
        SetEmergencyMode(true);
        return false;
    }
    
    return true;
}

void CRiskManagementSystem::CheckWeeklyDrawdown()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    datetime weekStart = TimeCurrent() - (dt.day_of_week * 24 * 3600);
    
    if(m_weeklyDrawdownTime < weekStart)
    {
        m_weeklyDrawdownStart = m_accountEquity;
        m_weeklyDrawdownTime = weekStart;
    }
    
    double weeklyDrawdown = (m_weeklyDrawdownStart - m_accountEquity) / m_weeklyDrawdownStart;
    if(weeklyDrawdown > 0.10)
    {
        m_maxRiskPerTrade *= 0.5;
        LogRiskEvent("تقليل حجم المخاطرة بسبب السحب الأسبوعي > 10%: " + DoubleToString(weeklyDrawdown * 100, 2) + "%");
    }
}

double CRiskManagementSystem::CalculateCurrencyExposure(string currency)
{
    double totalExposure = 0;
    
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(m_position.SelectByIndex(i))
        {
            string symbol = PositionGetString(POSITION_SYMBOL);
            string baseCurrency = StringSubstr(symbol, 0, 3);
            string quoteCurrency = StringSubstr(symbol, 3, 3);
            
            double positionValue = MathAbs(PositionGetDouble(POSITION_VOLUME) * PositionGetDouble(POSITION_PRICE_CURRENT));
            
            if(baseCurrency == currency || quoteCurrency == currency)
            {
                totalExposure += positionValue;
            }
        }
    }
    
    return totalExposure / m_accountBalance;
}

bool CRiskManagementSystem::CheckEnhancedCorrelationRisk(string symbol)
{
    if(CheckCorrelationRisk(symbol) > 0.8)
    {
        LogRiskEvent("ارتباط عالي مع الصفقات المفتوحة: " + DoubleToString(CheckCorrelationRisk(symbol), 2));
        return false;
    }
    
    string baseCurrency = StringSubstr(symbol, 0, 3);
    string quoteCurrency = StringSubstr(symbol, 3, 3);
    
    if(CalculateCurrencyExposure(baseCurrency) > 0.30 || CalculateCurrencyExposure(quoteCurrency) > 0.30)
    {
        LogRiskEvent("تجاوز حد التعرض للعملة 30%");
        return false;
    }
    
    return true;
}

double CRiskManagementSystem::GetSessionRiskMultiplier()
{
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    if((dt.hour >= 8 && dt.hour <= 10) || (dt.hour >= 13 && dt.hour <= 15))
    {
        return 0.3;
    }
    
    if(dt.hour >= 0 && dt.hour < 8) return 0.7;
    if(dt.hour >= 8 && dt.hour < 16) return 1.2;
    return 1.0;
}

void CRiskManagementSystem::UpdateTradeHistory(double profit, double riskAmount, string symbol)
{
    if(m_tradeHistoryCount >= 100)
    {
        for(int i = 0; i < 99; i++)
        {
            m_tradeHistory[i] = m_tradeHistory[i+1];
        }
        m_tradeHistoryCount = 99;
    }
    
    m_tradeHistory[m_tradeHistoryCount].closeTime = TimeCurrent();
    m_tradeHistory[m_tradeHistoryCount].profit = profit;
    m_tradeHistory[m_tradeHistoryCount].riskAmount = riskAmount;
    m_tradeHistory[m_tradeHistoryCount].isWin = profit > 0;
    m_tradeHistory[m_tradeHistoryCount].symbol = symbol;
    
    if(profit > 0)
    {
        m_consecutiveLosses = 0;
    }
    else
    {
        m_consecutiveLosses++;
    }
    
    m_tradeHistoryCount++;
    m_lastTradeTime = TimeCurrent();
    
    Print("تحديث سجل الصفقات: ", symbol, " ربح=", DoubleToString(profit, 2), " خسائر متتالية=", m_consecutiveLosses);
}
