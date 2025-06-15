//+------------------------------------------------------------------+
//|                                    test_risk_management.mq5      |
//|                         Risk Management System Test Suite        |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Quantum Trading Systems"
#property version   "1.00"
#property script_show_inputs

#include "../RiskManagement.mqh"

input bool InpTestKellyCriterion = true;
input bool InpTestCapitalProtection = true;
input bool InpTestCorrelationManagement = true;
input bool InpTestSessionRiskAdjustment = true;
input bool InpTestCurrencyExposure = true;

CRiskManagementSystem g_riskManager;

void OnStart()
{
    Print("🧪 بدء اختبار نظام إدارة المخاطر المحسن");
    Print("═══════════════════════════════════════");
    
    if(!g_riskManager.Initialize(2.0, 5.0, 15.0))
    {
        Print("❌ فشل في تهيئة نظام إدارة المخاطر");
        return;
    }
    
    if(InpTestKellyCriterion)
        TestKellyCriterion();
        
    if(InpTestCapitalProtection)
        TestCapitalProtection();
        
    if(InpTestCorrelationManagement)
        TestCorrelationManagement();
        
    if(InpTestSessionRiskAdjustment)
        TestSessionRiskAdjustment();
        
    if(InpTestCurrencyExposure)
        TestCurrencyExposure();
    
    Print("═══════════════════════════════════════");
    Print("✅ انتهاء جميع الاختبارات");
}

void TestKellyCriterion()
{
    Print("\n📊 اختبار Kelly Criterion:");
    Print("─────────────────────────");
    
    // Test with no trade history (should return default risk)
    double kellyRisk = g_riskManager.CalculateKellyCriterion();
    Print("Kelly مع عدم وجود تاريخ صفقات: ", DoubleToString(kellyRisk, 2), "%");
    
    // Simulate trade history with mixed results
    Print("محاكاة تاريخ صفقات متنوع...");
    
    // Add 25 trades: 15 wins, 10 losses
    for(int i = 0; i < 15; i++)
    {
        g_riskManager.UpdateTradeHistory(100.0 + i * 10, 50.0, "EURUSD"); // Wins
    }
    
    for(int i = 0; i < 10; i++)
    {
        g_riskManager.UpdateTradeHistory(-80.0 - i * 5, 50.0, "GBPUSD"); // Losses
    }
    
    kellyRisk = g_riskManager.CalculateKellyCriterion();
    Print("Kelly مع 25 صفقة (15 ربح، 10 خسارة): ", DoubleToString(kellyRisk, 2), "%");
    
    // Test extreme cases
    for(int i = 0; i < 5; i++)
    {
        g_riskManager.UpdateTradeHistory(200.0, 50.0, "USDJPY"); // More wins
    }
    
    kellyRisk = g_riskManager.CalculateKellyCriterion();
    Print("Kelly مع 30 صفقة (20 ربح، 10 خسارة): ", DoubleToString(kellyRisk, 2), "%");
    
    Print("✅ اختبار Kelly Criterion مكتمل");
}

void TestCapitalProtection()
{
    Print("\n🛡️ اختبار حماية رأس المال:");
    Print("─────────────────────────");
    
    // Test normal conditions
    bool protectionOK = g_riskManager.CheckCapitalProtection();
    Print("حماية رأس المال في الظروف العادية: ", protectionOK ? "✅ مسموح" : "❌ محظور");
    
    // Test consecutive losses
    Print("اختبار الخسائر المتتالية...");
    for(int i = 0; i < 6; i++)
    {
        g_riskManager.UpdateTradeHistory(-100.0, 50.0, "EURGBP");
        Print("خسارة رقم ", i+1, " - الخسائر المتتالية الحالية: ", i+1);
    }
    
    protectionOK = g_riskManager.CheckCapitalProtection();
    Print("حماية رأس المال بعد 6 خسائر متتالية: ", protectionOK ? "✅ مسموح" : "❌ محظور");
    
    // Reset consecutive losses with a win
    g_riskManager.UpdateTradeHistory(150.0, 50.0, "AUDUSD");
    protectionOK = g_riskManager.CheckCapitalProtection();
    Print("حماية رأس المال بعد ربح (إعادة تعيين): ", protectionOK ? "✅ مسموح" : "❌ محظور");
    
    // Test weekly drawdown
    Print("اختبار السحب الأسبوعي...");
    g_riskManager.CheckWeeklyDrawdown();
    
    Print("✅ اختبار حماية رأس المال مكتمل");
}

void TestCorrelationManagement()
{
    Print("\n🔗 اختبار إدارة الارتباط:");
    Print("─────────────────────────");
    
    // Test correlation risk for different symbols
    string symbols[] = {"EURUSD", "GBPUSD", "EURGBP", "USDJPY", "AUDUSD"};
    
    for(int i = 0; i < ArraySize(symbols); i++)
    {
        bool correlationOK = g_riskManager.CheckEnhancedCorrelationRisk(symbols[i]);
        Print("فحص الارتباط لـ ", symbols[i], ": ", correlationOK ? "✅ مسموح" : "❌ محظور");
    }
    
    // Test correlation calculation between symbols
    double correlation = g_riskManager.CalculateCorrelation("EURUSD", "GBPUSD");
    Print("الارتباط بين EURUSD و GBPUSD: ", DoubleToString(correlation, 3));
    
    correlation = g_riskManager.CalculateCorrelation("EURUSD", "USDJPY");
    Print("الارتباط بين EURUSD و USDJPY: ", DoubleToString(correlation, 3));
    
    Print("✅ اختبار إدارة الارتباط مكتمل");
}

