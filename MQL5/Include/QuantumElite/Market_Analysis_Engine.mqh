//+------------------------------------------------------------------+
//|                                        Market_Analysis_Engine.mqh |
//|                                  Copyright 2024, QuantumElite EA |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, QuantumElite EA"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Include necessary files                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Global indicator handles                                         |
//+------------------------------------------------------------------+
int g_handleADX_M5 = INVALID_HANDLE;
int g_handleADX_M15 = INVALID_HANDLE;
int g_handleADX_H1 = INVALID_HANDLE;
int g_handleADX_H4 = INVALID_HANDLE;
int g_handleATR_M5 = INVALID_HANDLE;
int g_handleATR_M15 = INVALID_HANDLE;
int g_handleATR_H1 = INVALID_HANDLE;
int g_handleATR_H4 = INVALID_HANDLE;
int g_handleVolume_H1 = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Market regime enumeration                                        |
//+------------------------------------------------------------------+
enum MARKET_REGIME
{
    STRONG_TREND_UP,
    WEAK_TREND_UP,
    RANGING,
    WEAK_TREND_DOWN,
    STRONG_TREND_DOWN,
    HIGH_VOLATILITY
};

//+------------------------------------------------------------------+
//| Multi-timeframe analysis structure                              |
//+------------------------------------------------------------------+
struct MultiTimeframeAnalysis
{
    double M5_trend;     // وزن 10%
    double M15_trend;    // وزن 20%
    double H1_trend;     // وزن 40%
    double H4_trend;     // وزن 30%
    
    //+------------------------------------------------------------------+
    //| Calculate overall trend based on weighted timeframes            |
    //+------------------------------------------------------------------+
    double CalculateOverallTrend()
    {
        return M5_trend * 0.1 + M15_trend * 0.2 + 
               H1_trend * 0.4 + H4_trend * 0.3;
    }
    
    //+------------------------------------------------------------------+
    //| Update trend values for all timeframes                          |
    //+------------------------------------------------------------------+
    void UpdateTrends(string symbol)
    {
        M5_trend = GetTrendStrength(symbol, PERIOD_M5);
        M15_trend = GetTrendStrength(symbol, PERIOD_M15);
        H1_trend = GetTrendStrength(symbol, PERIOD_H1);
        H4_trend = GetTrendStrength(symbol, PERIOD_H4);
    }
    
private:
    //+------------------------------------------------------------------+
    //| Get trend strength for specific timeframe                       |
    //+------------------------------------------------------------------+
    double GetTrendStrength(string symbol, ENUM_TIMEFRAMES timeframe)
    {
        int adx_handle = INVALID_HANDLE;
        
        switch(timeframe)
        {
            case PERIOD_M5:  adx_handle = g_handleADX_M5; break;
            case PERIOD_M15: adx_handle = g_handleADX_M15; break;
            case PERIOD_H1:  adx_handle = g_handleADX_H1; break;
            case PERIOD_H4:  adx_handle = g_handleADX_H4; break;
            default: return 0.0;
        }
        
        if(adx_handle == INVALID_HANDLE)
            return 0.0;
            
        double adx_buffer[3];
        double plus_di_buffer[3];
        double minus_di_buffer[3];
        
        if(CopyBuffer(adx_handle, 0, 0, 3, adx_buffer) < 3 ||
           CopyBuffer(adx_handle, 1, 0, 3, plus_di_buffer) < 3 ||
           CopyBuffer(adx_handle, 2, 0, 3, minus_di_buffer) < 3)
            return 0.0;
            
        double adx_value = adx_buffer[0];
        double plus_di = plus_di_buffer[0];
        double minus_di = minus_di_buffer[0];
        
        if(adx_value < 20) return 0.0; // Weak trend
        
        if(plus_di > minus_di)
            return adx_value / 100.0; // Positive trend
        else
            return -(adx_value / 100.0); // Negative trend
    }
};

//+------------------------------------------------------------------+
//| Volume analysis structure                                        |
//+------------------------------------------------------------------+
struct VolumeAnalysis
{
    double currentVolume;
    double avgVolume;
    double volumeRatio;
    bool isHighVolume;
    bool isLowLiquidity;
    
