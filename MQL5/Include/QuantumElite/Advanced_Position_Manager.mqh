//+------------------------------------------------------------------+
//|                                    Advanced_Position_Manager.mqh |
//|                         نظام إدارة المراكز المتقدم              |
//|                    Copyright 2024, Quantum Trading Systems       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//+------------------------------------------------------------------+
//| Dynamic Trailing Stop Parameters Structure                      |
//+------------------------------------------------------------------+
struct TrailingParams {
    double activationDistance;  // متى يبدأ
    double trailingDistance;    // المسافة
    double stepSize;           // حجم الخطوة
    bool useATR;              // استخدم ATR
    bool protectProfit;       // حماية الأرباح
    
    TrailingParams() {
        activationDistance = 20.0;
        trailingDistance = 10.0;
        stepSize = 5.0;
        useATR = true;
        protectProfit = true;
    }
};

//+------------------------------------------------------------------+
//| Partial Close Level Structure                                   |
//+------------------------------------------------------------------+
struct CloseLevel {
    double profitPips;
    double closePercent;
    
    CloseLevel() {
        profitPips = 0.0;
        closePercent = 0.0;
    }
    
    CloseLevel(double pips, double percent) {
        profitPips = pips;
        closePercent = percent;
    }
};

//+------------------------------------------------------------------+
//| Dynamic Trailing Stop Class                                     |
//+------------------------------------------------------------------+
class CDynamicTrailingStop {
private:
    TrailingParams m_params;
    datetime m_lastUpdate[];
    double m_lastSL[];
    
public:
    CDynamicTrailingStop();
    ~CDynamicTrailingStop();
    
    void SetParameters(TrailingParams &params);
    void UpdateTrailingStop(ulong ticket);
    bool ShouldUpdateTrailing(ulong ticket, double currentProfit, double currentSL);
    double CalculateNewSL(string symbol, ulong ticket, double currentPrice, double currentSL);
    
private:
    double GetATRValue(string symbol);
    bool IsPositionProfitable(ulong ticket, double minPips);
    void UpdateLastModification(ulong ticket, double newSL);
};

//+------------------------------------------------------------------+
//| Partial Close Manager Class                                     |
//+------------------------------------------------------------------+
class CPartialCloseManager {
private:
    CloseLevel m_levels[4];
    bool m_levelExecuted[];
    
public:
    CPartialCloseManager();
    ~CPartialCloseManager();
    
    void InitializeLevels();
    void ManagePartialClose(ulong ticket);
    bool ExecutePartialClose(ulong ticket, double percent);
    void ResetLevels(ulong ticket);
    
private:
    double GetPositionProfitPips(ulong ticket);
    bool IsLevelReached(ulong ticket, int levelIndex);
    bool IsLevelExecuted(ulong ticket, int levelIndex);
    void MarkLevelExecuted(ulong ticket, int levelIndex);
};

//+------------------------------------------------------------------+
//| Break-Even Manager Class                                        |
//+------------------------------------------------------------------+
class CBreakEvenManager {
private:
    bool m_movedToBreakEven[];
    double m_profitThreshold;
    double m_buffer;
    
public:
    CBreakEvenManager();
    ~CBreakEvenManager();
    
    void SetParameters(double profitThreshold, double buffer);
    void MoveToBreakEven(ulong ticket);
    bool ShouldMoveToBreakEven(ulong ticket);
    
private:
    bool IsAlreadyMoved(ulong ticket);
    void MarkAsMoved(ulong ticket);
    double CalculateBreakEvenPrice(ulong ticket);
};

//+------------------------------------------------------------------+
//| Scale Manager Class                                             |
//+------------------------------------------------------------------+
class CScaleManager {
private:
    int m_maxScaleIns;
    double m_scaleInPercent;
    double m_minTrendStrength;
    
public:
    CScaleManager();
    ~CScaleManager();
    
    void SetParameters(int maxScaleIns, double scalePercent, double minTrend);
    bool ScaleIn(ulong originalTicket);
    bool ScaleOut(ulong ticket, double percent);
    
private:
    bool CanScaleIn(ulong ticket);
    bool IsTrendStrong(string symbol);
    int CountScaleIns(ulong originalTicket);
    double CalculateScaleVolume(ulong originalTicket);
};

