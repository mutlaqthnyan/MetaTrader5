//+------------------------------------------------------------------+
//|                                           Forex_Session_Manager.mqh |
//|                                  Copyright 2024, Quantum Trading Systems |
//|                                             https://quantumelite.trading |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Trading Session Enumeration                                     |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SESSION
{
   SESSION_ASIAN,      // الجلسة الآسيوية
   SESSION_LONDON,     // جلسة لندن
   SESSION_NY,         // جلسة نيويورك
   SESSION_SYDNEY,     // جلسة سيدني
   SESSION_OVERLAP_LONDON_NY,    // تداخل لندن-نيويورك
   SESSION_OVERLAP_ASIAN_LONDON, // تداخل آسيا-لندن
   SESSION_NONE        // لا توجد جلسة نشطة
};

//+------------------------------------------------------------------+
//| Session Information Structure                                   |
//+------------------------------------------------------------------+
struct SessionInfo
{
   ENUM_TRADING_SESSION sessionType;  // نوع الجلسة
   datetime startTime;                 // وقت البداية
   datetime endTime;                   // وقت النهاية
   double volatilityMultiplier;        // مضاعف التقلب
   double spreadMultiplier;            // مضاعف السبريد
   bool isActive;                      // هل الجلسة نشطة
   string description;                 // وصف الجلسة
   
   SessionInfo()
   {
      sessionType = SESSION_NONE;
      startTime = 0;
      endTime = 0;
      volatilityMultiplier = 1.0;
      spreadMultiplier = 1.0;
      isActive = false;
      description = "";
   }
};

//+------------------------------------------------------------------+
//| Session Strategy Structure                                      |
//+------------------------------------------------------------------+
struct SessionStrategy
{
   ENUM_TRADING_SESSION session;      // الجلسة المستهدفة
   double riskMultiplier;              // مضاعف المخاطرة
   int maxPositions;                   // أقصى عدد مراكز
   double minVolatility;               // أدنى تقلب مطلوب
   double maxSpread;                   // أقصى سبريد مسموح
   bool allowScalping;                 // السماح بالسكالبينغ
   bool allowSwing;                    // السماح بالسوينغ
   
   SessionStrategy()
   {
      session = SESSION_NONE;
      riskMultiplier = 1.0;
      maxPositions = 3;
      minVolatility = 0.0;
      maxSpread = 3.0;
      allowScalping = true;
      allowSwing = true;
   }
};

//+------------------------------------------------------------------+
//| Forex Session Manager Class                                    |
//+------------------------------------------------------------------+
class CForexSessionManager
{
private:
   SessionInfo m_sessions[7];          // معلومات الجلسات
   SessionStrategy m_strategies[7];    // استراتيجيات الجلسات
   ENUM_TRADING_SESSION m_currentSession;
   ENUM_TRADING_SESSION m_previousSession;
   datetime m_lastUpdateTime;
   
   // Private methods
   void InitializeSessions();
   void InitializeStrategies();
   bool IsTimeInRange(datetime currentTime, int startHour, int endHour);
   double CalculateSessionVolatility(ENUM_TRADING_SESSION session);
   
public:
   CForexSessionManager();
   ~CForexSessionManager();
   
   // Current session identification - تحديد الجلسات الحالية
   ENUM_TRADING_SESSION GetCurrentSession();
   SessionInfo GetCurrentSessionInfo();
   bool IsSessionActive(ENUM_TRADING_SESSION session);
   
   // Session overlaps
   bool IsOverlapPeriod();
   ENUM_TRADING_SESSION GetOverlapSession();
   double GetOverlapVolatilityBonus();
   
   // Optimal trading times
   bool IsOptimalTradingTime(string symbol);
   double GetOptimalityScore();
   string GetTradingRecommendation();
   
   // Session-specific strategies
   SessionStrategy GetSessionStrategy(ENUM_TRADING_SESSION session);
   bool ValidateTradeForSession(string symbol, double lotSize);
   double GetSessionRiskMultiplier();
   
   // Settings and configuration
   void SetSessionStrategy(ENUM_TRADING_SESSION session, SessionStrategy strategy);
   void UpdateSessionTimes();
   
   // Information getters
   string GetSessionName(ENUM_TRADING_SESSION session);
   datetime GetSessionStartTime(ENUM_TRADING_SESSION session);
   datetime GetSessionEndTime(ENUM_TRADING_SESSION session);
   double GetSessionVolatility(ENUM_TRADING_SESSION session);
   
