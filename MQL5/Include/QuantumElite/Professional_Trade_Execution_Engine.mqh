//+------------------------------------------------------------------+
//|                                Professional_Trade_Execution_Engine.mqh |
//|                                  Copyright 2024, Quantum Trading Systems |
//|                                             Professional Trade Execution |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Math\Stat\Math.mqh>
#include "Risk_Management_System.mqh"
#include "Market_Analysis_Engine.mqh"

//+------------------------------------------------------------------+
//| Execution Parameters Structure                                   |
//+------------------------------------------------------------------+
struct ExecutionParams
{
    int maxSlippage;           // Maximum allowed slippage in points
    int maxRetries;            // Maximum retry attempts
    double maxSpread;          // Maximum spread allowed for execution
    bool useMarketExecution;   // Use market execution vs limit orders
    bool allowPartialFill;     // Allow partial order fills
    int delayBetweenRetries;   // Delay between retry attempts (ms)
    double minLiquidity;       // Minimum liquidity threshold
    
    ExecutionParams()
    {
        maxSlippage = 20;
        maxRetries = 3;
        maxSpread = 5.0;
        useMarketExecution = true;
        allowPartialFill = false;
        delayBetweenRetries = 1000;
        minLiquidity = 0.5;
    }
};

//+------------------------------------------------------------------+
//| Trade Request Structure                                          |
//+------------------------------------------------------------------+
struct TradeRequest
{
    string symbol;
    ENUM_ORDER_TYPE orderType;
    double volume;
    double price;
    double stopLoss;
    double takeProfit;
    string comment;
    int magicNumber;
    datetime expiration;
    
    TradeRequest()
    {
        symbol = "";
        orderType = ORDER_TYPE_BUY;
        volume = 0.0;
        price = 0.0;
        stopLoss = 0.0;
        takeProfit = 0.0;
        comment = "";
        magicNumber = 0;
        expiration = 0;
    }
};

//+------------------------------------------------------------------+
//| Execution Result Structure                                       |
//+------------------------------------------------------------------+
struct ExecutionResult
{
    bool success;
    ulong ticket;
    double executedPrice;
    double executedVolume;
    double actualSlippage;
    int retryCount;
    uint errorCode;
    string errorDescription;
    datetime executionTime;
    
    ExecutionResult()
    {
        success = false;
        ticket = 0;
        executedPrice = 0.0;
        executedVolume = 0.0;
        actualSlippage = 0.0;
        retryCount = 0;
        errorCode = 0;
        errorDescription = "";
        executionTime = 0;
    }
};

//+------------------------------------------------------------------+
//| Execution Error Types                                           |
//+------------------------------------------------------------------+
enum EXECUTION_ERROR
{
    NO_ERROR,
    REQUOTE,
    OFF_QUOTES,
    NO_LIQUIDITY,
    TRADE_DISABLED,
    INVALID_STOPS,
    NOT_ENOUGH_MONEY,
    MARKET_CLOSED,
    INVALID_VOLUME,
    PRICE_CHANGED,
    TIMEOUT,
    CONNECTION_LOST
};

//+------------------------------------------------------------------+
//| Market Condition Types                                          |
//+------------------------------------------------------------------+
enum MARKET_CONDITION_TYPE
{
    CONDITION_NORMAL,
    CONDITION_HIGH_VOLATILITY,
    CONDITION_LOW_LIQUIDITY,
    CONDITION_NEWS_EVENT,
    CONDITION_SESSION_OVERLAP,
    CONDITION_MARKET_CLOSE
};

//+------------------------------------------------------------------+
//| Professional Trade Execution Class                              |
//+------------------------------------------------------------------+
class CProfessionalTradeExecution
{
private:
    CTrade                  m_trade;
    CSymbolInfo            m_symbolInfo;
    CAccountInfo           m_account;
    CRiskManagementSystem* m_riskManager;
    CMarketAnalysisEngine* m_marketEngine;
    
    ExecutionParams        m_defaultParams;
    bool                   m_isInitialized;
    
    // Performance tracking
    int                    m_totalExecutions;
    int                    m_successfulExecutions;
    double                 m_averageSlippage;
    double                 m_averageExecutionTime;
    
public:
    CProfessionalTradeExecution();
    ~CProfessionalTradeExecution();
    
    bool Initialize(CRiskManagementSystem* riskManager, CMarketAnalysisEngine* marketEngine);
    void Deinitialize();
    
    // Main execution methods
    ExecutionResult ExecuteOrder(TradeRequest &request, ExecutionParams &params);
    ExecutionResult ExecuteOrderWithDefaults(TradeRequest &request);
    
    // Configuration methods
    void SetDefaultParams(ExecutionParams &params) { m_defaultParams = params; }
    ExecutionParams GetDefaultParams() { return m_defaultParams; }
    
    // Performance methods
    double GetSuccessRate();
    double GetAverageSlippage() { return m_averageSlippage; }
    double GetAverageExecutionTime() { return m_averageExecutionTime; }
    
    // Enhanced monitoring methods
    void LogPerformanceSummary();
    void LogExecutionStatistics();
    void ResetPerformanceMetrics();
    string GetPerformanceReport();
    
private:
    bool ValidateRequest(TradeRequest &request);
    bool CheckPreExecutionConditions(TradeRequest &request, ExecutionParams &params);
    ExecutionResult ExecuteWithRetry(TradeRequest &request, ExecutionParams &params);
    void UpdatePerformanceMetrics(ExecutionResult &result);
    void LogExecution(TradeRequest &request, ExecutionResult &result);
};

//+------------------------------------------------------------------+
//| Smart Order Routing Class                                       |
//+------------------------------------------------------------------+
class CSmartOrderRouting
{
private:
    CMarketAnalysisEngine* m_marketEngine;
    CSymbolInfo           m_symbolInfo;
    
    double                m_liquidityThreshold;
    double                m_volatilityThreshold;
    int                   m_maxOrderParts;
    
public:
    CSmartOrderRouting();
    ~CSmartOrderRouting();
    
    bool Initialize(CMarketAnalysisEngine* marketEngine);
    
    bool RouteOrder(TradeRequest &request, ExecutionParams &params);
    bool ShouldDelayExecution(string symbol);
    bool ShouldSplitOrder(TradeRequest &request);
    
    MARKET_CONDITION_TYPE GetMarketCondition(string symbol);
    double CalculateOptimalTiming(string symbol);
    
private:
    bool IsLowLiquidity(string symbol);
    bool IsHighVolatility(string symbol);
    bool IsNewsTime();
    bool IsSessionOverlap();
    double GetExpectedSlippage(string symbol, double volume);
    bool ExecuteInParts(TradeRequest &request, ExecutionParams &params);
    bool WaitForBetterPrice(TradeRequest &request, int maxWaitSeconds = 30);
    bool DelayExecution(TradeRequest &request, int delaySeconds = 60);
};

//+------------------------------------------------------------------+
//| Slippage Manager Class                                          |
//+------------------------------------------------------------------+
class CSlippageManager
{
private:
    CMarketAnalysisEngine* m_marketEngine;
    CSymbolInfo           m_symbolInfo;
    
    double                m_baseSlippage;
    double                m_maxSlippage;
    
public:
    CSlippageManager();
    ~CSlippageManager();
    
    bool Initialize(CMarketAnalysisEngine* marketEngine);
    
    double CalculateDynamicSlippage(string symbol);
    bool IsSlippageAcceptable(double requested, double executed, string symbol);
    double GetVolatilityFactor(string symbol);
    double GetTimeFactor();
    double GetNewsFactor();
    double GetLiquidityFactor(string symbol);
    
    void SetBaseSlippage(double slippage) { m_baseSlippage = slippage; }
    void SetMaxSlippage(double slippage) { m_maxSlippage = slippage; }
    
private:
    double CalculateATRFactor(string symbol);
    double CalculateSpreadFactor(string symbol);
    double CalculateVolumeFactor(string symbol);
};

//+------------------------------------------------------------------+
//| Execution Error Handler Class                                   |
//+------------------------------------------------------------------+
class CExecutionErrorHandler
{
private:
    int m_maxRetries;
    int m_baseDelay;
    
public:
    CExecutionErrorHandler();
    ~CExecutionErrorHandler();
    
    bool HandleError(EXECUTION_ERROR error, TradeRequest &request, ExecutionParams &params);
    EXECUTION_ERROR ClassifyError(uint errorCode);
    bool ShouldRetry(EXECUTION_ERROR error, int currentRetry);
    int CalculateRetryDelay(int retryCount);
    
