//+------------------------------------------------------------------+
//|                           QUANTUM ELITE TRADER PRO v4.0         |
//|                         نظام التداول الكمي المتطور              |
//|                    Copyright 2024, Quantum Trading Systems       |
//|                         https://quantumelite.trading             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "4.00"
#property strict
#property description "نظام تداول متقدم بالذكاء الاصطناعي والتحليل الكمي"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "Market_Analysis_Engine.mqh"
#include "Pattern_Recognition_Engine.mqh"
#include "Risk_Management_System.mqh"

#define QUANTUM_VERSION "4.0.0"
#define MAX_SYMBOLS 100
#define MAX_PATTERNS 50
#define MAX_ML_FEATURES 20
#define MAX_QUANTUM_LEVELS 10
#define SIGNAL_BUFFER_SIZE 1000
#define DASHBOARD_UPDATE_MS 500

enum ENUM_TRADING_MODE
{
   MODE_CONSERVATIVE,
   MODE_BALANCED,
   MODE_AGGRESSIVE,
   MODE_SMART
};

enum ENUM_AI_MODEL
{
   MODEL_NEURAL_NETWORK,
   MODEL_ENSEMBLE,
   MODEL_DEEP_LEARNING,
   MODEL_QUANTUM
};

enum ENUM_MARKET_TYPE
{
   MARKET_FOREX,
   MARKET_STOCKS,
   MARKET_CRYPTO,
   MARKET_INDICES,
   MARKET_COMMODITIES
};

input group "🎯 الإعدادات الأساسية"
input bool              InpEnableStrategy        = true;
input bool              InpEnableMLPrediction    = true;
input bool              InpEnableQuantumAnalysis = true;
input ENUM_TRADING_MODE InpTradingMode          = MODE_SMART;
input bool              InpEnableScanner         = true;
input int               InpMaxConcurrentTrades   = 10;
input int               InpMaxPositionsPerSymbol = 2;
input double            InpInitialCapital        = 10000;

input group "🤖 إعدادات الذكاء الاصطناعي والتعلم الآلي"
input int               InpMLLookback            = 100;
input double            InpMLConfidenceThreshold = 75.0;
input bool              InpPatternRecognition    = true;
input bool              InpMarketRegimeDetection = true;
input ENUM_AI_MODEL     InpAIModel              = MODEL_ENSEMBLE;
input int               InpNeuralNetworkLayers   = 4;
input int               InpNeuronsPerLayer       = 64;

input group "🔬 إعدادات التحليل الكمي"
input int               InpQuantumLevels         = 5;
input bool              InpFibonacciConfluence   = true;
input bool              InpHarmonicPatterns      = true;
input bool              InpElliottWaveAnalysis   = true;
input bool              InpVolumeProfileAnalysis = true;
input bool              InpMarketMicrostructure  = true;

input group "🛡️ إدارة المخاطر المتقدمة"
input double            InpRiskPerTrade          = 1.0;
input double            InpMaxDailyRisk          = 3.0;
input double            InpMaxDrawdown           = 10.0;
input bool              InpDynamicPositionSizing = true;
input bool              InpCorrelationFilter     = true;
input bool              InpVolatilityAdjustment  = true;
input double            InpVolatilityMultiplier  = 2.0;
input double            InpSessionFactor         = 1.0;
input double            InpRiskRewardRatio       = 2.0;

input group "📱 إعدادات Telegram"
input bool              InpEnableTelegram        = true;
input string            InpTelegramToken         = "";
input string            InpTelegramChatID        = "";
input bool              InpDailyReports          = true;
input int               InpReportHour            = 22;

input group "🎨 إعدادات العرض والواجهة"
input bool              InpShowDashboard         = true;
input bool              InpShowSignals           = true;
input bool              InpShowStatistics        = true;
input color             InpBullishColor          = clrLime;
input color             InpBearishColor          = clrRed;
input color             InpNeutralColor          = clrYellow;

input group "🌍 إعدادات الأسواق"
input bool              InpTradeForex            = true;
input bool              InpTradeStocks           = false;
input bool              InpTradeCrypto           = false;
input bool              InpTradeIndices          = false;
input bool              InpTradeCommodities      = false;

struct SymbolData
{
   string            symbol;
   double            signalScore;
   double            trendStrength;
   double            volatility;
   double            momentum;
   ENUM_MARKET_TYPE  marketType;
   datetime          lastAnalysis;
   bool              isActive;
};

struct MarketContext
{
   double            atr;
   double            volatilityRatio;
   double            sessionMultiplier;
   ENUM_TIMEFRAMES   timeframe;
   datetime          sessionStart;
   datetime          sessionEnd;
};

struct TradingSignal
{
   string            symbol;
   int               direction;
   double            entryPrice;
   double            stopLoss;
   double            takeProfit;
   double            confidence;
   double            riskReward;
   string            reason;
   datetime          timestamp;
   bool              isExecuted;
};

struct ActiveTrade
{
   ulong             ticket;
   string            symbol;
   int               direction;
   double            entryPrice;
   double            currentPrice;
   double            profit;
   double            profitPercent;
   double            volume;
   datetime          openTime;
   string            comment;
   bool              isActive;
};