   // Market analysis
   bool IsHighVolatilityPeriod();
   bool IsLowSpreadPeriod();
   double GetExpectedSpread(string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CForexSessionManager::CForexSessionManager()
{
   m_currentSession = SESSION_NONE;
   m_previousSession = SESSION_NONE;
   m_lastUpdateTime = 0;
   
   InitializeSessions();
   InitializeStrategies();
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CForexSessionManager::~CForexSessionManager()
{
}

//+------------------------------------------------------------------+
//| Initialize Sessions                                             |
//+------------------------------------------------------------------+
void CForexSessionManager::InitializeSessions()
{
   // Sydney Session (21:00-06:00 GMT)
   m_sessions[0].sessionType = SESSION_SYDNEY;
   m_sessions[0].description = "Sydney Session - جلسة سيدني";
   m_sessions[0].volatilityMultiplier = 0.7;
   m_sessions[0].spreadMultiplier = 1.2;
   
   // Asian Session (23:00-08:00 GMT)
   m_sessions[1].sessionType = SESSION_ASIAN;
   m_sessions[1].description = "Asian Session - الجلسة الآسيوية";
   m_sessions[1].volatilityMultiplier = 0.8;
   m_sessions[1].spreadMultiplier = 1.1;
   
   // London Session (08:00-17:00 GMT)
   m_sessions[2].sessionType = SESSION_LONDON;
   m_sessions[2].description = "London Session - جلسة لندن";
   m_sessions[2].volatilityMultiplier = 1.3;
   m_sessions[2].spreadMultiplier = 0.8;
   
   // NY Session (13:00-22:00 GMT)
   m_sessions[3].sessionType = SESSION_NY;
   m_sessions[3].description = "New York Session - جلسة نيويورك";
   m_sessions[3].volatilityMultiplier = 1.2;
   m_sessions[3].spreadMultiplier = 0.9;
   
   // London-NY Overlap (13:00-17:00 GMT)
   m_sessions[4].sessionType = SESSION_OVERLAP_LONDON_NY;
   m_sessions[4].description = "London-NY Overlap - تداخل لندن-نيويورك";
   m_sessions[4].volatilityMultiplier = 1.5;
   m_sessions[4].spreadMultiplier = 0.7;
   
   // Asian-London Overlap (08:00-09:00 GMT)
   m_sessions[5].sessionType = SESSION_OVERLAP_ASIAN_LONDON;
   m_sessions[5].description = "Asian-London Overlap - تداخل آسيا-لندن";
   m_sessions[5].volatilityMultiplier = 1.1;
   m_sessions[5].spreadMultiplier = 0.9;
}

//+------------------------------------------------------------------+
//| Initialize Strategies                                           |
//+------------------------------------------------------------------+
void CForexSessionManager::InitializeStrategies()
{
   // Sydney Session Strategy
   m_strategies[0].session = SESSION_SYDNEY;
   m_strategies[0].riskMultiplier = 0.8;
   m_strategies[0].maxPositions = 2;
   m_strategies[0].allowScalping = false;
   m_strategies[0].allowSwing = true;
   
   // Asian Session Strategy
   m_strategies[1].session = SESSION_ASIAN;
   m_strategies[1].riskMultiplier = 0.9;
   m_strategies[1].maxPositions = 3;
   m_strategies[1].allowScalping = true;
   m_strategies[1].allowSwing = true;
   
   // London Session Strategy
   m_strategies[2].session = SESSION_LONDON;
   m_strategies[2].riskMultiplier = 1.2;
   m_strategies[2].maxPositions = 5;
   m_strategies[2].allowScalping = true;
   m_strategies[2].allowSwing = true;
   
   // NY Session Strategy
   m_strategies[3].session = SESSION_NY;
   m_strategies[3].riskMultiplier = 1.1;
   m_strategies[3].maxPositions = 4;
   m_strategies[3].allowScalping = true;
   m_strategies[3].allowSwing = true;
   
   // London-NY Overlap Strategy
   m_strategies[4].session = SESSION_OVERLAP_LONDON_NY;
   m_strategies[4].riskMultiplier = 1.4;
   m_strategies[4].maxPositions = 6;
   m_strategies[4].allowScalping = true;
   m_strategies[4].allowSwing = false;
   
   // Asian-London Overlap Strategy
   m_strategies[5].session = SESSION_OVERLAP_ASIAN_LONDON;
   m_strategies[5].riskMultiplier = 1.0;
   m_strategies[5].maxPositions = 3;
   m_strategies[5].allowScalping = true;
   m_strategies[5].allowSwing = true;
}

//+------------------------------------------------------------------+
//| Get Current Session                                            |
//+------------------------------------------------------------------+
ENUM_TRADING_SESSION CForexSessionManager::GetCurrentSession()
{
   datetime currentTime = TimeCurrent();
   MqlDateTime timeStruct;
   TimeToStruct(currentTime, timeStruct);
   int hour = timeStruct.hour;
   
   // Check for overlap periods first (higher priority)
   if(hour >= 13 && hour < 17)
      return SESSION_OVERLAP_LONDON_NY;
   
   if(hour >= 8 && hour < 9)
      return SESSION_OVERLAP_ASIAN_LONDON;
   
   // Check individual sessions
   if(hour >= 21 || hour < 6)
      return SESSION_SYDNEY;
   
   if(hour >= 23 || hour < 8)
      return SESSION_ASIAN;
   
   if(hour >= 8 && hour < 17)
      return SESSION_LONDON;
   
   if(hour >= 13 && hour < 22)
      return SESSION_NY;
   
   return SESSION_NONE;
}

//+------------------------------------------------------------------+
//| Get Current Session Info                                       |
//+------------------------------------------------------------------+
SessionInfo CForexSessionManager::GetCurrentSessionInfo()
{
   ENUM_TRADING_SESSION currentSession = GetCurrentSession();
   
   for(int i = 0; i < ArraySize(m_sessions); i++)
   {
      if(m_sessions[i].sessionType == currentSession)
      {
         m_sessions[i].isActive = true;
         return m_sessions[i];
      }
   }
   
   SessionInfo emptySession;
   return emptySession;
}

//+------------------------------------------------------------------+
//| Check if Session is Active                                     |
//+------------------------------------------------------------------+
bool CForexSessionManager::IsSessionActive(ENUM_TRADING_SESSION session)
{
   return GetCurrentSession() == session;
}

//+------------------------------------------------------------------+
//| Check if Overlap Period                                        |
//+------------------------------------------------------------------+
bool CForexSessionManager::IsOverlapPeriod()
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   return (current == SESSION_OVERLAP_LONDON_NY || current == SESSION_OVERLAP_ASIAN_LONDON);
}

//+------------------------------------------------------------------+
//| Get Overlap Session                                            |
//+------------------------------------------------------------------+
ENUM_TRADING_SESSION CForexSessionManager::GetOverlapSession()
{
   if(IsOverlapPeriod())
      return GetCurrentSession();
   
   return SESSION_NONE;
}

//+------------------------------------------------------------------+
//| Get Overlap Volatility Bonus                                  |
//+------------------------------------------------------------------+
double CForexSessionManager::GetOverlapVolatilityBonus()
{
   if(!IsOverlapPeriod()) return 1.0;
   
   ENUM_TRADING_SESSION overlap = GetOverlapSession();
   
   if(overlap == SESSION_OVERLAP_LONDON_NY)
      return 1.3; // 30% volatility bonus
   
   if(overlap == SESSION_OVERLAP_ASIAN_LONDON)
      return 1.1; // 10% volatility bonus
   
   return 1.0;
}

//+------------------------------------------------------------------+
//| Check if Optimal Trading Time                                 |
//+------------------------------------------------------------------+
bool CForexSessionManager::IsOptimalTradingTime(string symbol)
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   
   // Major pairs are optimal during London and NY sessions
   if(symbol == "EURUSD" || symbol == "GBPUSD" || symbol == "USDCHF")
   {
      return (current == SESSION_LONDON || current == SESSION_NY || IsOverlapPeriod());
   }
   
   // JPY pairs are optimal during Asian and London sessions
   if(StringFind(symbol, "JPY") >= 0)
   {
      return (current == SESSION_ASIAN || current == SESSION_LONDON);
   }
   
   // AUD/NZD pairs are optimal during Sydney and Asian sessions
   if(StringFind(symbol, "AUD") >= 0 || StringFind(symbol, "NZD") >= 0)
   {
      return (current == SESSION_SYDNEY || current == SESSION_ASIAN);
   }
   
   return true; // Default to true for other pairs
}

//+------------------------------------------------------------------+
//| Get Optimality Score                                          |
//+------------------------------------------------------------------+
double CForexSessionManager::GetOptimalityScore()
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   
   switch(current)
   {
      case SESSION_OVERLAP_LONDON_NY: return 1.0; // Perfect
      case SESSION_LONDON: return 0.9;
      case SESSION_NY: return 0.8;
      case SESSION_OVERLAP_ASIAN_LONDON: return 0.7;
      case SESSION_ASIAN: return 0.6;
      case SESSION_SYDNEY: return 0.4;
      default: return 0.2;
   }
}