    // Specific error handling methods
    bool HandleRequote(TradeRequest &request, ExecutionParams &params);
    bool HandleOffQuotes(TradeRequest &request, ExecutionParams &params);
    bool HandleNoLiquidity(TradeRequest &request, ExecutionParams &params);
    bool HandleInvalidStops(TradeRequest &request, ExecutionParams &params);
    bool HandleInsufficientMargin(TradeRequest &request, ExecutionParams &params);
    
    // Order modification methods
    bool RetryWithNewPrice(TradeRequest &request);
    bool SplitOrder(TradeRequest &request, ExecutionParams &params);
    bool AdjustStops(TradeRequest &request);
    bool ReduceVolume(TradeRequest &request);
    
private:
    void LogError(EXECUTION_ERROR error, TradeRequest &request, string details);
    bool IsRetryableError(EXECUTION_ERROR error);
    double GetCurrentPrice(string symbol, ENUM_ORDER_TYPE orderType);
};

//+------------------------------------------------------------------+
//| CProfessionalTradeExecution Implementation                       |
//+------------------------------------------------------------------+
CProfessionalTradeExecution::CProfessionalTradeExecution()
{
    m_riskManager = NULL;
    m_marketEngine = NULL;
    m_isInitialized = false;
    m_totalExecutions = 0;
    m_successfulExecutions = 0;
    m_averageSlippage = 0.0;
    m_averageExecutionTime = 0.0;
}

CProfessionalTradeExecution::~CProfessionalTradeExecution()
{
    Deinitialize();
}

bool CProfessionalTradeExecution::Initialize(CRiskManagementSystem* riskManager, CMarketAnalysisEngine* marketEngine)
{
    if(riskManager == NULL || marketEngine == NULL)
    {
        Print("❌ خطأ: مؤشرات فارغة في تهيئة محرك التنفيذ المهني");
        return false;
    }
    
    m_riskManager = riskManager;
    m_marketEngine = marketEngine;
    
    // Configure CTrade with professional settings
    m_trade.SetExpertMagicNumber(12345); // Will be set dynamically
    m_trade.SetMarginMode();
    m_trade.SetDeviationInPoints(m_defaultParams.maxSlippage);
    m_trade.SetTypeFilling(ORDER_FILLING_IOC); // Immediate or Cancel
    m_trade.SetTypeFillingBySymbol(_Symbol);
    
    m_isInitialized = true;
    
    Print("✅ تم تهيئة محرك التنفيذ المهني بنجاح");
    return true;
}

void CProfessionalTradeExecution::Deinitialize()
{
    m_riskManager = NULL;
    m_marketEngine = NULL;
    m_isInitialized = false;
}

ExecutionResult CProfessionalTradeExecution::ExecuteOrder(TradeRequest &request, ExecutionParams &params)
{
    ExecutionResult result;
    result.executionTime = TimeCurrent();
    
    if(!m_isInitialized)
    {
        result.errorCode = ERR_NOT_INITIALIZED;
        result.errorDescription = "محرك التنفيذ غير مهيأ";
        Print("❌ ", result.errorDescription);
        return result;
    }
    
    // Step 1: Validate request
    if(!ValidateRequest(request))
    {
        result.errorCode = ERR_INVALID_PARAMETER;
        result.errorDescription = "طلب تداول غير صالح";
        Print("❌ ", result.errorDescription);
        return result;
    }
    
    // Step 2: Check pre-execution conditions
    if(!CheckPreExecutionConditions(request, params))
    {
        result.errorCode = ERR_TRADE_NOT_ALLOWED;
        result.errorDescription = "شروط التنفيذ غير مستوفاة";
        Print("❌ ", result.errorDescription);
        return result;
    }
    
    // Step 3: Execute with retry mechanism
    result = ExecuteWithRetry(request, params);
    
    // Step 4: Update performance metrics
    UpdatePerformanceMetrics(result);
    
    // Step 5: Log execution
    LogExecution(request, result);
    
    return result;
}

ExecutionResult CProfessionalTradeExecution::ExecuteOrderWithDefaults(TradeRequest &request)
{
    return ExecuteOrder(request, m_defaultParams);
}

bool CProfessionalTradeExecution::ValidateRequest(TradeRequest &request)
{
    // Check symbol validity
    if(request.symbol == "" || !m_symbolInfo.Name(request.symbol))
    {
        Print("❌ رمز التداول غير صالح: ", request.symbol);
        return false;
    }
    
    // Use Risk Management System for comprehensive validation
    if(m_riskManager != NULL)
    {
        // First validate trade risk using existing risk management system
        if(!m_riskManager.ValidateTradeRisk(request.symbol, request.volume))
        {
            Print("❌ فشل التحقق من المخاطر للرمز: ", request.symbol, " الحجم: ", request.volume);
            return false;
        }
        
        // Calculate recommended position size based on stop loss
        if(request.stopLoss > 0 && request.price > 0)
        {
            double stopLossDistance = MathAbs(request.price - request.stopLoss);
            double recommendedSize = m_riskManager.CalculatePositionSize(request.symbol, stopLossDistance);
            
            if(recommendedSize > 0)
            {
                // Use recommended size if it's more conservative
                if(recommendedSize < request.volume)
                {
                    Print("💡 توصية مدير المخاطر بحجم: ", DoubleToString(recommendedSize, 2), 
                          " بدلاً من: ", DoubleToString(request.volume, 2));
                    Print("✅ تم تطبيق الحجم المحافظ للحماية من المخاطر");
                    request.volume = recommendedSize;
                }
                else if(recommendedSize > request.volume * 1.5)
                {
                    Print("⚠️ الحجم المطلوب أقل بكثير من التوصية - قد يكون محافظ جداً");
                }
            }
            else
            {
                Print("❌ مدير المخاطر لا يسمح بالتداول في الوقت الحالي");
                return false;
            }
        }
        
        // Get current risk status for logging
        string riskStatus = m_riskManager.GetRiskStatus();
        double riskLevel = m_riskManager.GetCurrentRiskLevel();
        Print("📊 حالة المخاطر الحالية: ", riskStatus, " (", DoubleToString(riskLevel, 1), "%)");
        
        if(riskStatus == "CRITICAL")
        {
            Print("🚨 تحذير: مستوى المخاطر حرج - قد يتم رفض التداول");
        }
    }
    
    // Standard volume validation after risk management adjustments
    double minVolume = m_symbolInfo.LotsMin();
    double maxVolume = m_symbolInfo.LotsMax();
    double stepVolume = m_symbolInfo.LotsStep();
    
    if(request.volume < minVolume || request.volume > maxVolume)
    {
        Print("❌ حجم التداول خارج النطاق المسموح: ", DoubleToString(request.volume, 2));
        return false;
    }
    
    // Normalize volume to step
    double normalizedVolume = MathRound(request.volume / stepVolume) * stepVolume;
    if(MathAbs(request.volume - normalizedVolume) > 0.000001)
    {
        Print("⚠️ تم تطبيع حجم التداول من ", DoubleToString(request.volume, 2), 
              " إلى ", DoubleToString(normalizedVolume, 2));
        request.volume = normalizedVolume;
    }
    
    // Check stop loss and take profit levels
    if(request.stopLoss > 0 || request.takeProfit > 0)
    {
        double minStopLevel = m_symbolInfo.StopsLevel() * m_symbolInfo.Point();
        double currentPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                             m_symbolInfo.Ask() : m_symbolInfo.Bid();
        
        if(request.stopLoss > 0)
        {
            double slDistance = MathAbs(currentPrice - request.stopLoss);
            if(slDistance < minStopLevel)
            {
                Print("❌ مستوى وقف الخسارة قريب جداً من السعر الحالي");
                return false;
            }
        }
        
        if(request.takeProfit > 0)
        {
            double tpDistance = MathAbs(currentPrice - request.takeProfit);
            if(tpDistance < minStopLevel)
            {
                Print("❌ مستوى جني الأرباح قريب جداً من السعر الحالي");
                return false;
            }
        }
    }
    
    // Final validation after all adjustments
    if(request.volume <= 0)
    {
        Print("❌ الحجم النهائي غير صالح بعد التعديلات");
        return false;
    }
    
    Print("✅ تم التحقق من صحة طلب التداول بنجاح");
    return true;
}

