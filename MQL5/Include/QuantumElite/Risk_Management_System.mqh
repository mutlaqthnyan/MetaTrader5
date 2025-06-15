//+------------------------------------------------------------------+
//|                                        Risk_Management_System.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

enum ENUM_RISK_LEVEL
{
    RISK_LOW,
    RISK_MEDIUM,
    RISK_HIGH,
    RISK_CRITICAL
};

struct TradeRecord
{
    datetime closeTime;
    double profit;
    double riskAmount;
    bool isWin;
    string symbol;
};

class CRiskManagementSystem
{
private:
    double            m_accountBalance;
    double            m_accountEquity;
    double            m_maxRiskPerTrade;
    double            m_maxDailyRisk;
    double            m_maxWeeklyRisk;
    double            m_currentDailyRisk;
    double            m_currentWeeklyRisk;
    bool              m_emergencyMode;
    datetime          m_lastRiskCheck;
    datetime          m_dailyResetTime;
    datetime          m_weeklyResetTime;
    
    TradeRecord       m_tradeHistory[100];
    int               m_tradeHistoryCount;
    datetime          m_lastTradeTime;
    int               m_consecutiveLosses;
    
    double            m_weeklyDrawdownStart;
    datetime          m_weeklyDrawdownTime;
    
    CTrade            m_trade;
    CPositionInfo     m_position;
    
    void              LogRiskEvent(string message);
    double            GetDailyPnL();
    double            GetWeeklyPnL();
    void              ResetDailyCounters();
    void              ResetWeeklyCounters();
    
public:
                     CRiskManagementSystem();
                    ~CRiskManagementSystem();
    
    bool              Initialize(double maxRiskPerTrade = 2.0, double maxDailyRisk = 10.0, double maxWeeklyRisk = 20.0);
    void              UpdateAccountInfo();
    
    double            CalculatePositionSize(string symbol, double stopLoss, double riskPercent = 0);
    bool              ValidateRisk(string symbol, double volume, double stopLoss);
    ENUM_RISK_LEVEL   GetCurrentRiskLevel();
    
    bool              CanOpenPosition(string symbol, double volume, double stopLoss);
    void              OnPositionClosed(string symbol, double profit, double volume);
    
    void              SetEmergencyMode(bool enabled);
    bool              IsEmergencyMode() { return m_emergencyMode; }
    
    void              PrintRiskReport();
    
    double            CheckCorrelationRisk(string symbol);
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
    m_accountBalance = 0;
    m_accountEquity = 0;
    m_maxRiskPerTrade = 2.0;
    m_maxDailyRisk = 10.0;
    m_maxWeeklyRisk = 20.0;
    m_currentDailyRisk = 0;
    m_currentWeeklyRisk = 0;
    m_emergencyMode = false;
    m_lastRiskCheck = 0;
    m_dailyResetTime = 0;
    m_weeklyResetTime = 0;
    m_tradeHistoryCount = 0;
    m_lastTradeTime = 0;
    m_consecutiveLosses = 0;
    m_weeklyDrawdownStart = 0;
    m_weeklyDrawdownTime = 0;
}

CRiskManagementSystem::~CRiskManagementSystem()
{
}

bool CRiskManagementSystem::Initialize(double maxRiskPerTrade = 2.0, double maxDailyRisk = 10.0, double maxWeeklyRisk = 20.0)
{
    m_maxRiskPerTrade = MathMax(0.1, MathMin(maxRiskPerTrade, 10.0));
    m_maxDailyRisk = MathMax(1.0, MathMin(maxDailyRisk, 50.0));
    m_maxWeeklyRisk = MathMax(5.0, MathMin(maxWeeklyRisk, 100.0));
    
    UpdateAccountInfo();
    
    if(m_accountBalance <= 0)
    {
        Print("خطأ: رصيد الحساب غير صحيح");
        return false;
    }
    
    m_dailyResetTime = TimeCurrent();
    m_weeklyResetTime = TimeCurrent();
    m_weeklyDrawdownStart = m_accountEquity;
    m_weeklyDrawdownTime = TimeCurrent();
    
    Print("تم تهيئة نظام إدارة المخاطر:");
    Print("- الحد الأقصى للمخاطرة لكل صفقة: ", m_maxRiskPerTrade, "%");
    Print("- الحد الأقصى للمخاطرة اليومية: ", m_maxDailyRisk, "%");
    Print("- الحد الأقصى للمخاطرة الأسبوعية: ", m_maxWeeklyRisk, "%");
    Print("- رصيد الحساب: ", DoubleToString(m_accountBalance, 2));
    
    return true;
}

