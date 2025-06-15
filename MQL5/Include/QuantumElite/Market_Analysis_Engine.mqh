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
//|                          Market Analysis Engine                  |
//|                     محرك التحليل المتقدم للأسواق               |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Quantum Trading Systems"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Indicators\Indicators.mqh>

enum ENUM_MARKET_CONDITION
{
   MARKET_TRENDING_UP,
   MARKET_TRENDING_DOWN,
   MARKET_RANGING,
   MARKET_VOLATILE
};

enum ENUM_SIGNAL_STRENGTH
{
   SIGNAL_WEAK,
   SIGNAL_MODERATE,
   SIGNAL_STRONG,
   SIGNAL_VERY_STRONG
};

struct MarketData
{
   double            price;
   double            volume;
   double            volatility;
   double            momentum;
   ENUM_MARKET_CONDITION condition;
   datetime          timestamp;
};

struct TechnicalLevels
{
   double            support[];
   double            resistance[];
   double            pivotPoint;
   double            fibonacciLevels[];
};

class CMarketAnalysisEngine
{
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_lookbackPeriod;
   double            m_minSignalStrength;
   
   MarketData        m_marketData[];
   TechnicalLevels   m_levels;
   
   double            m_rsiValues[];
   double            m_macdMain[];
   double            m_macdSignal[];
   double            m_bbUpper[];
   double            m_bbLower[];
   double            m_bbMiddle[];
   
   int               m_handleRSI;
   int               m_handleMACD;
   int               m_handleBB;
   int               m_handleMA20;
   int               m_handleMA50;
   int               m_handleMA200;

public:
                     CMarketAnalysisEngine();
                    ~CMarketAnalysisEngine();
   
   bool              Initialize(string symbol, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   double            AnalyzeSymbolComplete(string symbol);
   double            AnalyzeTrend(string symbol);
   double            AnalyzeMomentum(string symbol);
   double            AnalyzeVolatility(string symbol);
   double            AnalyzeVolume(string symbol);
   double            AnalyzeBollingerBands(string symbol);
   double            AnalyzePivotPoints(string symbol);
   double            AnalyzeRSI(string symbol);
   double            AnalyzeMACD(string symbol);
   double            AnalyzeFibonacci(string symbol);
   
   double            GetTrendStrength(string symbol);
   double            GetVolatilityIndex(string symbol);
   ENUM_MARKET_CONDITION GetMarketCondition(string symbol);
   
   bool              UpdateMarketData(string symbol);
   double            CalculateNeuralNetworkPrediction(string symbol);
   double            GetQuantumAnalysisScore(string symbol);
   
   string            GenerateMarketReport(string symbol);
};

CMarketAnalysisEngine::CMarketAnalysisEngine()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_lookbackPeriod = 100;
   m_minSignalStrength = 0.6;
   
   m_handleRSI = INVALID_HANDLE;
   m_handleMACD = INVALID_HANDLE;
   m_handleBB = INVALID_HANDLE;
   m_handleMA20 = INVALID_HANDLE;
   m_handleMA50 = INVALID_HANDLE;
   m_handleMA200 = INVALID_HANDLE;
}

CMarketAnalysisEngine::~CMarketAnalysisEngine()
{
   Deinitialize();
}

bool CMarketAnalysisEngine::Initialize(string symbol, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   
   m_handleRSI = iRSI(symbol, timeframe, 14, PRICE_CLOSE);
   m_handleMACD = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
   m_handleBB = iBands(symbol, timeframe, 20, 0, 2.0, PRICE_CLOSE);
   m_handleMA20 = iMA(symbol, timeframe, 20, 0, MODE_EMA, PRICE_CLOSE);
   m_handleMA50 = iMA(symbol, timeframe, 50, 0, MODE_EMA, PRICE_CLOSE);
   m_handleMA200 = iMA(symbol, timeframe, 200, 0, MODE_SMA, PRICE_CLOSE);
   
   if(m_handleRSI == INVALID_HANDLE || m_handleMACD == INVALID_HANDLE || 
      m_handleBB == INVALID_HANDLE || m_handleMA20 == INVALID_HANDLE ||
      m_handleMA50 == INVALID_HANDLE || m_handleMA200 == INVALID_HANDLE)
   {
      Print("فشل في تهيئة المؤشرات للرمز: ", symbol);
      return false;
   }
   
   ArrayResize(m_rsiValues, m_lookbackPeriod);
   ArrayResize(m_macdMain, m_lookbackPeriod);
   ArrayResize(m_macdSignal, m_lookbackPeriod);
   ArrayResize(m_bbUpper, m_lookbackPeriod);
   ArrayResize(m_bbLower, m_lookbackPeriod);
   ArrayResize(m_bbMiddle, m_lookbackPeriod);
   
   ArraySetAsSeries(m_rsiValues, true);
   ArraySetAsSeries(m_macdMain, true);
   ArraySetAsSeries(m_macdSignal, true);
   ArraySetAsSeries(m_bbUpper, true);
   ArraySetAsSeries(m_bbLower, true);
   ArraySetAsSeries(m_bbMiddle, true);
   
   return true;
}

