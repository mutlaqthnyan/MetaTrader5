//+------------------------------------------------------------------+
//|                                                Trade_Journal.mqh |
//|                                  Copyright 2024, Quantum Trading Systems |
//|                                             https://quantumelite.trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Files\File.mqh>

//+------------------------------------------------------------------+
//| Trade Entry Structure                                           |
//+------------------------------------------------------------------+
struct TradeEntry
{
   long ticket;                 // رقم التذكرة
   string symbol;               // رمز العملة
   int orderType;               // نوع الأمر
   double lotSize;              // حجم المركز
   double entryPrice;           // سعر الدخول
   double stopLoss;             // وقف الخسارة
   double takeProfit;           // جني الأرباح
   datetime entryTime;          // وقت الدخول
   datetime exitTime;           // وقت الخروج
   double exitPrice;            // سعر الخروج
   double profit;               // الربح/الخسارة
   double commission;           // العمولة
   double swap;                 // السواب
   string entryReason;          // سبب الدخول
   string exitReason;           // سبب الخروج
   string strategy;             // الاستراتيجية المستخدمة
   string marketCondition;      // حالة السوق
   double riskReward;           // نسبة المخاطرة للعائد
   bool isWin;                  // هل الصفقة رابحة
   string notes;                // ملاحظات
   
   TradeEntry()
   {
      ticket = 0;
      symbol = "";
      orderType = -1;
      lotSize = 0.0;
      entryPrice = 0.0;
      stopLoss = 0.0;
      takeProfit = 0.0;
      entryTime = 0;
      exitTime = 0;
      exitPrice = 0.0;
      profit = 0.0;
      commission = 0.0;
      swap = 0.0;
      entryReason = "";
      exitReason = "";
      strategy = "";
      marketCondition = "";
      riskReward = 0.0;
      isWin = false;
      notes = "";
   }
};

//+------------------------------------------------------------------+
//| Pattern Analysis Structure                                      |
//+------------------------------------------------------------------+
struct PatternAnalysis
{
   string patternName;          // اسم النموذج
   int totalOccurrences;        // إجمالي الحدوث
   int successfulTrades;        // الصفقات الناجحة
   double successRate;          // معدل النجاح
   double averageProfit;        // متوسط الربح
   double averageLoss;          // متوسط الخسارة
   double profitFactor;         // عامل الربح
   datetime lastOccurrence;     // آخر حدوث
   
   PatternAnalysis()
   {
      patternName = "";
      totalOccurrences = 0;
      successfulTrades = 0;
      successRate = 0.0;
      averageProfit = 0.0;
      averageLoss = 0.0;
      profitFactor = 0.0;
      lastOccurrence = 0;
   }
};

//+------------------------------------------------------------------+
//| ML Model Performance Structure                                  |
//+------------------------------------------------------------------+
struct MLModelPerformance
{
   string modelName;            // اسم النموذج
   int totalPredictions;        // إجمالي التوقعات
   int correctPredictions;      // التوقعات الصحيحة
   double accuracy;             // دقة النموذج
   double precision;            // الدقة
   double recall;               // الاستدعاء
   double f1Score;              // نتيجة F1
   double profitFromModel;      // الربح من النموذج
   datetime lastUpdate;         // آخر تحديث
   
   MLModelPerformance()
   {
      modelName = "";
      totalPredictions = 0;
      correctPredictions = 0;
      accuracy = 0.0;
      precision = 0.0;
      recall = 0.0;
      f1Score = 0.0;
      profitFromModel = 0.0;
      lastUpdate = 0;
   }
};

//+------------------------------------------------------------------+
//| Performance Summary Structure                                   |
//+------------------------------------------------------------------+
struct PerformanceSummary
{
   int totalTrades;             // إجمالي الصفقات
   int winningTrades;           // الصفقات الرابحة
   int losingTrades;            // الصفقات الخاسرة
   double winRate;              // معدل الفوز
   double totalProfit;          // إجمالي الربح
   double totalLoss;            // إجمالي الخسارة
   double netProfit;            // صافي الربح
   double profitFactor;         // عامل الربح
   double averageWin;           // متوسط الربح
   double averageLoss;          // متوسط الخسارة
   double largestWin;           // أكبر ربح
   double largestLoss;          // أكبر خسارة
   double averageRiskReward;    // متوسط نسبة المخاطرة للعائد
   