//+------------------------------------------------------------------+
//| Get Trading Recommendation                                     |
//+------------------------------------------------------------------+
string CForexSessionManager::GetTradingRecommendation()
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   double score = GetOptimalityScore();
   
   string recommendation = "";
   
   if(score >= 0.8)
      recommendation = "Excellent - توصية ممتازة للتداول";
   else if(score >= 0.6)
      recommendation = "Good - توصية جيدة للتداول";
   else if(score >= 0.4)
      recommendation = "Fair - توصية متوسطة للتداول";
   else
      recommendation = "Poor - تجنب التداول";
   
   recommendation += " | Session: " + GetSessionName(current);
   
   if(IsOverlapPeriod())
      recommendation += " | Overlap Active - تداخل نشط";
   
   return recommendation;
}

//+------------------------------------------------------------------+
//| Get Session Strategy                                           |
//+------------------------------------------------------------------+
SessionStrategy CForexSessionManager::GetSessionStrategy(ENUM_TRADING_SESSION session)
{
   for(int i = 0; i < ArraySize(m_strategies); i++)
   {
      if(m_strategies[i].session == session)
         return m_strategies[i];
   }
   
   SessionStrategy defaultStrategy;
   return defaultStrategy;
}

//+------------------------------------------------------------------+
//| Validate Trade for Session                                    |
//+------------------------------------------------------------------+
bool CForexSessionManager::ValidateTradeForSession(string symbol, double lotSize)
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   SessionStrategy strategy = GetSessionStrategy(current);
   
   // Check if trading is optimal for this symbol
   if(!IsOptimalTradingTime(symbol))
   {
      Print("⚠️ Non-optimal trading time for ", symbol);
      return false;
   }
   
   // Check maximum positions
   int currentPositions = PositionsTotal();
   if(currentPositions >= strategy.maxPositions)
   {
      Print("⚠️ Maximum positions reached for session: ", strategy.maxPositions);
      return false;
   }
   
   // Check spread conditions
   double currentSpread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * SymbolInfoDouble(symbol, SYMBOL_POINT);
   double maxAllowedSpread = strategy.maxSpread * SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   if(currentSpread > maxAllowedSpread)
   {
      Print("⚠️ Spread too high: ", currentSpread, " > ", maxAllowedSpread);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Get Session Risk Multiplier                                   |
//+------------------------------------------------------------------+
double CForexSessionManager::GetSessionRiskMultiplier()
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   SessionStrategy strategy = GetSessionStrategy(current);
   
   double multiplier = strategy.riskMultiplier;
   
   // Apply overlap bonus
   if(IsOverlapPeriod())
      multiplier *= 1.1;
   
   return multiplier;
}