void CMarketAnalysisEngine::Deinitialize()
{
   if(m_handleRSI != INVALID_HANDLE) IndicatorRelease(m_handleRSI);
   if(m_handleMACD != INVALID_HANDLE) IndicatorRelease(m_handleMACD);
   if(m_handleBB != INVALID_HANDLE) IndicatorRelease(m_handleBB);
   if(m_handleMA20 != INVALID_HANDLE) IndicatorRelease(m_handleMA20);
   if(m_handleMA50 != INVALID_HANDLE) IndicatorRelease(m_handleMA50);
   if(m_handleMA200 != INVALID_HANDLE) IndicatorRelease(m_handleMA200);
}

double CMarketAnalysisEngine::AnalyzeSymbolComplete(string symbol)
{
   double totalScore = 0;
   
   totalScore += AnalyzeTrend(symbol) * 0.25;
   totalScore += AnalyzeMomentum(symbol) * 0.20;
   totalScore += AnalyzeVolatility(symbol) * 0.15;
   totalScore += AnalyzeVolume(symbol) * 0.15;
   totalScore += AnalyzeBollingerBands(symbol) * 0.10;
   totalScore += AnalyzePivotPoints(symbol) * 0.10;
   totalScore += AnalyzeFibonacci(symbol) * 0.05;
   
   return MathMin(totalScore, 100.0);
}