//+------------------------------------------------------------------+
//| Advanced Position Manager Main Class                            |
//+------------------------------------------------------------------+
class CAdvancedPositionManager {
private:
    CDynamicTrailingStop* m_trailingStop;
    CPartialCloseManager* m_partialClose;
    CBreakEvenManager* m_breakEven;
    CScaleManager* m_scaleManager;
    
    CTrade m_trade;
    CPositionInfo m_position;
    
    bool m_enableTrailing;
    bool m_enablePartialClose;
    bool m_enableBreakEven;
    bool m_enableScaling;
    
    datetime m_lastManagement[];
    int m_minManagementInterval;
    
public:
    CAdvancedPositionManager();
    ~CAdvancedPositionManager();
    
    bool Initialize();
    void Deinitialize();
    
    void SetTrailingEnabled(bool enabled) { m_enableTrailing = enabled; }
    void SetPartialCloseEnabled(bool enabled) { m_enablePartialClose = enabled; }
    void SetBreakEvenEnabled(bool enabled) { m_enableBreakEven = enabled; }
    void SetScalingEnabled(bool enabled) { m_enableScaling = enabled; }
    
    void ManageAllPositions();
    void ManagePosition(ulong ticket);
    
private:
    bool CanManagePosition(ulong ticket);
    void UpdateLastManagement(ulong ticket);
    bool IsPositionValid(ulong ticket);
};

//+------------------------------------------------------------------+
//| CDynamicTrailingStop Implementation                             |
//+------------------------------------------------------------------+
CDynamicTrailingStop::CDynamicTrailingStop() {
    m_params.activationDistance = 20.0;
    m_params.trailingDistance = 10.0;
    m_params.stepSize = 5.0;
    m_params.useATR = true;
    m_params.protectProfit = true;
}

CDynamicTrailingStop::~CDynamicTrailingStop() {
    ArrayFree(m_lastUpdate);
    ArrayFree(m_lastSL);
}

void CDynamicTrailingStop::SetParameters(TrailingParams &params) {
    m_params = params;
}

void CDynamicTrailingStop::UpdateTrailingStop(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) {
        Print("Position not found: ", ticket);
        return;
    }
    
    double currentProfit = PositionGetDouble(POSITION_PROFIT);
    double currentSL = PositionGetDouble(POSITION_SL);
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    string symbol = PositionGetString(POSITION_SYMBOL);
    
    if(!IsPositionProfitable(ticket, m_params.activationDistance)) {
        return;
    }
    
    if(!ShouldUpdateTrailing(ticket, currentProfit, currentSL)) {
        return;
    }
    
    double newSL = CalculateNewSL(symbol, ticket, currentPrice, currentSL);
    
    if(newSL != currentSL) {
        double tp = PositionGetDouble(POSITION_TP);
        if(m_trade.PositionModify(ticket, newSL, tp)) {
            Print("✅ Trailing stop updated for ", symbol, " - New SL: ", newSL);
            UpdateLastModification(ticket, newSL);
        } else {
            Print("❌ Failed to update trailing stop for ", symbol, " - Error: ", GetLastError());
        }
    }
}

double CDynamicTrailingStop::CalculateNewSL(string symbol, ulong ticket, double currentPrice, double currentSL) {
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double trailingDistance = m_params.trailingDistance;
    
    if(m_params.useATR) {
        double atr = GetATRValue(symbol);
        if(atr > 0) {
            trailingDistance = atr / point * 0.5;
        }
    }
    
    double newSL = currentSL;
    
    if(posType == POSITION_TYPE_BUY) {
        double proposedSL = currentPrice - trailingDistance * point;
        if(proposedSL > currentSL || currentSL == 0) {
            newSL = NormalizeDouble(proposedSL, digits);
        }
    } else if(posType == POSITION_TYPE_SELL) {
        double proposedSL = currentPrice + trailingDistance * point;
        if(proposedSL < currentSL || currentSL == 0) {
            newSL = NormalizeDouble(proposedSL, digits);
        }
    }
    
    return newSL;
}

bool CDynamicTrailingStop::IsPositionProfitable(ulong ticket, double minPips) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    string symbol = PositionGetString(POSITION_SYMBOL);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double profitPips = 0;
    
    if(posType == POSITION_TYPE_BUY) {
        profitPips = (currentPrice - openPrice) / point;
    } else {
        profitPips = (openPrice - currentPrice) / point;
    }
    
    return profitPips >= minPips;
}