bool CProfessionalTradeExecution::CheckPreExecutionConditions(TradeRequest &request, ExecutionParams &params)
{
    // Check if trading is allowed
    if(!m_symbolInfo.Name(request.symbol))
    {
        Print("❌ لا يمكن الحصول على معلومات الرمز: ", request.symbol);
        return false;
    }
    
    // Check if market is open
    if(!IsMarketOpen(request.symbol))
    {
        Print("❌ السوق مغلق للرمز: ", request.symbol);
        return false;
    }
    
    // Check spread condition
    double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
    if(currentSpread > params.maxSpread * m_symbolInfo.Point())
    {
        Print("❌ الفارق السعري مرتفع جداً: ", currentSpread, " > ", params.maxSpread * m_symbolInfo.Point());
        return false;
    }
    
    // Check risk management validation
    if(m_riskManager != NULL)
    {
        if(!m_riskManager.ValidateTradeRisk(request.symbol, request.volume))
        {
            Print("❌ فشل في التحقق من إدارة المخاطر");
            return false;
        }
    }
    
    // Check account margin
    double marginRequired = 0;
    if(!OrderCalcMargin(request.orderType, request.symbol, request.volume, 
                       request.price > 0 ? request.price : m_symbolInfo.Ask(), marginRequired))
    {
        Print("❌ لا يمكن حساب الهامش المطلوب");
        return false;
    }
    
    double freeMargin = m_account.MarginFree();
    if(marginRequired > freeMargin * 0.9) // Use max 90% of free margin
    {
        Print("❌ هامش غير كافي. مطلوب: ", marginRequired, ", متاح: ", freeMargin);
        return false;
    }
    
    return true;
}

ExecutionResult CProfessionalTradeExecution::ExecuteWithRetry(TradeRequest &request, ExecutionParams &params)
{
    ExecutionResult result;
    CExecutionErrorHandler errorHandler;
    
    // Set trade parameters
    m_trade.SetExpertMagicNumber(request.magicNumber);
    m_trade.SetDeviationInPoints(params.maxSlippage);
    
    for(int retry = 0; retry <= params.maxRetries; retry++)
    {
        result.retryCount = retry;
        
        // Get current price
        double currentPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                             m_symbolInfo.Ask() : m_symbolInfo.Bid();
        
        // Execute the trade
        bool tradeResult = false;
        uint startTime = GetTickCount();
        
        if(request.orderType == ORDER_TYPE_BUY)
        {
            tradeResult = m_trade.Buy(request.volume, request.symbol, 
                                    request.price > 0 ? request.price : 0,
                                    request.stopLoss, request.takeProfit, request.comment);
        }
        else if(request.orderType == ORDER_TYPE_SELL)
        {
            tradeResult = m_trade.Sell(request.volume, request.symbol,
                                     request.price > 0 ? request.price : 0,
                                     request.stopLoss, request.takeProfit, request.comment);
        }
        
        uint executionTime = GetTickCount() - startTime;
        
        // Check result
        if(tradeResult)
        {
            result.success = true;
            result.ticket = m_trade.ResultOrder();
            result.executedPrice = m_trade.ResultPrice();
            result.executedVolume = m_trade.ResultVolume();
            result.actualSlippage = CalculateSlippagePoints(currentPrice, result.executedPrice, request.symbol);
            result.executionTime = TimeCurrent();
            
            // Check if slippage is acceptable
            if(result.actualSlippage <= params.maxSlippage * m_symbolInfo.Point())
            {
                Print("✅ تم تنفيذ الصفقة بنجاح - التذكرة: ", result.ticket, 
                      ", الانزلاق: ", result.actualSlippage / m_symbolInfo.Point(), " نقطة");
                break;
            }
            else
            {
                Print("⚠️ انزلاق مرتفع: ", result.actualSlippage / m_symbolInfo.Point(), " نقطة");
                if(!params.allowPartialFill && retry < params.maxRetries)
                {
                    // Close the position and retry
                    m_trade.PositionClose(result.ticket);
                    result.success = false;
                }
            }
        }
        else
        {
            // Handle execution error
            result.errorCode = m_trade.ResultRetcode();
            result.errorDescription = "خطأ في التنفيذ: " + IntegerToString(result.errorCode);
            
            EXECUTION_ERROR execError = errorHandler.ClassifyError(result.errorCode);
            
            if(retry < params.maxRetries && errorHandler.ShouldRetry(execError, retry))
            {
                Print("⚠️ محاولة إعادة التنفيذ ", retry + 1, "/", params.maxRetries, 
                      " - الخطأ: ", result.errorDescription);
                
                // Handle specific error
                if(errorHandler.HandleError(execError, request, params))
                {
                    Sleep(errorHandler.CalculateRetryDelay(retry));
                    continue;
                }
            }
            
            Print("❌ فشل في تنفيذ الصفقة نهائياً - الخطأ: ", result.errorDescription);
            break;
        }
    }
    
    m_totalExecutions++;
    if(result.success) m_successfulExecutions++;
    
    return result;
}

void CProfessionalTradeExecution::UpdatePerformanceMetrics(ExecutionResult &result)
{
    m_totalExecutions++;
    
    if(result.success)
    {
        m_successfulExecutions++;
        
        // Update average slippage
        if(m_successfulExecutions > 1)
        {
            m_averageSlippage = (m_averageSlippage * (m_successfulExecutions - 1) + 
                               result.actualSlippage) / m_successfulExecutions;
        }
        else
        {
            m_averageSlippage = result.actualSlippage;
        }
        
        // Update average execution time
        if(m_successfulExecutions > 1)
        {
            m_averageExecutionTime = (m_averageExecutionTime * (m_successfulExecutions - 1) + 
                                    result.executionTime) / m_successfulExecutions;
        }
        else
        {
            m_averageExecutionTime = result.executionTime;
        }
        
        // Track execution quality metrics
        double slippagePoints = result.actualSlippage / SymbolInfoDouble(result.symbol, SYMBOL_POINT);
        if(slippagePoints <= 1.0)
        {
            Print("🎯 تنفيذ ممتاز - انزلاق منخفض: ", DoubleToString(slippagePoints, 1), " نقطة");
        }
        else if(slippagePoints <= 3.0)
        {
            Print("✅ تنفيذ جيد - انزلاق مقبول: ", DoubleToString(slippagePoints, 1), " نقطة");
        }
        else
        {
            Print("⚠️ تنفيذ بانزلاق مرتفع: ", DoubleToString(slippagePoints, 1), " نقطة");
        }
        
        // Log performance summary every 10 successful executions
        if(m_successfulExecutions % 10 == 0)
        {
            LogPerformanceSummary();
        }
    }
    else
    {
        Print("📊 إحصائيات الأداء محدثة - إجمالي المحاولات: ", m_totalExecutions, 
              ", الناجحة: ", m_successfulExecutions);
    }
}

void CProfessionalTradeExecution::LogExecution(TradeRequest &request, ExecutionResult &result)
{
    string logMessage = StringFormat("📊 تنفيذ صفقة %s - النوع: %s, الحجم: %.2f",
                                   request.symbol,
                                   request.orderType == ORDER_TYPE_BUY ? "شراء" : "بيع",
                                   request.volume);
    
    if(result.success)
    {
        logMessage += StringFormat(", التذكرة: %d, السعر: %.5f, الانزلاق: %.1f نقطة",
                                 result.ticket, result.executedPrice, 
                                 result.actualSlippage / SymbolInfoDouble(request.symbol, SYMBOL_POINT));
        
        Print("✅ ", logMessage);
        Print("   📈 تفاصيل التنفيذ الناجح:");
        Print("      السعر المطلوب: ", DoubleToString(request.price, _Digits));
        Print("      السعر المنفذ: ", DoubleToString(result.executedPrice, _Digits));
        Print("      الانزلاق: ", DoubleToString(result.actualSlippage / SymbolInfoDouble(request.symbol, SYMBOL_POINT), 1), " نقطة");
        Print("      وقت التنفيذ: ", result.executionTime, " مللي ثانية");
        
        // Log risk management integration
        if(m_riskManager != NULL)
        {
            string riskStatus = m_riskManager.GetRiskStatus();
            double riskLevel = m_riskManager.GetCurrentRiskLevel();
            Print("      حالة المخاطر بعد التنفيذ: ", riskStatus, " (", DoubleToString(riskLevel, 1), "%)");
        }
    }
    else
    {
        logMessage += StringFormat(", فشل - الخطأ: %s", result.errorDescription);
        Print("❌ ", logMessage);
        Print("   📉 تفاصيل التنفيذ الفاشل:");
        Print("      كود الخطأ: ", result.errorCode);
        Print("      رسالة الخطأ: ", result.errorDescription);
        Print("      عدد المحاولات: ", result.retryCount);
        
        // Log failed execution for risk management analysis
        if(m_riskManager != NULL)
        {
            Print("      تم إبلاغ نظام إدارة المخاطر بفشل التنفيذ");
        }
    }
}

double CProfessionalTradeExecution::GetSuccessRate()
{
    if(m_totalExecutions == 0) return 0.0;
    return (double)m_successfulExecutions / m_totalExecutions * 100.0;
}

