//+------------------------------------------------------------------+
//|                          Pattern Recognition Engine              |
//|                     محرك التعرف على الأنماط المتقدم              |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Quantum Trading Systems"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

enum ENUM_PATTERN_TYPE
{
   PATTERN_DOUBLE_BOTTOM,
   PATTERN_DOUBLE_TOP,
   PATTERN_HEAD_AND_SHOULDERS,
   PATTERN_INVERSE_HEAD_AND_SHOULDERS,
   PATTERN_ASCENDING_TRIANGLE,
   PATTERN_DESCENDING_TRIANGLE,
   PATTERN_SYMMETRICAL_TRIANGLE,
   PATTERN_GARTLEY,
   PATTERN_BUTTERFLY,
   PATTERN_BAT,
   PATTERN_CRAB
};

enum ENUM_TRIANGLE_TYPE
{
   TRIANGLE_ASCENDING,
   TRIANGLE_DESCENDING,
   TRIANGLE_SYMMETRICAL
};

struct PatternData
{
   string            patternName;
   double            confidence;
   double            entryPrice;
   double            stopLoss;
   double            takeProfit;
   datetime          detectedTime;
   int               direction;
   string            description;
   double            accuracy;
   bool              isValid;
};

struct PatternStrength
{
   double            accuracy;
   double            completion;
   double            volume_confirm;
   double            time_symmetry;
   
   double GetOverallScore()
   {
      return accuracy * 0.4 + completion * 0.3 + 
             volume_confirm * 0.2 + time_symmetry * 0.1;
   }
};

struct PatternRecord
{
   string            pattern_type;
   datetime          detected_time;
   double            entry_price;
   double            target_price;
   double            stop_price;
   bool              hit_target;
   double            actual_profit;
   double            success_rate;
};

struct GartleyPattern
{
   double            XA, AB, BC, CD;
   double            XA_ratio;
   double            AB_ratio;
   double            BC_ratio_min;
   double            BC_ratio_max;
   double            CD_ratio_min;
   double            CD_ratio_max;
   
   void Initialize()
   {
      XA_ratio = 0.618;
      AB_ratio = 0.786;
      BC_ratio_min = 0.382;
      BC_ratio_max = 0.886;
      CD_ratio_min = 1.13;
      CD_ratio_max = 1.618;
   }
};

struct ButterflyPattern
{
   double            XA, AB, BC, CD;
   double            XA_ratio;
   double            AB_ratio;
   double            BC_ratio_min;
   double            BC_ratio_max;
   double            CD_ratio_min;
   double            CD_ratio_max;
   
   void Initialize()
   {
      XA_ratio = 0.786;
      AB_ratio = 0.786;
      BC_ratio_min = 0.382;
      BC_ratio_max = 0.886;
      CD_ratio_min = 1.618;
      CD_ratio_max = 2.618;
   }
};

class CHarmonicPatterns
{
private:
   double            m_tolerance;
   
public:
                     CHarmonicPatterns() { m_tolerance = 0.05; }
                    ~CHarmonicPatterns() {}
   
   bool              DetectGartley(double &prices[], int &points[], PatternData &pattern);
   bool              DetectButterfly(double &prices[], int &points[], PatternData &pattern);
   double            CalculateFibonacciRatio(double point1, double point2, double point3);
   bool              ValidateRatio(double actual, double expected, double tolerance = 0.05);
   bool              ValidatePatternSize(double &prices[], int &points[]);
   bool              ValidateTimeSymmetry(int &points[]);
};

class CChartPatterns
{
private:
   int               m_lookbackPeriod;
   
public:
                     CChartPatterns() { m_lookbackPeriod = 100; }
                    ~CChartPatterns() {}
   
   bool              DetectHeadAndShoulders(double &highs[], double &lows[], PatternData &pattern);
   bool              DetectDoubleTop(double &highs[], double &lows[], PatternData &pattern);
   bool              DetectDoubleBottom(double &highs[], double &lows[], PatternData &pattern);
   bool              DetectTriangle(ENUM_TRIANGLE_TYPE type, double &highs[], double &lows[], PatternData &pattern);
   
   bool              FindPeaksAndValleys(double &prices[], int &peaks[], int &valleys[]);
   double            CalculateNeckline(double &highs[], double &lows[], int leftShoulder, int head, int rightShoulder);
   bool              ValidateSymmetry(double &prices[], int &points[]);
};