struct AIModelData
{
   double            biases[];
   int               layers;
   int               neuronsPerLayer;
   double            learningRate;
   double            accuracy;
};

// Neural network weights - using single array with manual indexing for MQL5 compatibility
double g_neuralWeights[];

CTrade                    g_trade;
CPositionInfo             g_position;
CSymbolInfo               g_symbolInfo;
CAccountInfo              g_account;
CMarketAnalysisEngine     g_marketEngine;
CPatternRecognitionEngine g_patternEngine;
CRiskManagementSystem     g_riskManager;

SymbolData                g_symbols[];
TradingSignal             g_signals[];
ActiveTrade               g_activeTrades[];
AIModelData               g_aiModel;

bool                      g_isInitialized = false;
datetime                  g_lastScanTime = 0;
datetime                  g_lastReportTime = 0;
int                       g_totalTrades = 0;
double                    g_totalProfit = 0;
double                    g_winRate = 0;

int OnInit()
{
   Print("═══════════════════════════════════════════════════════════════");
   Print("🎯 QUANTUM ELITE TRADER PRO v", QUANTUM_VERSION, " - بدء التهيئة");
   Print("═══════════════════════════════════════════════════════════════");

   g_trade.SetExpertMagicNumber(GetMagicNumber());
   g_trade.SetMarginMode();
   g_trade.SetDeviationInPoints(10);

   ArrayResize(g_symbols, 0);
   ArrayResize(g_signals, 0);
   ArrayResize(g_activeTrades, 0);

   if(!InitializeSubsystems())
   {
      Print("❌ فشلت تهيئة الأنظمة الفرعية!");
      return INIT_FAILED;
   }

   EventSetTimer(1);

   if(InpEnableTelegram)
   {
      SendTelegramMessage("🚀 تم تشغيل QUANTUM ELITE TRADER PRO v" + QUANTUM_VERSION +
                          "\n⚡ النظام جاهز للعمل" +
                          "\n📊 الرمز الحالي: " + Symbol());
   }

   g_isInitialized = true;
   Print("✅ تمت التهيئة بنجاح!");

   return INIT_SUCCEEDED;
}

bool InitializeSubsystems()
{
   if(InpEnableMLPrediction && !InitializeAI())
   {
      Print("❌ فشلت تهيئة نظام الذكاء الاصطناعي!");
      return false;
   }
   
   if(!g_marketEngine.Initialize(Symbol()))
   {
      Print("❌ فشلت تهيئة محرك التحليل!");
      return false;
   }
   
   if(!g_patternEngine.Initialize())
   {
      Print("❌ فشلت تهيئة محرك الأنماط!");
      return false;
   }
   
   if(!g_riskManager.Initialize(InpRiskPerTrade, InpMaxDailyRisk, InpMaxDrawdown))
   {
      Print("❌ فشلت تهيئة نظام إدارة المخاطر!");
      return false;
   }

   return true;
}

bool InitializeAI()
{
   g_aiModel.layers = InpNeuralNetworkLayers;
   g_aiModel.neuronsPerLayer = InpNeuronsPerLayer;
   g_aiModel.learningRate = 0.001;
   g_aiModel.accuracy = 0;
   
   ArrayResize(g_aiModel.biases, g_aiModel.layers);
   ArrayResize(g_neuralWeights, g_aiModel.layers * g_aiModel.neuronsPerLayer);
   
   for(int layer = 0; layer < g_aiModel.layers; layer++)
   {
      g_aiModel.biases[layer] = (MathRand() / 32767.0) * 2.0 - 1.0;
      
      for(int neuron = 0; neuron < g_aiModel.neuronsPerLayer; neuron++)
      {
         g_neuralWeights[layer * g_aiModel.neuronsPerLayer + neuron] = (MathRand() / 32767.0) * 2.0 - 1.0;
      }
   }
   
   return true;
}

int GetMagicNumber()
{
   return 20241208;
}

void OnTick()
{
   if(!g_isInitialized) return;
   
   UpdateMarketData();
   ProcessTradingSignals();
   ManageActiveTrades();
   
   if(InpShowDashboard)
   {
      UpdateDashboard();
   }
}

void OnTimer()
{
   if(!g_isInitialized) return;
   
   if(InpEnableScanner && TimeCurrent() - g_lastScanTime > 30)
   {
      PerformMarketScan();
      g_lastScanTime = TimeCurrent();
   }
   
   CheckDailyReport();
   
   if(!g_riskManager.CheckRiskLimits())
   {
      if(g_riskManager.GetCurrentRiskLevel() == RISK_CRITICAL)
      {
         g_riskManager.EmergencyCloseAll();
      }
   }
}

void UpdateMarketData()
{
   // تحديث معلومات الحساب تلقائياً عند الاستعلام
   
   for(int i = 0; i < ArraySize(g_symbols); i++)
   {
      if(g_symbols[i].isActive)
      {
         AnalyzeSymbol(g_symbols[i]);
      }
   }
}