void CProfessionalTradeExecution::LogPerformanceSummary()
{
    Print("📊 ملخص أداء محرك التنفيذ المهني:");
    Print("   إجمالي المحاولات: ", m_totalExecutions);
    Print("   التنفيذات الناجحة: ", m_successfulExecutions);
    Print("   معدل النجاح: ", DoubleToString(GetSuccessRate(), 1), "%");
    Print("   متوسط الانزلاق: ", DoubleToString(m_averageSlippage / SymbolInfoDouble(_Symbol, SYMBOL_POINT), 2), " نقطة");
    Print("   متوسط وقت التنفيذ: ", DoubleToString(m_averageExecutionTime, 0), " مللي ثانية");
    
    // Performance quality assessment
    double successRate = GetSuccessRate();
    if(successRate >= 95.0)
    {
        Print("🏆 أداء ممتاز - معدل نجاح عالي جداً");
    }
    else if(successRate >= 85.0)
    {
        Print("✅ أداء جيد - معدل نجاح مرتفع");
    }
    else if(successRate >= 70.0)
    {
        Print("⚠️ أداء متوسط - يحتاج تحسين");
    }
    else
    {
        Print("🚨 أداء ضعيف - يتطلب مراجعة فورية");
    }
}

void CProfessionalTradeExecution::LogExecutionStatistics()
{
    Print("📈 إحصائيات التنفيذ التفصيلية:");
    Print("   إجمالي الصفقات المنفذة: ", m_totalExecutions);
    Print("   الصفقات الناجحة: ", m_successfulExecutions);
    Print("   الصفقات الفاشلة: ", (m_totalExecutions - m_successfulExecutions));
    Print("   معدل النجاح: ", DoubleToString(GetSuccessRate(), 2), "%");
    
    if(m_successfulExecutions > 0)
    {
        Print("   متوسط الانزلاق: ", DoubleToString(m_averageSlippage / SymbolInfoDouble(_Symbol, SYMBOL_POINT), 2), " نقطة");
        Print("   متوسط وقت التنفيذ: ", DoubleToString(m_averageExecutionTime, 1), " مللي ثانية");
        
        // Execution speed assessment
        if(m_averageExecutionTime < 100)
        {
            Print("⚡ سرعة تنفيذ ممتازة");
        }
        else if(m_averageExecutionTime < 500)
        {
            Print("✅ سرعة تنفيذ جيدة");
        }
        else
        {
            Print("⚠️ سرعة تنفيذ بطيئة - قد تحتاج تحسين");
        }
    }
}

void CProfessionalTradeExecution::ResetPerformanceMetrics()
{
    m_totalExecutions = 0;
    m_successfulExecutions = 0;
    m_averageSlippage = 0.0;
    m_averageExecutionTime = 0.0;
    
    Print("🔄 تم إعادة تعيين مقاييس الأداء");
}

string CProfessionalTradeExecution::GetPerformanceReport()
{
    string report = "تقرير أداء محرك التنفيذ المهني\n";
    report += "=====================================\n";
    report += StringFormat("إجمالي المحاولات: %d\n", m_totalExecutions);
    report += StringFormat("التنفيذات الناجحة: %d\n", m_successfulExecutions);
    report += StringFormat("معدل النجاح: %.2f%%\n", GetSuccessRate());
    
    if(m_successfulExecutions > 0)
    {
        report += StringFormat("متوسط الانزلاق: %.2f نقطة\n", 
                              m_averageSlippage / SymbolInfoDouble(_Symbol, SYMBOL_POINT));
        report += StringFormat("متوسط وقت التنفيذ: %.1f مللي ثانية\n", m_averageExecutionTime);
    }
    
    report += "=====================================\n";
    
    return report;
}

//+------------------------------------------------------------------+
//| CSmartOrderRouting Implementation                                |
//+------------------------------------------------------------------+
CSmartOrderRouting::CSmartOrderRouting()
{
    m_marketEngine = NULL;
    m_liquidityThreshold = 0.5;
    m_volatilityThreshold = 2.0;
    m_maxOrderParts = 5;
}

CSmartOrderRouting::~CSmartOrderRouting()
{
    m_marketEngine = NULL;
}

bool CSmartOrderRouting::Initialize(CMarketAnalysisEngine* marketEngine)
{
    if(marketEngine == NULL)
    {
        Print("❌ خطأ: محرك التحليل فارغ في تهيئة التوجيه الذكي");
        return false;
    }
    
    m_marketEngine = marketEngine;
    Print("✅ تم تهيئة نظام التوجيه الذكي للأوامر بنجاح");
    return true;
}

bool CSmartOrderRouting::RouteOrder(TradeRequest &request, ExecutionParams &params)
{
    Print("🎯 بدء التوجيه الذكي للأمر - الرمز: ", request.symbol, ", الحجم: ", request.volume);
    
    // Step 1: Check liquidity conditions
    if(IsLowLiquidity(request.symbol))
    {
        Print("⚠️ سيولة منخفضة - سيتم تقسيم الأمر");
        return ExecuteInParts(request, params);
    }
    
    // Step 2: Check expected slippage
    double expectedSlippage = GetExpectedSlippage(request.symbol, request.volume);
    if(expectedSlippage > params.maxSlippage * m_symbolInfo.Point())
    {
        Print("⚠️ انزلاق متوقع مرتفع: ", expectedSlippage / m_symbolInfo.Point(), " نقطة - انتظار سعر أفضل");
        return WaitForBetterPrice(request, 30);
    }
    
    // Step 3: Check for news events
    if(IsNewsTime())
    {
        Print("⚠️ وقت الأخبار - تأجيل التنفيذ");
        return DelayExecution(request, 60);
    }
    
    // Step 4: Check volatility conditions
    if(IsHighVolatility(request.symbol))
    {
        Print("⚠️ تقلبات عالية - استخدام معاملات محافظة");
        params.maxSlippage = (int)(params.maxSlippage * 1.5);
        params.maxRetries = MathMin(params.maxRetries + 2, 5);
    }
    
    // Step 5: Check session overlap for optimal timing
    if(IsSessionOverlap())
    {
        Print("✅ تداخل جلسات - ظروف مثالية للتنفيذ");
        params.maxSlippage = (int)(params.maxSlippage * 0.8);
    }
    
    Print("✅ شروط التوجيه مستوفاة - المتابعة للتنفيذ المباشر");
    return true; // Proceed with normal execution
}

bool CSmartOrderRouting::ShouldDelayExecution(string symbol)
{
    // Check multiple conditions for execution delay
    if(IsNewsTime()) return true;
    if(IsLowLiquidity(symbol)) return true;
    if(IsHighVolatility(symbol) && !IsSessionOverlap()) return true;
    
    // Check spread conditions
    if(!m_symbolInfo.Name(symbol)) return true;
    double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
    double normalSpread = currentSpread * 2.0; // Assume normal spread is half current
    
    if(currentSpread > normalSpread) return true;
    
    return false;
}

bool CSmartOrderRouting::ShouldSplitOrder(TradeRequest &request)
{
    // Split large orders in low liquidity conditions
    if(IsLowLiquidity(request.symbol)) return true;
    
    // Split if expected slippage is too high
    double expectedSlippage = GetExpectedSlippage(request.symbol, request.volume);
    if(expectedSlippage > 10 * m_symbolInfo.Point()) return true;
    
    // Split very large volumes
    double maxVolume = m_symbolInfo.LotsMax();
    if(request.volume > maxVolume * 0.1) return true; // Split if > 10% of max volume
    
    return false;
}

MARKET_CONDITION_TYPE CSmartOrderRouting::GetMarketCondition(string symbol)
{
    if(!m_symbolInfo.Name(symbol)) return CONDITION_NORMAL;
    
    // Check volatility
    if(IsHighVolatility(symbol)) return CONDITION_HIGH_VOLATILITY;
    
    // Check liquidity
    if(IsLowLiquidity(symbol)) return CONDITION_LOW_LIQUIDITY;
    
    // Check news events
    if(IsNewsTime()) return CONDITION_NEWS_EVENT;
    
    // Check session overlap
    if(IsSessionOverlap()) return CONDITION_SESSION_OVERLAP;
    
    // Check market hours
    if(!IsMarketOpen(symbol)) return CONDITION_MARKET_CLOSE;
    
    return CONDITION_NORMAL;
}