class CPatternDatabase
{
private:
   PatternRecord     m_records[];
   string            m_filename;
   
public:
                     CPatternDatabase();
                    ~CPatternDatabase();
   
   bool              Initialize(string filename = "pattern_database.csv");
   void              SavePattern(PatternRecord &record);
   double            GetPatternSuccessRate(string pattern_type);
   bool              LoadFromFile();
   bool              SaveToFile();
   void              UpdatePatternOutcome(datetime detected_time, bool success, double profit);
};

class CPatternRecognitionEngine
{
private:
   CHarmonicPatterns m_harmonicPatterns;
   CChartPatterns    m_chartPatterns;
   CPatternDatabase  m_database;
   
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_isInitialized;
   
   double            m_priceData[];
   double            m_highs[];
   double            m_lows[];
   double            m_volumes[];
   
public:
                     CPatternRecognitionEngine();
                    ~CPatternRecognitionEngine();
   
   bool              Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   bool              DetectPattern(string symbol, ENUM_PATTERN_TYPE patternType, PatternData &pattern);
   bool              ScanAllPatterns(string symbol, PatternData &patterns[]);
   
   PatternStrength   EvaluatePatternStrength(PatternData &pattern);
   bool              UpdatePriceData(string symbol);
   
   double            GetPatternConfidence(ENUM_PATTERN_TYPE patternType, string symbol);
   bool              IsPatternValid(PatternData &pattern);
   
   string            GeneratePatternReport(string symbol);
};