    //+------------------------------------------------------------------+
    //| Analyze volume conditions                                        |
    //+------------------------------------------------------------------+
    void Analyze(string symbol)
    {
        long volume_buffer[20];
        
        if(CopyTickVolume(symbol, PERIOD_H1, 0, 20, volume_buffer) < 20)
        {
            isHighVolume = false;
            isLowLiquidity = true;
            return;
        }
        
        currentVolume = (double)volume_buffer[0];
        
        // Calculate average volume
        double sum = 0;
        for(int i = 1; i < 20; i++)
            sum += (double)volume_buffer[i];
        avgVolume = sum / 19.0;
        
        volumeRatio = (avgVolume > 0) ? currentVolume / avgVolume : 1.0;
        
        isHighVolume = (volumeRatio > 1.5);
        isLowLiquidity = (volumeRatio < 0.3);
    }
    
    //+------------------------------------------------------------------+
    //| Check if volume conditions are favorable for trading            |
    //+------------------------------------------------------------------+
    bool IsVolumeGoodForTrading()
    {
        return !isLowLiquidity && volumeRatio > 0.7;
    }
};

//+------------------------------------------------------------------+
//| Market microstructure analysis                                  |
//+------------------------------------------------------------------+
struct MarketMicrostructure
{
    double spread;
    double avgSpread;
    int tickVolume;
    double priceVelocity;
    double spreadHistory[10];
    int spreadIndex;
    
    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    MarketMicrostructure()
    {
        spreadIndex = 0;
        ArrayInitialize(spreadHistory, 0.0);
    }
    
    //+------------------------------------------------------------------+
    //| Update market microstructure data                               |
    //+------------------------------------------------------------------+
    void Update(string symbol)
    {
        MqlTick tick;
        if(!SymbolInfoTick(symbol, tick))
            return;
            
        spread = tick.ask - tick.bid;
        tickVolume = (int)tick.volume;
        
        // Update spread history
        spreadHistory[spreadIndex] = spread;
        spreadIndex = (spreadIndex + 1) % 10;
        
        // Calculate average spread
        double sum = 0;
        for(int i = 0; i < 10; i++)
            sum += spreadHistory[i];
        avgSpread = sum / 10.0;
        
        // Calculate price velocity (price change per second)
        static double lastPrice = 0;
        static datetime lastTime = 0;
        
        if(lastTime > 0)
        {
            double priceDiff = MathAbs(tick.last - lastPrice);
            int timeDiff = (int)(tick.time - lastTime);
            priceVelocity = (timeDiff > 0) ? priceDiff / timeDiff : 0;
        }
        
        lastPrice = tick.last;
        lastTime = tick.time;
    }
    
    //+------------------------------------------------------------------+
    //| Check if market conditions are good for trading                 |
    //+------------------------------------------------------------------+
    bool IsGoodMarketCondition()
    {
        // Spread should be less than 2x average
        bool spreadOK = (avgSpread > 0) ? (spread < 2.0 * avgSpread) : true;
        
        // Tick volume should be above minimum
        bool volumeOK = (tickVolume > 10);
        
        // No erratic price moves
        bool velocityOK = (priceVelocity < 0.001); // Adjust threshold as needed
        
        return spreadOK && volumeOK && velocityOK;
    }
    
    //+------------------------------------------------------------------+
    //| Get spread quality rating (0-100)                               |
    //+------------------------------------------------------------------+
    int GetSpreadQuality()
    {
        if(avgSpread <= 0) return 50;
        
        double ratio = spread / avgSpread;
        
        if(ratio <= 0.5) return 100;      // Excellent
        else if(ratio <= 1.0) return 80;  // Good
        else if(ratio <= 1.5) return 60;  // Fair
        else if(ratio <= 2.0) return 40;  // Poor
        else return 20;                   // Very poor
    }
};

//+------------------------------------------------------------------+
//| Main Market Analysis Engine class                               |
//+------------------------------------------------------------------+
class CMarketAnalysisEngine
{
private:
    MultiTimeframeAnalysis m_mtfAnalysis;
    VolumeAnalysis m_volumeAnalysis;
    MarketMicrostructure m_microstructure;
    string m_symbol;
    
public:
    //+------------------------------------------------------------------+
    //| Constructor                                                      |
    //+------------------------------------------------------------------+
    CMarketAnalysisEngine(string symbol = "")
    {
        m_symbol = (symbol == "") ? Symbol() : symbol;
    }
    