   PerformanceSummary()
   {
      totalTrades = 0;
      winningTrades = 0;
      losingTrades = 0;
      winRate = 0.0;
      totalProfit = 0.0;
      totalLoss = 0.0;
      netProfit = 0.0;
      profitFactor = 0.0;
      averageWin = 0.0;
      averageLoss = 0.0;
      largestWin = 0.0;
      largestLoss = 0.0;
      averageRiskReward = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Trade Journal Class                                             |
//+------------------------------------------------------------------+
class CTradeJournal
{
private:
   TradeEntry m_trades[];
   PatternAnalysis m_patterns[];
   MLModelPerformance m_models[];
   PerformanceSummary m_summary;
   int m_tradeCount;
   int m_patternCount;
   int m_modelCount;
   string m_journalFile;
   string m_csvFile;
   
   // Private methods
   void UpdatePerformanceSummary();
   void UpdatePatternAnalysis(string pattern, bool isWin, double profit);
   void SaveToFile();
   void LoadFromFile();
   string FormatTradeEntry(TradeEntry &trade);
   
public:
   CTradeJournal();
   ~CTradeJournal();
   
   // Detailed trade logging - تسجيل تفصيلي للصفقات
   void LogTrade(long ticket, string symbol, int orderType, double lotSize, 
                 double entryPrice, double exitPrice, double profit,
                 string entryReason, string exitReason, string strategy);
   void LogTradeEntry(TradeEntry &trade);
   void UpdateTradeExit(long ticket, double exitPrice, double profit, string exitReason);
   
   // Performance metrics
   PerformanceSummary GetPerformanceSummary();
   void CalculateMetrics();
   double GetWinRate();
   double GetProfitFactor();
   double GetAverageRiskReward();
   
   // Pattern success rates
   void AddPatternOccurrence(string patternName, bool isSuccessful, double profit);
   PatternAnalysis GetPatternAnalysis(string patternName);
   PatternAnalysis[] GetAllPatterns();
   double GetPatternSuccessRate(string patternName);
   
   // ML model accuracy tracking
   void LogMLPrediction(string modelName, bool wasCorrect, double profit);
   void UpdateModelAccuracy(string modelName);
   MLModelPerformance GetModelPerformance(string modelName);
   MLModelPerformance[] GetAllModels();
   double GetModelAccuracy(string modelName);
   
   // Data export and reporting
   void ExportToCSV(string filename);
   void ExportToJSON(string filename);
   string GenerateDetailedReport();
   void PrintTradeStatistics();
   
   // Search and filtering
   TradeEntry[] GetTradesBySymbol(string symbol);
   TradeEntry[] GetTradesByStrategy(string strategy);
   TradeEntry[] GetTradesByDateRange(datetime startDate, datetime endDate);
   TradeEntry[] GetWinningTrades();
   TradeEntry[] GetLosingTrades();
   
   // Settings
   void SetJournalFile(string filename) { m_journalFile = filename; }
   void SetCSVFile(string filename) { m_csvFile = filename; }
   
   // Getters
   int GetTotalTrades() { return m_tradeCount; }
   TradeEntry GetTrade(int index);
   TradeEntry GetLastTrade();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeJournal::CTradeJournal()
{
   m_tradeCount = 0;
   m_patternCount = 0;
   m_modelCount = 0;
   m_journalFile = "trade_journal.txt";
   m_csvFile = "trade_journal.csv";
   
   ArrayResize(m_trades, 10000);
   ArrayResize(m_patterns, 100);
   ArrayResize(m_models, 50);
   
   LoadFromFile();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeJournal::~CTradeJournal()
{
   SaveToFile();
}

//+------------------------------------------------------------------+
//| Log Trade                                                       |
//+------------------------------------------------------------------+
void CTradeJournal::LogTrade(long ticket, string symbol, int orderType, double lotSize,
                            double entryPrice, double exitPrice, double profit,
                            string entryReason, string exitReason, string strategy)
{
   if(m_tradeCount >= ArraySize(m_trades))
   {
      ArrayResize(m_trades, ArraySize(m_trades) + 1000);
   }
   
   TradeEntry trade;
   trade.ticket = ticket;
   trade.symbol = symbol;
   trade.orderType = orderType;
   trade.lotSize = lotSize;
   trade.entryPrice = entryPrice;
   trade.exitPrice = exitPrice;
   trade.profit = profit;
   trade.entryReason = entryReason;
   trade.exitReason = exitReason;
   trade.strategy = strategy;
   trade.entryTime = TimeCurrent();
   trade.exitTime = TimeCurrent();
   trade.isWin = profit > 0;
   
   // Calculate risk-reward ratio
   if(trade.stopLoss > 0 && trade.takeProfit > 0)
   {
      double risk = MathAbs(entryPrice - trade.stopLoss);
      double reward = MathAbs(trade.takeProfit - entryPrice);
      trade.riskReward = (risk > 0) ? reward / risk : 0.0;
   }
   
   m_trades[m_tradeCount] = trade;
   m_tradeCount++;
   
   UpdatePerformanceSummary();
   SaveToFile();
   
   Print("✅ Trade logged: ", symbol, " | Profit: ", DoubleToString(profit, 2), 
         " | Strategy: ", strategy);
}

//+------------------------------------------------------------------+
//| Log Trade Entry                                                |
//+------------------------------------------------------------------+
void CTradeJournal::LogTradeEntry(TradeEntry &trade)
{
   if(m_tradeCount >= ArraySize(m_trades))
   {
      ArrayResize(m_trades, ArraySize(m_trades) + 1000);
   }
   
   m_trades[m_tradeCount] = trade;
   m_tradeCount++;
   
   UpdatePerformanceSummary();
   SaveToFile();
}

//+------------------------------------------------------------------+
//| Update Trade Exit                                              |
//+------------------------------------------------------------------+
void CTradeJournal::UpdateTradeExit(long ticket, double exitPrice, double profit, string exitReason)
{
   for(int i = 0; i < m_tradeCount; i++)
   {
      if(m_trades[i].ticket == ticket)
      {
         m_trades[i].exitPrice = exitPrice;
         m_trades[i].profit = profit;
         m_trades[i].exitReason = exitReason;
         m_trades[i].exitTime = TimeCurrent();
         m_trades[i].isWin = profit > 0;
         
         UpdatePerformanceSummary();
         SaveToFile();
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| Update Performance Summary                                      |
//+------------------------------------------------------------------+
void CTradeJournal::UpdatePerformanceSummary()
{
   m_summary.totalTrades = m_tradeCount;
   m_summary.winningTrades = 0;
   m_summary.losingTrades = 0;
   m_summary.totalProfit = 0.0;
   m_summary.totalLoss = 0.0;
   m_summary.largestWin = 0.0;
   m_summary.largestLoss = 0.0;
   
   double totalRiskReward = 0.0;
   int rrCount = 0;
   
   for(int i = 0; i < m_tradeCount; i++)
   {
      if(m_trades[i].isWin)
      {
         m_summary.winningTrades++;
         m_summary.totalProfit += m_trades[i].profit;
         if(m_trades[i].profit > m_summary.largestWin)
            m_summary.largestWin = m_trades[i].profit;
      }
      else
      {
         m_summary.losingTrades++;
         m_summary.totalLoss += MathAbs(m_trades[i].profit);
         if(MathAbs(m_trades[i].profit) > m_summary.largestLoss)
            m_summary.largestLoss = MathAbs(m_trades[i].profit);
      }
      
      if(m_trades[i].riskReward > 0)
      {
         totalRiskReward += m_trades[i].riskReward;
         rrCount++;
      }
   }
   
   m_summary.netProfit = m_summary.totalProfit - m_summary.totalLoss;
   
   if(m_tradeCount > 0)
   {
      m_summary.winRate = ((double)m_summary.winningTrades / m_tradeCount) * 100;
   }
   
   if(m_summary.winningTrades > 0)
   {
      m_summary.averageWin = m_summary.totalProfit / m_summary.winningTrades;
   }
   
   if(m_summary.losingTrades > 0)
   {
      m_summary.averageLoss = m_summary.totalLoss / m_summary.losingTrades;
   }
   
   if(m_summary.totalLoss > 0)
   {
      m_summary.profitFactor = m_summary.totalProfit / m_summary.totalLoss;
   }
   
   if(rrCount > 0)
   {
      m_summary.averageRiskReward = totalRiskReward / rrCount;
   }
}

//+------------------------------------------------------------------+
//| Add Pattern Occurrence                                         |
//+------------------------------------------------------------------+
void CTradeJournal::AddPatternOccurrence(string patternName, bool isSuccessful, double profit)
{
   int patternIndex = -1;
   
   // Find existing pattern
   for(int i = 0; i < m_patternCount; i++)
   {
      if(m_patterns[i].patternName == patternName)
      {
         patternIndex = i;
         break;
      }
   }
   
   // Create new pattern if not found
   if(patternIndex < 0)
   {
      if(m_patternCount >= ArraySize(m_patterns))
      {
         ArrayResize(m_patterns, ArraySize(m_patterns) + 50);
      }
      
      m_patterns[m_patternCount].patternName = patternName;
      patternIndex = m_patternCount;
      m_patternCount++;
   }
   
   // Update pattern statistics
   m_patterns[patternIndex].totalOccurrences++;
   m_patterns[patternIndex].lastOccurrence = TimeCurrent();
   
   if(isSuccessful)
   {
      m_patterns[patternIndex].successfulTrades++;
      m_patterns[patternIndex].averageProfit = 
         (m_patterns[patternIndex].averageProfit * (m_patterns[patternIndex].successfulTrades - 1) + profit) / 
         m_patterns[patternIndex].successfulTrades;
   }
   else
   {
      int lossTrades = m_patterns[patternIndex].totalOccurrences - m_patterns[patternIndex].successfulTrades;
      m_patterns[patternIndex].averageLoss = 
         (m_patterns[patternIndex].averageLoss * (lossTrades - 1) + MathAbs(profit)) / lossTrades;
   }
   
   // Calculate success rate and profit factor
   m_patterns[patternIndex].successRate = 
      ((double)m_patterns[patternIndex].successfulTrades / m_patterns[patternIndex].totalOccurrences) * 100;
   
   if(m_patterns[patternIndex].averageLoss > 0)
   {
      m_patterns[patternIndex].profitFactor = 
         m_patterns[patternIndex].averageProfit / m_patterns[patternIndex].averageLoss;
   }
   
   Print("📊 Pattern updated: ", patternName, " | Success Rate: ", 
         DoubleToString(m_patterns[patternIndex].successRate, 1), "%");
}

//+------------------------------------------------------------------+
//| Log ML Prediction                                              |
//+------------------------------------------------------------------+
void CTradeJournal::LogMLPrediction(string modelName, bool wasCorrect, double profit)
{
   int modelIndex = -1;
   
   // Find existing model
   for(int i = 0; i < m_modelCount; i++)
   {
      if(m_models[i].modelName == modelName)
      {
         modelIndex = i;
         break;
      }
   }
   
   // Create new model if not found
   if(modelIndex < 0)
   {
      if(m_modelCount >= ArraySize(m_models))
      {
         ArrayResize(m_models, ArraySize(m_models) + 25);
      }
      
      m_models[m_modelCount].modelName = modelName;
      modelIndex = m_modelCount;
      m_modelCount++;
   }
   
   // Update model statistics
   m_models[modelIndex].totalPredictions++;
   m_models[modelIndex].lastUpdate = TimeCurrent();
   m_models[modelIndex].profitFromModel += profit;
   
   if(wasCorrect)
   {
      m_models[modelIndex].correctPredictions++;
   }
   
   // Calculate accuracy
   m_models[modelIndex].accuracy = 
      ((double)m_models[modelIndex].correctPredictions / m_models[modelIndex].totalPredictions) * 100;
   
   Print("🤖 ML Model updated: ", modelName, " | Accuracy: ", 
         DoubleToString(m_models[modelIndex].accuracy, 1), "%");
}

//+------------------------------------------------------------------+
//| Get Performance Summary                                        |
//+------------------------------------------------------------------+
PerformanceSummary CTradeJournal::GetPerformanceSummary()
{
   UpdatePerformanceSummary();
   return m_summary;
}

//+------------------------------------------------------------------+
//| Get Pattern Analysis                                           |
//+------------------------------------------------------------------+
PatternAnalysis CTradeJournal::GetPatternAnalysis(string patternName)
{
   for(int i = 0; i < m_patternCount; i++)
   {
      if(m_patterns[i].patternName == patternName)
         return m_patterns[i];
   }
   
   PatternAnalysis emptyPattern;
   return emptyPattern;
}

//+------------------------------------------------------------------+
//| Get Model Performance                                          |
//+------------------------------------------------------------------+
MLModelPerformance CTradeJournal::GetModelPerformance(string modelName)
{
   for(int i = 0; i < m_modelCount; i++)
   {
      if(m_models[i].modelName == modelName)
         return m_models[i];
   }
   
   MLModelPerformance emptyModel;
   return emptyModel;
}

//+------------------------------------------------------------------+
//| Export to CSV                                                  |
//+------------------------------------------------------------------+
void CTradeJournal::ExportToCSV(string filename)
{
   int fileHandle = FileOpen(filename, FILE_WRITE | FILE_CSV);
   
   if(fileHandle != INVALID_HANDLE)
   {
      // Write header
      FileWrite(fileHandle, "Ticket", "Symbol", "Type", "LotSize", "EntryPrice", 
                "ExitPrice", "Profit", "EntryTime", "ExitTime", "Strategy", 
                "EntryReason", "ExitReason", "RiskReward", "IsWin");
      
      // Write trade data
      for(int i = 0; i < m_tradeCount; i++)
      {
         FileWrite(fileHandle, 
                   IntegerToString(m_trades[i].ticket),
                   m_trades[i].symbol,
                   IntegerToString(m_trades[i].orderType),
                   DoubleToString(m_trades[i].lotSize, 2),
                   DoubleToString(m_trades[i].entryPrice, 5),
                   DoubleToString(m_trades[i].exitPrice, 5),
                   DoubleToString(m_trades[i].profit, 2),
                   TimeToString(m_trades[i].entryTime),
                   TimeToString(m_trades[i].exitTime),
                   m_trades[i].strategy,
                   m_trades[i].entryReason,
                   m_trades[i].exitReason,
                   DoubleToString(m_trades[i].riskReward, 2),
                   m_trades[i].isWin ? "TRUE" : "FALSE");
      }
      
      FileClose(fileHandle);
      Print("✅ Trade journal exported to CSV: ", filename);
   }
   else
   {
      Print("❌ Failed to create CSV file: ", filename);
   }
}

//+------------------------------------------------------------------+
//| Generate Detailed Report                                       |
//+------------------------------------------------------------------+
string CTradeJournal::GenerateDetailedReport()
{
   UpdatePerformanceSummary();
   
   string report = "=== DETAILED TRADE JOURNAL REPORT ===\n";
   report += "Generated: " + TimeToString(TimeCurrent()) + "\n\n";
   
   // Performance Summary
   report += "=== PERFORMANCE SUMMARY ===\n";
   report += "Total Trades: " + IntegerToString(m_summary.totalTrades) + "\n";
   report += "Winning Trades: " + IntegerToString(m_summary.winningTrades) + "\n";
   report += "Losing Trades: " + IntegerToString(m_summary.losingTrades) + "\n";
   report += "Win Rate: " + DoubleToString(m_summary.winRate, 2) + "%\n";
   report += "Net Profit: " + DoubleToString(m_summary.netProfit, 2) + "\n";
   report += "Profit Factor: " + DoubleToString(m_summary.profitFactor, 2) + "\n";
   report += "Average Win: " + DoubleToString(m_summary.averageWin, 2) + "\n";
   report += "Average Loss: " + DoubleToString(m_summary.averageLoss, 2) + "\n";
   report += "Largest Win: " + DoubleToString(m_summary.largestWin, 2) + "\n";
   report += "Largest Loss: " + DoubleToString(m_summary.largestLoss, 2) + "\n";
   report += "Average Risk/Reward: " + DoubleToString(m_summary.averageRiskReward, 2) + "\n\n";
   
   // Pattern Analysis
   report += "=== PATTERN ANALYSIS ===\n";
   for(int i = 0; i < m_patternCount; i++)
   {
      report += "Pattern: " + m_patterns[i].patternName + "\n";
      report += "  Occurrences: " + IntegerToString(m_patterns[i].totalOccurrences) + "\n";
      report += "  Success Rate: " + DoubleToString(m_patterns[i].successRate, 1) + "%\n";
      report += "  Profit Factor: " + DoubleToString(m_patterns[i].profitFactor, 2) + "\n\n";
   }
   
   // ML Model Performance
   report += "=== ML MODEL PERFORMANCE ===\n";
   for(int i = 0; i < m_modelCount; i++)
   {
      report += "Model: " + m_models[i].modelName + "\n";
      report += "  Predictions: " + IntegerToString(m_models[i].totalPredictions) + "\n";
      report += "  Accuracy: " + DoubleToString(m_models[i].accuracy, 1) + "%\n";
      report += "  Profit: " + DoubleToString(m_models[i].profitFromModel, 2) + "\n\n";
   }
   
   return report;
}

//+------------------------------------------------------------------+
//| Save to File                                                   |
//+------------------------------------------------------------------+
void CTradeJournal::SaveToFile()
{
   int fileHandle = FileOpen(m_journalFile, FILE_WRITE | FILE_TXT);
   
   if(fileHandle != INVALID_HANDLE)
   {
      FileWriteString(fileHandle, GenerateDetailedReport());
      FileClose(fileHandle);
   }
}

//+------------------------------------------------------------------+
//| Load from File                                                 |
//+------------------------------------------------------------------+
void CTradeJournal::LoadFromFile()
{
   // Implementation for loading previous journal data
   // This would parse the saved file and restore trade history
}

//+------------------------------------------------------------------+
//| Get Trades by Symbol                                          |
//+------------------------------------------------------------------+
TradeEntry[] CTradeJournal::GetTradesBySymbol(string symbol)
{
   TradeEntry filteredTrades[];
   int count = 0;
   
   for(int i = 0; i < m_tradeCount; i++)
   {
      if(m_trades[i].symbol == symbol)
      {
         ArrayResize(filteredTrades, count + 1);
         filteredTrades[count] = m_trades[i];
         count++;
      }
   }
   
   return filteredTrades;
}

//+------------------------------------------------------------------+
//| Print Trade Statistics                                         |
//+------------------------------------------------------------------+
void CTradeJournal::PrintTradeStatistics()
{
   UpdatePerformanceSummary();
   
   Print("=== TRADE JOURNAL STATISTICS ===");
   Print("Total Trades: ", m_summary.totalTrades);
   Print("Win Rate: ", DoubleToString(m_summary.winRate, 2), "%");
   Print("Net Profit: ", DoubleToString(m_summary.netProfit, 2));
   Print("Profit Factor: ", DoubleToString(m_summary.profitFactor, 2));
   Print("Patterns Tracked: ", m_patternCount);
   Print("ML Models Tracked: ", m_modelCount);
}

//+------------------------------------------------------------------+
//| Get Trade                                                      |
//+------------------------------------------------------------------+
TradeEntry CTradeJournal::GetTrade(int index)
{
   if(index >= 0 && index < m_tradeCount)
      return m_trades[index];
   
   TradeEntry emptyTrade;
   return emptyTrade;
}

//+------------------------------------------------------------------+
//| Get Last Trade                                                 |
//+------------------------------------------------------------------+
TradeEntry CTradeJournal::GetLastTrade()
{
   if(m_tradeCount > 0)
      return m_trades[m_tradeCount - 1];
   
   TradeEntry emptyTrade;
   return emptyTrade;
}