void CRiskManagementSystem::UpdateAccountInfo()
{
    m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    m_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    datetime currentTime = TimeCurrent();
    
    MqlDateTime dt;
    TimeToStruct(currentTime, dt);
    
    datetime todayStart = currentTime - (dt.hour * 3600 + dt.min * 60 + dt.sec);
    if(m_dailyResetTime < todayStart)
    {
        ResetDailyCounters();
        m_dailyResetTime = todayStart;
    }
    
    datetime weekStart = currentTime - (dt.day_of_week * 24 * 3600 + dt.hour * 3600 + dt.min * 60 + dt.sec);
    if(m_weeklyResetTime < weekStart)
    {
        ResetWeeklyCounters();
        m_weeklyResetTime = weekStart;
    }
}

double CRiskManagementSystem::CalculatePositionSize(string symbol, double stopLoss, double riskPercent = 0)
{
    if(m_emergencyMode)
    {
        Print("وضع الطوارئ مفعل - لا يمكن فتح صفقات جديدة");
        return 0;
    }
    
    UpdateAccountInfo();
    
    if(!CheckCapitalProtection())
    {
        return 0;
    }
    
    if(!CheckEnhancedCorrelationRisk(symbol))
    {
        return 0;
    }
    
    double riskAmount = riskPercent > 0 ? riskPercent : m_maxRiskPerTrade;
    
    double kellyRisk = CalculateKellyCriterion();
    if(kellyRisk > 0 && kellyRisk < riskAmount)
    {
        riskAmount = kellyRisk;
        Print("استخدام Kelly Criterion: ", DoubleToString(riskAmount, 2), "%");
    }
    
    double sessionMultiplier = GetSessionRiskMultiplier();
    riskAmount *= sessionMultiplier;
    
    double riskAmountMoney = m_accountBalance * riskAmount / 100.0;
    
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    
    if(tickValue == 0 || tickSize == 0 || currentPrice == 0)
    {
        Print("خطأ في الحصول على معلومات الرمز: ", symbol);
        return 0;
    }
    
    double stopLossPoints = MathAbs(currentPrice - stopLoss);
    double stopLossTicks = stopLossPoints / tickSize;
    
    double volume = riskAmountMoney / (stopLossTicks * tickValue);
    
    double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    volume = MathMax(volume, minVolume);
    volume = MathMin(volume, maxVolume);
    volume = MathRound(volume / volumeStep) * volumeStep;
    
    Print("حساب حجم الصفقة:");
    Print("- الرمز: ", symbol);
    Print("- المخاطرة: ", DoubleToString(riskAmount, 2), "% (", DoubleToString(riskAmountMoney, 2), " ", AccountInfoString(ACCOUNT_CURRENCY), ")");
    Print("- معامل الجلسة: ", DoubleToString(sessionMultiplier, 2));
    Print("- الحجم المحسوب: ", DoubleToString(volume, 2));
    
    return volume;
}