void AnalyzeSymbol(SymbolData &symbolData)
{
   string symbol = symbolData.symbol;
   double score = 0;
   
   score += g_marketEngine.AnalyzeSymbolComplete(symbol);
   
   if(InpPatternRecognition)
   {
      PatternData pattern;
      if(g_patternEngine.DetectPattern(symbol, PATTERN_DOUBLE_BOTTOM, pattern))
      {
         score += pattern.confidence * 0.3;
      }
   }
   
   symbolData.signalScore = score;
   symbolData.lastAnalysis = TimeCurrent();
   symbolData.trendStrength = g_marketEngine.GetTrendStrength(symbol);
   symbolData.volatility = g_marketEngine.GetVolatilityIndex(symbol);
}

int CountPositionsForSymbol(string symbol)
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(g_position.SelectByIndex(i))
      {
         if(PositionGetString(POSITION_SYMBOL) == symbol)
         {
            count++;
         }
      }
   }
   return count;
}

void ProcessTradingSignals()
{
   for(int i = 0; i < ArraySize(g_signals); i++)
   {
      if(!g_signals[i].isExecuted && g_signals[i].confidence > InpMLConfidenceThreshold)
      {
         if(ExecuteTrade(g_signals[i]))
         {
            g_signals[i].isExecuted = true;
         }
      }
   }
   
   // Remove executed signals to prevent reprocessing
   int newSize = 0;
   for(int i = 0; i < ArraySize(g_signals); i++)
   {
      if(!g_signals[i].isExecuted)
      {
         g_signals[newSize] = g_signals[i];
         newSize++;
      }
   }
   ArrayResize(g_signals, newSize);
}

bool ExecuteTrade(TradingSignal &signal)
{
   if(PositionsTotal() >= InpMaxConcurrentTrades)
   {
      return false;
   }
   
   if(CountPositionsForSymbol(signal.symbol) >= InpMaxPositionsPerSymbol)
   {
      Print("⚠️ تم الوصول للحد الأقصى من الصفقات للرمز: ", signal.symbol);
      return false;
   }
   
   double riskAmount = g_riskManager.CalculateRiskAmount(signal.symbol, signal.entryPrice, signal.stopLoss);
   
   if(!g_riskManager.IsTradeAllowed(signal.symbol, riskAmount))
   {
      return false;
   }
   
   double volume = g_riskManager.CalculatePositionSize(signal.symbol, signal.entryPrice, signal.stopLoss);
   if(volume <= 0) return false;
   
   bool result = false;
   
   if(signal.direction > 0)
   {
      result = g_trade.Buy(volume, signal.symbol, signal.entryPrice, signal.stopLoss, signal.takeProfit);
   }
   else
   {
      result = g_trade.Sell(volume, signal.symbol, signal.entryPrice, signal.stopLoss, signal.takeProfit);
   }
   
   if(result)
   {
      AddToActiveTrades(signal, g_trade.ResultOrder());
      
      if(InpEnableTelegram)
      {
         SendTradeExecutionNotification(signal, g_trade.ResultOrder());
      }
      
      signal.isExecuted = true;
      g_totalTrades++;
      
      Print("✅ تم تنفيذ صفقة ", signal.symbol, " - التذكرة: ", g_trade.ResultOrder());
   }
   else
   {
      Print("❌ فشل تنفيذ صفقة ", signal.symbol, " - الخطأ: ", GetLastError());
   }
   
   return result;
}

void AddToActiveTrades(TradingSignal &signal, ulong ticket)
{
   int size = ArraySize(g_activeTrades);
   ArrayResize(g_activeTrades, size + 1);
   
   g_activeTrades[size].ticket = ticket;
   g_activeTrades[size].symbol = signal.symbol;
   g_activeTrades[size].isActive = true;
   g_activeTrades[size].direction = signal.direction;
   g_activeTrades[size].entryPrice = signal.entryPrice;
   g_activeTrades[size].currentPrice = signal.entryPrice;
   g_activeTrades[size].profit = 0;
   g_activeTrades[size].profitPercent = 0;
   g_activeTrades[size].volume = g_riskManager.CalculatePositionSize(signal.symbol, signal.entryPrice, signal.stopLoss);
   g_activeTrades[size].openTime = TimeCurrent();
   g_activeTrades[size].comment = signal.reason;
}

void ManageActiveTrades()
{
   for(int i = ArraySize(g_activeTrades) - 1; i >= 0; i--)
   {
      if(g_position.SelectByTicket(g_activeTrades[i].ticket))
      {
         g_activeTrades[i].currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         g_activeTrades[i].profit = PositionGetDouble(POSITION_PROFIT);
         
         double entryPrice = g_activeTrades[i].entryPrice;
         if(entryPrice > 0)
         {
            g_activeTrades[i].profitPercent = (g_activeTrades[i].currentPrice - entryPrice) / entryPrice * 100;
            if(g_activeTrades[i].direction < 0)
            {
               g_activeTrades[i].profitPercent *= -1;
            }
         }
      }
      else
      {
         if(g_activeTrades[i].profit > 0)
         {
            g_totalProfit += g_activeTrades[i].profit;
         }
         
         for(int j = i; j < ArraySize(g_activeTrades) - 1; j++)
         {
            g_activeTrades[j] = g_activeTrades[j + 1];
         }
         ArrayResize(g_activeTrades, ArraySize(g_activeTrades) - 1);
      }
   }
   
   UpdateWinRate();
}

