//+------------------------------------------------------------------+
//|                       Pattern Recognition Engine                 |
//|                    محرك التعرف على الأنماط المتقدم              |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Quantum Trading Systems"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

enum ENUM_PATTERN_TYPE
{
   PATTERN_NONE,
   PATTERN_DOUBLE_BOTTOM,
   PATTERN_DOUBLE_TOP,
   PATTERN_HEAD_SHOULDERS,
   PATTERN_INVERSE_HS,
   PATTERN_ASCENDING_TRIANGLE,
   PATTERN_DESCENDING_TRIANGLE,
   PATTERN_SYMMETRICAL_TRIANGLE,
   PATTERN_FLAG_BULLISH,
   PATTERN_FLAG_BEARISH,
   PATTERN_PENNANT,
   PATTERN_WEDGE_RISING,
   PATTERN_WEDGE_FALLING,
   PATTERN_HARMONIC_GARTLEY,
   PATTERN_HARMONIC_BUTTERFLY,
   PATTERN_HARMONIC_BAT,
   PATTERN_HARMONIC_CRAB
};

struct PatternData
{
   ENUM_PATTERN_TYPE type;
   string            symbol;
   string            description;
   double            confidence;
   bool              isBullish;
   double            entryPrice;
   double            stopPrice;
   double            targetPrice;
   datetime          detectionTime;
   bool              isActive;
   double            riskReward;
};

class CPatternRecognitionEngine
{
private:
   int               m_lookbackPeriod;
   double            m_minPatternSize;
   double            m_maxPatternSize;
   double            m_minConfidence;
   
   PatternData       m_detectedPatterns[];
   
public:
                     CPatternRecognitionEngine();
                    ~CPatternRecognitionEngine();
   
   bool              Initialize(int lookback = 200, double minSize = 0.01, double maxSize = 0.1);
   void              Deinitialize();
   
   bool              DetectPattern(string symbol, ENUM_PATTERN_TYPE patternType, PatternData &pattern);
   bool              ScanAllPatterns(string symbol, PatternData &patterns[]);
   
   bool              DetectDoubleBottom(string symbol, PatternData &pattern);
   bool              DetectDoubleTop(string symbol, PatternData &pattern);
   bool              DetectHeadAndShoulders(string symbol, PatternData &pattern);
   bool              DetectInverseHeadAndShoulders(string symbol, PatternData &pattern);
   bool              DetectAscendingTriangle(string symbol, PatternData &pattern);
   bool              DetectDescendingTriangle(string symbol, PatternData &pattern);
   bool              DetectSymmetricalTriangle(string symbol, PatternData &pattern);
   bool              DetectFlag(string symbol, PatternData &pattern);
   bool              DetectGartleyPattern(string symbol, PatternData &pattern);
   
   bool              ValidatePattern(PatternData &pattern);
   double            CalculatePatternConfidence(PatternData &pattern);
   
   string            GetPatternDescription(ENUM_PATTERN_TYPE type);
   bool              IsPatternBullish(ENUM_PATTERN_TYPE type);
   
   int               GetDetectedPatternsCount() { return ArraySize(m_detectedPatterns); }
   PatternData       GetPattern(int index) { return m_detectedPatterns[index]; }
};

CPatternRecognitionEngine::CPatternRecognitionEngine()
{
   m_lookbackPeriod = 200;
   m_minPatternSize = 0.01;
   m_maxPatternSize = 0.1;
   m_minConfidence = 60.0;
}

CPatternRecognitionEngine::~CPatternRecognitionEngine()
{
   Deinitialize();
}

bool CPatternRecognitionEngine::Initialize(int lookback = 200, double minSize = 0.01, double maxSize = 0.1)
{
   m_lookbackPeriod = lookback;
   m_minPatternSize = minSize;
   m_maxPatternSize = maxSize;
   
   ArrayResize(m_detectedPatterns, 0);
   
   return true;
}

void CPatternRecognitionEngine::Deinitialize()
{
   ArrayFree(m_detectedPatterns);
}