bool CRiskManagementSystem::ValidateRisk(string symbol, double volume, double stopLoss)
{
    if(m_emergencyMode)
    {
        Print("وضع الطوارئ مفعل - رفض الصفقة");
        return false;
    }
    
    UpdateAccountInfo();
    
    double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    
    double stopLossPoints = MathAbs(currentPrice - stopLoss);
    double stopLossTicks = stopLossPoints / tickSize;
    double potentialLoss = stopLossTicks * tickValue * volume;
    
    double riskPercent = (potentialLoss / m_accountBalance) * 100;
    
    if(riskPercent > m_maxRiskPerTrade)
    {
        Print("المخاطرة مرتفعة جداً: ", DoubleToString(riskPercent, 2), "% > ", DoubleToString(m_maxRiskPerTrade, 2), "%");
        return false;
    }
    
    if(m_currentDailyRisk + riskPercent > m_maxDailyRisk)
    {
        Print("تجاوز الحد الأقصى للمخاطرة اليومية");
        return false;
    }
    
    if(m_currentWeeklyRisk + riskPercent > m_maxWeeklyRisk)
    {
        Print("تجاوز الحد الأقصى للمخاطرة الأسبوعية");
        return false;
    }
    
    return true;
}

double CRiskManagementSystem::CheckCorrelationRisk(string symbol)
{
    double maxCorrelation = 0;
    int periods = 50;
    
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(m_position.SelectByIndex(i))
        {
            string openSymbol = PositionGetString(POSITION_SYMBOL);
            if(openSymbol == symbol) continue;
            
            double correlation = 0;
            double sum1 = 0, sum2 = 0, sum1Sq = 0, sum2Sq = 0, sumProduct = 0;
            
            for(int j = 1; j <= periods; j++)
            {
                double price1 = iClose(symbol, PERIOD_D1, j);
                double price2 = iClose(openSymbol, PERIOD_D1, j);
                double prevPrice1 = iClose(symbol, PERIOD_D1, j+1);
                double prevPrice2 = iClose(openSymbol, PERIOD_D1, j+1);
                
                if(price1 > 0 && price2 > 0 && prevPrice1 > 0 && prevPrice2 > 0)
                {
                    double return1 = (price1 - prevPrice1) / prevPrice1;
                    double return2 = (price2 - prevPrice2) / prevPrice2;
                    
                    sum1 += return1;
                    sum2 += return2;
                    sum1Sq += return1 * return1;
                    sum2Sq += return2 * return2;
                    sumProduct += return1 * return2;
                }
            }
            
            double n = periods;
            double numerator = n * sumProduct - sum1 * sum2;
            double denominator = MathSqrt((n * sum1Sq - sum1 * sum1) * (n * sum2Sq - sum2 * sum2));
            
            if(denominator != 0)
            {
                correlation = MathAbs(numerator / denominator);
                maxCorrelation = MathMax(maxCorrelation, correlation);
            }
        }
    }
    
    return maxCorrelation;
}

ENUM_RISK_LEVEL CRiskManagementSystem::GetCurrentRiskLevel()
{
    UpdateAccountInfo();
    
    double dailyRiskPercent = (m_currentDailyRisk / m_maxDailyRisk) * 100;
    double weeklyRiskPercent = (m_currentWeeklyRisk / m_maxWeeklyRisk) * 100;
    double equityRiskPercent = ((m_accountBalance - m_accountEquity) / m_accountBalance) * 100;
    
    double maxRiskPercent = MathMax(dailyRiskPercent, MathMax(weeklyRiskPercent, equityRiskPercent));
    
    if(maxRiskPercent >= 80) return RISK_CRITICAL;
    if(maxRiskPercent >= 60) return RISK_HIGH;
    if(maxRiskPercent >= 30) return RISK_MEDIUM;
    return RISK_LOW;
}

bool CRiskManagementSystem::CanOpenPosition(string symbol, double volume, double stopLoss)
{
    if(!ValidateRisk(symbol, volume, stopLoss))
        return false;
    
    ENUM_RISK_LEVEL riskLevel = GetCurrentRiskLevel();
    if(riskLevel == RISK_CRITICAL)
    {
        Print("مستوى المخاطرة حرج - منع فتح صفقات جديدة");
        return false;
    }
    
    double correlation = CheckCorrelationRisk(symbol);
    if(correlation > 0.7)
    {
        Print("ارتباط عالي مع الصفقات المفتوحة: ", DoubleToString(correlation, 2));
        if(correlation > 0.8)
        {
            Print("ارتباط مرتفع جداً - رفض الصفقة");
            return false;
        }
    }
    
    return true;
}