bool CHarmonicPatterns::DetectGartley(double &prices[], int &points[], PatternData &pattern)
{
   if(ArraySize(points) < 5) return false;
   
   int X = points[0];
   int A = points[1]; 
   int B = points[2];
   int C = points[3];
   int D = points[4];
   
   double XA = MathAbs(prices[A] - prices[X]);
   double AB = MathAbs(prices[B] - prices[A]);
   double BC = MathAbs(prices[C] - prices[B]);
   double CD = MathAbs(prices[D] - prices[C]);
   
   if(XA < Point() || AB < Point()) return false;
   
   double AB_XA_ratio = AB / XA;
   double BC_AB_ratio = BC / AB;
   double CD_BC_ratio = CD / BC;
   
   if(!ValidateRatio(AB_XA_ratio, 0.618, m_tolerance)) return false;
   if(BC_AB_ratio < 0.382 || BC_AB_ratio > 0.886) return false;
   if(CD_BC_ratio < 1.13 || CD_BC_ratio > 1.618) return false;
   
   if(!ValidatePatternSize(prices, points)) return false;
   if(!ValidateTimeSymmetry(points)) return false;
   
   pattern.patternName = "Gartley";
   pattern.confidence = 75.0 + (ValidateRatio(AB_XA_ratio, 0.618, 0.02) ? 15.0 : 0.0);
   pattern.entryPrice = prices[D];
   pattern.direction = (prices[D] > prices[C]) ? -1 : 1;
   pattern.stopLoss = prices[D] + (pattern.direction * XA * 0.236);
   pattern.takeProfit = prices[D] - (pattern.direction * XA * 0.618);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

bool CHarmonicPatterns::DetectButterfly(double &prices[], int &points[], PatternData &pattern)
{
   if(ArraySize(points) < 5) return false;
   
   int X = points[0];
   int A = points[1];
   int B = points[2]; 
   int C = points[3];
   int D = points[4];
   
   double XA = MathAbs(prices[A] - prices[X]);
   double AB = MathAbs(prices[B] - prices[A]);
   double BC = MathAbs(prices[C] - prices[B]);
   double CD = MathAbs(prices[D] - prices[C]);
   
   if(XA < Point() || AB < Point()) return false;
   
   double AB_XA_ratio = AB / XA;
   double BC_AB_ratio = BC / AB;
   double CD_BC_ratio = CD / BC;
   
   if(!ValidateRatio(AB_XA_ratio, 0.786, m_tolerance)) return false;
   if(BC_AB_ratio < 0.382 || BC_AB_ratio > 0.886) return false;
   if(CD_BC_ratio < 1.618 || CD_BC_ratio > 2.618) return false;
   
   if(!ValidatePatternSize(prices, points)) return false;
   if(!ValidateTimeSymmetry(points)) return false;
   
   pattern.patternName = "Butterfly";
   pattern.confidence = 70.0 + (ValidateRatio(AB_XA_ratio, 0.786, 0.02) ? 20.0 : 0.0);
   pattern.entryPrice = prices[D];
   pattern.direction = (prices[D] > prices[C]) ? -1 : 1;
   pattern.stopLoss = prices[D] + (pattern.direction * XA * 0.382);
   pattern.takeProfit = prices[D] - (pattern.direction * XA * 0.786);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

double CHarmonicPatterns::CalculateFibonacciRatio(double point1, double point2, double point3)
{
   if(MathAbs(point2 - point1) < Point()) return 0;
   
   double ratio = MathAbs(point3 - point2) / MathAbs(point2 - point1);
   
   double tolerance = 0.05;
   
   if(MathAbs(ratio - 0.618) < tolerance) return 0.618;
   if(MathAbs(ratio - 0.786) < tolerance) return 0.786;
   if(MathAbs(ratio - 1.272) < tolerance) return 1.272;
   if(MathAbs(ratio - 1.618) < tolerance) return 1.618;
   if(MathAbs(ratio - 0.382) < tolerance) return 0.382;
   if(MathAbs(ratio - 0.236) < tolerance) return 0.236;
   
   return ratio;
}

bool CHarmonicPatterns::ValidateRatio(double actual, double expected, double tolerance = 0.05)
{
   return MathAbs(actual - expected) <= tolerance;
}

bool CHarmonicPatterns::ValidatePatternSize(double &prices[], int &points[])
{
   if(ArraySize(points) < 2) return false;
   
   double range = MathAbs(prices[points[ArraySize(points)-1]] - prices[points[0]]);
   double avgPrice = (prices[points[ArraySize(points)-1]] + prices[points[0]]) / 2.0;
   
   double minSize = avgPrice * 0.001;
   double maxSize = avgPrice * 0.1;
   
   return (range >= minSize && range <= maxSize);
}

bool CHarmonicPatterns::ValidateTimeSymmetry(int &points[])
{
   if(ArraySize(points) < 5) return false;
   
   int timeSpan1 = points[2] - points[0];
   int timeSpan2 = points[4] - points[2];
   
   double ratio = (double)timeSpan2 / (double)timeSpan1;
   
   return (ratio >= 0.5 && ratio <= 2.0);
}

bool CChartPatterns::DetectHeadAndShoulders(double &highs[], double &lows[], PatternData &pattern)
{
   int peaks[];
   int valleys[];
   
   if(!FindPeaksAndValleys(highs, peaks, valleys)) return false;
   if(ArraySize(peaks) < 3) return false;
   
   int leftShoulder = peaks[0];
   int head = peaks[1];
   int rightShoulder = peaks[2];
   
   if(highs[head] <= highs[leftShoulder] || highs[head] <= highs[rightShoulder]) return false;
   
   double shoulderDiff = MathAbs(highs[leftShoulder] - highs[rightShoulder]);
   double avgShoulder = (highs[leftShoulder] + highs[rightShoulder]) / 2.0;
   
   if(shoulderDiff > avgShoulder * 0.02) return false;
   
   double neckline = CalculateNeckline(highs, lows, leftShoulder, head, rightShoulder);
   
   pattern.patternName = "Head and Shoulders";
   pattern.confidence = 80.0;
   pattern.entryPrice = neckline;
   pattern.direction = -1;
   pattern.stopLoss = highs[head];
   pattern.takeProfit = neckline - (highs[head] - neckline);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

bool CChartPatterns::DetectDoubleTop(double &highs[], double &lows[], PatternData &pattern)
{
   int peaks[];
   int valleys[];
   
   if(!FindPeaksAndValleys(highs, peaks, valleys)) return false;
   if(ArraySize(peaks) < 2) return false;
   
   int firstPeak = peaks[0];
   int secondPeak = peaks[1];
   
   double peakDiff = MathAbs(highs[firstPeak] - highs[secondPeak]);
   double avgPeak = (highs[firstPeak] + highs[secondPeak]) / 2.0;
   
   if(peakDiff > avgPeak * 0.02) return false;
   
   int valleyBetween = -1;
   for(int i = 0; i < ArraySize(valleys); i++)
   {
      if(valleys[i] > firstPeak && valleys[i] < secondPeak)
      {
         valleyBetween = valleys[i];
         break;
      }
   }
   
   if(valleyBetween == -1) return false;
   
   pattern.patternName = "Double Top";
   pattern.confidence = 75.0;
   pattern.entryPrice = lows[valleyBetween];
   pattern.direction = -1;
   pattern.stopLoss = MathMax(highs[firstPeak], highs[secondPeak]);
   pattern.takeProfit = lows[valleyBetween] - (avgPeak - lows[valleyBetween]);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

bool CChartPatterns::DetectDoubleBottom(double &highs[], double &lows[], PatternData &pattern)
{
   int peaks[];
   int valleys[];
   
   if(!FindPeaksAndValleys(lows, valleys, peaks)) return false;
   if(ArraySize(valleys) < 2) return false;
   
   int firstBottom = valleys[0];
   int secondBottom = valleys[1];
   
   double bottomDiff = MathAbs(lows[firstBottom] - lows[secondBottom]);
   double avgBottom = (lows[firstBottom] + lows[secondBottom]) / 2.0;
   
   if(bottomDiff > avgBottom * 0.02) return false;
   
   int peakBetween = -1;
   for(int i = 0; i < ArraySize(peaks); i++)
   {
      if(peaks[i] > firstBottom && peaks[i] < secondBottom)
      {
         peakBetween = peaks[i];
         break;
      }
   }
   
   if(peakBetween == -1) return false;
   
   pattern.patternName = "Double Bottom";
   pattern.confidence = 75.0;
   pattern.entryPrice = highs[peakBetween];
   pattern.direction = 1;
   pattern.stopLoss = MathMin(lows[firstBottom], lows[secondBottom]);
   pattern.takeProfit = highs[peakBetween] + (highs[peakBetween] - avgBottom);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

bool CChartPatterns::DetectTriangle(ENUM_TRIANGLE_TYPE type, double &highs[], double &lows[], PatternData &pattern)
{
   int peaks[];
   int valleys[];
   
   if(!FindPeaksAndValleys(highs, peaks, valleys)) return false;
   if(ArraySize(peaks) < 2 || ArraySize(valleys) < 2) return false;
   
   double upperTrendSlope = 0, lowerTrendSlope = 0;
   bool validPattern = false;
   
   if(ArraySize(peaks) >= 2)
   {
      upperTrendSlope = (highs[peaks[1]] - highs[peaks[0]]) / (peaks[1] - peaks[0]);
   }
   
   if(ArraySize(valleys) >= 2)
   {
      lowerTrendSlope = (lows[valleys[1]] - lows[valleys[0]]) / (valleys[1] - valleys[0]);
   }
   
   switch(type)
   {
      case TRIANGLE_ASCENDING:
         validPattern = (MathAbs(upperTrendSlope) < 0.0001 && lowerTrendSlope > 0);
         pattern.patternName = "Ascending Triangle";
         pattern.direction = 1;
         break;
         
      case TRIANGLE_DESCENDING:
         validPattern = (upperTrendSlope < 0 && MathAbs(lowerTrendSlope) < 0.0001);
         pattern.patternName = "Descending Triangle";
         pattern.direction = -1;
         break;
         
      case TRIANGLE_SYMMETRICAL:
         validPattern = (upperTrendSlope < 0 && lowerTrendSlope > 0);
         pattern.patternName = "Symmetrical Triangle";
         pattern.direction = 0;
         break;
   }
   
   if(!validPattern) return false;
   
   double convergencePoint = highs[peaks[ArraySize(peaks)-1]];
   double range = MathAbs(highs[peaks[0]] - lows[valleys[0]]);
   
   pattern.confidence = 70.0;
   pattern.entryPrice = convergencePoint;
   pattern.stopLoss = convergencePoint - (pattern.direction * range * 0.5);
   pattern.takeProfit = convergencePoint + (pattern.direction * range * 1.0);
   pattern.detectedTime = TimeCurrent();
   pattern.isValid = true;
   
   return true;
}

bool CChartPatterns::FindPeaksAndValleys(double &prices[], int &peaks[], int &valleys[])
{
   ArrayResize(peaks, 0);
   ArrayResize(valleys, 0);
   
   int priceSize = ArraySize(prices);
   if(priceSize < 5) return false;
   
   for(int i = 2; i < priceSize - 2; i++)
   {
      if(prices[i] > prices[i-1] && prices[i] > prices[i+1] && 
         prices[i] > prices[i-2] && prices[i] > prices[i+2])
      {
         int size = ArraySize(peaks);
         ArrayResize(peaks, size + 1);
         peaks[size] = i;
      }
      
      if(prices[i] < prices[i-1] && prices[i] < prices[i+1] && 
         prices[i] < prices[i-2] && prices[i] < prices[i+2])
      {
         int size = ArraySize(valleys);
         ArrayResize(valleys, size + 1);
         valleys[size] = i;
      }
   }
   
   return (ArraySize(peaks) > 0 || ArraySize(valleys) > 0);
}

double CChartPatterns::CalculateNeckline(double &highs[], double &lows[], int leftShoulder, int head, int rightShoulder)
{
   int leftValley = -1, rightValley = -1;
   
   for(int i = leftShoulder; i < head; i++)
   {
      if(leftValley == -1 || lows[i] < lows[leftValley])
         leftValley = i;
   }
   
   for(int i = head; i < rightShoulder; i++)
   {
      if(rightValley == -1 || lows[i] < lows[rightValley])
         rightValley = i;
   }
   
   if(leftValley == -1 || rightValley == -1)
      return (lows[leftShoulder] + lows[rightShoulder]) / 2.0;
   
   return (lows[leftValley] + lows[rightValley]) / 2.0;
}

bool CChartPatterns::ValidateSymmetry(double &prices[], int &points[])
{
   if(ArraySize(points) < 3) return false;
   
   double leftRange = MathAbs(prices[points[1]] - prices[points[0]]);
   double rightRange = MathAbs(prices[points[2]] - prices[points[1]]);
   
   if(leftRange < Point() || rightRange < Point()) return false;
   
   double ratio = rightRange / leftRange;
   return (ratio >= 0.7 && ratio <= 1.3);
}

CPatternDatabase::CPatternDatabase()
{
   m_filename = "pattern_database.csv";
}

CPatternDatabase::~CPatternDatabase()
{
}

bool CPatternDatabase::Initialize(string filename = "pattern_database.csv")
{
   m_filename = filename;
   return LoadFromFile();
}

void CPatternDatabase::SavePattern(PatternRecord &record)
{
   int size = ArraySize(m_records);
   ArrayResize(m_records, size + 1);
   m_records[size] = record;
   
   SaveToFile();
}

double CPatternDatabase::GetPatternSuccessRate(string pattern_type)
{
   int totalCount = 0;
   int successCount = 0;
   
   for(int i = 0; i < ArraySize(m_records); i++)
   {
      if(m_records[i].pattern_type == pattern_type)
      {
         totalCount++;
         if(m_records[i].hit_target)
            successCount++;
      }
   }
   
   if(totalCount == 0) return 50.0;
   
   return (double)successCount / (double)totalCount * 100.0;
}

bool CPatternDatabase::LoadFromFile()
{
   return true;
}

bool CPatternDatabase::SaveToFile()
{
   return true;
}

void CPatternDatabase::UpdatePatternOutcome(datetime detected_time, bool success, double profit)
{
   for(int i = 0; i < ArraySize(m_records); i++)
   {
      if(m_records[i].detected_time == detected_time)
      {
         m_records[i].hit_target = success;
         m_records[i].actual_profit = profit;
         break;
      }
   }
   
   SaveToFile();
}

CPatternRecognitionEngine::CPatternRecognitionEngine()
{
   m_isInitialized = false;
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
}

CPatternRecognitionEngine::~CPatternRecognitionEngine()
{
   Deinitialize();
}

bool CPatternRecognitionEngine::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   
   if(!m_database.Initialize())
   {
      Print("❌ فشلت تهيئة قاعدة بيانات الأنماط!");
      return false;
   }
   
   m_isInitialized = true;
   Print("✅ تم تهيئة محرك التعرف على الأنماط بنجاح");
   
   return true;
}

void CPatternRecognitionEngine::Deinitialize()
{
   m_isInitialized = false;
   ArrayFree(m_priceData);
   ArrayFree(m_highs);
   ArrayFree(m_lows);
   ArrayFree(m_volumes);
}

bool CPatternRecognitionEngine::DetectPattern(string symbol, ENUM_PATTERN_TYPE patternType, PatternData &pattern)
{
   if(!m_isInitialized) return false;
   
   if(!UpdatePriceData(symbol)) return false;
   
   switch(patternType)
   {
      case PATTERN_DOUBLE_BOTTOM:
         return m_chartPatterns.DetectDoubleBottom(m_highs, m_lows, pattern);
         
      case PATTERN_DOUBLE_TOP:
         return m_chartPatterns.DetectDoubleTop(m_highs, m_lows, pattern);
         
      case PATTERN_HEAD_AND_SHOULDERS:
         return m_chartPatterns.DetectHeadAndShoulders(m_highs, m_lows, pattern);
         
      case PATTERN_GARTLEY:
         {
            int points[] = {0, 20, 40, 60, 80};
            return m_harmonicPatterns.DetectGartley(m_priceData, points, pattern);
         }
         
      case PATTERN_BUTTERFLY:
         {
            int points[] = {0, 20, 40, 60, 80};
            return m_harmonicPatterns.DetectButterfly(m_priceData, points, pattern);
         }
         
      default:
         return false;
   }
}

bool CPatternRecognitionEngine::ScanAllPatterns(string symbol, PatternData &patterns[])
{
   ArrayResize(patterns, 0);
   
   ENUM_PATTERN_TYPE patternTypes[] = {
      PATTERN_DOUBLE_BOTTOM,
      PATTERN_DOUBLE_TOP,
      PATTERN_HEAD_AND_SHOULDERS,
      PATTERN_GARTLEY,
      PATTERN_BUTTERFLY
   };
   
   for(int i = 0; i < ArraySize(patternTypes); i++)
   {
      PatternData pattern;
      if(DetectPattern(symbol, patternTypes[i], pattern))
      {
         int size = ArraySize(patterns);
         ArrayResize(patterns, size + 1);
         patterns[size] = pattern;
      }
   }
   
   return ArraySize(patterns) > 0;
}

PatternStrength CPatternRecognitionEngine::EvaluatePatternStrength(PatternData &pattern)
{
   PatternStrength strength;
   
   strength.accuracy = m_database.GetPatternSuccessRate(pattern.patternName);
   strength.completion = pattern.confidence;
   strength.volume_confirm = 70.0;
   strength.time_symmetry = 80.0;
   
   return strength;
}

bool CPatternRecognitionEngine::UpdatePriceData(string symbol)
{
   ArraySetAsSeries(m_priceData, true);
   ArraySetAsSeries(m_highs, true);
   ArraySetAsSeries(m_lows, true);
   ArraySetAsSeries(m_volumes, true);
   
   if(CopyClose(symbol, m_timeframe, 0, 100, m_priceData) <= 0) return false;
   if(CopyHigh(symbol, m_timeframe, 0, 100, m_highs) <= 0) return false;
   if(CopyLow(symbol, m_timeframe, 0, 100, m_lows) <= 0) return false;
   if(CopyTickVolume(symbol, m_timeframe, 0, 100, m_volumes) <= 0) return false;
   
   return true;
}

double CPatternRecognitionEngine::GetPatternConfidence(ENUM_PATTERN_TYPE patternType, string symbol)
{
   PatternData pattern;
   if(DetectPattern(symbol, patternType, pattern))
   {
      PatternStrength strength = EvaluatePatternStrength(pattern);
      return strength.GetOverallScore();
   }
   
   return 0.0;
}

bool CPatternRecognitionEngine::IsPatternValid(PatternData &pattern)
{
   if(pattern.confidence < 60.0) return false;
   if(MathAbs(pattern.entryPrice - pattern.stopLoss) < 5 * Point()) return false;
   if(MathAbs(pattern.takeProfit - pattern.entryPrice) < 10 * Point()) return false;
   
   return pattern.isValid;
}

string CPatternRecognitionEngine::GeneratePatternReport(string symbol)
{
   string report = "تقرير الأنماط - " + symbol + "\n";
   report += "═══════════════════════════════════\n";
   
   PatternData patterns[];
   if(ScanAllPatterns(symbol, patterns))
   {
      for(int i = 0; i < ArraySize(patterns); i++)
      {
         report += "🔍 النمط: " + patterns[i].patternName + "\n";
         report += "📊 الثقة: " + DoubleToString(patterns[i].confidence, 1) + "%\n";
         report += "💰 سعر الدخول: " + DoubleToString(patterns[i].entryPrice, 5) + "\n";
         report += "🛑 وقف الخسارة: " + DoubleToString(patterns[i].stopLoss, 5) + "\n";
         report += "🎯 الهدف: " + DoubleToString(patterns[i].takeProfit, 5) + "\n";
         report += "───────────────────────────────────\n";
      }
   }
   else
   {
      report += "❌ لم يتم العثور على أنماط صالحة\n";
   }
   
   return report;
}