bool CPatternRecognitionEngine::DetectPattern(string symbol, ENUM_PATTERN_TYPE patternType, PatternData &pattern)
{
   switch(patternType)
   {
      case PATTERN_DOUBLE_BOTTOM:
         return DetectDoubleBottom(symbol, pattern);
      case PATTERN_DOUBLE_TOP:
         return DetectDoubleTop(symbol, pattern);
      case PATTERN_HEAD_SHOULDERS:
         return DetectHeadAndShoulders(symbol, pattern);
      case PATTERN_INVERSE_HS:
         return DetectInverseHeadAndShoulders(symbol, pattern);
      case PATTERN_ASCENDING_TRIANGLE:
         return DetectAscendingTriangle(symbol, pattern);
      case PATTERN_DESCENDING_TRIANGLE:
         return DetectDescendingTriangle(symbol, pattern);
      case PATTERN_SYMMETRICAL_TRIANGLE:
         return DetectSymmetricalTriangle(symbol, pattern);
      case PATTERN_FLAG_BULLISH:
      case PATTERN_FLAG_BEARISH:
         return DetectFlag(symbol, pattern);
      case PATTERN_HARMONIC_GARTLEY:
         return DetectGartleyPattern(symbol, pattern);
      default:
         return false;
   }
}

bool CPatternRecognitionEngine::ScanAllPatterns(string symbol, PatternData &patterns[])
{
   ArrayResize(patterns, 0);
   PatternData tempPattern;
   
   ENUM_PATTERN_TYPE patternTypes[] = {
      PATTERN_DOUBLE_BOTTOM, PATTERN_DOUBLE_TOP, PATTERN_HEAD_SHOULDERS,
      PATTERN_INVERSE_HS, PATTERN_ASCENDING_TRIANGLE, PATTERN_DESCENDING_TRIANGLE,
      PATTERN_SYMMETRICAL_TRIANGLE, PATTERN_FLAG_BULLISH, PATTERN_HARMONIC_GARTLEY
   };
   
   for(int i = 0; i < ArraySize(patternTypes); i++)
   {
      if(DetectPattern(symbol, patternTypes[i], tempPattern))
      {
         int size = ArraySize(patterns);
         ArrayResize(patterns, size + 1);
         patterns[size] = tempPattern;
      }
   }
   
   return ArraySize(patterns) > 0;
}