void CRiskManagementSystem::OnPositionClosed(string symbol, double profit, double volume)
{
    double riskAmount = (MathAbs(profit) / m_accountBalance) * 100;
    
    m_currentDailyRisk += riskAmount;
    m_currentWeeklyRisk += riskAmount;
    
    UpdateTradeHistory(profit, riskAmount, symbol);
    
    Print("إغلاق صفقة: ", symbol, " ربح=", DoubleToString(profit, 2), " مخاطرة=", DoubleToString(riskAmount, 2), "%");
    
    if(profit < 0)
    {
        ENUM_RISK_LEVEL riskLevel = GetCurrentRiskLevel();
        if(riskLevel >= RISK_HIGH)
        {
            Print("⚠️ مستوى مخاطرة مرتفع بعد الخسارة");
        }
    }
}

void CRiskManagementSystem::SetEmergencyMode(bool enabled)
{
    m_emergencyMode = enabled;
    if(enabled)
    {
        Print("🚨 تفعيل وضع الطوارئ - إيقاف جميع العمليات");
        LogRiskEvent("تفعيل وضع الطوارئ");
    }
    else
    {
        Print("✅ إلغاء وضع الطوارئ");
        LogRiskEvent("إلغاء وضع الطوارئ");
    }
}

void CRiskManagementSystem::PrintRiskReport()
{
    UpdateAccountInfo();
    
    Print("=== تقرير إدارة المخاطر ===");
    Print("رصيد الحساب: ", DoubleToString(m_accountBalance, 2), " ", AccountInfoString(ACCOUNT_CURRENCY));
    Print("رأس المال الحالي: ", DoubleToString(m_accountEquity, 2), " ", AccountInfoString(ACCOUNT_CURRENCY));
    Print("المخاطرة اليومية: ", DoubleToString(m_currentDailyRisk, 2), "% / ", DoubleToString(m_maxDailyRisk, 2), "%");
    Print("المخاطرة الأسبوعية: ", DoubleToString(m_currentWeeklyRisk, 2), "% / ", DoubleToString(m_maxWeeklyRisk, 2), "%");
    Print("مستوى المخاطرة: ", EnumToString(GetCurrentRiskLevel()));
    Print("وضع الطوارئ: ", m_emergencyMode ? "مفعل" : "غير مفعل");
    Print("عدد الصفقات في السجل: ", m_tradeHistoryCount);
    Print("الخسائر المتتالية: ", m_consecutiveLosses);
    Print("===============================");
}

void CRiskManagementSystem::LogRiskEvent(string message)
{
    datetime currentTime = TimeCurrent();
    Print("[", TimeToString(currentTime), "] ", message);
}

double CRiskManagementSystem::GetDailyPnL()
{
    double dailyPnL = 0;
    datetime todayStart = TimeCurrent() - (TimeCurrent() % (24 * 3600));
    
    for(int i = 0; i < m_tradeHistoryCount; i++)
    {
        if(m_tradeHistory[i].closeTime >= todayStart)
        {
            dailyPnL += m_tradeHistory[i].profit;
        }
    }
    
    return dailyPnL;
}

double CRiskManagementSystem::GetWeeklyPnL()
{
    double weeklyPnL = 0;
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    datetime weekStart = TimeCurrent() - (dt.day_of_week * 24 * 3600);
    
    for(int i = 0; i < m_tradeHistoryCount; i++)
    {
        if(m_tradeHistory[i].closeTime >= weekStart)
        {
            weeklyPnL += m_tradeHistory[i].profit;
        }
    }
    
    return weeklyPnL;
}

void CRiskManagementSystem::ResetDailyCounters()
{
    m_currentDailyRisk = 0;
    Print("إعادة تعيين عدادات المخاطرة اليومية");
}

void CRiskManagementSystem::ResetWeeklyCounters()
{
    m_currentWeeklyRisk = 0;
    m_weeklyDrawdownStart = m_accountEquity;
    Print("إعادة تعيين عدادات المخاطرة الأسبوعية");
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