double CMarketAnalysisEngine::AnalyzeTrend(string symbol)
{
   double ema20[], ema50[], ema200[];
   ArraySetAsSeries(ema20, true);
   ArraySetAsSeries(ema50, true);
   ArraySetAsSeries(ema200, true);
   
   if(CopyBuffer(m_handleMA20, 0, 0, 10, ema20) <= 0 ||
      CopyBuffer(m_handleMA50, 0, 0, 10, ema50) <= 0 ||
      CopyBuffer(m_handleMA200, 0, 0, 10, ema200) <= 0)
   {
      return 0;
   }
   
   double score = 0;
   
   if(ema20[0] > ema50[0] && ema50[0] > ema200[0])
   {
      score += 40;
      if(ema20[0] > ema20[1] && ema50[0] > ema50[1])
         score += 20;
   }
   else if(ema20[0] < ema50[0] && ema50[0] < ema200[0])
   {
      score += 40;
      if(ema20[0] < ema20[1] && ema50[0] < ema50[1])
         score += 20;
   }
   
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   if(currentPrice > ema20[0])
      score += 10;
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeMomentum(string symbol)
{
   if(CopyBuffer(m_handleRSI, 0, 0, 10, m_rsiValues) <= 0)
      return 0;
   
   double score = 0;
   double rsi = m_rsiValues[0];
   
   if(rsi > 30 && rsi < 70)
   {
      score += 30;
   }
   
   if(rsi > 50 && m_rsiValues[0] > m_rsiValues[1])
   {
      score += 25;
   }
   else if(rsi < 50 && m_rsiValues[0] < m_rsiValues[1])
   {
      score += 25;
   }
   
   if(rsi > 70)
      score += 15;
   else if(rsi < 30)
      score += 15;
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeVolatility(string symbol)
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
   double score = 0;
   
   if(volatilityRatio > 0.01 && volatilityRatio < 0.03)
   {
      score += 50;
   }
   else if(volatilityRatio > 0.005)
   {
      score += 30;
   }
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeVolume(string symbol)
{
   long volume[];
   double close[];
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(close, true);
   
   CopyTickVolume(symbol, PERIOD_CURRENT, 0, 20, volume);
   CopyClose(symbol, PERIOD_CURRENT, 0, 20, close);
   
   double avgVolume = 0;
   for(int i = 1; i < 20; i++)
   {
      avgVolume += (double)volume[i];
   }
   avgVolume /= 19;
   
   double score = 0;
   double volumeRatio = (double)volume[0] / avgVolume;
   
   if(volumeRatio > 2.0)
   {
      score += 50;
   }
   else if(volumeRatio > 1.5)
   {
      score += 30;
   }
   else if(volumeRatio > 1.2)
   {
      score += 20;
   }
   
   double priceChange = (close[0] - close[1]) / close[1];
   
   if(volumeRatio > 1.5 && MathAbs(priceChange) > 0.001)
   {
      score += 30;
   }
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeBollingerBands(string symbol)
{
   if(CopyBuffer(m_handleBB, 0, 0, 5, m_bbMiddle) <= 0 ||
      CopyBuffer(m_handleBB, 1, 0, 5, m_bbUpper) <= 0 ||
      CopyBuffer(m_handleBB, 2, 0, 5, m_bbLower) <= 0)
   {
      return 0;
   }
   
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double bandWidth = (m_bbUpper[0] - m_bbLower[0]) / m_bbMiddle[0];
   double score = 0;
   
   if(currentPrice > m_bbUpper[0])
   {
      score += 20;
   }
   else if(currentPrice < m_bbLower[0])
   {
      score += 20;
   }
   else if(currentPrice > m_bbMiddle[0])
   {
      score += 30;
   }
   
   if(bandWidth > 0.02)
   {
      score += 20;
   }
   else if(bandWidth < 0.01)
   {
      score += 30;
   }
   
   return score;
}

double CMarketAnalysisEngine::AnalyzePivotPoints(string symbol)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_D1, 1, 1, high);
   CopyLow(symbol, PERIOD_D1, 1, 1, low);
   CopyClose(symbol, PERIOD_D1, 1, 1, close);
   
   double pivot = (high[0] + low[0] + close[0]) / 3;
   double r1 = 2 * pivot - low[0];
   double s1 = 2 * pivot - high[0];
   double r2 = pivot + (high[0] - low[0]);
   double s2 = pivot - (high[0] - low[0]);
   
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double score = 0;
   
   double levels[] = {s2, s1, pivot, r1, r2};
   
   for(int i = 0; i < ArraySize(levels); i++)
   {
      double distance = MathAbs(currentPrice - levels[i]) / currentPrice;
      
      if(distance < 0.001)
      {
         score += 40;
      }
      else if(distance < 0.002)
      {
         score += 20;
      }
   }
   
   return MathMin(score, 100.0);
}

double CMarketAnalysisEngine::AnalyzeRSI(string symbol)
{
   if(CopyBuffer(m_handleRSI, 0, 0, 5, m_rsiValues) <= 0)
      return 0;
   
   double rsi = m_rsiValues[0];
   double score = 0;
   
   if(rsi > 70)
      score += 30;
   else if(rsi < 30)
      score += 30;
   else if(rsi > 45 && rsi < 55)
      score += 20;
   
   if(m_rsiValues[0] > m_rsiValues[1] && m_rsiValues[1] > m_rsiValues[2])
      score += 25;
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeMACD(string symbol)
{
   if(CopyBuffer(m_handleMACD, 0, 0, 5, m_macdMain) <= 0 ||
      CopyBuffer(m_handleMACD, 1, 0, 5, m_macdSignal) <= 0)
   {
      return 0;
   }
   
   double score = 0;
   
   if(m_macdMain[0] > m_macdSignal[0] && m_macdMain[1] <= m_macdSignal[1])
   {
      score += 40;
   }
   else if(m_macdMain[0] < m_macdSignal[0] && m_macdMain[1] >= m_macdSignal[1])
   {
      score += 40;
   }
   
   if(m_macdMain[0] > 0 && m_macdMain[0] > m_macdMain[1])
   {
      score += 20;
   }
   else if(m_macdMain[0] < 0 && m_macdMain[0] < m_macdMain[1])
   {
      score += 20;
   }
   
   return score;
}

double CMarketAnalysisEngine::AnalyzeFibonacci(string symbol)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, 100, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, 100, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, 100, close);
   
   double swingHigh = high[ArrayMaximum(high, 0, 50)];
   double swingLow = low[ArrayMinimum(low, 0, 50)];
   double range = swingHigh - swingLow;
   
   double fibLevels[] = {0.236, 0.382, 0.5, 0.618, 0.786};
   double currentPrice = close[0];
   double score = 0;
   
   for(int i = 0; i < ArraySize(fibLevels); i++)
   {
      double fibLevel = swingLow + (range * fibLevels[i]);
      double distance = MathAbs(currentPrice - fibLevel) / currentPrice;
      
      if(distance < 0.002)
      {
         score += 20;
      }
   }
   
   return MathMin(score, 100.0);
}