double CDynamicTrailingStop::GetATRValue(string symbol) {
    int atrHandle = iATR(symbol, PERIOD_CURRENT, 14);
    if(atrHandle == INVALID_HANDLE) return 0.0;
    
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    
    if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0) {
        IndicatorRelease(atrHandle);
        return 0.0;
    }
    
    double result = atrBuffer[0];
    IndicatorRelease(atrHandle);
    return result;
}

bool CDynamicTrailingStop::ShouldUpdateTrailing(ulong ticket, double currentProfit, double currentSL) {
    return true;
}

void CDynamicTrailingStop::UpdateLastModification(ulong ticket, double newSL) {
    // Implementation for tracking last modification time
}

//+------------------------------------------------------------------+
//| CPartialCloseManager Implementation                             |
//+------------------------------------------------------------------+
CPartialCloseManager::CPartialCloseManager() {
    InitializeLevels();
}

CPartialCloseManager::~CPartialCloseManager() {
    ArrayFree(m_levelExecuted);
}

void CPartialCloseManager::InitializeLevels() {
    m_levels[0] = CloseLevel(20.0, 0.25);  // أغلق 25% عند 20 pips
    m_levels[1] = CloseLevel(40.0, 0.25);  // أغلق 25% عند 40 pips
    m_levels[2] = CloseLevel(60.0, 0.25);  // أغلق 25% عند 60 pips
    m_levels[3] = CloseLevel(80.0, 0.25);  // يبقى 25% للركض مع الترند
}

void CPartialCloseManager::ManagePartialClose(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) return;
    
    for(int i = 0; i < 3; i++) { // Only first 3 levels, keep 25% running
        if(IsLevelReached(ticket, i) && !IsLevelExecuted(ticket, i)) {
            if(ExecutePartialClose(ticket, m_levels[i].closePercent)) {
                MarkLevelExecuted(ticket, i);
                Print("✅ Partial close executed at level ", i+1, " for ticket ", ticket);
            }
        }
    }
}

bool CPartialCloseManager::ExecutePartialClose(ulong ticket, double percent) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    double currentVolume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = currentVolume * percent;
    string symbol = PositionGetString(POSITION_SYMBOL);
    
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    closeVolume = MathMax(closeVolume, minLot);
    closeVolume = MathRound(closeVolume / lotStep) * lotStep;
    
    if(closeVolume >= currentVolume) return false;
    
    CTrade trade;
    return trade.PositionClosePartial(ticket, closeVolume);
}

double CPartialCloseManager::GetPositionProfitPips(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) return 0.0;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    string symbol = PositionGetString(POSITION_SYMBOL);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    if(posType == POSITION_TYPE_BUY) {
        return (currentPrice - openPrice) / point;
    } else {
        return (openPrice - currentPrice) / point;
    }
}

bool CPartialCloseManager::IsLevelReached(ulong ticket, int levelIndex) {
    double profitPips = GetPositionProfitPips(ticket);
    return profitPips >= m_levels[levelIndex].profitPips;
}

bool CPartialCloseManager::IsLevelExecuted(ulong ticket, int levelIndex) {
    // Simple implementation - in production, this should track per position
    return false;
}

void CPartialCloseManager::MarkLevelExecuted(ulong ticket, int levelIndex) {
    // Implementation for marking level as executed
}

void CPartialCloseManager::ResetLevels(ulong ticket) {
    // Implementation for resetting levels when position closes
}

//+------------------------------------------------------------------+
//| CBreakEvenManager Implementation                                |
//+------------------------------------------------------------------+
CBreakEvenManager::CBreakEvenManager() {
    m_profitThreshold = 10.0;  // 10 pips
    m_buffer = 2.0;            // 2 pips buffer
}

CBreakEvenManager::~CBreakEvenManager() {
    ArrayFree(m_movedToBreakEven);
}

void CBreakEvenManager::SetParameters(double profitThreshold, double buffer) {
    m_profitThreshold = profitThreshold;
    m_buffer = buffer;
}