bool CPatternRecognitionEngine::DetectDoubleBottom(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int firstBottom = 50; firstBottom < m_lookbackPeriod - 50; firstBottom++)
   {
      for(int secondBottom = 10; secondBottom < firstBottom - 20; secondBottom++)
      {
         double firstLow = low[firstBottom];
         double secondLow = low[secondBottom];
         
         if(MathAbs(firstLow - secondLow) / firstLow < 0.02)
         {
            double highestHigh = high[ArrayMaximum(high, secondBottom, firstBottom - secondBottom)];
            
            if(close[0] > highestHigh)
            {
               pattern.type = PATTERN_DOUBLE_BOTTOM;
               pattern.symbol = symbol;
               pattern.description = "قاع مزدوج";
               pattern.confidence = 75.0;
               pattern.isBullish = true;
               pattern.entryPrice = highestHigh;
               pattern.stopPrice = MathMin(firstLow, secondLow) - (highestHigh - MathMin(firstLow, secondLow)) * 0.1;
               pattern.targetPrice = highestHigh + (highestHigh - MathMin(firstLow, secondLow));
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.targetPrice - pattern.entryPrice) / (pattern.entryPrice - pattern.stopPrice);
               
               return ValidatePattern(pattern);
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectDoubleTop(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int firstTop = 50; firstTop < m_lookbackPeriod - 50; firstTop++)
   {
      for(int secondTop = 10; secondTop < firstTop - 20; secondTop++)
      {
         double firstHigh = high[firstTop];
         double secondHigh = high[secondTop];
         
         if(MathAbs(firstHigh - secondHigh) / firstHigh < 0.02)
         {
            double lowestLow = low[ArrayMinimum(low, secondTop, firstTop - secondTop)];
            
            if(close[0] < lowestLow)
            {
               pattern.type = PATTERN_DOUBLE_TOP;
               pattern.symbol = symbol;
               pattern.description = "قمة مزدوجة";
               pattern.confidence = 75.0;
               pattern.isBullish = false;
               pattern.entryPrice = lowestLow;
               pattern.stopPrice = MathMax(firstHigh, secondHigh) + (MathMax(firstHigh, secondHigh) - lowestLow) * 0.1;
               pattern.targetPrice = lowestLow - (MathMax(firstHigh, secondHigh) - lowestLow);
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.entryPrice - pattern.targetPrice) / (pattern.stopPrice - pattern.entryPrice);
               
               return ValidatePattern(pattern);
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectHeadAndShoulders(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int head = 30; head < m_lookbackPeriod - 30; head++)
   {
      for(int leftShoulder = head + 15; leftShoulder < m_lookbackPeriod - 15; leftShoulder++)
      {
         for(int rightShoulder = 15; rightShoulder < head - 15; rightShoulder++)
         {
            double headHigh = high[head];
            double leftShoulderHigh = high[leftShoulder];
            double rightShoulderHigh = high[rightShoulder];
            
            if(headHigh > leftShoulderHigh && headHigh > rightShoulderHigh &&
               MathAbs(leftShoulderHigh - rightShoulderHigh) / leftShoulderHigh < 0.05)
            {
               double necklineLevel = (low[ArrayMinimum(low, rightShoulder, head - rightShoulder)] + 
                                     low[ArrayMinimum(low, head, leftShoulder - head)]) / 2;
               
               if(close[0] < necklineLevel)
               {
                  pattern.type = PATTERN_HEAD_SHOULDERS;
                  pattern.symbol = symbol;
                  pattern.description = "رأس وكتفين";
                  pattern.confidence = 80.0;
                  pattern.isBullish = false;
                  pattern.entryPrice = necklineLevel;
                  pattern.stopPrice = headHigh;
                  pattern.targetPrice = necklineLevel - (headHigh - necklineLevel);
                  pattern.detectionTime = TimeCurrent();
                  pattern.isActive = true;
                  pattern.riskReward = (pattern.entryPrice - pattern.targetPrice) / (pattern.stopPrice - pattern.entryPrice);
                  
                  return ValidatePattern(pattern);
               }
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectInverseHeadAndShoulders(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int head = 30; head < m_lookbackPeriod - 30; head++)
   {
      for(int leftShoulder = head + 15; leftShoulder < m_lookbackPeriod - 15; leftShoulder++)
      {
         for(int rightShoulder = 15; rightShoulder < head - 15; rightShoulder++)
         {
            double headLow = low[head];
            double leftShoulderLow = low[leftShoulder];
            double rightShoulderLow = low[rightShoulder];
            
            if(headLow < leftShoulderLow && headLow < rightShoulderLow &&
               MathAbs(leftShoulderLow - rightShoulderLow) / leftShoulderLow < 0.05)
            {
               double necklineLevel = (high[ArrayMaximum(high, rightShoulder, head - rightShoulder)] + 
                                     high[ArrayMaximum(high, head, leftShoulder - head)]) / 2;
               
               if(close[0] > necklineLevel)
               {
                  pattern.type = PATTERN_INVERSE_HS;
                  pattern.symbol = symbol;
                  pattern.description = "رأس وكتفين مقلوب";
                  pattern.confidence = 80.0;
                  pattern.isBullish = true;
                  pattern.entryPrice = necklineLevel;
                  pattern.stopPrice = headLow;
                  pattern.targetPrice = necklineLevel + (necklineLevel - headLow);
                  pattern.detectionTime = TimeCurrent();
                  pattern.isActive = true;
                  pattern.riskReward = (pattern.targetPrice - pattern.entryPrice) / (pattern.entryPrice - pattern.stopPrice);
                  
                  return ValidatePattern(pattern);
               }
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectAscendingTriangle(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int start = 50; start < m_lookbackPeriod - 50; start++)
   {
      double resistanceLevel = high[start];
      int touchPoints = 1;
      double lowestLow = low[start];
      int lowestIndex = start;
      
      for(int i = start - 1; i >= 10; i--)
      {
         if(MathAbs(high[i] - resistanceLevel) / resistanceLevel < 0.005)
         {
            touchPoints++;
         }
         
         if(low[i] < lowestLow)
         {
            lowestLow = low[i];
            lowestIndex = i;
         }
      }
      
      if(touchPoints >= 2 && lowestIndex < start - 10)
      {
         double supportSlope = (low[10] - lowestLow) / (lowestIndex - 10);
         
         if(supportSlope > 0)
         {
            if(close[0] > resistanceLevel)
            {
               pattern.type = PATTERN_ASCENDING_TRIANGLE;
               pattern.symbol = symbol;
               pattern.description = "مثلث صاعد";
               pattern.confidence = 70.0;
               pattern.isBullish = true;
               pattern.entryPrice = resistanceLevel;
               pattern.stopPrice = lowestLow - (resistanceLevel - lowestLow) * 0.1;
               pattern.targetPrice = resistanceLevel + (resistanceLevel - lowestLow);
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.targetPrice - pattern.entryPrice) / (pattern.entryPrice - pattern.stopPrice);
               
               return ValidatePattern(pattern);
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectDescendingTriangle(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int start = 50; start < m_lookbackPeriod - 50; start++)
   {
      double supportLevel = low[start];
      int touchPoints = 1;
      double highestHigh = high[start];
      int highestIndex = start;
      
      for(int i = start - 1; i >= 10; i--)
      {
         if(MathAbs(low[i] - supportLevel) / supportLevel < 0.005)
         {
            touchPoints++;
         }
         
         if(high[i] > highestHigh)
         {
            highestHigh = high[i];
            highestIndex = i;
         }
      }
      
      if(touchPoints >= 2 && highestIndex < start - 10)
      {
         double resistanceSlope = (high[10] - highestHigh) / (highestIndex - 10);
         
         if(resistanceSlope < 0)
         {
            if(close[0] < supportLevel)
            {
               pattern.type = PATTERN_DESCENDING_TRIANGLE;
               pattern.symbol = symbol;
               pattern.description = "مثلث هابط";
               pattern.confidence = 70.0;
               pattern.isBullish = false;
               pattern.entryPrice = supportLevel;
               pattern.stopPrice = highestHigh + (highestHigh - supportLevel) * 0.1;
               pattern.targetPrice = supportLevel - (highestHigh - supportLevel);
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.entryPrice - pattern.targetPrice) / (pattern.stopPrice - pattern.entryPrice);
               
               return ValidatePattern(pattern);
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectSymmetricalTriangle(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int start = 50; start < m_lookbackPeriod - 50; start++)
   {
      double upperTrendSlope = 0;
      double lowerTrendSlope = 0;
      int upperTouchPoints = 0;
      int lowerTouchPoints = 0;
      
      for(int i = start - 1; i >= 10; i--)
      {
         if(i == start - 1)
         {
            upperTrendSlope = (high[10] - high[start]) / (start - 10);
            lowerTrendSlope = (low[10] - low[start]) / (start - 10);
         }
         
         double expectedUpper = high[start] + upperTrendSlope * (start - i);
         double expectedLower = low[start] + lowerTrendSlope * (start - i);
         
         if(MathAbs(high[i] - expectedUpper) / expectedUpper < 0.01)
            upperTouchPoints++;
         if(MathAbs(low[i] - expectedLower) / expectedLower < 0.01)
            lowerTouchPoints++;
      }
      
      if(upperTouchPoints >= 2 && lowerTouchPoints >= 2 && 
         upperTrendSlope < 0 && lowerTrendSlope > 0)
      {
         double convergencePoint = (high[start] + low[start]) / 2;
         
         if(MathAbs(close[0] - convergencePoint) / convergencePoint > 0.01)
         {
            pattern.type = PATTERN_SYMMETRICAL_TRIANGLE;
            pattern.symbol = symbol;
            pattern.description = "مثلث متماثل";
            pattern.confidence = 65.0;
            pattern.isBullish = close[0] > convergencePoint;
            pattern.entryPrice = close[0];
            
            if(pattern.isBullish)
            {
               pattern.stopPrice = low[start];
               pattern.targetPrice = close[0] + (high[start] - low[start]);
            }
            else
            {
               pattern.stopPrice = high[start];
               pattern.targetPrice = close[0] - (high[start] - low[start]);
            }
            
            pattern.detectionTime = TimeCurrent();
            pattern.isActive = true;
            pattern.riskReward = MathAbs(pattern.targetPrice - pattern.entryPrice) / MathAbs(pattern.stopPrice - pattern.entryPrice);
            
            return ValidatePattern(pattern);
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectFlag(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, 100, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, 100, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, 100, close);
   CopyTickVolume(symbol, PERIOD_CURRENT, 0, 100, volume);
   
   for(int poleStart = 20; poleStart < 80; poleStart++)
   {
      double poleHeight = MathAbs(close[poleStart] - close[poleStart + 10]);
      double priceRange = close[poleStart + 10];
      
      if(poleHeight / priceRange > 0.03)
      {
         bool isBullishPole = close[poleStart] > close[poleStart + 10];
         
         double flagHigh = 0, flagLow = 999999;
         
         for(int i = poleStart - 1; i >= poleStart - 15 && i >= 0; i--)
         {
            if(high[i] > flagHigh) flagHigh = high[i];
            if(low[i] < flagLow) flagLow = low[i];
         }
         
         double flagHeight = flagHigh - flagLow;
         
         if(flagHeight / poleHeight < 0.5)
         {
            if(isBullishPole && close[0] > flagHigh)
            {
               pattern.type = PATTERN_FLAG_BULLISH;
               pattern.symbol = symbol;
               pattern.description = "علم صاعد";
               pattern.confidence = 75.0;
               pattern.isBullish = true;
               pattern.entryPrice = flagHigh;
               pattern.stopPrice = flagLow;
               pattern.targetPrice = flagHigh + poleHeight;
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.targetPrice - pattern.entryPrice) / (pattern.entryPrice - pattern.stopPrice);
               
               return ValidatePattern(pattern);
            }
            else if(!isBullishPole && close[0] < flagLow)
            {
               pattern.type = PATTERN_FLAG_BEARISH;
               pattern.symbol = symbol;
               pattern.description = "علم هابط";
               pattern.confidence = 75.0;
               pattern.isBullish = false;
               pattern.entryPrice = flagLow;
               pattern.stopPrice = flagHigh;
               pattern.targetPrice = flagLow - poleHeight;
               pattern.detectionTime = TimeCurrent();
               pattern.isActive = true;
               pattern.riskReward = (pattern.entryPrice - pattern.targetPrice) / (pattern.stopPrice - pattern.entryPrice);
               
               return ValidatePattern(pattern);
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::DetectGartleyPattern(string symbol, PatternData &pattern)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   CopyHigh(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, high);
   CopyLow(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, low);
   CopyClose(symbol, PERIOD_CURRENT, 0, m_lookbackPeriod, close);
   
   for(int X = 80; X < m_lookbackPeriod - 20; X++)
   {
      for(int A = 60; A < X - 10; A++)
      {
         for(int B = 40; B < A - 10; B++)
         {
            for(int C = 20; C < B - 10; C++)
            {
               int D = 0;
               
               double XA = MathAbs(close[X] - close[A]);
               double AB = MathAbs(close[A] - close[B]);
               double BC = MathAbs(close[B] - close[C]);
               double CD = MathAbs(close[C] - close[D]);
               
               double AB_XA = AB / XA;
               double BC_AB = BC / AB;
               double CD_BC = CD / BC;
               double AD_XA = MathAbs(close[A] - close[D]) / XA;
               
               if(MathAbs(AB_XA - 0.618) < 0.05 &&
                  MathAbs(BC_AB - 0.382) < 0.05 &&
                  MathAbs(CD_BC - 1.272) < 0.1 &&
                  MathAbs(AD_XA - 0.786) < 0.05)
               {
                  bool isBullish = close[X] > close[A];
                  
                  pattern.type = PATTERN_HARMONIC_GARTLEY;
                  pattern.symbol = symbol;
                  pattern.description = "جارتلي هارمونيكي";
                  pattern.confidence = 85.0;
                  pattern.isBullish = isBullish;
                  pattern.entryPrice = close[D];
                  
                  if(isBullish)
                  {
                     pattern.stopPrice = close[D] - XA * 0.1;
                     pattern.targetPrice = close[D] + BC * 0.618;
                  }
                  else
                  {
                     pattern.stopPrice = close[D] + XA * 0.1;
                     pattern.targetPrice = close[D] - BC * 0.618;
                  }
                  
                  pattern.detectionTime = TimeCurrent();
                  pattern.isActive = true;
                  pattern.riskReward = MathAbs(pattern.targetPrice - pattern.entryPrice) / MathAbs(pattern.stopPrice - pattern.entryPrice);
                  
                  return ValidatePattern(pattern);
               }
            }
         }
      }
   }
   
   return false;
}

bool CPatternRecognitionEngine::ValidatePattern(PatternData &pattern)
{
   if(pattern.riskReward < 1.5)
   {
      return false;
   }
   
   double patternSize = MathAbs(pattern.targetPrice - pattern.entryPrice) / pattern.entryPrice;
   if(patternSize < m_minPatternSize || patternSize > m_maxPatternSize)
   {
      return false;
   }
   
   pattern.confidence = CalculatePatternConfidence(pattern);
   
   return pattern.confidence > 60.0;
}

double CPatternRecognitionEngine::CalculatePatternConfidence(PatternData &pattern)
{
   double confidence = pattern.confidence;
   
   if(pattern.riskReward > 3.0)
   {
      confidence += 10;
   }
   else if(pattern.riskReward > 2.0)
   {
      confidence += 5;
   }
   
   double patternSize = MathAbs(pattern.targetPrice - pattern.entryPrice) / pattern.entryPrice;
   if(patternSize > 0.02 && patternSize < 0.05)
   {
      confidence += 5;
   }
   
   return MathMin(confidence, 95.0);
}

string CPatternRecognitionEngine::GetPatternDescription(ENUM_PATTERN_TYPE type)
{
   switch(type)
   {
      case PATTERN_DOUBLE_BOTTOM: return "قاع مزدوج";
      case PATTERN_DOUBLE_TOP: return "قمة مزدوجة";
      case PATTERN_HEAD_SHOULDERS: return "رأس وكتفين";
      case PATTERN_INVERSE_HS: return "رأس وكتفين مقلوب";
      case PATTERN_ASCENDING_TRIANGLE: return "مثلث صاعد";
      case PATTERN_DESCENDING_TRIANGLE: return "مثلث هابط";
      case PATTERN_SYMMETRICAL_TRIANGLE: return "مثلث متماثل";
      case PATTERN_FLAG_BULLISH: return "علم صاعد";
      case PATTERN_FLAG_BEARISH: return "علم هابط";
      case PATTERN_PENNANT: return "راية";
      case PATTERN_WEDGE_RISING: return "إسفين صاعد";
      case PATTERN_WEDGE_FALLING: return "إسفين هابط";
      case PATTERN_HARMONIC_GARTLEY: return "جارتلي هارمونيكي";
      case PATTERN_HARMONIC_BUTTERFLY: return "فراشة هارمونيكية";
      case PATTERN_HARMONIC_BAT: return "خفاش هارمونيكي";
      case PATTERN_HARMONIC_CRAB: return "سرطان هارمونيكي";
      default: return "نمط غير معروف";
   }
}

bool CPatternRecognitionEngine::IsPatternBullish(ENUM_PATTERN_TYPE type)
{
   switch(type)
   {
      case PATTERN_DOUBLE_BOTTOM:
      case PATTERN_INVERSE_HS:
      case PATTERN_ASCENDING_TRIANGLE:
      case PATTERN_FLAG_BULLISH:
      case PATTERN_WEDGE_FALLING:
         return true;
         
      case PATTERN_DOUBLE_TOP:
      case PATTERN_HEAD_SHOULDERS:
      case PATTERN_DESCENDING_TRIANGLE:
      case PATTERN_FLAG_BEARISH:
      case PATTERN_WEDGE_RISING:
         return false;
         
      default:
         return true;
   }
}