double CMarketAnalysisEngine::GetTrendStrength(string symbol)
{
   return AnalyzeTrend(symbol) / 100.0;
}

double CMarketAnalysisEngine::GetVolatilityIndex(string symbol)
{
   return AnalyzeVolatility(symbol) / 100.0;
}

ENUM_MARKET_CONDITION CMarketAnalysisEngine::GetMarketCondition(string symbol)
{
   double trendScore = AnalyzeTrend(symbol);
   double volatilityScore = AnalyzeVolatility(symbol);
   
   if(trendScore > 60 && volatilityScore < 30)
   {
      double ema20[], ema50[];
      ArraySetAsSeries(ema20, true);
      ArraySetAsSeries(ema50, true);
      
      CopyBuffer(m_handleMA20, 0, 0, 2, ema20);
      CopyBuffer(m_handleMA50, 0, 0, 2, ema50);
      
      if(ema20[0] > ema50[0])
         return MARKET_TRENDING_UP;
      else
         return MARKET_TRENDING_DOWN;
   }
   else if(volatilityScore > 60)
   {
      return MARKET_VOLATILE;
   }
   
   return MARKET_RANGING;
}

bool CMarketAnalysisEngine::UpdateMarketData(string symbol)
{
   int dataSize = ArraySize(m_marketData);
   ArrayResize(m_marketData, dataSize + 1);
   
   m_marketData[dataSize].price = SymbolInfoDouble(symbol, SYMBOL_BID);
   m_marketData[dataSize].volume = (double)SymbolInfoInteger(symbol, SYMBOL_VOLUME);
   m_marketData[dataSize].volatility = GetVolatilityIndex(symbol);
   m_marketData[dataSize].momentum = AnalyzeMomentum(symbol);
   m_marketData[dataSize].condition = GetMarketCondition(symbol);
   m_marketData[dataSize].timestamp = TimeCurrent();
   
   return true;
}

double CMarketAnalysisEngine::CalculateNeuralNetworkPrediction(string symbol)
{
   double inputs[10];
   double close[];
   long volume[];
   
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   
   CopyClose(symbol, PERIOD_CURRENT, 0, 10, close);
   CopyTickVolume(symbol, PERIOD_CURRENT, 0, 10, volume);
   
   for(int i = 0; i < 5; i++)
   {
      inputs[i] = (close[i] - close[i+1]) / close[i+1];
      inputs[i+5] = (double)volume[i] / 10000.0;
   }
   
   double prediction = 0;
   for(int i = 0; i < 10; i++)
   {
      prediction += inputs[i] * (0.1 + i * 0.05);
   }
   
   return MathMax(0, MathMin(100, prediction * 100 + 50));
}

double CMarketAnalysisEngine::GetQuantumAnalysisScore(string symbol)
{
   double fibScore = AnalyzeFibonacci(symbol);
   double pivotScore = AnalyzePivotPoints(symbol);
   double trendScore = AnalyzeTrend(symbol);
   
   double quantumScore = (fibScore * 0.4 + pivotScore * 0.4 + trendScore * 0.2);
   
   return quantumScore;
}

string CMarketAnalysisEngine::GenerateMarketReport(string symbol)
{
   string report = "تقرير تحليل السوق - " + symbol + "\n";
   report += "═══════════════════════════════════\n";
   
   double totalScore = AnalyzeSymbolComplete(symbol);
   report += "النتيجة الإجمالية: " + DoubleToString(totalScore, 1) + "%\n";
   
   ENUM_MARKET_CONDITION condition = GetMarketCondition(symbol);
   string conditionStr = "";
   switch(condition)
   {
      case MARKET_TRENDING_UP: conditionStr = "اتجاه صاعد"; break;
      case MARKET_TRENDING_DOWN: conditionStr = "اتجاه هابط"; break;
      case MARKET_RANGING: conditionStr = "تذبذب جانبي"; break;
      case MARKET_VOLATILE: conditionStr = "متقلب"; break;
   }
   
   report += "حالة السوق: " + conditionStr + "\n";
   report += "قوة الاتجاه: " + DoubleToString(GetTrendStrength(symbol) * 100, 1) + "%\n";
   report += "مؤشر التقلب: " + DoubleToString(GetVolatilityIndex(symbol) * 100, 1) + "%\n";
   
   return report;
}