void TestSessionRiskAdjustment()
{
    Print("\n🕐 اختبار تعديل المخاطر حسب الجلسة:");
    Print("─────────────────────────────────");
    
    // Test different session multipliers
    double sessionMultiplier = g_riskManager.GetSessionRiskMultiplier();
    Print("مضاعف المخاطرة للجلسة الحالية: ", DoubleToString(sessionMultiplier, 1), "x");
    
    // Simulate different times
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    Print("الوقت الحالي (UTC): ", dt.hour, ":", dt.min);
    
    if(dt.hour >= 0 && dt.hour < 8)
        Print("الجلسة: آسيوية (مضاعف متوقع: 0.7x)");
    else if(dt.hour >= 8 && dt.hour < 16)
        Print("الجلسة: أوروبية (مضاعف متوقع: 1.2x)");
    else
        Print("الجلسة: أمريكية (مضاعف متوقع: 1.0x)");
    
    // Check for news time
    if((dt.hour >= 8 && dt.hour <= 10) || (dt.hour >= 13 && dt.hour <= 15))
        Print("وقت الأخبار: نعم (مضاعف متوقع: 0.3x)");
    else
        Print("وقت الأخبار: لا");
    
    Print("✅ اختبار تعديل المخاطر حسب الجلسة مكتمل");
}

void TestCurrencyExposure()
{
    Print("\n💱 اختبار التعرض للعملات:");
    Print("─────────────────────────");
    
    // Test currency exposure calculation
    string currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CHF", "CAD"};
    
    for(int i = 0; i < ArraySize(currencies); i++)
    {
        double exposure = g_riskManager.CalculateCurrencyExposure(currencies[i]);
        Print("التعرض لعملة ", currencies[i], ": ", DoubleToString(exposure * 100, 2), "%");
    }
    
    // Test enhanced correlation risk with currency exposure
    Print("\nاختبار الارتباط المحسن مع التعرض للعملات:");
    string testSymbols[] = {"EURUSD", "EURJPY", "EURGBP", "USDCHF", "GBPJPY"};
    
    for(int i = 0; i < ArraySize(testSymbols); i++)
    {
        bool riskOK = g_riskManager.CheckEnhancedCorrelationRisk(testSymbols[i]);
        Print("فحص المخاطر المحسن لـ ", testSymbols[i], ": ", riskOK ? "✅ مسموح" : "❌ محظور");
    }
    
    Print("✅ اختبار التعرض للعملات مكتمل");
}

void TestPositionSizeCalculation()
{
    Print("\n📏 اختبار حساب حجم المركز:");
    Print("─────────────────────────");
    
    string symbol = "EURUSD";
    double entryPrice = 1.1000;
    double stopLoss = 1.0950;
    
    double positionSize = g_riskManager.CalculatePositionSize(symbol, entryPrice, stopLoss);
    Print("حجم المركز لـ ", symbol, ": ", DoubleToString(positionSize, 2), " لوت");
    
    double riskAmount = g_riskManager.CalculateRiskAmount(symbol, entryPrice, stopLoss);
    Print("مبلغ المخاطرة: ", DoubleToString(riskAmount, 2));
    
    // Test with different stop loss distances
    stopLoss = 1.0900; // Larger stop
    positionSize = g_riskManager.CalculatePositionSize(symbol, entryPrice, stopLoss);
    Print("حجم المركز مع وقف أكبر: ", DoubleToString(positionSize, 2), " لوت");
    
    Print("✅ اختبار حساب حجم المركز مكتمل");
}

void TestRiskValidation()
{
    Print("\n✔️ اختبار التحقق من المخاطر:");
    Print("─────────────────────────");
    
    bool validParams = g_riskManager.ValidateRiskParameters();
    Print("صحة معاملات المخاطر: ", validParams ? "✅ صحيحة" : "❌ خاطئة");
    
    ENUM_RISK_LEVEL riskLevel = g_riskManager.GetCurrentRiskLevel();
    string riskLevelStr;
    switch(riskLevel)
    {
        case RISK_LOW: riskLevelStr = "منخفض"; break;
        case RISK_MEDIUM: riskLevelStr = "متوسط"; break;
        case RISK_HIGH: riskLevelStr = "عالي"; break;
        case RISK_CRITICAL: riskLevelStr = "حرج"; break;
        default: riskLevelStr = "غير معروف"; break;
    }
    Print("مستوى المخاطر الحالي: ", riskLevelStr);
    
    double dailyPnL = g_riskManager.GetDailyPnL();
    Print("الربح/الخسارة اليومية: ", DoubleToString(dailyPnL, 2));
    
    double currentDrawdown = g_riskManager.GetCurrentDrawdown();
    Print("السحب الحالي: ", DoubleToString(currentDrawdown, 2), "%");
    
    Print("✅ اختبار التحقق من المخاطر مكتمل");
}