void CBreakEvenManager::MoveToBreakEven(ulong ticket) {
    if(!ShouldMoveToBreakEven(ticket)) return;
    
    if(IsAlreadyMoved(ticket)) return;
    
    double breakEvenPrice = CalculateBreakEvenPrice(ticket);
    double tp = PositionGetDouble(POSITION_TP);
    
    CTrade trade;
    if(trade.PositionModify(ticket, breakEvenPrice, tp)) {
        MarkAsMoved(ticket);
        string symbol = PositionGetString(POSITION_SYMBOL);
        Print("✅ Position moved to break-even: ", symbol, " - New SL: ", breakEvenPrice);
    }
}

bool CBreakEvenManager::ShouldMoveToBreakEven(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    string symbol = PositionGetString(POSITION_SYMBOL);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double profitPips = 0;
    if(posType == POSITION_TYPE_BUY) {
        profitPips = (currentPrice - openPrice) / point;
    } else {
        profitPips = (openPrice - currentPrice) / point;
    }
    
    return profitPips >= m_profitThreshold;
}

double CBreakEvenManager::CalculateBreakEvenPrice(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) return 0.0;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    string symbol = PositionGetString(POSITION_SYMBOL);
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double breakEvenPrice = openPrice;
    
    if(posType == POSITION_TYPE_BUY) {
        breakEvenPrice = openPrice + m_buffer * point;
    } else {
        breakEvenPrice = openPrice - m_buffer * point;
    }
    
    return NormalizeDouble(breakEvenPrice, digits);
}

bool CBreakEvenManager::IsAlreadyMoved(ulong ticket) {
    // Simple implementation - should track per position
    return false;
}

void CBreakEvenManager::MarkAsMoved(ulong ticket) {
    // Implementation for marking position as moved to break-even
}

//+------------------------------------------------------------------+
//| CScaleManager Implementation                                     |
//+------------------------------------------------------------------+
CScaleManager::CScaleManager() {
    m_maxScaleIns = 2;
    m_scaleInPercent = 0.5;  // 50% of original
    m_minTrendStrength = 0.7;
}

CScaleManager::~CScaleManager() {
}

void CScaleManager::SetParameters(int maxScaleIns, double scalePercent, double minTrend) {
    m_maxScaleIns = maxScaleIns;
    m_scaleInPercent = scalePercent;
    m_minTrendStrength = minTrend;
}

bool CScaleManager::ScaleIn(ulong originalTicket) {
    if(!CanScaleIn(originalTicket)) return false;
    
    if(!PositionSelectByTicket(originalTicket)) return false;
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double volume = CalculateScaleVolume(originalTicket);
    
    if(volume <= 0) return false;
    
    CTrade trade;
    bool result = false;
    
    if(posType == POSITION_TYPE_BUY) {
        result = trade.Buy(volume, symbol);
    } else {
        result = trade.Sell(volume, symbol);
    }
    
    if(result) {
        Print("✅ Scale-in executed for ", symbol, " - Volume: ", volume);
    }
    
    return result;
}

bool CScaleManager::ScaleOut(ulong ticket, double percent) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    double currentVolume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = currentVolume * percent;
    
    CTrade trade;
    return trade.PositionClosePartial(ticket, closeVolume);
}

bool CScaleManager::CanScaleIn(ulong ticket) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    // Check if position is profitable
    double profit = PositionGetDouble(POSITION_PROFIT);
    if(profit <= 0) return false;
    
    // Check trend strength
    string symbol = PositionGetString(POSITION_SYMBOL);
    if(!IsTrendStrong(symbol)) return false;
    
    // Check scale-in count
    if(CountScaleIns(ticket) >= m_maxScaleIns) return false;
    
    return true;
}

bool CScaleManager::IsTrendStrong(string symbol) {
    // Simple trend strength calculation using moving averages
    double ma20[], ma50[];
    ArraySetAsSeries(ma20, true);
    ArraySetAsSeries(ma50, true);
    
    int ma20Handle = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    int ma50Handle = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
    
    if(ma20Handle == INVALID_HANDLE || ma50Handle == INVALID_HANDLE) return false;
    
    if(CopyBuffer(ma20Handle, 0, 0, 2, ma20) <= 0 || 
       CopyBuffer(ma50Handle, 0, 0, 2, ma50) <= 0) {
        IndicatorRelease(ma20Handle);
        IndicatorRelease(ma50Handle);
        return false;
    }
    
    bool trendUp = ma20[0] > ma50[0] && ma20[1] > ma50[1];
    bool trendDown = ma20[0] < ma50[0] && ma20[1] < ma50[1];
    
    IndicatorRelease(ma20Handle);
    IndicatorRelease(ma50Handle);
    
    return trendUp || trendDown;
}