void UpdateWinRate()
{
   if(g_totalTrades == 0)
   {
      g_winRate = 0;
      return;
   }
   
   int winningTrades = 0;
   
   for(int i = 0; i < ArraySize(g_activeTrades); i++)
   {
      if(g_activeTrades[i].profit > 0)
      {
         winningTrades++;
      }
   }
   
   g_winRate = (double)winningTrades / g_totalTrades * 100;
}

void PerformMarketScan()
{
   Print("🔍 بدء مسح السوق الشامل...");
   
   string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD", "XAUUSD", "BTCUSD", "ETHUSD"};
   
   for(int i = 0; i < ArraySize(symbols); i++)
   {
      if(CountPositionsForSymbol(symbols[i]) < InpMaxPositionsPerSymbol)
      {
         TradingSignal signal;
         if(GenerateSignal(symbols[i], signal))
         {
            signal.isExecuted = false;
            int size = ArraySize(g_signals);
            ArrayResize(g_signals, size + 1);
            g_signals[size] = signal;
            
            if(InpEnableTelegram)
            {
               SendSignalNotification(signal);
            }
         }
      }
   }
}

void AddSymbolToScan(string symbol, ENUM_MARKET_TYPE marketType)
{
   int size = ArraySize(g_symbols);
   ArrayResize(g_symbols, size + 1);
   
   g_symbols[size].symbol = symbol;
   g_symbols[size].marketType = marketType;
   g_symbols[size].isActive = true;
   g_symbols[size].lastAnalysis = 0;
   g_symbols[size].signalScore = 0;
   g_symbols[size].trendStrength = 0;
   g_symbols[size].volatility = 0;
   g_symbols[size].momentum = 0;
}

bool GenerateSignal(string symbol, TradingSignal &signal)
{
   double score = g_marketEngine.AnalyzeSymbolComplete(symbol);
   
   if(InpEnableQuantumAnalysis)
   {
      score += g_marketEngine.GetQuantumAnalysisScore(symbol);
   }
   
   if(InpEnableMLPrediction)
   {
      score += GetMLPrediction(symbol);
   }
   
   // Balanced 5-zone scoring system
   int direction = 0;
   string signalStrength = "";
   
   if(score >= 70)
   {
      direction = 1;  // Strong/Weak Buy
      signalStrength = (score >= 80) ? "شراء قوي" : "شراء ضعيف";
   }
   else if(score <= 30)
   {
      direction = -1; // Strong/Weak Sell  
      signalStrength = (score <= 20) ? "بيع قوي" : "بيع ضعيف";
   }
   else if(score > 30 && score < 40)
   {
      direction = -1; // Weak Sell zone
      signalStrength = "بيع ضعيف";
   }
   else if(score >= 60 && score < 70)
   {
      direction = 1;  // Weak Buy zone
      signalStrength = "شراء ضعيف";
   }
   else
   {
      // Neutral zone (40-60) - no trading
      return false;
   }
   
   // Generate signal with balanced direction
   signal.symbol = symbol;
   signal.confidence = score;
   signal.timestamp = TimeCurrent();
   signal.entryPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   signal.direction = direction;
   
   // Apply enhanced analysis and validation
   double trendScore = AnalyzeTrendDirection(symbol);
   double volatilityMultiplier = GetVolatilityMultiplier(symbol);
   double sessionFactor = GetSessionVolatilityFactor();
   
   // Adjust confidence based on trend analysis
   signal.confidence = (signal.confidence * 0.7) + (trendScore * 0.3);
   
   // Apply dynamic SL/TP levels using enhanced ATR
   MarketContext context;
   context.volatilityRatio = volatilityMultiplier;
   context.sessionMultiplier = sessionFactor;
   CalculateDynamicLevels(symbol, signal, context);
   
   // Validate signal before returning
   if(!ValidateSignal(signal))
   {
      return false;
   }
   
   signal.reason = "تحليل كمي متوازن - " + signalStrength;
   signal.isExecuted = false;
   
   return true;
}

void CalculateDynamicLevels(string symbol, TradingSignal &signal, MarketContext &context)
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
   
   context.atr = atr;
   context.volatilityRatio = atr / close[0];
   context.sessionMultiplier = InpSessionFactor;
   context.timeframe = PERIOD_CURRENT;
   context.sessionStart = TimeCurrent();
   context.sessionEnd = TimeCurrent() + PeriodSeconds(PERIOD_D1);
   
   double pipSize = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 5 || SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 3)
      pipSize *= 10;
   
   double enhancedVolatilityMultiplier = InpVolatilityMultiplier * context.volatilityRatio;
   double enhancedSessionFactor = InpSessionFactor * context.sessionMultiplier;
   
   double slDistance = atr * enhancedVolatilityMultiplier * enhancedSessionFactor;
   double tpDistance = atr * InpRiskRewardRatio * enhancedVolatilityMultiplier;
   
   double minSL = 10 * pipSize;
   double maxSL = 100 * pipSize;
   
   slDistance = MathMax(minSL, MathMin(maxSL, slDistance));
   
   double minRR = 1.5;
   double maxRR = 3.0;
   double currentRR = tpDistance / slDistance;
   
   if(currentRR < minRR)
      tpDistance = slDistance * minRR;
   else if(currentRR > maxRR)
      tpDistance = slDistance * maxRR;
   
   if(signal.direction > 0)
   {
      signal.stopLoss = signal.entryPrice - slDistance;
      signal.takeProfit = signal.entryPrice + tpDistance;
   }
   else
   {
      signal.stopLoss = signal.entryPrice + slDistance;
      signal.takeProfit = signal.entryPrice - tpDistance;
   }
   
   signal.riskReward = MathAbs(signal.takeProfit - signal.entryPrice) / MathAbs(signal.entryPrice - signal.stopLoss);
   signal.reason += " - تحليل متقدم (ATR: " + DoubleToString(atr/pipSize, 1) + 
                   " نقطة، تقلبات: " + DoubleToString(context.volatilityRatio, 2) + 
                   "، جلسة: " + DoubleToString(context.sessionMultiplier, 1) + ")";
}