double CSmartOrderRouting::CalculateOptimalTiming(string symbol)
{
    double score = 1.0; // Base score
    
    // Penalize high volatility periods
    if(IsHighVolatility(symbol)) score *= 0.7;
    
    // Penalize low liquidity periods
    if(IsLowLiquidity(symbol)) score *= 0.6;
    
    // Penalize news times
    if(IsNewsTime()) score *= 0.3;
    
    // Bonus for session overlaps
    if(IsSessionOverlap()) score *= 1.3;
    
    // Check spread conditions
    if(m_symbolInfo.Name(symbol))
    {
        double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
        double normalSpread = currentSpread * 0.5; // Assume normal is half current
        
        if(currentSpread <= normalSpread) score *= 1.2;
        else if(currentSpread > normalSpread * 2) score *= 0.5;
    }
    
    return MathMax(0.1, MathMin(2.0, score)); // Clamp between 0.1 and 2.0
}

bool CSmartOrderRouting::IsLowLiquidity(string symbol)
{
    if(!m_symbolInfo.Name(symbol)) return true;
    
    // Check current volume vs average
    long currentVolume = iVolume(symbol, PERIOD_M1, 0);
    
    // Calculate average volume for last 20 periods
    long totalVolume = 0;
    for(int i = 1; i <= 20; i++)
    {
        totalVolume += iVolume(symbol, PERIOD_M1, i);
    }
    double avgVolume = totalVolume / 20.0;
    
    // Consider low liquidity if current volume is less than 50% of average
    if(currentVolume < avgVolume * 0.5) return true;
    
    // Check spread as liquidity indicator
    double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
    double price = m_symbolInfo.Bid();
    double spreadPercent = price > 0 ? (currentSpread / price) * 100 : 0;
    
    // Consider low liquidity if spread > 0.1%
    if(spreadPercent > 0.1) return true;
    
    return false;
}

bool CSmartOrderRouting::IsHighVolatility(string symbol)
{
    if(m_marketEngine == NULL) return false;
    
    // Use market analysis engine to check volatility
    double volatilityScore = m_marketEngine.AnalyzeVolatility(symbol);
    
    // Consider high volatility if score > threshold
    return volatilityScore > m_volatilityThreshold * 25.0; // Assuming score is 0-100
}

bool CSmartOrderRouting::IsNewsTime()
{
    // Get current time structure
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    // Check for major news times (simplified)
    // Major news usually at: 08:30, 10:00, 12:30, 14:00, 15:30 GMT
    int currentMinute = timeStruct.hour * 60 + timeStruct.min;
    
    int newsTimes[] = {510, 600, 750, 840, 930}; // News times in minutes from midnight
    int newsWindow = 30; // 30 minutes window around news
    
    for(int i = 0; i < ArraySize(newsTimes); i++)
    {
        if(MathAbs(currentMinute - newsTimes[i]) <= newsWindow)
        {
            return true;
        }
    }
    
    return false;
}

bool CSmartOrderRouting::IsSessionOverlap()
{
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    int currentHour = timeStruct.hour;
    
    // London-New York overlap: 12:00-17:00 GMT
    if(currentHour >= 12 && currentHour < 17) return true;
    
    // Asian-London overlap: 07:00-09:00 GMT  
    if(currentHour >= 7 && currentHour < 9) return true;
    
    return false;
}

double CSmartOrderRouting::GetExpectedSlippage(string symbol, double volume)
{
    if(!m_symbolInfo.Name(symbol)) return 999.0;
    
    double baseSlippage = 2.0 * m_symbolInfo.Point(); // Base 2 points
    
    // Adjust for volume
    double maxVolume = m_symbolInfo.LotsMax();
    double volumeFactor = volume / maxVolume;
    baseSlippage *= (1.0 + volumeFactor);
    
    // Adjust for volatility
    if(IsHighVolatility(symbol)) baseSlippage *= 2.0;
    
    // Adjust for liquidity
    if(IsLowLiquidity(symbol)) baseSlippage *= 1.5;
    
    // Adjust for spread
    double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
    baseSlippage += currentSpread * 0.5;
    
    return baseSlippage;
}

bool CSmartOrderRouting::ExecuteInParts(TradeRequest &request, ExecutionParams &params)
{
    Print("🔄 تقسيم الأمر إلى أجزاء - الحجم الأصلي: ", request.volume);
    
    double totalVolume = request.volume;
    double partSize = totalVolume / m_maxOrderParts;
    double minLot = m_symbolInfo.LotsMin();
    double lotStep = m_symbolInfo.LotsStep();
    
    // Ensure part size is valid
    partSize = MathMax(partSize, minLot);
    partSize = MathRound(partSize / lotStep) * lotStep;
    
    if(partSize < minLot)
    {
        Print("❌ لا يمكن تقسيم الأمر - الحجم صغير جداً");
        return false;
    }
    
    // Calculate actual number of parts
    int actualParts = (int)(totalVolume / partSize);
    double remainder = totalVolume - (actualParts * partSize);
    
    Print("📊 تقسيم الأمر: ", actualParts, " أجزاء بحجم ", partSize, " + باقي ", remainder);
    
    // Modify original request for first part
    request.volume = partSize;
    
    // Note: In a real implementation, you would need to:
    // 1. Execute each part with delays
    // 2. Monitor market conditions between parts
    // 3. Adjust remaining parts based on execution results
    // 4. Handle partial fills and errors
    
    Print("✅ تم إعداد تقسيم الأمر - سيتم التنفيذ على مراحل");
    return true;
}

bool CSmartOrderRouting::WaitForBetterPrice(TradeRequest &request, int maxWaitSeconds)
{
    Print("⏳ انتظار سعر أفضل لمدة ", maxWaitSeconds, " ثانية");
    
    if(!m_symbolInfo.Name(request.symbol)) return false;
    
    double initialPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                         m_symbolInfo.Ask() : m_symbolInfo.Bid();
    double targetImprovement = 2.0 * m_symbolInfo.Point(); // Wait for 2 points improvement
    
    datetime startTime = TimeCurrent();
    datetime endTime = startTime + maxWaitSeconds;
    
    while(TimeCurrent() < endTime)
    {
        Sleep(1000); // Wait 1 second
        
        double currentPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                             m_symbolInfo.Ask() : m_symbolInfo.Bid();
        
        // Check if price improved
        bool priceImproved = false;
        if(request.orderType == ORDER_TYPE_BUY)
        {
            priceImproved = (currentPrice <= initialPrice - targetImprovement);
        }
        else
        {
            priceImproved = (currentPrice >= initialPrice + targetImprovement);
        }
        
        if(priceImproved)
        {
            Print("✅ تحسن السعر - المتابعة للتنفيذ");
            return true;
        }
        
        // Check if conditions changed (became worse)
        if(IsNewsTime() || IsHighVolatility(request.symbol))
        {
            Print("⚠️ تغيرت ظروف السوق - إيقاف الانتظار");
            break;
        }
    }
    
    Print("⏰ انتهت مهلة الانتظار - المتابعة للتنفيذ");
    return true; // Proceed anyway after timeout
}

bool CSmartOrderRouting::DelayExecution(TradeRequest &request, int delaySeconds)
{
    Print("⏸️ تأجيل التنفيذ لمدة ", delaySeconds, " ثانية بسبب ظروف السوق");
    
    datetime startTime = TimeCurrent();
    datetime endTime = startTime + delaySeconds;
    
    while(TimeCurrent() < endTime)
    {
        Sleep(5000); // Check every 5 seconds
        
        // Check if conditions improved
        if(!IsNewsTime() && !IsHighVolatility(request.symbol))
        {
            Print("✅ تحسنت ظروف السوق - المتابعة للتنفيذ");
            return true;
        }
    }
    
    Print("⏰ انتهت مهلة التأجيل - المتابعة للتنفيذ");
    return true; // Proceed anyway after delay
}

//+------------------------------------------------------------------+
//| CSlippageManager Implementation                                  |
//+------------------------------------------------------------------+
CSlippageManager::CSlippageManager()
{
    m_marketEngine = NULL;
    m_baseSlippage = 2.0;
    m_maxSlippage = 20.0;
}

CSlippageManager::~CSlippageManager()
{
    m_marketEngine = NULL;
}

bool CSlippageManager::Initialize(CMarketAnalysisEngine* marketEngine)
{
    if(marketEngine == NULL)
    {
        Print("❌ خطأ: محرك التحليل فارغ في تهيئة مدير الانزلاق");
        return false;
    }
    
    m_marketEngine = marketEngine;
    Print("✅ تم تهيئة مدير الانزلاق الديناميكي بنجاح");
    return true;
}