//+------------------------------------------------------------------+
//| Get Session Name                                              |
//+------------------------------------------------------------------+
string CForexSessionManager::GetSessionName(ENUM_TRADING_SESSION session)
{
   switch(session)
   {
      case SESSION_SYDNEY: return "Sydney - سيدني";
      case SESSION_ASIAN: return "Asian - آسيوية";
      case SESSION_LONDON: return "London - لندن";
      case SESSION_NY: return "New York - نيويورك";
      case SESSION_OVERLAP_LONDON_NY: return "London-NY Overlap - تداخل لندن-نيويورك";
      case SESSION_OVERLAP_ASIAN_LONDON: return "Asian-London Overlap - تداخل آسيا-لندن";
      default: return "None - لا يوجد";
   }
}

//+------------------------------------------------------------------+
//| Check High Volatility Period                                  |
//+------------------------------------------------------------------+
bool CForexSessionManager::IsHighVolatilityPeriod()
{
   double score = GetOptimalityScore();
   return score >= 0.8;
}

//+------------------------------------------------------------------+
//| Check Low Spread Period                                       |
//+------------------------------------------------------------------+
bool CForexSessionManager::IsLowSpreadPeriod()
{
   ENUM_TRADING_SESSION current = GetCurrentSession();
   
   for(int i = 0; i < ArraySize(m_sessions); i++)
   {
      if(m_sessions[i].sessionType == current)
      {
         return m_sessions[i].spreadMultiplier <= 0.9;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get Expected Spread                                           |
//+------------------------------------------------------------------+
double CForexSessionManager::GetExpectedSpread(string symbol)
{
   double baseSpread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * SymbolInfoDouble(symbol, SYMBOL_POINT);
   ENUM_TRADING_SESSION current = GetCurrentSession();
   
   for(int i = 0; i < ArraySize(m_sessions); i++)
   {
      if(m_sessions[i].sessionType == current)
      {
         return baseSpread * m_sessions[i].spreadMultiplier;
      }
   }
   
   return baseSpread;
}