double AnalyzeTrendDirection(string symbol)
{
   int handleEMA20 = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
   int handleEMA50 = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
   int handleEMA200 = iMA(symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
   
   if(handleEMA20 == INVALID_HANDLE || handleEMA50 == INVALID_HANDLE || handleEMA200 == INVALID_HANDLE)
   {
      Print("فشل في تهيئة مؤشرات EMA للرمز: ", symbol);
      return 50.0;
   }
   
   double ema20[], ema50[], ema200[];
   ArraySetAsSeries(ema20, true);
   ArraySetAsSeries(ema50, true);
   ArraySetAsSeries(ema200, true);
   
   if(CopyBuffer(handleEMA20, 0, 0, 5, ema20) <= 0 ||
      CopyBuffer(handleEMA50, 0, 0, 5, ema50) <= 0 ||
      CopyBuffer(handleEMA200, 0, 0, 5, ema200) <= 0)
   {
      IndicatorRelease(handleEMA20);
      IndicatorRelease(handleEMA50);
      IndicatorRelease(handleEMA200);
      return 50.0;
   }
   
   double score = 50.0;
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   
   if(ema20[0] > ema50[0] && ema50[0] > ema200[0])
   {
      score = 75.0;
      if(ema20[0] > ema20[1] && ema50[0] > ema50[1])
         score = 90.0;
      if(currentPrice > ema20[0])
         score = MathMin(100.0, score + 10.0);
   }
   else if(ema20[0] < ema50[0] && ema50[0] < ema200[0])
   {
      score = 25.0;
      if(ema20[0] < ema20[1] && ema50[0] < ema50[1])
         score = 10.0;
      if(currentPrice < ema20[0])
         score = MathMax(0.0, score - 10.0);
   }
   else if(ema20[0] > ema50[0] && ema50[0] < ema200[0])
   {
      score = 60.0;
   }
   else if(ema20[0] < ema50[0] && ema50[0] > ema200[0])
   {
      score = 40.0;
   }
   
   IndicatorRelease(handleEMA20);
   IndicatorRelease(handleEMA50);
   IndicatorRelease(handleEMA200);
   
   return score;
}

double GetVolatilityMultiplier(string symbol)
{
   double currentATR = CalculateATR(symbol, 14);
   double longTermATR = CalculateATR(symbol, 50);
   
   if(longTermATR == 0.0) return 1.0;
   
   double ratio = currentATR / longTermATR;
   
   if(ratio > 2.0) return 2.0;
   if(ratio < 0.5) return 0.5;
   
   return ratio;
}

bool ValidateSignal(TradingSignal &signal)
{
   if(signal.confidence < 60.0) return false;
   
   if(MathAbs(signal.entryPrice - signal.stopLoss) < 5 * SymbolInfoDouble(signal.symbol, SYMBOL_POINT))
      return false;
   
   if(signal.riskReward < 1.0) return false;
   
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);
   
   if(timeStruct.hour >= 22 || timeStruct.hour <= 2)
   {
      if(signal.confidence < 75.0) return false;
   }
   
   if(timeStruct.day_of_week == 1 && timeStruct.hour < 8)
      return false;
   
   if(timeStruct.day_of_week == 5 && timeStruct.hour > 20)
      return false;
   
   double spread = SymbolInfoInteger(signal.symbol, SYMBOL_SPREAD) * SymbolInfoDouble(signal.symbol, SYMBOL_POINT);
   double slDistance = MathAbs(signal.entryPrice - signal.stopLoss);
   
   if(spread > slDistance * 0.3) return false;
   
   return true;
}

double CalculateATR(string symbol, int period)
{
   int handleATR = iATR(symbol, PERIOD_CURRENT, period);
   
   if(handleATR == INVALID_HANDLE)
   {
      Print("فشل في تهيئة مؤشر ATR للرمز: ", symbol);
      
      double high[], low[], close[];
      ArraySetAsSeries(high, true);
      ArraySetAsSeries(low, true);
      ArraySetAsSeries(close, true);
      
      if(CopyHigh(symbol, PERIOD_CURRENT, 0, period + 1, high) <= 0 ||
         CopyLow(symbol, PERIOD_CURRENT, 0, period + 1, low) <= 0 ||
         CopyClose(symbol, PERIOD_CURRENT, 0, period + 1, close) <= 0)
      {
         return 0.0;
      }
      
      double atr = 0.0;
      for(int i = 1; i < period + 1; i++)
      {
         double tr = MathMax(high[i] - low[i], 
                     MathMax(MathAbs(high[i] - close[i+1]), 
                             MathAbs(low[i] - close[i+1])));
         atr += tr;
      }
      
      return atr / period;
   }
   
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   
   if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) <= 0)
   {
      IndicatorRelease(handleATR);
      return 0.0;
   }
   
   double result = atrBuffer[0];
   IndicatorRelease(handleATR);
   
   return result;
}