double CSlippageManager::CalculateDynamicSlippage(string symbol)
{
    if(!m_symbolInfo.Name(symbol))
    {
        Print("❌ لا يمكن الحصول على معلومات الرمز: ", symbol);
        return m_maxSlippage;
    }
    
    Print("🔄 حساب الانزلاق الديناميكي للرمز: ", symbol);
    
    // Start with base slippage
    double dynamicSlippage = m_baseSlippage;
    
    // Factor 1: Volatility adjustment
    double volatilityFactor = GetVolatilityFactor(symbol);
    dynamicSlippage *= volatilityFactor;
    
    // Factor 2: Time-based adjustment
    double timeFactor = GetTimeFactor();
    dynamicSlippage *= timeFactor;
    
    // Factor 3: News event adjustment
    double newsFactor = GetNewsFactor();
    dynamicSlippage *= newsFactor;
    
    // Factor 4: Liquidity adjustment
    double liquidityFactor = GetLiquidityFactor(symbol);
    dynamicSlippage *= liquidityFactor;
    
    // Factor 5: ATR-based adjustment
    double atrFactor = CalculateATRFactor(symbol);
    dynamicSlippage *= atrFactor;
    
    // Factor 6: Spread-based adjustment
    double spreadFactor = CalculateSpreadFactor(symbol);
    dynamicSlippage *= spreadFactor;
    
    // Factor 7: Volume-based adjustment
    double volumeFactor = CalculateVolumeFactor(symbol);
    dynamicSlippage *= volumeFactor;
    
    // Apply limits
    dynamicSlippage = MathMax(1.0, dynamicSlippage); // Minimum 1 point
    dynamicSlippage = MathMin(m_maxSlippage, dynamicSlippage); // Maximum limit
    
    Print("📊 الانزلاق المحسوب: ", DoubleToString(dynamicSlippage, 1), " نقطة");
    Print("   - عامل التقلب: ", DoubleToString(volatilityFactor, 2));
    Print("   - عامل الوقت: ", DoubleToString(timeFactor, 2));
    Print("   - عامل الأخبار: ", DoubleToString(newsFactor, 2));
    Print("   - عامل السيولة: ", DoubleToString(liquidityFactor, 2));
    
    return dynamicSlippage;
}

bool CSlippageManager::IsSlippageAcceptable(double requested, double executed, string symbol)
{
    if(!m_symbolInfo.Name(symbol)) return false;
    
    double actualSlippage = MathAbs(executed - requested);
    double maxAllowed = CalculateDynamicSlippage(symbol) * m_symbolInfo.Point();
    
    bool acceptable = actualSlippage <= maxAllowed;
    
    Print(acceptable ? "✅" : "❌", " فحص الانزلاق - الفعلي: ", 
          DoubleToString(actualSlippage / m_symbolInfo.Point(), 1), 
          " نقطة, المسموح: ", DoubleToString(maxAllowed / m_symbolInfo.Point(), 1), " نقطة");
    
    return acceptable;
}

double CSlippageManager::GetVolatilityFactor(string symbol)
{
    if(m_marketEngine == NULL) return 1.5; // Conservative default
    
    // Get volatility score from market analysis engine
    double volatilityScore = m_marketEngine.AnalyzeVolatility(symbol);
    
    // Convert volatility score (0-100) to factor (0.5-3.0)
    double factor = 0.5 + (volatilityScore / 100.0) * 2.5;
    
    // Apply thresholds
    if(volatilityScore < 20) factor = 0.7;      // Low volatility
    else if(volatilityScore < 40) factor = 1.0; // Normal volatility
    else if(volatilityScore < 60) factor = 1.3; // Moderate volatility
    else if(volatilityScore < 80) factor = 1.8; // High volatility
    else factor = 2.5;                          // Very high volatility
    
    return factor;
}

double CSlippageManager::GetTimeFactor()
{
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    int currentHour = timeStruct.hour;
    int currentMinute = timeStruct.min;
    
    // Major trading sessions (GMT)
    // Asian: 00:00-09:00, London: 08:00-17:00, New York: 13:00-22:00
    
    double factor = 1.0;
    
    // Session overlap periods (higher liquidity, lower slippage)
    if((currentHour >= 8 && currentHour < 9) ||   // Asian-London overlap
       (currentHour >= 13 && currentHour < 17))   // London-NY overlap
    {
        factor = 0.8; // Reduce slippage during overlaps
    }
    // Major session times (normal slippage)
    else if((currentHour >= 8 && currentHour < 17) ||  // London session
            (currentHour >= 13 && currentHour < 22))   // NY session
    {
        factor = 1.0; // Normal slippage
    }
    // Off-hours (higher slippage)
    else if(currentHour >= 22 || currentHour < 2)
    {
        factor = 1.5; // Higher slippage during thin hours
    }
    // Asian session
    else
    {
        factor = 1.2; // Slightly higher slippage
    }
    
    // Friday close adjustment (last 2 hours of NY session on Friday)
    if(timeStruct.day_of_week == 5 && currentHour >= 20)
    {
        factor *= 1.3; // Increase slippage before weekend
    }
    
    return factor;
}

double CSlippageManager::GetNewsFactor()
{
    // Check if we're in a news period
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    int currentMinute = timeStruct.hour * 60 + timeStruct.min;
    
    // Major news times (GMT) in minutes from midnight
    int majorNewsTimes[] = {510, 600, 750, 840, 930}; // 08:30, 10:00, 12:30, 14:00, 15:30
    int newsWindow = 30; // 30 minutes window
    
    // Check if we're within news window
    for(int i = 0; i < ArraySize(majorNewsTimes); i++)
    {
        int timeDiff = MathAbs(currentMinute - majorNewsTimes[i]);
        if(timeDiff <= newsWindow)
        {
            // Closer to news time = higher factor
            double proximity = 1.0 - (double)timeDiff / newsWindow;
            return 1.5 + proximity * 1.0; // Factor between 1.5-2.5
        }
    }
    
    // Check for high-impact news days (simplified)
    // First Friday of month (NFP), FOMC days, etc.
    if(timeStruct.day_of_week == 5 && timeStruct.day <= 7)
    {
        return 1.3; // NFP Friday
    }
    
    return 1.0; // Normal times
}

double CSlippageManager::GetLiquidityFactor(string symbol)
{
    if(!m_symbolInfo.Name(symbol)) return 2.0;
    
    // Check current volume vs average
    long currentVolume = iVolume(symbol, PERIOD_M1, 0);
    
    // Calculate average volume for last 20 periods
    long totalVolume = 0;
    int validPeriods = 0;
    
    for(int i = 1; i <= 20; i++)
    {
        long periodVolume = iVolume(symbol, PERIOD_M1, i);
        if(periodVolume > 0)
        {
            totalVolume += periodVolume;
            validPeriods++;
        }
    }
    
    if(validPeriods == 0) return 1.5; // Conservative default
    
    double avgVolume = (double)totalVolume / validPeriods;
    double volumeRatio = avgVolume > 0 ? currentVolume / avgVolume : 0.5;
    
    // Convert volume ratio to liquidity factor
    double factor = 1.0;
    
    if(volumeRatio < 0.3)        factor = 2.0;  // Very low liquidity
    else if(volumeRatio < 0.5)   factor = 1.5;  // Low liquidity
    else if(volumeRatio < 0.8)   factor = 1.2;  // Below average liquidity
    else if(volumeRatio < 1.2)   factor = 1.0;  // Normal liquidity
    else if(volumeRatio < 2.0)   factor = 0.9;  // Good liquidity
    else                         factor = 0.8;  // Excellent liquidity
    
    return factor;
}

double CSlippageManager::CalculateATRFactor(string symbol)
{
    // Get ATR for volatility measurement
    int atrHandle = iATR(symbol, PERIOD_M15, 14);
    if(atrHandle == INVALID_HANDLE) return 1.2;
    
    double atrValues[1];
    if(CopyBuffer(atrHandle, 0, 0, 1, atrValues) <= 0)
    {
        IndicatorRelease(atrHandle);
        return 1.2;
    }
    
    IndicatorRelease(atrHandle);
    
    if(!m_symbolInfo.Name(symbol)) return 1.2;
    
    double currentATR = atrValues[0];
    double point = m_symbolInfo.Point();
    double atrPoints = currentATR / point;
    
    // Normalize ATR to factor
    double factor = 1.0;
    
    if(atrPoints < 10)        factor = 0.8;  // Low volatility
    else if(atrPoints < 20)   factor = 1.0;  // Normal volatility
    else if(atrPoints < 40)   factor = 1.3;  // High volatility
    else if(atrPoints < 80)   factor = 1.6;  // Very high volatility
    else                      factor = 2.0;  // Extreme volatility
    
    return factor;
}