    //+------------------------------------------------------------------+
    //| Initialize all indicator handles                                 |
    //+------------------------------------------------------------------+
    bool Initialize()
    {
        // Initialize ADX handles for all timeframes
        g_handleADX_M5 = iADX(m_symbol, PERIOD_M5, 14);
        g_handleADX_M15 = iADX(m_symbol, PERIOD_M15, 14);
        g_handleADX_H1 = iADX(m_symbol, PERIOD_H1, 14);
        g_handleADX_H4 = iADX(m_symbol, PERIOD_H4, 14);
        
        // Initialize ATR handles for all timeframes
        g_handleATR_M5 = iATR(m_symbol, PERIOD_M5, 14);
        g_handleATR_M15 = iATR(m_symbol, PERIOD_M15, 14);
        g_handleATR_H1 = iATR(m_symbol, PERIOD_H1, 14);
        g_handleATR_H4 = iATR(m_symbol, PERIOD_H4, 14);
        
        // Initialize Volume handle
        g_handleVolume_H1 = iVolumes(m_symbol, PERIOD_H1, VOLUME_TICK);
        
        // Check if all handles are valid
        if(g_handleADX_M5 == INVALID_HANDLE || g_handleADX_M15 == INVALID_HANDLE ||
           g_handleADX_H1 == INVALID_HANDLE || g_handleADX_H4 == INVALID_HANDLE ||
           g_handleATR_M5 == INVALID_HANDLE || g_handleATR_M15 == INVALID_HANDLE ||
           g_handleATR_H1 == INVALID_HANDLE || g_handleATR_H4 == INVALID_HANDLE ||
           g_handleVolume_H1 == INVALID_HANDLE)
        {
            Print("Failed to initialize indicator handles for Market Analysis Engine");
            return false;
        }
        
        Print("Market Analysis Engine initialized successfully for ", m_symbol);
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Release all indicator handles                                    |
    //+------------------------------------------------------------------+
    void Deinitialize()
    {
        if(g_handleADX_M5 != INVALID_HANDLE) IndicatorRelease(g_handleADX_M5);
        if(g_handleADX_M15 != INVALID_HANDLE) IndicatorRelease(g_handleADX_M15);
        if(g_handleADX_H1 != INVALID_HANDLE) IndicatorRelease(g_handleADX_H1);
        if(g_handleADX_H4 != INVALID_HANDLE) IndicatorRelease(g_handleADX_H4);
        if(g_handleATR_M5 != INVALID_HANDLE) IndicatorRelease(g_handleATR_M5);
        if(g_handleATR_M15 != INVALID_HANDLE) IndicatorRelease(g_handleATR_M15);
        if(g_handleATR_H1 != INVALID_HANDLE) IndicatorRelease(g_handleATR_H1);
        if(g_handleATR_H4 != INVALID_HANDLE) IndicatorRelease(g_handleATR_H4);
        if(g_handleVolume_H1 != INVALID_HANDLE) IndicatorRelease(g_handleVolume_H1);
        
        Print("Market Analysis Engine deinitialized");
    }
    
    //+------------------------------------------------------------------+
    //| Detect current market regime                                    |
    //+------------------------------------------------------------------+
    MARKET_REGIME DetectMarketRegime(string symbol = "")
    {
        if(symbol == "") symbol = m_symbol;
        
        // Get ADX and ATR values for H1 timeframe
        double adx_buffer[3];
        double plus_di_buffer[3];
        double minus_di_buffer[3];
        double atr_buffer[3];
        
        if(CopyBuffer(g_handleADX_H1, 0, 0, 3, adx_buffer) < 3 ||
           CopyBuffer(g_handleADX_H1, 1, 0, 3, plus_di_buffer) < 3 ||
           CopyBuffer(g_handleADX_H1, 2, 0, 3, minus_di_buffer) < 3 ||
           CopyBuffer(g_handleATR_H1, 0, 0, 3, atr_buffer) < 3)
        {
            return RANGING;
        }
        
        double adx = adx_buffer[0];
        double plus_di = plus_di_buffer[0];
        double minus_di = minus_di_buffer[0];
        double atr = atr_buffer[0];
        
        // Get current price for ATR comparison
        double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
        double atr_percentage = (currentPrice > 0) ? (atr / currentPrice) * 100 : 0;
        
        // High volatility check
        if(atr_percentage > 2.0) // ATR > 2% of price
            return HIGH_VOLATILITY;
        
        // Trend strength analysis
        if(adx > 40) // Strong trend
        {
            if(plus_di > minus_di)
                return STRONG_TREND_UP;
            else
                return STRONG_TREND_DOWN;
        }
        else if(adx > 20) // Weak trend
        {
            if(plus_di > minus_di)
                return WEAK_TREND_UP;
            else
                return WEAK_TREND_DOWN;
        }
        else // Ranging market
        {
            return RANGING;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Perform complete market analysis                                |
    //+------------------------------------------------------------------+
    void PerformCompleteAnalysis()
    {
        // Update multi-timeframe analysis
        m_mtfAnalysis.UpdateTrends(m_symbol);
        
        // Update volume analysis
        m_volumeAnalysis.Analyze(m_symbol);
        
        // Update market microstructure
        m_microstructure.Update(m_symbol);
    }
    
    //+------------------------------------------------------------------+
    //| Get overall market score (0-100)                               |
    //+------------------------------------------------------------------+
    double GetOverallMarketScore()
    {
        double trendScore = MathAbs(m_mtfAnalysis.CalculateOverallTrend()) * 100;
        double volumeScore = m_volumeAnalysis.IsVolumeGoodForTrading() ? 80 : 40;
        double microScore = m_microstructure.GetSpreadQuality();
        double conditionScore = m_microstructure.IsGoodMarketCondition() ? 80 : 20;
        
        return (trendScore * 0.4 + volumeScore * 0.2 + microScore * 0.2 + conditionScore * 0.2);
    }
    
    //+------------------------------------------------------------------+
    //| Get market analysis summary                                      |
    //+------------------------------------------------------------------+
    string GetAnalysisSummary()
    {
        MARKET_REGIME regime = DetectMarketRegime();
        double overallTrend = m_mtfAnalysis.CalculateOverallTrend();
        double marketScore = GetOverallMarketScore();
        
        string regimeStr = "";
        switch(regime)
        {
            case STRONG_TREND_UP: regimeStr = "Strong Uptrend"; break;
            case WEAK_TREND_UP: regimeStr = "Weak Uptrend"; break;
            case RANGING: regimeStr = "Ranging Market"; break;
            case WEAK_TREND_DOWN: regimeStr = "Weak Downtrend"; break;
            case STRONG_TREND_DOWN: regimeStr = "Strong Downtrend"; break;
            case HIGH_VOLATILITY: regimeStr = "High Volatility"; break;
        }
        
        return StringFormat("Market Analysis for %s:\n" +
                          "Regime: %s\n" +
                          "Overall Trend: %.3f\n" +
                          "Market Score: %.1f/100\n" +
                          "Volume Ratio: %.2f\n" +
                          "Spread Quality: %d/100\n" +
                          "Good Conditions: %s",
                          m_symbol, regimeStr, overallTrend, marketScore,
                          m_volumeAnalysis.volumeRatio,
                          m_microstructure.GetSpreadQuality(),
                          m_microstructure.IsGoodMarketCondition() ? "Yes" : "No");
    }
    
    //+------------------------------------------------------------------+
    //| Check if market conditions are suitable for trading             |
    //+------------------------------------------------------------------+
    bool IsMarketSuitableForTrading()
    {
        return (GetOverallMarketScore() > 60.0 && 
                m_volumeAnalysis.IsVolumeGoodForTrading() &&
                m_microstructure.IsGoodMarketCondition());
    }
    
    //+------------------------------------------------------------------+
    //| Get multi-timeframe analysis                                    |
    //+------------------------------------------------------------------+
    MultiTimeframeAnalysis* GetMTFAnalysis() { return &m_mtfAnalysis; }
    
    //+------------------------------------------------------------------+
    //| Get volume analysis                                             |
    //+------------------------------------------------------------------+
    VolumeAnalysis* GetVolumeAnalysis() { return &m_volumeAnalysis; }
    
    //+------------------------------------------------------------------+
    //| Get market microstructure analysis                             |
    //+------------------------------------------------------------------+
    MarketMicrostructure* GetMicrostructure() { return &m_microstructure; }
};

//+------------------------------------------------------------------+
//| Global instance for easy access                                 |
//+------------------------------------------------------------------+
CMarketAnalysisEngine* g_MarketEngine = NULL;

//+------------------------------------------------------------------+
//| Initialize Market Analysis Engine                               |
//+------------------------------------------------------------------+
bool InitializeMarketEngine(string symbol = "")
{
    if(g_MarketEngine != NULL)
        delete g_MarketEngine;
        
    g_MarketEngine = new CMarketAnalysisEngine(symbol);
    
    if(g_MarketEngine == NULL)
    {
        Print("Failed to create Market Analysis Engine instance");
        return false;
    }
    
    return g_MarketEngine.Initialize();
}

//+------------------------------------------------------------------+
//| Deinitialize Market Analysis Engine                            |
//+------------------------------------------------------------------+
void DeinitializeMarketEngine()
{
    if(g_MarketEngine != NULL)
    {
        g_MarketEngine.Deinitialize();
        delete g_MarketEngine;
        g_MarketEngine = NULL;
    }
}

//+------------------------------------------------------------------+