int CScaleManager::CountScaleIns(ulong originalTicket) {
    // Simple implementation - should track scale-ins per original position
    return 0;
}

double CScaleManager::CalculateScaleVolume(ulong originalTicket) {
    if(!PositionSelectByTicket(originalTicket)) return 0.0;
    
    double originalVolume = PositionGetDouble(POSITION_VOLUME);
    return originalVolume * m_scaleInPercent;
}

//+------------------------------------------------------------------+
//| CAdvancedPositionManager Implementation                         |
//+------------------------------------------------------------------+
CAdvancedPositionManager::CAdvancedPositionManager() {
    m_trailingStop = NULL;
    m_partialClose = NULL;
    m_breakEven = NULL;
    m_scaleManager = NULL;
    
    m_enableTrailing = true;
    m_enablePartialClose = true;
    m_enableBreakEven = true;
    m_enableScaling = false;
    
    m_minManagementInterval = 60; // 60 seconds
}

CAdvancedPositionManager::~CAdvancedPositionManager() {
    Deinitialize();
}

bool CAdvancedPositionManager::Initialize() {
    m_trailingStop = new CDynamicTrailingStop();
    m_partialClose = new CPartialCloseManager();
    m_breakEven = new CBreakEvenManager();
    m_scaleManager = new CScaleManager();
    
    if(m_trailingStop == NULL || m_partialClose == NULL || 
       m_breakEven == NULL || m_scaleManager == NULL) {
        Print("❌ Failed to initialize Advanced Position Manager components");
        Deinitialize();
        return false;
    }
    
    Print("✅ Advanced Position Manager initialized successfully");
    return true;
}

void CAdvancedPositionManager::Deinitialize() {
    if(m_trailingStop != NULL) {
        delete m_trailingStop;
        m_trailingStop = NULL;
    }
    
    if(m_partialClose != NULL) {
        delete m_partialClose;
        m_partialClose = NULL;
    }
    
    if(m_breakEven != NULL) {
        delete m_breakEven;
        m_breakEven = NULL;
    }
    
    if(m_scaleManager != NULL) {
        delete m_scaleManager;
        m_scaleManager = NULL;
    }
    
    ArrayFree(m_lastManagement);
}

void CAdvancedPositionManager::ManageAllPositions() {
    int totalPositions = PositionsTotal();
    
    for(int i = 0; i < totalPositions; i++) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0) {
            ManagePosition(ticket);
        }
    }
}

void CAdvancedPositionManager::ManagePosition(ulong ticket) {
    if(!IsPositionValid(ticket)) return;
    
    if(!CanManagePosition(ticket)) return;
    
    // Break-even management (highest priority)
    if(m_enableBreakEven && m_breakEven != NULL) {
        m_breakEven.MoveToBreakEven(ticket);
    }
    
    // Trailing stop management
    if(m_enableTrailing && m_trailingStop != NULL) {
        m_trailingStop.UpdateTrailingStop(ticket);
    }
    
    // Partial close management
    if(m_enablePartialClose && m_partialClose != NULL) {
        m_partialClose.ManagePartialClose(ticket);
    }
    
    // Scale-in management (lowest priority)
    if(m_enableScaling && m_scaleManager != NULL) {
        m_scaleManager.ScaleIn(ticket);
    }
    
    UpdateLastManagement(ticket);
}

bool CAdvancedPositionManager::CanManagePosition(ulong ticket) {
    // Check time-based management limits
    datetime lastManagement = 0;
    
    // Simple implementation - should track per position
    datetime currentTime = TimeCurrent();
    
    if(currentTime - lastManagement < m_minManagementInterval) {
        return false;
    }
    
    return true;
}

void CAdvancedPositionManager::UpdateLastManagement(ulong ticket) {
    // Implementation for tracking last management time per position
}

bool CAdvancedPositionManager::IsPositionValid(ulong ticket) {
    return PositionSelectByTicket(ticket);
}