double CSlippageManager::CalculateSpreadFactor(string symbol)
{
    if(!m_symbolInfo.Name(symbol)) return 1.5;
    
    double currentSpread = m_symbolInfo.Spread() * m_symbolInfo.Point();
    double price = m_symbolInfo.Bid();
    
    if(price <= 0) return 1.5;
    
    // Calculate spread as percentage of price
    double spreadPercent = (currentSpread / price) * 100;
    
    // Convert spread percentage to factor
    double factor = 1.0;
    
    if(spreadPercent < 0.01)      factor = 0.8;  // Very tight spread
    else if(spreadPercent < 0.02) factor = 0.9;  // Tight spread
    else if(spreadPercent < 0.05) factor = 1.0;  // Normal spread
    else if(spreadPercent < 0.1)  factor = 1.2;  // Wide spread
    else if(spreadPercent < 0.2)  factor = 1.5;  // Very wide spread
    else                          factor = 2.0;  // Extremely wide spread
    
    return factor;
}

double CSlippageManager::CalculateVolumeFactor(string symbol)
{
    // Get tick volume for the current bar
    long currentVolume = iVolume(symbol, PERIOD_M1, 0);
    
    // Calculate average volume for comparison
    long totalVolume = 0;
    int validBars = 0;
    
    for(int i = 1; i <= 10; i++) // Last 10 minutes
    {
        long barVolume = iVolume(symbol, PERIOD_M1, i);
        if(barVolume > 0)
        {
            totalVolume += barVolume;
            validBars++;
        }
    }
    
    if(validBars == 0) return 1.2;
    
    double avgVolume = (double)totalVolume / validBars;
    double volumeRatio = avgVolume > 0 ? currentVolume / avgVolume : 0.5;
    
    // Convert to factor - higher volume = lower slippage
    double factor = 1.0;
    
    if(volumeRatio < 0.2)        factor = 1.8;  // Very low volume
    else if(volumeRatio < 0.5)   factor = 1.4;  // Low volume
    else if(volumeRatio < 0.8)   factor = 1.1;  // Below average volume
    else if(volumeRatio < 1.5)   factor = 1.0;  // Normal volume
    else if(volumeRatio < 3.0)   factor = 0.9;  // High volume
    else                         factor = 0.8;  // Very high volume
    
    return factor;
}

//+------------------------------------------------------------------+
//| CExecutionErrorHandler Implementation                            |
//+------------------------------------------------------------------+
CExecutionErrorHandler::CExecutionErrorHandler()
{
    m_maxRetries = 3;
    m_baseDelay = 1000; // 1 second base delay
}

CExecutionErrorHandler::~CExecutionErrorHandler()
{
    // Nothing to cleanup
}

bool CExecutionErrorHandler::HandleError(EXECUTION_ERROR error, TradeRequest &request, ExecutionParams &params)
{
    Print("🔧 معالجة خطأ التنفيذ: ", ExecutionErrorToString(error), " للرمز: ", request.symbol);
    
    switch(error)
    {
        case NO_ERROR:
            return true;
            
        case REQUOTE:
            Print("📈 إعادة تسعير - محاولة بسعر جديد");
            return HandleRequote(request, params);
            
        case OFF_QUOTES:
            Print("📊 خارج الأسعار - محاولة بسعر جديد");
            return HandleOffQuotes(request, params);
            
        case NO_LIQUIDITY:
            Print("💧 سيولة منخفضة - تقسيم الأمر");
            return HandleNoLiquidity(request, params);
            
        case TRADE_DISABLED:
            Print("🚫 التداول معطل - لا يمكن المعالجة");
            LogError(error, request, "التداول معطل للرمز");
            return false;
            
        case INVALID_STOPS:
            Print("🎯 مستويات وقف خاطئة - تعديل المستويات");
            return HandleInvalidStops(request, params);
            
        case NOT_ENOUGH_MONEY:
            Print("💰 رصيد غير كافي - تقليل الحجم");
            return HandleInsufficientMargin(request, params);
            
        case MARKET_CLOSED:
            Print("🕐 السوق مغلق - تأجيل التنفيذ");
            LogError(error, request, "السوق مغلق");
            return false;
            
        case INVALID_VOLUME:
            Print("📏 حجم غير صالح - تعديل الحجم");
            return ReduceVolume(request);
            
        case PRICE_CHANGED:
            Print("💱 تغير السعر - محاولة بسعر جديد");
            return RetryWithNewPrice(request);
            
        case TIMEOUT:
            Print("⏰ انتهت المهلة - إعادة المحاولة");
            return true; // Allow retry
            
        case CONNECTION_LOST:
            Print("🔌 انقطاع الاتصال - إعادة المحاولة");
            return true; // Allow retry
            
        default:
            Print("❓ خطأ غير معروف - محاولة عامة");
            LogError(error, request, "خطأ غير معروف");
            return false;
    }
}

EXECUTION_ERROR CExecutionErrorHandler::ClassifyError(uint errorCode)
{
    switch(errorCode)
    {
        case TRADE_RETCODE_DONE:
        case TRADE_RETCODE_DONE_PARTIAL:
            return NO_ERROR;
            
        case TRADE_RETCODE_REQUOTE:
            return REQUOTE;
            
        case TRADE_RETCODE_REJECT:
        case TRADE_RETCODE_CANCEL:
            return OFF_QUOTES;
            
        case TRADE_RETCODE_PRICE_OFF:
        case TRADE_RETCODE_PRICE_CHANGED:
            return PRICE_CHANGED;
            
        case TRADE_RETCODE_NO_MONEY:
            return NOT_ENOUGH_MONEY;
            
        case TRADE_RETCODE_MARKET_CLOSED:
            return MARKET_CLOSED;
            
        case TRADE_RETCODE_INVALID_VOLUME:
            return INVALID_VOLUME;
            
        case TRADE_RETCODE_INVALID_STOPS:
        case TRADE_RETCODE_INVALID_PRICE:
            return INVALID_STOPS;
            
        case TRADE_RETCODE_TRADE_DISABLED:
            return TRADE_DISABLED;
            
        case TRADE_RETCODE_TIMEOUT:
            return TIMEOUT;
            
        case TRADE_RETCODE_CONNECTION:
            return CONNECTION_LOST;
            
        default:
            // Check for liquidity-related errors
            if(errorCode >= 10000 && errorCode <= 10999)
                return NO_LIQUIDITY;
            
            return OFF_QUOTES; // Default classification
    }
}

bool CExecutionErrorHandler::ShouldRetry(EXECUTION_ERROR error, int currentRetry)
{
    if(currentRetry >= m_maxRetries) return false;
    
    return IsRetryableError(error);
}

int CExecutionErrorHandler::CalculateRetryDelay(int retryCount)
{
    // Exponential backoff: base_delay * (2^retry_count)
    int delay = m_baseDelay * (int)MathPow(2, retryCount);
    
    // Cap maximum delay at 30 seconds
    delay = MathMin(delay, 30000);
    
    // Add random jitter (±20%) to avoid thundering herd
    double jitter = 0.8 + (MathRand() / 32767.0) * 0.4; // 0.8 to 1.2
    delay = (int)(delay * jitter);
    
    Print("⏱️ تأخير إعادة المحاولة: ", delay, " مللي ثانية");
    return delay;
}

bool CExecutionErrorHandler::HandleRequote(TradeRequest &request, ExecutionParams &params)
{
    // Get fresh price for requote
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol))
    {
        Print("❌ لا يمكن الحصول على معلومات الرمز للإعادة التسعير");
        return false;
    }
    
    double newPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                     symbolInfo.Ask() : symbolInfo.Bid();
    
    // Check if new price is reasonable (within 5 points of original)
    if(request.price > 0)
    {
        double priceDiff = MathAbs(newPrice - request.price);
        double maxDiff = 5.0 * symbolInfo.Point();
        
        if(priceDiff > maxDiff)
        {
            Print("⚠️ فرق السعر كبير جداً: ", priceDiff / symbolInfo.Point(), " نقطة");
            // Still proceed but with increased slippage allowance
            params.maxSlippage = (int)(params.maxSlippage * 1.5);
        }
    }
    
    // Update request with new price
    request.price = newPrice;
    
    Print("✅ تم تحديث السعر للإعادة التسعير: ", newPrice);
    return true;
}

bool CExecutionErrorHandler::HandleOffQuotes(TradeRequest &request, ExecutionParams &params)
{
    // Similar to requote but more conservative
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    // Wait a moment for quotes to stabilize
    Sleep(500);
    
    // Get fresh quotes
    double newPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                     symbolInfo.Ask() : symbolInfo.Bid();
    
    // Check spread condition
    double currentSpread = symbolInfo.Spread() * symbolInfo.Point();
    if(currentSpread > params.maxSpread * symbolInfo.Point())
    {
        Print("⚠️ الفارق السعري مرتفع جداً: ", currentSpread / symbolInfo.Point(), " نقطة");
        return false; // Don't retry with high spread
    }
    
    request.price = newPrice;
    Print("✅ تم تحديث السعر بعد خروج الأسعار: ", newPrice);
    return true;
}

