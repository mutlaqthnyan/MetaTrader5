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
