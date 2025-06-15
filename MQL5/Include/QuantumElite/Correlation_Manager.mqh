//+------------------------------------------------------------------+
//|                                            Correlation_Manager.mqh |
//|                                  Copyright 2024, Quantum Trading Systems |
//|                                             https://quantumelite.trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Correlation Data Structure                                      |
//+------------------------------------------------------------------+
struct CorrelationData
{
   string symbol1;              // الرمز الأول
   string symbol2;              // الرمز الثاني
   double correlation;          // معامل الارتباط
   datetime lastUpdate;         // آخر تحديث
   int sampleSize;             // حجم العينة
   double reliability;         // موثوقية البيانات
   
   CorrelationData()
   {
      symbol1 = "";
      symbol2 = "";
      correlation = 0.0;
      lastUpdate = 0;
      sampleSize = 0;
      reliability = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Portfolio Position Structure                                    |
//+------------------------------------------------------------------+
struct PortfolioPosition
{
   string symbol;              // رمز العملة
   double lotSize;             // حجم المركز
   int orderType;              // نوع الأمر
   double entryPrice;          // سعر الدخول
   double currentPrice;        // السعر الحالي
   double unrealizedPL;        // الربح/الخسارة غير المحققة
   double riskWeight;          // وزن المخاطرة
   
   PortfolioPosition()
   {
      symbol = "";
      lotSize = 0.0;
      orderType = -1;
      entryPrice = 0.0;
      currentPrice = 0.0;
      unrealizedPL = 0.0;
      riskWeight = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Hedging Suggestion Structure                                    |
//+------------------------------------------------------------------+
struct HedgingSuggestion
{
   string hedgeSymbol;         // رمز التحوط
   double hedgeSize;           // حجم التحوط
   int hedgeType;              // نوع التحوط
   double expectedReduction;   // تقليل المخاطرة المتوقع
   double cost;                // تكلفة التحوط
   string reason;              // سبب التحوط
   
   HedgingSuggestion()
   {
      hedgeSymbol = "";
      hedgeSize = 0.0;
      hedgeType = -1;
      expectedReduction = 0.0;
      cost = 0.0;
      reason = "";
   }
};

//+------------------------------------------------------------------+
//| Correlation Manager Class                                       |
//+------------------------------------------------------------------+
class CCorrelationManager
{
private:
   CorrelationData m_correlationMatrix[];
   PortfolioPosition m_portfolio[];
   HedgingSuggestion m_hedgingSuggestions[];
   int m_matrixSize;
   int m_portfolioSize;
   int m_lookbackPeriod;
   double m_highCorrelationThreshold;
   double m_lowCorrelationThreshold;
   datetime m_lastMatrixUpdate;
   
   // Private methods
   double CalculatePearsonCorrelation(string symbol1, string symbol2, int period);
   void UpdateCorrelationMatrix();
   int FindCorrelationIndex(string symbol1, string symbol2);
   double GetPriceArray(string symbol, double &prices[], int count);
   void AnalyzePortfolioRisk();
   void GenerateHedgingSuggestions();
   
public:
   CCorrelationManager();
   ~CCorrelationManager();
   
   // Dynamic correlation calculation - حساب الارتباط الديناميكي
   double GetCorrelation(string symbol1, string symbol2);
   void UpdateSymbolCorrelation(string symbol1, string symbol2);
   bool IsHighCorrelation(string symbol1, string symbol2);
   
   // Portfolio correlation matrix
   void BuildCorrelationMatrix(string symbols[]);
   double[,] GetCorrelationMatrix();
   void PrintCorrelationMatrix();
   
   // Hedging suggestions
   HedgingSuggestion[] GetHedgingSuggestions();
   HedgingSuggestion GetBestHedge(string symbol);
   double CalculateHedgeRatio(string symbol1, string symbol2);
   
   // Risk distribution
   double CalculatePortfolioRisk();
   double GetDiversificationRatio();
   double CalculateVaR(double confidenceLevel);
   void OptimizeRiskDistribution();
   
   // Portfolio management
   void AddPosition(string symbol, double lotSize, int orderType, double entryPrice);
   void RemovePosition(string symbol);
   void UpdatePortfolio();
   
   // Settings
   void SetLookbackPeriod(int period) { m_lookbackPeriod = period; }
   void SetCorrelationThresholds(double high, double low);
   
   // Information getters
   double GetPortfolioCorrelation();
   string GetRiskDistributionReport();
   int GetHighlyCorrelatedPairs();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCorrelationManager::CCorrelationManager()
{
   m_matrixSize = 0;
   m_portfolioSize = 0;
   m_lookbackPeriod = 50;
   m_highCorrelationThreshold = 0.7;
   m_lowCorrelationThreshold = -0.7;
   m_lastMatrixUpdate = 0;
   
   ArrayResize(m_correlationMatrix, 1000);
   ArrayResize(m_portfolio, 100);
   ArrayResize(m_hedgingSuggestions, 50);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCorrelationManager::~CCorrelationManager()
{
}

//+------------------------------------------------------------------+
//| Get Correlation                                                 |
//+------------------------------------------------------------------+
double CCorrelationManager::GetCorrelation(string symbol1, string symbol2)
{
   int index = FindCorrelationIndex(symbol1, symbol2);
   
   if(index >= 0)
   {
      // Check if data is recent (within 1 hour)
      if(TimeCurrent() - m_correlationMatrix[index].lastUpdate < 3600)
      {
         return m_correlationMatrix[index].correlation;
      }
   }
   
   // Calculate new correlation
   double correlation = CalculatePearsonCorrelation(symbol1, symbol2, m_lookbackPeriod);
   
   // Store in matrix
   if(index < 0)
   {
      // Add new entry
      m_correlationMatrix[m_matrixSize].symbol1 = symbol1;
      m_correlationMatrix[m_matrixSize].symbol2 = symbol2;
      m_correlationMatrix[m_matrixSize].correlation = correlation;
      m_correlationMatrix[m_matrixSize].lastUpdate = TimeCurrent();
      m_correlationMatrix[m_matrixSize].sampleSize = m_lookbackPeriod;
      m_correlationMatrix[m_matrixSize].reliability = MathMin(1.0, m_lookbackPeriod / 100.0);
      m_matrixSize++;
   }
   else
   {
      // Update existing entry
      m_correlationMatrix[index].correlation = correlation;
      m_correlationMatrix[index].lastUpdate = TimeCurrent();
   }
   
   return correlation;
}

//+------------------------------------------------------------------+
//| Calculate Pearson Correlation                                  |
//+------------------------------------------------------------------+
double CCorrelationManager::CalculatePearsonCorrelation(string symbol1, string symbol2, int period)
{
   double prices1[], prices2[];
   ArraySetAsSeries(prices1, true);
   ArraySetAsSeries(prices2, true);
   
   // Get price data
   if(CopyClose(symbol1, PERIOD_H1, 0, period, prices1) <= 0) return 0.0;
   if(CopyClose(symbol2, PERIOD_H1, 0, period, prices2) <= 0) return 0.0;
   
   if(ArraySize(prices1) != ArraySize(prices2)) return 0.0;
   
   // Calculate means
   double mean1 = 0.0, mean2 = 0.0;
   for(int i = 0; i < period; i++)
   {
      mean1 += prices1[i];
      mean2 += prices2[i];
   }
   mean1 /= period;
   mean2 /= period;
   
   // Calculate correlation components
   double numerator = 0.0;
   double sum1Sq = 0.0, sum2Sq = 0.0;
   
   for(int i = 0; i < period; i++)
   {
      double diff1 = prices1[i] - mean1;
      double diff2 = prices2[i] - mean2;
      
      numerator += diff1 * diff2;
      sum1Sq += diff1 * diff1;
      sum2Sq += diff2 * diff2;
   }
   
   double denominator = MathSqrt(sum1Sq * sum2Sq);
   
   if(denominator == 0.0) return 0.0;
   
   return numerator / denominator;
}

//+------------------------------------------------------------------+
//| Find Correlation Index                                         |
//+------------------------------------------------------------------+
int CCorrelationManager::FindCorrelationIndex(string symbol1, string symbol2)
{
   for(int i = 0; i < m_matrixSize; i++)
   {
      if((m_correlationMatrix[i].symbol1 == symbol1 && m_correlationMatrix[i].symbol2 == symbol2) ||
         (m_correlationMatrix[i].symbol1 == symbol2 && m_correlationMatrix[i].symbol2 == symbol1))
      {
         return i;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Check High Correlation                                         |
//+------------------------------------------------------------------+
bool CCorrelationManager::IsHighCorrelation(string symbol1, string symbol2)
{
   double correlation = GetCorrelation(symbol1, symbol2);
   return MathAbs(correlation) > m_highCorrelationThreshold;
}

//+------------------------------------------------------------------+
//| Build Correlation Matrix                                       |
//+------------------------------------------------------------------+
void CCorrelationManager::BuildCorrelationMatrix(string symbols[])
{
   int symbolCount = ArraySize(symbols);
   
   Print("Building correlation matrix for ", symbolCount, " symbols...");
   
   for(int i = 0; i < symbolCount; i++)
   {
      for(int j = i + 1; j < symbolCount; j++)
      {
         double correlation = GetCorrelation(symbols[i], symbols[j]);
         Print(symbols[i], " vs ", symbols[j], ": ", DoubleToString(correlation, 3));
      }
   }
   
   m_lastMatrixUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Print Correlation Matrix                                       |
//+------------------------------------------------------------------+
void CCorrelationManager::PrintCorrelationMatrix()
{
   Print("=== Correlation Matrix Report ===");
   Print("Last Update: ", TimeToString(m_lastMatrixUpdate));
   Print("Total Pairs: ", m_matrixSize);
   
   int highCorrelations = 0;
   
   for(int i = 0; i < m_matrixSize; i++)
   {
      double corr = m_correlationMatrix[i].correlation;
      string status = "";
      
      if(MathAbs(corr) > m_highCorrelationThreshold)
      {
         status = " [HIGH RISK]";
         highCorrelations++;
      }
      else if(MathAbs(corr) < 0.3)
      {
         status = " [DIVERSIFIED]";
      }
      
      Print(m_correlationMatrix[i].symbol1, " vs ", m_correlationMatrix[i].symbol2, 
            ": ", DoubleToString(corr, 3), status);
   }
   
   Print("High correlation pairs: ", highCorrelations);
}

//+------------------------------------------------------------------+
//| Add Position to Portfolio                                      |
//+------------------------------------------------------------------+
void CCorrelationManager::AddPosition(string symbol, double lotSize, int orderType, double entryPrice)
{
   if(m_portfolioSize >= ArraySize(m_portfolio)) return;
   
   m_portfolio[m_portfolioSize].symbol = symbol;
   m_portfolio[m_portfolioSize].lotSize = lotSize;
   m_portfolio[m_portfolioSize].orderType = orderType;
   m_portfolio[m_portfolioSize].entryPrice = entryPrice;
   m_portfolio[m_portfolioSize].currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   
   // Calculate unrealized P&L
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   
   if(orderType == ORDER_TYPE_BUY)
   {
      m_portfolio[m_portfolioSize].unrealizedPL = 
         (m_portfolio[m_portfolioSize].currentPrice - entryPrice) / point * tickValue * lotSize;
   }
   else
   {
      m_portfolio[m_portfolioSize].unrealizedPL = 
         (entryPrice - m_portfolio[m_portfolioSize].currentPrice) / point * tickValue * lotSize;
   }
   
   m_portfolioSize++;
   
   // Analyze portfolio risk after adding position
   AnalyzePortfolioRisk();
}

//+------------------------------------------------------------------+
//| Calculate Portfolio Risk                                       |
//+------------------------------------------------------------------+
double CCorrelationManager::CalculatePortfolioRisk()
{
   if(m_portfolioSize < 2) return 1.0;
   
   double totalRisk = 0.0;
   double totalWeight = 0.0;
   
   // Calculate individual position risks
   for(int i = 0; i < m_portfolioSize; i++)
   {
      double positionRisk = MathAbs(m_portfolio[i].lotSize) * 
                           SymbolInfoDouble(m_portfolio[i].symbol, SYMBOL_TRADE_TICK_VALUE);
      m_portfolio[i].riskWeight = positionRisk;
      totalWeight += positionRisk;
   }
   
   // Normalize weights
   for(int i = 0; i < m_portfolioSize; i++)
   {
      m_portfolio[i].riskWeight /= totalWeight;
   }
   
   // Calculate portfolio risk considering correlations
   for(int i = 0; i < m_portfolioSize; i++)
   {
      for(int j = 0; j < m_portfolioSize; j++)
      {
         double correlation = (i == j) ? 1.0 : GetCorrelation(m_portfolio[i].symbol, m_portfolio[j].symbol);
         totalRisk += m_portfolio[i].riskWeight * m_portfolio[j].riskWeight * correlation;
      }
   }
   
   return MathSqrt(totalRisk);
}

//+------------------------------------------------------------------+
//| Get Diversification Ratio                                     |
//+------------------------------------------------------------------+
double CCorrelationManager::GetDiversificationRatio()
{
   if(m_portfolioSize < 2) return 1.0;
   
   double portfolioRisk = CalculatePortfolioRisk();
   double averageIndividualRisk = 1.0 / MathSqrt(m_portfolioSize);
   
   return averageIndividualRisk / portfolioRisk;
}

//+------------------------------------------------------------------+
//| Analyze Portfolio Risk                                         |
//+------------------------------------------------------------------+
void CCorrelationManager::AnalyzePortfolioRisk()
{
   double portfolioRisk = CalculatePortfolioRisk();
   double diversificationRatio = GetDiversificationRatio();
   
   Print("=== Portfolio Risk Analysis ===");
   Print("Portfolio Risk: ", DoubleToString(portfolioRisk, 4));
   Print("Diversification Ratio: ", DoubleToString(diversificationRatio, 2));
   
   if(portfolioRisk > 0.8)
   {
      Print("⚠️ HIGH PORTFOLIO RISK - Consider hedging");
      GenerateHedgingSuggestions();
   }
   else if(diversificationRatio < 1.2)
   {
      Print("⚠️ LOW DIVERSIFICATION - Consider adding uncorrelated positions");
   }
   else
   {
      Print("✅ Portfolio risk within acceptable limits");
   }
}

//+------------------------------------------------------------------+
//| Generate Hedging Suggestions                                   |
//+------------------------------------------------------------------+
void CCorrelationManager::GenerateHedgingSuggestions()
{
   int suggestionCount = 0;
   
   // Find highly correlated positions that need hedging
   for(int i = 0; i < m_portfolioSize; i++)
   {
      for(int j = i + 1; j < m_portfolioSize; j++)
      {
         double correlation = GetCorrelation(m_portfolio[i].symbol, m_portfolio[j].symbol);
         
         if(MathAbs(correlation) > m_highCorrelationThreshold && suggestionCount < ArraySize(m_hedgingSuggestions))
         {
            // Generate hedge suggestion
            m_hedgingSuggestions[suggestionCount].hedgeSymbol = FindBestHedgeSymbol(m_portfolio[i].symbol);
            m_hedgingSuggestions[suggestionCount].hedgeSize = CalculateOptimalHedgeSize(m_portfolio[i].symbol);
            m_hedgingSuggestions[suggestionCount].hedgeType = (m_portfolio[i].orderType == ORDER_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            m_hedgingSuggestions[suggestionCount].expectedReduction = MathAbs(correlation) * 0.5;
            m_hedgingSuggestions[suggestionCount].cost = CalculateHedgeCost(m_hedgingSuggestions[suggestionCount].hedgeSymbol);
            m_hedgingSuggestions[suggestionCount].reason = "High correlation with " + m_portfolio[j].symbol + " (" + DoubleToString(correlation, 2) + ")";
            
            suggestionCount++;
         }
      }
   }
   
   Print("Generated ", suggestionCount, " hedging suggestions");
}

//+------------------------------------------------------------------+
//| Find Best Hedge Symbol                                        |
//+------------------------------------------------------------------+
string CCorrelationManager::FindBestHedgeSymbol(string symbol)
{
   // Simplified hedge symbol selection
   // In practice, this would analyze multiple potential hedge instruments
   
   if(StringFind(symbol, "EUR") >= 0) return "USDCHF";
   if(StringFind(symbol, "GBP") >= 0) return "EURJPY";
   if(StringFind(symbol, "USD") >= 0) return "EURUSD";
   if(StringFind(symbol, "JPY") >= 0) return "AUDJPY";
   
   return "EURUSD"; // Default hedge
}

//+------------------------------------------------------------------+
//| Calculate Optimal Hedge Size                                  |
//+------------------------------------------------------------------+
double CCorrelationManager::CalculateOptimalHedgeSize(string symbol)
{
   // Find position size for the symbol
   for(int i = 0; i < m_portfolioSize; i++)
   {
      if(m_portfolio[i].symbol == symbol)
      {
         return m_portfolio[i].lotSize * 0.7; // 70% hedge ratio
      }
   }
   return 0.1; // Default small hedge
}

//+------------------------------------------------------------------+
//| Calculate Hedge Cost                                           |
//+------------------------------------------------------------------+
double CCorrelationManager::CalculateHedgeCost(string hedgeSymbol)
{
   double spread = SymbolInfoInteger(hedgeSymbol, SYMBOL_SPREAD) * SymbolInfoDouble(hedgeSymbol, SYMBOL_POINT);
   double swapLong = SymbolInfoDouble(hedgeSymbol, SYMBOL_SWAP_LONG);
   double swapShort = SymbolInfoDouble(hedgeSymbol, SYMBOL_SWAP_SHORT);
   
   return spread + MathMax(MathAbs(swapLong), MathAbs(swapShort));
}

//+------------------------------------------------------------------+
//| Get Best Hedge                                                |
//+------------------------------------------------------------------+
HedgingSuggestion CCorrelationManager::GetBestHedge(string symbol)
{
   HedgingSuggestion bestHedge;
   double bestScore = 0.0;
   
   for(int i = 0; i < ArraySize(m_hedgingSuggestions); i++)
   {
      if(m_hedgingSuggestions[i].hedgeSymbol == "") continue;
      
      double score = m_hedgingSuggestions[i].expectedReduction / (m_hedgingSuggestions[i].cost + 0.001);
      
      if(score > bestScore)
      {
         bestScore = score;
         bestHedge = m_hedgingSuggestions[i];
      }
   }
   
   return bestHedge;
}

//+------------------------------------------------------------------+
//| Set Correlation Thresholds                                    |
//+------------------------------------------------------------------+
void CCorrelationManager::SetCorrelationThresholds(double high, double low)
{
   m_highCorrelationThreshold = MathMax(high, 0.5);
   m_lowCorrelationThreshold = MathMin(low, -0.5);
}

//+------------------------------------------------------------------+
//| Get Portfolio Correlation                                      |
//+------------------------------------------------------------------+
double CCorrelationManager::GetPortfolioCorrelation()
{
   if(m_portfolioSize < 2) return 0.0;
   
   double totalCorrelation = 0.0;
   int pairCount = 0;
   
   for(int i = 0; i < m_portfolioSize; i++)
   {
      for(int j = i + 1; j < m_portfolioSize; j++)
      {
         totalCorrelation += MathAbs(GetCorrelation(m_portfolio[i].symbol, m_portfolio[j].symbol));
         pairCount++;
      }
   }
   
   return pairCount > 0 ? totalCorrelation / pairCount : 0.0;
}

//+------------------------------------------------------------------+
//| Get Risk Distribution Report                                   |
//+------------------------------------------------------------------+
string CCorrelationManager::GetRiskDistributionReport()
{
   string report = "=== Risk Distribution Report ===\n";
   report += "Portfolio Size: " + IntegerToString(m_portfolioSize) + "\n";
   report += "Portfolio Risk: " + DoubleToString(CalculatePortfolioRisk(), 4) + "\n";
   report += "Diversification Ratio: " + DoubleToString(GetDiversificationRatio(), 2) + "\n";
   report += "Average Correlation: " + DoubleToString(GetPortfolioCorrelation(), 3) + "\n";
   report += "High Correlation Pairs: " + IntegerToString(GetHighlyCorrelatedPairs()) + "\n";
   
   return report;
}

//+------------------------------------------------------------------+
//| Get Highly Correlated Pairs                                   |
//+------------------------------------------------------------------+
int CCorrelationManager::GetHighlyCorrelatedPairs()
{
   int count = 0;
   
   for(int i = 0; i < m_matrixSize; i++)
   {
      if(MathAbs(m_correlationMatrix[i].correlation) > m_highCorrelationThreshold)
         count++;
   }
   
   return count;
}