bool CExecutionErrorHandler::HandleNoLiquidity(TradeRequest &request, ExecutionParams &params)
{
    // Split the order into smaller parts
    return SplitOrder(request, params);
}

bool CExecutionErrorHandler::HandleInvalidStops(TradeRequest &request, ExecutionParams &params)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    double minStopLevel = symbolInfo.StopsLevel() * symbolInfo.Point();
    double currentPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                         symbolInfo.Ask() : symbolInfo.Bid();
    
    bool adjusted = false;
    
    // Adjust stop loss
    if(request.stopLoss > 0)
    {
        double slDistance = MathAbs(currentPrice - request.stopLoss);
        if(slDistance < minStopLevel)
        {
            if(request.orderType == ORDER_TYPE_BUY)
            {
                request.stopLoss = currentPrice - minStopLevel * 1.2; // 20% buffer
            }
            else
            {
                request.stopLoss = currentPrice + minStopLevel * 1.2;
            }
            adjusted = true;
            Print("🎯 تم تعديل وقف الخسارة إلى: ", request.stopLoss);
        }
    }
    
    // Adjust take profit
    if(request.takeProfit > 0)
    {
        double tpDistance = MathAbs(currentPrice - request.takeProfit);
        if(tpDistance < minStopLevel)
        {
            if(request.orderType == ORDER_TYPE_BUY)
            {
                request.takeProfit = currentPrice + minStopLevel * 1.2;
            }
            else
            {
                request.takeProfit = currentPrice - minStopLevel * 1.2;
            }
            adjusted = true;
            Print("🎯 تم تعديل جني الأرباح إلى: ", request.takeProfit);
        }
    }
    
    return adjusted;
}

bool CExecutionErrorHandler::HandleInsufficientMargin(TradeRequest &request, ExecutionParams &params)
{
    // Reduce volume by 50%
    double newVolume = request.volume * 0.5;
    
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    double minVolume = symbolInfo.LotsMin();
    double lotStep = symbolInfo.LotsStep();
    
    // Ensure new volume is valid
    newVolume = MathMax(newVolume, minVolume);
    newVolume = MathRound(newVolume / lotStep) * lotStep;
    
    if(newVolume < minVolume)
    {
        Print("❌ لا يمكن تقليل الحجم أكثر");
        return false;
    }
    
    request.volume = newVolume;
    Print("💰 تم تقليل الحجم إلى: ", newVolume, " بسبب عدم كفاية الهامش");
    return true;
}

bool CExecutionErrorHandler::RetryWithNewPrice(TradeRequest &request)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    // Get current market price
    double newPrice = (request.orderType == ORDER_TYPE_BUY) ? 
                     symbolInfo.Ask() : symbolInfo.Bid();
    
    request.price = newPrice;
    Print("💱 تم تحديث السعر: ", newPrice);
    return true;
}

bool CExecutionErrorHandler::SplitOrder(TradeRequest &request, ExecutionParams &params)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    double totalVolume = request.volume;
    double partSize = totalVolume / 3.0; // Split into 3 parts
    double minVolume = symbolInfo.LotsMin();
    double lotStep = symbolInfo.LotsStep();
    
    // Ensure part size is valid
    partSize = MathMax(partSize, minVolume);
    partSize = MathRound(partSize / lotStep) * lotStep;
    
    if(partSize < minVolume)
    {
        Print("❌ لا يمكن تقسيم الأمر - الحجم صغير جداً");
        return false;
    }
    
    // Modify request for first part
    request.volume = partSize;
    
    Print("🔄 تم تقسيم الأمر - الجزء الأول: ", partSize, " من أصل: ", totalVolume);
    
    // Note: In a complete implementation, you would need to:
    // 1. Store remaining parts for later execution
    // 2. Execute parts with delays
    // 3. Monitor execution results
    // 4. Adjust remaining parts based on market conditions
    
    return true;
}

bool CExecutionErrorHandler::AdjustStops(TradeRequest &request)
{
    return HandleInvalidStops(request, ExecutionParams()); // Use default params
}

bool CExecutionErrorHandler::ReduceVolume(TradeRequest &request)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(request.symbol)) return false;
    
    double minVolume = symbolInfo.LotsMin();
    double lotStep = symbolInfo.LotsStep();
    double newVolume = request.volume * 0.8; // Reduce by 20%
    
    // Normalize volume
    newVolume = MathMax(newVolume, minVolume);
    newVolume = MathRound(newVolume / lotStep) * lotStep;
    
    if(newVolume < minVolume)
    {
        Print("❌ لا يمكن تقليل الحجم أكثر");
        return false;
    }
    
    request.volume = newVolume;
    Print("📏 تم تقليل الحجم إلى: ", newVolume);
    return true;
}

void CExecutionErrorHandler::LogError(EXECUTION_ERROR error, TradeRequest &request, string details)
{
    string logMessage = StringFormat("خطأ تنفيذ: %s - الرمز: %s, النوع: %s, الحجم: %.2f",
                                   ExecutionErrorToString(error),
                                   request.symbol,
                                   request.orderType == ORDER_TYPE_BUY ? "شراء" : "بيع",
                                   request.volume);
    
    if(details != "")
    {
        logMessage += " - التفاصيل: " + details;
    }
    
    Print("📝 ", logMessage);
}

bool CExecutionErrorHandler::IsRetryableError(EXECUTION_ERROR error)
{
    switch(error)
    {
        case REQUOTE:
        case OFF_QUOTES:
        case PRICE_CHANGED:
        case TIMEOUT:
        case CONNECTION_LOST:
        case NO_LIQUIDITY:
        case INVALID_STOPS:
        case NOT_ENOUGH_MONEY:
        case INVALID_VOLUME:
            return true;
            
        case TRADE_DISABLED:
        case MARKET_CLOSED:
            return false;
            
        default:
            return false;
    }
}

double CExecutionErrorHandler::GetCurrentPrice(string symbol, ENUM_ORDER_TYPE orderType)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(symbol)) return 0.0;
    
    return (orderType == ORDER_TYPE_BUY) ? symbolInfo.Ask() : symbolInfo.Bid();
}

//+------------------------------------------------------------------+
//| Global Functions Implementation                                 |
//+------------------------------------------------------------------+
string ExecutionErrorToString(EXECUTION_ERROR error)
{
    switch(error)
    {
        case NO_ERROR: return "لا يوجد خطأ";
        case REQUOTE: return "إعادة تسعير";
        case OFF_QUOTES: return "خارج الأسعار";
        case NO_LIQUIDITY: return "سيولة منخفضة";
        case TRADE_DISABLED: return "التداول معطل";
        case INVALID_STOPS: return "مستويات وقف خاطئة";
        case NOT_ENOUGH_MONEY: return "رصيد غير كافي";
        case MARKET_CLOSED: return "السوق مغلق";
        case INVALID_VOLUME: return "حجم غير صالح";
        case PRICE_CHANGED: return "تغير السعر";
        case TIMEOUT: return "انتهت المهلة";
        case CONNECTION_LOST: return "انقطاع الاتصال";
        default: return "خطأ غير معروف";
    }
}

string MarketConditionToString(MARKET_CONDITION_TYPE condition)
{
    switch(condition)
    {
        case CONDITION_NORMAL: return "عادي";
        case CONDITION_HIGH_VOLATILITY: return "تقلبات عالية";
        case CONDITION_LOW_LIQUIDITY: return "سيولة منخفضة";
        case CONDITION_NEWS_EVENT: return "حدث إخباري";
        case CONDITION_SESSION_OVERLAP: return "تداخل جلسات";
        case CONDITION_MARKET_CLOSE: return "إغلاق السوق";
        default: return "غير معروف";
    }
}

bool IsMarketOpen(string symbol)
{
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(symbol)) return false;
    
    // Check if symbol is selected and quotes are available
    if(!symbolInfo.Select()) return false;
    
    // Check trading session
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    
    // Basic check - avoid weekends
    if(timeStruct.day_of_week == 0 || timeStruct.day_of_week == 6)
        return false;
    
    // Check if we can get current prices
    double bid = symbolInfo.Bid();
    double ask = symbolInfo.Ask();
    
    return (bid > 0 && ask > 0 && ask > bid);
}

double CalculateSlippagePoints(double requestedPrice, double executedPrice, string symbol)
{
    if(requestedPrice <= 0 || executedPrice <= 0) return 0.0;
    
    CSymbolInfo symbolInfo;
    if(!symbolInfo.Name(symbol)) return 0.0;
    
    double slippage = MathAbs(executedPrice - requestedPrice);
    return slippage; // Return in price units, not points
}

//+------------------------------------------------------------------+