double GetSessionVolatilityFactor()
{
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);
   
   int hour = timeStruct.hour;
   
   if(hour >= 0 && hour < 8)
   {
      return 0.7;
   }
   else if(hour >= 8 && hour < 13)
   {
      return 1.2;
   }
   else if(hour >= 13 && hour < 17)
   {
      if(hour >= 13 && hour < 15)
         return 1.5;
      else
         return 1.2;
   }
   else if(hour >= 17 && hour < 22)
   {
      return 1.0;
   }
   else
   {
      return 0.8;
   }
}

double GetMLPrediction(string symbol)
{
   double inputs[20];
   double close[];
   long volume[];
   
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   
   CopyClose(symbol, PERIOD_CURRENT, 0, 20, close);
   CopyTickVolume(symbol, PERIOD_CURRENT, 0, 20, volume);
   
   for(int i = 0; i < 10; i++)
   {
      inputs[i] = (close[i] - close[i+1]) / close[i+1];
      inputs[i+10] = (double)volume[i] / 10000.0;
   }
   
   double prediction = ProcessNeuralNetwork(inputs);
   
   return prediction * 50;
}

double ProcessNeuralNetwork(double &inputs[])
{
   double layerOutput = 0;
   
   for(int layer = 0; layer < g_aiModel.layers; layer++)
   {
      layerOutput = g_aiModel.biases[layer];
      
      for(int i = 0; i < ArraySize(inputs) && i < g_aiModel.neuronsPerLayer; i++)
      {
         layerOutput += inputs[i] * g_neuralWeights[layer * g_aiModel.neuronsPerLayer + i];
      }
      
      layerOutput = 1.0 / (1.0 + MathExp(-layerOutput));
   }
   
   return layerOutput;
}

void UpdateDashboard()
{
   static datetime lastUpdate = 0;
   
   if(TimeCurrent() - lastUpdate < 5) return;
   
   string dashboardText = "QUANTUM ELITE TRADER PRO v" + QUANTUM_VERSION + "\n";
   dashboardText += "═══════════════════════════════════\n";
   dashboardText += "💰 الرصيد: " + DoubleToString(g_account.Balance(), 2) + "\n";
   dashboardText += "📈 الربح الإجمالي: " + DoubleToString(g_totalProfit, 2) + "\n";
   dashboardText += "🎯 معدل النجاح: " + DoubleToString(g_winRate, 1) + "%\n";
   dashboardText += "📊 الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "\n";
   dashboardText += "🔍 الإشارات: " + IntegerToString(ArraySize(g_signals)) + "\n";
   dashboardText += "⚠️ مستوى المخاطرة: " + GetRiskLevelString() + "\n";
   
   Comment(dashboardText);
   lastUpdate = TimeCurrent();
}

string GetRiskLevelString()
{
   switch(g_riskManager.GetCurrentRiskLevel())
   {
      case RISK_LOW: return "منخفض 🟢";
      case RISK_MEDIUM: return "متوسط 🟡";
      case RISK_HIGH: return "عالي 🟠";
      case RISK_CRITICAL: return "حرج 🔴";
      default: return "غير معروف";
   }
}

void CheckDailyReport()
{
   if(!InpDailyReports || !InpEnableTelegram) return;
   
   MqlDateTime currentTime;
   TimeToStruct(TimeCurrent(), currentTime);
   
   if(currentTime.hour == InpReportHour && 
      TimeCurrent() - g_lastReportTime > 3600)
   {
      SendDailyReport();
      g_lastReportTime = TimeCurrent();
   }
}

void SendDailyReport()
{
   string report = "📊 التقرير اليومي - QUANTUM ELITE TRADER PRO\n";
   report += "═══════════════════════════════════════\n";
   report += "💰 رصيد الحساب: " + DoubleToString(g_account.Balance(), 2) + "\n";
   report += "📈 الربح الإجمالي: " + DoubleToString(g_totalProfit, 2) + "\n";
   report += "🎯 معدل النجاح: " + DoubleToString(g_winRate, 1) + "%\n";
   report += "🔢 الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "\n";
   report += "🎯 الإشارات المولدة: " + IntegerToString(ArraySize(g_signals)) + "\n";
   report += "📊 توزيع الرموز: " + GetSymbolDistribution() + "\n";
   report += "⚠️ مستوى المخاطرة: " + GetRiskLevelString() + "\n";
   report += "⏰ وقت التقرير: " + TimeToString(TimeCurrent());
   
   SendTelegramMessage(report);
}

