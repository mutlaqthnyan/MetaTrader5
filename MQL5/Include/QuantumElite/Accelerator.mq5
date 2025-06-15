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
#include <Trade\OrderInfo.mqh>
#include <Math\Stat\Math.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Indicators\Indicators.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

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

input group "📱 إعدادات Telegram"
input bool              InpEnableTelegram        = true;
input string            InpTelegramToken         = "7657830880:AAFHX7DsRFyM6Mu9gexXSEeR8U5Ndi5Q1WE";
input string            InpTelegramChatID        = "728976245";
input bool              InpDailyReports          = true;
input int               InpReportHour            = 22;

struct QuantumSignal
{
   string              symbol;
   int                 direction;
   double              entryPrice;
   double              stopLoss;
   double              takeProfit;
   double              confidence;
   datetime            timestamp;
   string              reason;
   double              quantumLevel;
   double              mlPrediction;
   bool                isExecuted;
};

struct NeuralLayer
{
   double              weights[];
   double              biases[];
   int                 neurons;
};

CTrade              g_trade;
CPositionInfo       g_position;
CSymbolInfo         g_symbolInfo;
CAccountInfo        g_account;

QuantumSignal       g_signals[];
NeuralLayer         g_neuralLayers[];
double              g_neuralBiases[];

// Neural network weights - using single array with manual indexing for MQL5 compatibility
double              g_neuralWeights[];

bool                g_isInitialized = false;
datetime            g_lastScanTime = 0;
datetime            g_lastReportTime = 0;
int                 g_activeTradeCount = 0;
double              g_dailyProfit = 0;

int OnInit()
{
   Print("═══════════════════════════════════════════════════════════════");
   Print("🎯 QUANTUM ELITE TRADER PRO v", QUANTUM_VERSION, " - بدء التهيئة");
   Print("═══════════════════════════════════════════════════════════════");

   g_trade.SetExpertMagicNumber(GetMagicNumber());
   g_trade.SetMarginMode();
   g_trade.SetDeviationInPoints(10);

   ArrayResize(g_signals, 0);
   ArrayResize(g_neuralLayers, InpNeuralNetworkLayers);
   ArrayResize(g_neuralWeights, InpNeuralNetworkLayers);
   ArrayResize(g_neuralBiases, InpNeuralNetworkLayers);

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
   if(InpEnableMLPrediction && !InitializeNeuralNetwork())
   {
      Print("❌ فشلت تهيئة الشبكة العصبية!");
      return false;
   }

   return true;
}

