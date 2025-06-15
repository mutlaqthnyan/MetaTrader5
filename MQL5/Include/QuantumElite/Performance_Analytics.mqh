//+------------------------------------------------------------------+
//|                                         Performance_Analytics.mqh |
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
//| Performance Metrics Structure                                   |
//+------------------------------------------------------------------+
struct PerformanceMetrics
{
   double totalReturn;          // إجمالي العائد
   double sharpeRatio;          // نسبة شارب
   double sortinoRatio;         // نسبة سورتينو
   double maxDrawdown;          // أقصى انخفاض
   double maxDrawdownPercent;   // أقصى انخفاض بالنسبة المئوية
   double winRate;              // معدل الفوز
   double profitFactor;         // عامل الربح
   double averageWin;           // متوسط الربح
   double averageLoss;          // متوسط الخسارة
   int totalTrades;             // إجمالي الصفقات
   int winningTrades;           // الصفقات الرابحة
   int losingTrades;            // الصفقات الخاسرة
   
   PerformanceMetrics()
   {
      totalReturn = 0.0;
      sharpeRatio = 0.0;
      sortinoRatio = 0.0;
      maxDrawdown = 0.0;
      maxDrawdownPercent = 0.0;
      winRate = 0.0;
      profitFactor = 0.0;
      averageWin = 0.0;
      averageLoss = 0.0;
      totalTrades = 0;
      winningTrades = 0;
      losingTrades = 0;
   }
};

//+------------------------------------------------------------------+
//| Drawdown Data Structure                                         |
//+------------------------------------------------------------------+
struct DrawdownData
{
   datetime startTime;          // بداية الانخفاض
   datetime endTime;            // نهاية الانخفاض
   double peakValue;            // القيمة العليا
   double troughValue;          // القيمة السفلى
   double drawdownAmount;       // مقدار الانخفاض
   double drawdownPercent;      // نسبة الانخفاض
   int duration;                // مدة الانخفاض بالأيام
   
   DrawdownData()
   {
      startTime = 0;
      endTime = 0;
      peakValue = 0.0;
      troughValue = 0.0;
      drawdownAmount = 0.0;
      drawdownPercent = 0.0;
      duration = 0;
   }
};

//+------------------------------------------------------------------+
//| Streak Analysis Structure                                       |
//+------------------------------------------------------------------+
struct StreakAnalysis
{
   int currentWinStreak;        // سلسلة الفوز الحالية
   int currentLossStreak;       // سلسلة الخسارة الحالية
   int maxWinStreak;            // أطول سلسلة فوز
   int maxLossStreak;           // أطول سلسلة خسارة
   double maxWinStreakProfit;   // ربح أطول سلسلة فوز
   double maxLossStreakLoss;    // خسارة أطول سلسلة خسارة
   