string UrlEncode(string text)
{
   string result = "";
   char chars[];
   StringToCharArray(text, chars, 0, StringLen(text), CP_UTF8);
   
   for(int i = 0; i < ArraySize(chars) - 1; i++)
   {
      uchar ch = (uchar)chars[i];
      
      if((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || 
         (ch >= '0' && ch <= '9') || ch == '-' || ch == '_' || 
         ch == '.' || ch == '~')
      {
         result += CharToString(ch);
      }
      else
      {
         result += StringFormat("%%%02X", ch);
      }
   }
   
   return result;
}

void SendTelegramMessage(string message)
{
   if(!InpEnableTelegram || InpTelegramToken == "") return;
   
   string url = "https://api.telegram.org/bot" + InpTelegramToken + "/sendMessage";
   string encodedMessage = UrlEncode(message);
   string postData = "chat_id=" + InpTelegramChatID + "&text=" + encodedMessage;
   
   char data[];
   char result[];
   string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
   
   StringToCharArray(postData, data, 0, StringLen(postData), CP_UTF8);
   
   int timeout = 5000;
   int res = WebRequest("POST", url, headers, timeout, data, result, headers);
   
   if(res == -1)
   {
      Print("❌ خطأ في إرسال رسالة تلغرام: ", GetLastError());
   }
}

void SendSignalNotification(TradingSignal &signal)
{
   if(!InpEnableTelegram || InpTelegramToken == "") return;
   
   string direction = (signal.direction > 0) ? "شراء 🟢" : "بيع 🔴";
   string emoji = (signal.direction > 0) ? "📈" : "📉";
   
   double riskReward = MathAbs((signal.takeProfit - signal.entryPrice) / (signal.entryPrice - signal.stopLoss));
   int currentSymbolPositions = CountPositionsForSymbol(signal.symbol);
   
   string message = emoji + " إشارة تداول جديدة " + emoji + "\n";
   message += "═══════════════════════════════\n";
   message += "📊 الرمز: " + signal.symbol + "\n";
   message += "📈 الاتجاه: " + direction + "\n";
   message += "💰 سعر الدخول: " + DoubleToString(signal.entryPrice, 5) + "\n";
   message += "🛑 وقف الخسارة: " + DoubleToString(signal.stopLoss, 5) + "\n";
   message += "🎯 جني الأرباح: " + DoubleToString(signal.takeProfit, 5) + "\n";
   message += "⚖️ نسبة المخاطرة/العائد: 1:" + DoubleToString(riskReward, 2) + "\n";
   message += "📊 مستوى الثقة: " + DoubleToString(signal.confidence, 1) + "%\n";
   message += "🔢 الصفقات الحالية للرمز: " + IntegerToString(currentSymbolPositions) + "/" + IntegerToString(InpMaxPositionsPerSymbol) + "\n";
   message += "📈 إجمالي الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   message += "💡 أساس التحليل: " + signal.reason + "\n";
   message += "⏰ وقت الإشارة: " + TimeToString(signal.timestamp, TIME_DATE|TIME_MINUTES) + "\n";
   message += "═══════════════════════════════\n";
   message += "⚠️ تذكير: هذه إشارة تحليلية وليست نصيحة استثمارية";
   message += "📊 الرمز: " + signal.symbol + "\n";
   message += "📈 الاتجاه: " + (signal.direction > 0 ? "شراء 🟢" : "بيع 🔴") + "\n";
   message += "💰 سعر الدخول المقترح: " + DoubleToString(signal.entryPrice, 5) + "\n";
   message += "🛑 وقف الخسارة: " + DoubleToString(signal.stopLoss, 5) + "\n";
   message += "🎯 هدف جني الأرباح: " + DoubleToString(signal.takeProfit, 5) + "\n";
   message += "📊 مستوى الثقة: " + DoubleToString(signal.confidence, 1) + "%\n";
   message += "💡 أساس التحليل: " + signal.reason + "\n";
   message += "📈 نسبة المخاطرة/العائد: 1:" + DoubleToString((signal.takeProfit - signal.entryPrice) / (signal.entryPrice - signal.stopLoss), 1) + "\n";
   message += "🔍 الصفقات الحالية للرمز: " + IntegerToString(CountPositionsForSymbol(signal.symbol)) + "/2\n";
   message += "📊 إجمالي الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "/10\n";
   message += "⏰ وقت الإشارة: " + TimeToString(signal.timestamp) + "\n";
   message += "⚠️ ملاحظة: سيتم تنفيذ الصفقة تلقائياً إذا استوفت شروط إدارة المخاطر";
   
   SendTelegramMessage(message);
}

void SendTradeExecutionNotification(TradingSignal &signal, ulong ticket)
{
   if(!InpEnableTelegram || InpTelegramToken == "") return;
   
   string direction = (signal.direction > 0) ? "شراء 🟢" : "بيع 🔴";
   string emoji = "✅";
   
   double riskReward = MathAbs((signal.takeProfit - signal.entryPrice) / (signal.entryPrice - signal.stopLoss));
   int currentSymbolPositions = CountPositionsForSymbol(signal.symbol);
   double volume = 0;
   
   for(int i = 0; i < ArraySize(g_activeTrades); i++)
   {
      if(g_activeTrades[i].ticket == ticket)
      {
         volume = g_activeTrades[i].volume;
         break;
      }
   }
   
   string message = emoji + " تم تنفيذ الصفقة بنجاح " + emoji + "\n";
   message += "═══════════════════════════════\n";
   message += "🎫 رقم التذكرة: " + IntegerToString(ticket) + "\n";
   message += "📊 الرمز: " + signal.symbol + "\n";
   message += "📈 الاتجاه: " + direction + "\n";
   message += "💰 سعر التنفيذ: " + DoubleToString(signal.entryPrice, 5) + "\n";
   message += "📦 حجم الصفقة: " + DoubleToString(volume, 2) + " لوت\n";
   message += "🛑 وقف الخسارة: " + DoubleToString(signal.stopLoss, 5) + "\n";
   message += "🎯 جني الأرباح: " + DoubleToString(signal.takeProfit, 5) + "\n";
   message += "⚖️ نسبة المخاطرة/العائد: 1:" + DoubleToString(riskReward, 2) + "\n";
   message += "📊 مستوى الثقة: " + DoubleToString(signal.confidence, 1) + "%\n";
   message += "🔢 الصفقات الحالية للرمز: " + IntegerToString(currentSymbolPositions) + "/" + IntegerToString(InpMaxPositionsPerSymbol) + "\n";
   message += "📈 إجمالي الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   message += "💡 أساس التحليل: " + signal.reason + "\n";
   message += "⏰ وقت التنفيذ: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES) + "\n";
   message += "═══════════════════════════════\n";
   message += "🎯 الصفقة نشطة ومراقبة تلقائياً";
   message += "🎫 رقم التذكرة: " + IntegerToString(ticket) + "\n";
   message += "📊 الرمز: " + signal.symbol + "\n";
   message += "📈 نوع الصفقة: " + (signal.direction > 0 ? "شراء 🟢" : "بيع 🔴") + "\n";
   message += "💰 سعر التنفيذ الفعلي: " + DoubleToString(SymbolInfoDouble(signal.symbol, SYMBOL_BID), 5) + "\n";
   message += "🛑 وقف الخسارة: " + DoubleToString(signal.stopLoss, 5) + "\n";
   message += "🎯 هدف الربح: " + DoubleToString(signal.takeProfit, 5) + "\n";
   message += "📊 مستوى الثقة: " + DoubleToString(signal.confidence, 1) + "%\n";
   message += "💡 أساس القرار: " + signal.reason + "\n";
   message += "🔍 الصفقات النشطة للرمز: " + IntegerToString(CountPositionsForSymbol(signal.symbol)) + "/2\n";
   message += "📊 إجمالي الصفقات النشطة: " + IntegerToString(ArraySize(g_activeTrades)) + "/10\n";
   message += "⏰ وقت التنفيذ: " + TimeToString(TimeCurrent()) + "\n";
   message += "🎯 حالة الصفقة: نشطة ومراقبة تلقائياً";
   
   SendTelegramMessage(message);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   
   g_marketEngine.Deinitialize();
   g_patternEngine.Deinitialize();
   g_riskManager.Deinitialize();
   
   if(InpEnableTelegram)
   {
      string message = "🛑 تم إيقاف QUANTUM ELITE TRADER PRO\n";
      message += "📊 إحصائيات الجلسة:\n";
      message += "💰 الربح الإجمالي: " + DoubleToString(g_totalProfit, 2) + "\n";
      message += "📈 عدد الصفقات: " + IntegerToString(g_totalTrades) + "\n";
      message += "🎯 معدل النجاح: " + DoubleToString(g_winRate, 1) + "%";
      
      SendTelegramMessage(message);
   }
   
   Print("🔄 تم إيقاف النظام - السبب: ", reason);
}

string GetSymbolDistribution()
{
   string distribution = "📊 توزيع الصفقات حسب الرموز:\n";
   distribution += "═══════════════════════════════\n";
   
   string symbols[];
   int counts[];
   
   for(int i = 0; i < ArraySize(g_activeTrades); i++)
   {
      if(g_activeTrades[i].isActive)
      {
         string symbol = g_activeTrades[i].symbol;
         
         bool found = false;
         for(int j = 0; j < ArraySize(symbols); j++)
         {
            if(symbols[j] == symbol)
            {
               counts[j]++;
               found = true;
               break;
            }
         }
         
         if(!found)
         {
            int size = ArraySize(symbols);
            ArrayResize(symbols, size + 1);
            ArrayResize(counts, size + 1);
            symbols[size] = symbol;
            counts[size] = 1;
         }
      }
   }
   
   if(ArraySize(symbols) == 0)
   {
      distribution += "📈 لا توجد صفقات نشطة حالياً\n";
   }
   else
   {
      for(int i = 0; i < ArraySize(symbols); i++)
      {
         distribution += "📊 " + symbols[i] + ": " + IntegerToString(counts[i]) + "/" + IntegerToString(InpMaxPositionsPerSymbol) + " صفقة\n";
      }
   }
   
   distribution += "📈 إجمالي الصفقات: " + IntegerToString(ArraySize(g_activeTrades)) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   
   for(int i = 0; i < ArraySize(symbols); i++)
   {
      int count = CountPositionsForSymbol(symbols[i]);
      if(count > 0)
      {
         if(distribution != "") distribution += ", ";
         distribution += symbols[i] + "(" + IntegerToString(count) + ")";
      }
   }
   
   if(distribution == "") distribution = "لا توجد صفقات نشطة";
   
   return distribution;
}