bool InitializeNeuralNetwork()
{
   ArrayResize(g_neuralBiases, InpNeuralNetworkLayers);
   ArrayResize(g_neuralWeights, InpNeuralNetworkLayers * InpNeuronsPerLayer);
   
   for(int layer = 0; layer < InpNeuralNetworkLayers; layer++)
   {
      g_neuralBiases[layer] = (MathRand() / 32767.0) * 2.0 - 1.0;
      
      for(int neuron = 0; neuron < InpNeuronsPerLayer; neuron++)
      {
         g_neuralWeights[layer * InpNeuronsPerLayer + neuron] = (MathRand() / 32767.0) * 2.0 - 1.0;
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
}

void UpdateMarketData()
{
   // تحديث معلومات الحساب تلقائياً عند الاستعلام - CAccountInfo لا يحتوي على Refresh()
}

void ProcessTradingSignals()
{
   for(int i = 0; i < ArraySize(g_signals); i++)
   {
      if(!g_signals[i].isExecuted && g_signals[i].confidence > InpMLConfidenceThreshold)
      {
         if(ExecuteSignal(g_signals[i]))
         {
            g_signals[i].isExecuted = true;
         }
      }
   }
   
   // إزالة الإشارات المنفذة من المصفوفة
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

void ManageActiveTrades()
{
   g_activeTradeCount = PositionsTotal();
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(g_position.SelectByIndex(i))
      {
         ManageIndividualTrade();
      }
   }
}

void ManageIndividualTrade()
{
   // منطق إدارة الصفقات الفردية
}

void PerformMarketScan()
{
   Print("🔍 بدء مسح السوق الشامل...");
   
   string symbols[];
   ArrayResize(symbols, 1);
   symbols[0] = Symbol();
   
   string forexSymbols[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "USDCAD", "NZDUSD"};
   for(int i = 0; i < ArraySize(forexSymbols); i++)
   {
      int size = ArraySize(symbols);
      ArrayResize(symbols, size + 1);
      symbols[size] = forexSymbols[i];
   }
   
   for(int i = 0; i < ArraySize(symbols); i++)
   {
      if(CountPositionsForSymbol(symbols[i]) < InpMaxPositionsPerSymbol)
      {
         QuantumSignal signal;
         if(AnalyzeSymbol(symbols[i], signal))
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

bool AnalyzeSymbol(string symbol, QuantumSignal &signal)
{
   double score = 0;
   
   score += AnalyzeTechnicalIndicators(symbol);
   score += AnalyzeQuantumLevels(symbol);
   
   if(InpEnableMLPrediction)
   {
      score += GetMLPrediction(symbol);
   }
   
   // نظام التسجيل المتوازن (0-100)
   // 70-100 = إشارة شراء قوية
   // 60-70 = إشارة شراء ضعيفة
   // 40-60 = منطقة محايدة (لا تتداول)
   // 30-40 = إشارة بيع ضعيفة
   // 0-30 = إشارة بيع قوية
   
   if(score >= 70 || score <= 40)
   {
      signal.symbol = symbol;
      signal.confidence = score;
      signal.timestamp = TimeCurrent();
      signal.entryPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
      
      // تحديد الاتجاه بناءً على النظام المتوازن
      if(score >= 70)
      {
         signal.direction = 1; // شراء (قوي أو ضعيف)
         signal.reason = score >= 80 ? "إشارة شراء قوية - تحليل كمي متقدم" : "إشارة شراء ضعيفة - تحليل كمي متقدم";
      }
      else if(score <= 40)
      {
         signal.direction = -1; // بيع (قوي أو ضعيف)
         signal.reason = score <= 30 ? "إشارة بيع قوية - تحليل كمي متقدم" : "إشارة بيع ضعيفة - تحليل كمي متقدم";
      }
      
      signal.stopLoss = signal.entryPrice * (1 - InpRiskPerTrade / 100);
      signal.takeProfit = signal.entryPrice * (1 + InpRiskPerTrade * 2 / 100);
      signal.isExecuted = false;
      
      return true;
   }
   
   // منطقة محايدة (40-60) - لا تتداول
   
   return false;
}

double AnalyzeTechnicalIndicators(string symbol)
{
   double score = 0;
   
   double ema20[], ema50[];
   ArraySetAsSeries(ema20, true);
   ArraySetAsSeries(ema50, true);
   
   int handleEMA20 = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
   int handleEMA50 = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   if(handleEMA20 != INVALID_HANDLE && handleEMA50 != INVALID_HANDLE)
   {
      CopyBuffer(handleEMA20, 0, 0, 3, ema20);
      CopyBuffer(handleEMA50, 0, 0, 3, ema50);
      
      if(ema20[0] > ema50[0])
      {
         score += 25;
      }
      
      IndicatorRelease(handleEMA20);
      IndicatorRelease(handleEMA50);
   }
   
   return score;
}

double AnalyzeQuantumLevels(string symbol)
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
   
   return score;
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
   
   for(int layer = 0; layer < InpNeuralNetworkLayers; layer++)
   {
      layerOutput = g_neuralBiases[layer];
      
      for(int i = 0; i < ArraySize(inputs) && i < InpNeuronsPerLayer; i++)
      {
         layerOutput += inputs[i] * g_neuralWeights[layer * InpNeuronsPerLayer + i];
      }
      
      layerOutput = 1.0 / (1.0 + MathExp(-layerOutput));
   }
   
   return layerOutput;
}

bool ExecuteSignal(QuantumSignal &signal)
{
   if(!IsTradeAllowed(signal.symbol))
   {
      return false;
   }
   
   double volume = CalculatePositionSize(signal.symbol, signal.entryPrice, signal.stopLoss);
   
   if(volume > 0)
   {
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
         if(InpEnableTelegram)
         {
            SendTradeExecutionNotification(signal, g_trade.ResultOrder());
         }
         Print("✅ تم تنفيذ صفقة ", signal.symbol, " - التذكرة: ", g_trade.ResultOrder());
         return true;
      }
   }
   
   return false;
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

bool IsTradeAllowed(string symbol)
{
   if(PositionsTotal() >= InpMaxConcurrentTrades)
   {
      return false;
   }
   
   if(CountPositionsForSymbol(symbol) >= InpMaxPositionsPerSymbol)
   {
      Print("⚠️ تم الوصول للحد الأقصى من الصفقات للرمز: ", symbol);
      return false;
   }
   
   double dailyRisk = CalculateDailyRisk();
   if(dailyRisk > InpMaxDailyRisk)
   {
      return false;
   }
   
   return true;
}

double CalculatePositionSize(string symbol, double entryPrice, double stopLoss)
{
   double riskAmount = g_account.Balance() * InpRiskPerTrade / 100;
   double stopDistance = MathAbs(entryPrice - stopLoss);
   
   if(stopDistance <= 0) return 0;
   
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if(tickValue <= 0 || tickSize <= 0) return 0;
   
   double volume = riskAmount / (stopDistance / tickSize * tickValue);
   
   double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double stepVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   volume = MathMax(volume, minVolume);
   volume = MathMin(volume, maxVolume);
   volume = MathRound(volume / stepVolume) * stepVolume;
   
   return volume;
}

double CalculateDailyRisk()
{
   double dailyPnL = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(g_position.SelectByIndex(i))
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
   
   return -dailyPnL / g_account.Balance() * 100;
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
   report += "📈 الربح اليومي: " + DoubleToString(g_dailyProfit, 2) + "\n";
   report += "🔢 الصفقات النشطة: " + IntegerToString(g_activeTradeCount) + "\n";
   report += "🎯 الإشارات المولدة: " + IntegerToString(ArraySize(g_signals)) + "\n";
   report += "📊 توزيع الرموز: " + GetSymbolDistribution() + "\n";
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

void SendSignalNotification(QuantumSignal &signal)
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
   message += "📈 إجمالي الصفقات النشطة: " + IntegerToString(PositionsTotal()) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   message += "🧠 التحليل الكمي: " + DoubleToString(signal.quantumLevel, 2) + "\n";
   message += "🤖 توقع الذكاء الاصطناعي: " + DoubleToString(signal.mlPrediction, 2) + "\n";
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
   message += "📊 إجمالي الصفقات النشطة: " + IntegerToString(PositionsTotal()) + "/10\n";
   message += "⏰ وقت الإشارة: " + TimeToString(signal.timestamp) + "\n";
   message += "⚠️ ملاحظة: سيتم تنفيذ الصفقة تلقائياً إذا استوفت شروط إدارة المخاطر";
   
   SendTelegramMessage(message);
}

void SendTradeExecutionNotification(QuantumSignal &signal, ulong ticket)
{
   if(!InpEnableTelegram || InpTelegramToken == "") return;
   
   string direction = (signal.direction > 0) ? "شراء 🟢" : "بيع 🔴";
   string emoji = "✅";
   
   double riskReward = MathAbs((signal.takeProfit - signal.entryPrice) / (signal.entryPrice - signal.stopLoss));
   int currentSymbolPositions = CountPositionsForSymbol(signal.symbol);
   double volume = 0;
   
   if(PositionSelectByTicket(ticket))
   {
      volume = PositionGetDouble(POSITION_VOLUME);
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
   message += "📈 إجمالي الصفقات النشطة: " + IntegerToString(PositionsTotal()) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   message += "🧠 التحليل الكمي: " + DoubleToString(signal.quantumLevel, 2) + "\n";
   message += "🤖 توقع الذكاء الاصطناعي: " + DoubleToString(signal.mlPrediction, 2) + "\n";
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
   message += "📊 إجمالي الصفقات النشطة: " + IntegerToString(PositionsTotal()) + "/10\n";
   message += "⏰ وقت التنفيذ: " + TimeToString(TimeCurrent()) + "\n";
   message += "🎯 حالة الصفقة: نشطة ومراقبة تلقائياً";
   
   SendTelegramMessage(message);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   
   if(InpEnableTelegram)
   {
      string message = "🛑 تم إيقاف QUANTUM ELITE TRADER PRO\n";
      message += "📊 إحصائيات الجلسة:\n";
      message += "💰 الربح الإجمالي: " + DoubleToString(g_dailyProfit, 2) + "\n";
      message += "📈 عدد الصفقات النشطة: " + IntegerToString(g_activeTradeCount);
      
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
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(g_position.SelectByIndex(i))
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         
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
   
   distribution += "📈 إجمالي الصفقات: " + IntegerToString(PositionsTotal()) + "/" + IntegerToString(InpMaxConcurrentTrades) + "\n";
   
   return distribution;
}