   StreakAnalysis()
   {
      currentWinStreak = 0;
      currentLossStreak = 0;
      maxWinStreak = 0;
      maxLossStreak = 0;
      maxWinStreakProfit = 0.0;
      maxLossStreakLoss = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Monte Carlo Result Structure                                   |
//+------------------------------------------------------------------+
struct MonteCarloResult
{
   double expectedReturn;       // العائد المتوقع
   double standardDeviation;    // الانحراف المعياري
   double confidenceInterval95; // فترة الثقة 95%
   double probabilityOfLoss;    // احتمالية الخسارة
   double valueAtRisk;          // القيمة المعرضة للخطر
   double expectedShortfall;    // النقص المتوقع
   
   MonteCarloResult()
   {
      expectedReturn = 0.0;
      standardDeviation = 0.0;
      confidenceInterval95 = 0.0;
      probabilityOfLoss = 0.0;
      valueAtRisk = 0.0;
      expectedShortfall = 0.0;
   }
};

//+------------------------------------------------------------------+
//| Performance Analytics Class                                     |
//+------------------------------------------------------------------+
class CPerformanceAnalytics
{
private:
   double m_equityHistory[];
   double m_returns[];
   DrawdownData m_drawdowns[];
   StreakAnalysis m_streakData;
   PerformanceMetrics m_metrics;
   int m_historySize;
   int m_drawdownCount;
   double m_riskFreeRate;
   double m_initialBalance;
   
   // Private methods
   void CalculateReturns();
   void UpdateDrawdownAnalysis();
   void UpdateStreakAnalysis(bool isWin, double profit);
   double CalculateStandardDeviation(double returns[], int size);
   double CalculateDownsideDeviation(double returns[], int size);
   
public:
   CPerformanceAnalytics();
   ~CPerformanceAnalytics();
   
   // Data input
   void AddEquityPoint(double equity);
   void AddTradeResult(bool isWin, double profit);
   void SetInitialBalance(double balance) { m_initialBalance = balance; }
   void SetRiskFreeRate(double rate) { m_riskFreeRate = rate; }
   
   // Sharpe/Sortino ratios
   double CalculateSharpeRatio();
   double CalculateSortinoRatio();
   double CalculateCalmarRatio();
   
   // Maximum drawdown tracking
   double GetMaxDrawdown();
   double GetMaxDrawdownPercent();
   DrawdownData GetCurrentDrawdown();
   DrawdownData[] GetAllDrawdowns();
   
   // Win/loss streak analysis
   StreakAnalysis GetStreakAnalysis();
   void UpdateStreaks(bool isWin, double profit);
   
   // Monte Carlo simulations
   MonteCarloResult RunMonteCarloSimulation(int iterations, int periods);
   double[] GenerateRandomReturns(int periods);
   double CalculateVaR(double confidenceLevel);
   
   // Performance metrics
   PerformanceMetrics GetPerformanceMetrics();
   void UpdateMetrics();
   
   // Reporting
   string GeneratePerformanceReport();
   void PrintDetailedAnalysis();
   
   // Risk metrics
   double CalculateBeta(double marketReturns[]);
   double CalculateAlpha(double marketReturns[]);
   double CalculateInformationRatio(double benchmarkReturns[]);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPerformanceAnalytics::CPerformanceAnalytics()
{
   m_historySize = 0;
   m_drawdownCount = 0;
   m_riskFreeRate = 0.02; // 2% annual risk-free rate
   m_initialBalance = 10000.0;
   
   ArrayResize(m_equityHistory, 10000);
   ArrayResize(m_returns, 10000);
   ArrayResize(m_drawdowns, 100);
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPerformanceAnalytics::~CPerformanceAnalytics()
{
}

//+------------------------------------------------------------------+
//| Add Equity Point                                               |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::AddEquityPoint(double equity)
{
   if(m_historySize >= ArraySize(m_equityHistory))
   {
      ArrayResize(m_equityHistory, ArraySize(m_equityHistory) + 1000);
      ArrayResize(m_returns, ArraySize(m_returns) + 1000);
   }
   
   m_equityHistory[m_historySize] = equity;
   m_historySize++;
   
   // Calculate return if we have previous data
   if(m_historySize > 1)
   {
      double previousEquity = m_equityHistory[m_historySize - 2];
      if(previousEquity > 0)
      {
         m_returns[m_historySize - 2] = (equity - previousEquity) / previousEquity;
      }
   }
   
   UpdateDrawdownAnalysis();
   UpdateMetrics();
}

//+------------------------------------------------------------------+
//| Add Trade Result                                               |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::AddTradeResult(bool isWin, double profit)
{
   m_metrics.totalTrades++;
   
   if(isWin)
   {
      m_metrics.winningTrades++;
      m_metrics.averageWin = (m_metrics.averageWin * (m_metrics.winningTrades - 1) + profit) / m_metrics.winningTrades;
   }
   else
   {
      m_metrics.losingTrades++;
      m_metrics.averageLoss = (m_metrics.averageLoss * (m_metrics.losingTrades - 1) + MathAbs(profit)) / m_metrics.losingTrades;
   }
   
   UpdateStreakAnalysis(isWin, profit);
   UpdateMetrics();
}

//+------------------------------------------------------------------+
//| Calculate Sharpe Ratio                                         |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateSharpeRatio()
{
   if(m_historySize < 2) return 0.0;
   
   // Calculate average return
   double avgReturn = 0.0;
   for(int i = 0; i < m_historySize - 1; i++)
   {
      avgReturn += m_returns[i];
   }
   avgReturn /= (m_historySize - 1);
   
   // Annualize the return (assuming daily data)
   double annualizedReturn = avgReturn * 252;
   
   // Calculate standard deviation
   double stdDev = CalculateStandardDeviation(m_returns, m_historySize - 1);
   double annualizedStdDev = stdDev * MathSqrt(252);
   
   if(annualizedStdDev == 0.0) return 0.0;
   
   return (annualizedReturn - m_riskFreeRate) / annualizedStdDev;
}

//+------------------------------------------------------------------+
//| Calculate Sortino Ratio                                        |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateSortinoRatio()
{
   if(m_historySize < 2) return 0.0;
   
   // Calculate average return
   double avgReturn = 0.0;
   for(int i = 0; i < m_historySize - 1; i++)
   {
      avgReturn += m_returns[i];
   }
   avgReturn /= (m_historySize - 1);
   
   // Annualize the return
   double annualizedReturn = avgReturn * 252;
   
   // Calculate downside deviation
   double downsideDeviation = CalculateDownsideDeviation(m_returns, m_historySize - 1);
   double annualizedDownsideDeviation = downsideDeviation * MathSqrt(252);
   
   if(annualizedDownsideDeviation == 0.0) return 0.0;
   
   return (annualizedReturn - m_riskFreeRate) / annualizedDownsideDeviation;
}

//+------------------------------------------------------------------+
//| Calculate Calmar Ratio                                         |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateCalmarRatio()
{
   if(m_historySize < 2) return 0.0;
   
   double totalReturn = m_metrics.totalReturn;
   double maxDD = GetMaxDrawdownPercent();
   
   if(maxDD == 0.0) return 0.0;
   
   return totalReturn / maxDD;
}

//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                   |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateStandardDeviation(double returns[], int size)
{
   if(size < 2) return 0.0;
   
   double mean = 0.0;
   for(int i = 0; i < size; i++)
   {
      mean += returns[i];
   }
   mean /= size;
   
   double variance = 0.0;
   for(int i = 0; i < size; i++)
   {
      variance += MathPow(returns[i] - mean, 2);
   }
   variance /= (size - 1);
   
   return MathSqrt(variance);
}

//+------------------------------------------------------------------+
//| Calculate Downside Deviation                                   |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateDownsideDeviation(double returns[], int size)
{
   if(size < 2) return 0.0;
   
   double downsideVariance = 0.0;
   int downsideCount = 0;
   
   for(int i = 0; i < size; i++)
   {
      if(returns[i] < 0)
      {
         downsideVariance += MathPow(returns[i], 2);
         downsideCount++;
      }
   }
   
   if(downsideCount == 0) return 0.0;
   
   downsideVariance /= downsideCount;
   return MathSqrt(downsideVariance);
}

//+------------------------------------------------------------------+
//| Update Drawdown Analysis                                       |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::UpdateDrawdownAnalysis()
{
   if(m_historySize < 2) return;
   
   double currentEquity = m_equityHistory[m_historySize - 1];
   double peak = currentEquity;
   
   // Find the peak before current point
   for(int i = m_historySize - 2; i >= 0; i--)
   {
      if(m_equityHistory[i] > peak)
         peak = m_equityHistory[i];
   }
   
   double drawdown = peak - currentEquity;
   double drawdownPercent = (peak > 0) ? (drawdown / peak) * 100 : 0.0;
   
   // Update maximum drawdown
   if(drawdown > m_metrics.maxDrawdown)
   {
      m_metrics.maxDrawdown = drawdown;
      m_metrics.maxDrawdownPercent = drawdownPercent;
   }
}

//+------------------------------------------------------------------+
//| Update Streak Analysis                                         |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::UpdateStreakAnalysis(bool isWin, double profit)
{
   if(isWin)
   {
      m_streakData.currentWinStreak++;
      m_streakData.currentLossStreak = 0;
      
      if(m_streakData.currentWinStreak > m_streakData.maxWinStreak)
      {
         m_streakData.maxWinStreak = m_streakData.currentWinStreak;
         m_streakData.maxWinStreakProfit += profit;
      }
   }
   else
   {
      m_streakData.currentLossStreak++;
      m_streakData.currentWinStreak = 0;
      
      if(m_streakData.currentLossStreak > m_streakData.maxLossStreak)
      {
         m_streakData.maxLossStreak = m_streakData.currentLossStreak;
         m_streakData.maxLossStreakLoss += MathAbs(profit);
      }
   }
}

//+------------------------------------------------------------------+
//| Run Monte Carlo Simulation                                     |
//+------------------------------------------------------------------+
MonteCarloResult CPerformanceAnalytics::RunMonteCarloSimulation(int iterations, int periods)
{
   MonteCarloResult result;
   
   if(m_historySize < 10)
   {
      Print("⚠️ Insufficient data for Monte Carlo simulation");
      return result;
   }
   
   double simulationResults[];
   ArrayResize(simulationResults, iterations);
   
   // Calculate historical return statistics
   double avgReturn = 0.0;
   for(int i = 0; i < m_historySize - 1; i++)
   {
      avgReturn += m_returns[i];
   }
   avgReturn /= (m_historySize - 1);
   
   double stdDev = CalculateStandardDeviation(m_returns, m_historySize - 1);
   
   // Run simulations
   for(int sim = 0; sim < iterations; sim++)
   {
      double cumulativeReturn = 0.0;
      
      for(int period = 0; period < periods; period++)
      {
         // Generate random return using normal distribution approximation
         double randomReturn = avgReturn + stdDev * (MathRand() / 32767.0 - 0.5) * 2.0;
         cumulativeReturn += randomReturn;
      }
      
      simulationResults[sim] = cumulativeReturn;
   }
   
   // Calculate statistics
   double sumReturns = 0.0;
   for(int i = 0; i < iterations; i++)
   {
      sumReturns += simulationResults[i];
   }
   result.expectedReturn = sumReturns / iterations;
   
   // Calculate standard deviation of simulation results
   double variance = 0.0;
   for(int i = 0; i < iterations; i++)
   {
      variance += MathPow(simulationResults[i] - result.expectedReturn, 2);
   }
   result.standardDeviation = MathSqrt(variance / (iterations - 1));
   
   // Sort results for percentile calculations
   ArraySort(simulationResults);
   
   // Calculate VaR (5th percentile)
   int varIndex = (int)(iterations * 0.05);
   result.valueAtRisk = -simulationResults[varIndex];
   
   // Calculate probability of loss
   int lossCount = 0;
   for(int i = 0; i < iterations; i++)
   {
      if(simulationResults[i] < 0) lossCount++;
   }
   result.probabilityOfLoss = (double)lossCount / iterations;
   
   // Calculate confidence interval
   int ci95Index = (int)(iterations * 0.025);
   result.confidenceInterval95 = simulationResults[iterations - ci95Index] - simulationResults[ci95Index];
   
   return result;
}

//+------------------------------------------------------------------+
//| Update Metrics                                                 |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::UpdateMetrics()
{
   if(m_historySize > 0)
   {
      m_metrics.totalReturn = ((m_equityHistory[m_historySize - 1] - m_initialBalance) / m_initialBalance) * 100;
   }
   
   if(m_metrics.totalTrades > 0)
   {
      m_metrics.winRate = ((double)m_metrics.winningTrades / m_metrics.totalTrades) * 100;
   }
   
   if(m_metrics.averageLoss > 0)
   {
      m_metrics.profitFactor = m_metrics.averageWin / m_metrics.averageLoss;
   }
   
   m_metrics.sharpeRatio = CalculateSharpeRatio();
   m_metrics.sortinoRatio = CalculateSortinoRatio();
}

//+------------------------------------------------------------------+
//| Get Performance Metrics                                        |
//+------------------------------------------------------------------+
PerformanceMetrics CPerformanceAnalytics::GetPerformanceMetrics()
{
   UpdateMetrics();
   return m_metrics;
}

//+------------------------------------------------------------------+
//| Get Max Drawdown                                              |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::GetMaxDrawdown()
{
   return m_metrics.maxDrawdown;
}

//+------------------------------------------------------------------+
//| Get Max Drawdown Percent                                      |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::GetMaxDrawdownPercent()
{
   return m_metrics.maxDrawdownPercent;
}

//+------------------------------------------------------------------+
//| Get Streak Analysis                                           |
//+------------------------------------------------------------------+
StreakAnalysis CPerformanceAnalytics::GetStreakAnalysis()
{
   return m_streakData;
}

//+------------------------------------------------------------------+
//| Generate Performance Report                                    |
//+------------------------------------------------------------------+
string CPerformanceAnalytics::GeneratePerformanceReport()
{
   UpdateMetrics();
   
   string report = "=== Performance Analytics Report ===\n";
   report += "Total Return: " + DoubleToString(m_metrics.totalReturn, 2) + "%\n";
   report += "Sharpe Ratio: " + DoubleToString(m_metrics.sharpeRatio, 3) + "\n";
   report += "Sortino Ratio: " + DoubleToString(m_metrics.sortinoRatio, 3) + "\n";
   report += "Calmar Ratio: " + DoubleToString(CalculateCalmarRatio(), 3) + "\n";
   report += "Max Drawdown: " + DoubleToString(m_metrics.maxDrawdownPercent, 2) + "%\n";
   report += "Win Rate: " + DoubleToString(m_metrics.winRate, 2) + "%\n";
   report += "Profit Factor: " + DoubleToString(m_metrics.profitFactor, 2) + "\n";
   report += "Total Trades: " + IntegerToString(m_metrics.totalTrades) + "\n";
   report += "Max Win Streak: " + IntegerToString(m_streakData.maxWinStreak) + "\n";
   report += "Max Loss Streak: " + IntegerToString(m_streakData.maxLossStreak) + "\n";
   
   return report;
}

//+------------------------------------------------------------------+
//| Print Detailed Analysis                                        |
//+------------------------------------------------------------------+
void CPerformanceAnalytics::PrintDetailedAnalysis()
{
   Print("=== Detailed Performance Analysis ===");
   Print("Data Points: ", m_historySize);
   Print("Total Return: ", DoubleToString(m_metrics.totalReturn, 2), "%");
   Print("Sharpe Ratio: ", DoubleToString(m_metrics.sharpeRatio, 3));
   Print("Sortino Ratio: ", DoubleToString(m_metrics.sortinoRatio, 3));
   Print("Max Drawdown: ", DoubleToString(m_metrics.maxDrawdownPercent, 2), "%");
   Print("Win Rate: ", DoubleToString(m_metrics.winRate, 2), "%");
   Print("Profit Factor: ", DoubleToString(m_metrics.profitFactor, 2));
   Print("Average Win: ", DoubleToString(m_metrics.averageWin, 2));
   Print("Average Loss: ", DoubleToString(m_metrics.averageLoss, 2));
   Print("Current Win Streak: ", m_streakData.currentWinStreak);
   Print("Current Loss Streak: ", m_streakData.currentLossStreak);
   Print("Max Win Streak: ", m_streakData.maxWinStreak);
   Print("Max Loss Streak: ", m_streakData.maxLossStreak);
}

//+------------------------------------------------------------------+
//| Calculate VaR                                                  |
//+------------------------------------------------------------------+
double CPerformanceAnalytics::CalculateVaR(double confidenceLevel)
{
   if(m_historySize < 10) return 0.0;
   
   double sortedReturns[];
   ArrayResize(sortedReturns, m_historySize - 1);
   ArrayCopy(sortedReturns, m_returns, 0, 0, m_historySize - 1);
   ArraySort(sortedReturns);
   
   int varIndex = (int)((1.0 - confidenceLevel) * (m_historySize - 1));
   return -sortedReturns[varIndex];
}
