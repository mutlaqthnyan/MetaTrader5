//+------------------------------------------------------------------+
//|                                               DataPreprocessor.mqh |
//|                           QUANTUM ELITE TRADER PRO v4.0         |
//|                         نظام التداول الكمي المتطور              |
//|                    Copyright 2024, Quantum Trading Systems       |
//|                         https://quantumelite.trading             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "4.00"

class CDataPreprocessor
{
private:
    // إحصائيات التطبيع لكل مجموعة من الميزات
    double m_priceMean[10], m_priceStd[10];           // Price features statistics
    double m_techMean[20], m_techStd[20];             // Technical indicators statistics  
    double m_microMean[10], m_microStd[10];           // Market microstructure statistics
    double m_temporalMean[10], m_temporalStd[10];     // Temporal features statistics
    
    bool m_isInitialized;
    
    // مؤشرات فنية مساعدة
    int m_rsiHandle, m_macdHandle, m_bbHandle;
    int m_ma5Handle, m_ma10Handle, m_ma20Handle, m_ma50Handle;
    int m_stochHandle, m_atrHandle, m_cciHandle;
    
public:
    CDataPreprocessor() : m_isInitialized(false) {}
    ~CDataPreprocessor() { Cleanup(); }
    
    bool Initialize(string symbol = "")
    {
        if(symbol == "") symbol = Symbol();
        
        // تهيئة المؤشرات الفنية
        m_rsiHandle = iRSI(symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
        m_macdHandle = iMACD(symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
        m_bbHandle = iBands(symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
        m_ma5Handle = iMA(symbol, PERIOD_CURRENT, 5, 0, MODE_SMA, PRICE_CLOSE);
        m_ma10Handle = iMA(symbol, PERIOD_CURRENT, 10, 0, MODE_SMA, PRICE_CLOSE);
        m_ma20Handle = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
        m_ma50Handle = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
        m_stochHandle = iStochastic(symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
        m_atrHandle = iATR(symbol, PERIOD_CURRENT, 14);
        m_cciHandle = iCCI(symbol, PERIOD_CURRENT, 14, PRICE_TYPICAL);
        
        // التحقق من صحة المؤشرات
        if(m_rsiHandle == INVALID_HANDLE || m_macdHandle == INVALID_HANDLE || 
           m_bbHandle == INVALID_HANDLE || m_ma5Handle == INVALID_HANDLE ||
           m_ma10Handle == INVALID_HANDLE || m_ma20Handle == INVALID_HANDLE ||
           m_ma50Handle == INVALID_HANDLE || m_stochHandle == INVALID_HANDLE ||
           m_atrHandle == INVALID_HANDLE || m_cciHandle == INVALID_HANDLE)
        {
            Print("❌ خطأ في تهيئة مؤشرات CDataPreprocessor");
            return false;
        }
        
        // تهيئة إحصائيات التطبيع بقيم افتراضية
        InitializeNormalizationStats();
        
        m_isInitialized = true;
        Print("✅ تم تهيئة CDataPreprocessor بنجاح");
        return true;
    }
    
    void ExtractFeatures(double &features[])
    {
        if(!m_isInitialized)
        {
            Print("❌ CDataPreprocessor غير مهيأ");
            return;
        }
        
        ArrayResize(features, 50); // 50 ميزة كما هو مطلوب
        ArrayInitialize(features, 0.0);
        
        int index = 0;
        
        // 1. Price Features (10 features) - ميزات السعر
        ExtractPriceFeatures(features, index);
        index += 10;
        
        // 2. Technical Indicators (20 features) - المؤشرات الفنية
        ExtractTechnicalIndicators(features, index);
        index += 20;
        
        // 3. Market Microstructure (10 features) - البنية الدقيقة للسوق
        ExtractMarketMicrostructure(features, index);
        index += 10;
        
        // 4. Temporal Features (10 features) - الميزات الزمنية
        ExtractTemporalFeatures(features, index);
    }
    
    void NormalizeData(double &data[])
    {
        if(!m_isInitialized || ArraySize(data) != 50)
        {
            Print("❌ خطأ في تطبيع البيانات - البيانات غير صحيحة");
            return;
        }
        
        // تطبيع كل مجموعة من الميزات باستخدام Z-score normalization
        
        // Price features (0-9)
        for(int i = 0; i < 10; i++)
        {
            if(m_priceStd[i] > 0.0001) // تجنب القسمة على صفر
                data[i] = (data[i] - m_priceMean[i]) / m_priceStd[i];
            else
                data[i] = 0.0;
        }
        
        // Technical indicators (10-29)
        for(int i = 0; i < 20; i++)
        {
            if(m_techStd[i] > 0.0001)
                data[10 + i] = (data[10 + i] - m_techMean[i]) / m_techStd[i];
            else
                data[10 + i] = 0.0;
        }
        
        // Market microstructure (30-39)
        for(int i = 0; i < 10; i++)
        {
            if(m_microStd[i] > 0.0001)
                data[30 + i] = (data[30 + i] - m_microMean[i]) / m_microStd[i];
            else
                data[30 + i] = 0.0;
        }
        
        // Temporal features (40-49)
        for(int i = 0; i < 10; i++)
        {
            if(m_temporalStd[i] > 0.0001)
                data[40 + i] = (data[40 + i] - m_temporalMean[i]) / m_temporalStd[i];
            else
                data[40 + i] = 0.0;
        }
    }
    
    bool UpdateNormalizationStats(double trainingData[][], int dataSize)
    {
        if(dataSize < 10 || ArrayRange(trainingData, 1) != 50)
        {
            Print("❌ بيانات التدريب غير كافية لحساب إحصائيات التطبيع");
            return false;
        }
        
        // حساب المتوسط والانحراف المعياري لكل مجموعة من الميزات
        
        // Price features (0-9)
        CalculateGroupStats(trainingData, dataSize, 0, 10, m_priceMean, m_priceStd);
        
        // Technical indicators (10-29)  
        CalculateGroupStats(trainingData, dataSize, 10, 20, m_techMean, m_techStd);
        
        // Market microstructure (30-39)
        CalculateGroupStats(trainingData, dataSize, 30, 10, m_microMean, m_microStd);
        
        // Temporal features (40-49)
        CalculateGroupStats(trainingData, dataSize, 40, 10, m_temporalMean, m_temporalStd);
        
        Print("✅ تم تحديث إحصائيات التطبيع من ", dataSize, " عينة");
        return true;
    }
    
private:
    void ExtractPriceFeatures(double &features[], int startIndex)
    {
        double close = iClose(Symbol(), PERIOD_CURRENT, 0);
        double open = iOpen(Symbol(), PERIOD_CURRENT, 0);
        double high = iHigh(Symbol(), PERIOD_CURRENT, 0);
        double low = iLow(Symbol(), PERIOD_CURRENT, 0);
        
        double prevClose = iClose(Symbol(), PERIOD_CURRENT, 1);
        double prevHigh = iHigh(Symbol(), PERIOD_CURRENT, 1);
        double prevLow = iLow(Symbol(), PERIOD_CURRENT, 1);
        
        // 0. Price change percentage
        features[startIndex + 0] = prevClose > 0 ? ((close - prevClose) / prevClose) * 100.0 : 0.0;
        
        // 1. High-Low range percentage
        features[startIndex + 1] = close > 0 ? ((high - low) / close) * 100.0 : 0.0;
        
        // 2. Open-Close percentage
        features[startIndex + 2] = open > 0 ? ((close - open) / open) * 100.0 : 0.0;
        
        // 3-6. Moving averages ratios
        double ma5[], ma10[], ma20[], ma50[];
        ArraySetAsSeries(ma5, true); ArraySetAsSeries(ma10, true);
        ArraySetAsSeries(ma20, true); ArraySetAsSeries(ma50, true);
        
        if(CopyBuffer(m_ma5Handle, 0, 0, 1, ma5) > 0 && ma5[0] > 0)
            features[startIndex + 3] = (close / ma5[0] - 1.0) * 100.0;
        if(CopyBuffer(m_ma10Handle, 0, 0, 1, ma10) > 0 && ma10[0] > 0)
            features[startIndex + 4] = (close / ma10[0] - 1.0) * 100.0;
        if(CopyBuffer(m_ma20Handle, 0, 0, 1, ma20) > 0 && ma20[0] > 0)
            features[startIndex + 5] = (close / ma20[0] - 1.0) * 100.0;
        if(CopyBuffer(m_ma50Handle, 0, 0, 1, ma50) > 0 && ma50[0] > 0)
            features[startIndex + 6] = (close / ma50[0] - 1.0) * 100.0;
        
        // 7. Previous candle body percentage
        features[startIndex + 7] = prevClose > 0 ? MathAbs(prevClose - iOpen(Symbol(), PERIOD_CURRENT, 1)) / prevClose * 100.0 : 0.0;
        
        // 8. Upper shadow percentage
        features[startIndex + 8] = close > 0 ? (high - MathMax(open, close)) / close * 100.0 : 0.0;
        
        // 9. Lower shadow percentage  
        features[startIndex + 9] = close > 0 ? (MathMin(open, close) - low) / close * 100.0 : 0.0;
    }
    
    void ExtractTechnicalIndicators(double &features[], int startIndex)
    {
        double rsi[], macd_main[], macd_signal[], bb_upper[], bb_lower[], bb_middle[];
        double stoch_main[], stoch_signal[], atr[], cci[];
        
        ArraySetAsSeries(rsi, true); ArraySetAsSeries(macd_main, true); ArraySetAsSeries(macd_signal, true);
        ArraySetAsSeries(bb_upper, true); ArraySetAsSeries(bb_lower, true); ArraySetAsSeries(bb_middle, true);
        ArraySetAsSeries(stoch_main, true); ArraySetAsSeries(stoch_signal, true);
        ArraySetAsSeries(atr, true); ArraySetAsSeries(cci, true);
        
        // 0-1. RSI and RSI change
        if(CopyBuffer(m_rsiHandle, 0, 0, 2, rsi) > 1)
        {
            features[startIndex + 0] = rsi[0];
            features[startIndex + 1] = rsi[0] - rsi[1]; // RSI change
        }
        
        // 2-4. MACD indicators
        if(CopyBuffer(m_macdHandle, 0, 0, 1, macd_main) > 0)
            features[startIndex + 2] = macd_main[0] * 10000; // Scale MACD
        if(CopyBuffer(m_macdHandle, 1, 0, 1, macd_signal) > 0)
            features[startIndex + 3] = macd_signal[0] * 10000; // Scale signal
        if(ArraySize(macd_main) > 0 && ArraySize(macd_signal) > 0)
            features[startIndex + 4] = (macd_main[0] - macd_signal[0]) * 10000; // MACD histogram
        
        // 5-7. Bollinger Bands
        double close = iClose(Symbol(), PERIOD_CURRENT, 0);
        if(CopyBuffer(m_bbHandle, 0, 0, 1, bb_middle) > 0 && bb_middle[0] > 0)
            features[startIndex + 5] = (close / bb_middle[0] - 1.0) * 100.0; // BB middle ratio
        if(CopyBuffer(m_bbHandle, 1, 0, 1, bb_upper) > 0 && CopyBuffer(m_bbHandle, 2, 0, 1, bb_lower) > 0)
        {
            if(bb_upper[0] > bb_lower[0])
            {
                features[startIndex + 6] = (close - bb_lower[0]) / (bb_upper[0] - bb_lower[0]) * 100.0; // BB position
                features[startIndex + 7] = (bb_upper[0] - bb_lower[0]) / bb_middle[0] * 100.0; // BB width
            }
        }
        
        // 8-9. Stochastic
        if(CopyBuffer(m_stochHandle, 0, 0, 1, stoch_main) > 0)
            features[startIndex + 8] = stoch_main[0];
        if(CopyBuffer(m_stochHandle, 1, 0, 1, stoch_signal) > 0)
            features[startIndex + 9] = stoch_signal[0];
        
        // 10-11. ATR and ATR ratio
        if(CopyBuffer(m_atrHandle, 0, 0, 1, atr) > 0)
        {
            features[startIndex + 10] = atr[0] / close * 100.0; // ATR percentage
            features[startIndex + 11] = atr[0] / SymbolInfoDouble(Symbol(), SYMBOL_POINT) / 10.0; // ATR in points scaled
        }
        
        // 12-13. CCI and CCI change
        if(CopyBuffer(m_cciHandle, 0, 0, 2, cci) > 1)
        {
            features[startIndex + 12] = cci[0] / 100.0; // Scale CCI
            features[startIndex + 13] = (cci[0] - cci[1]) / 100.0; // CCI change
        }
        
        // 14-19. Additional technical features
        features[startIndex + 14] = GetMomentum(4); // 4-period momentum
        features[startIndex + 15] = GetMomentum(9); // 9-period momentum
        features[startIndex + 16] = GetWilliamsR(14); // Williams %R
        features[startIndex + 17] = GetROC(10); // Rate of Change
        features[startIndex + 18] = GetStdDev(10); // Standard deviation
        features[startIndex + 19] = GetTrueRange(); // True Range
    }
    
    void ExtractMarketMicrostructure(double &features[], int startIndex)
    {
        // 0-1. Spread features
        double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
        double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
        double spread = ask - bid;
        double close = iClose(Symbol(), PERIOD_CURRENT, 0);
        
        features[startIndex + 0] = close > 0 ? spread / close * 10000.0 : 0.0; // Spread in basis points
        features[startIndex + 1] = spread / SymbolInfoDouble(Symbol(), SYMBOL_POINT); // Spread in points
        
        // 2-4. Volume features
        long volume = iVolume(Symbol(), PERIOD_CURRENT, 0);
        long prevVolume = iVolume(Symbol(), PERIOD_CURRENT, 1);
        long avgVolume = GetAverageVolume(20);
        
        features[startIndex + 2] = avgVolume > 0 ? (double)volume / avgVolume : 1.0; // Volume ratio
        features[startIndex + 3] = prevVolume > 0 ? (double)(volume - prevVolume) / prevVolume : 0.0; // Volume change
        features[startIndex + 4] = close > 0 ? (double)volume * close / 1000000.0 : 0.0; // Volume * Price (scaled)
        
        // 5-6. Tick features
        features[startIndex + 5] = GetTickCount(60); // Ticks in last minute
        features[startIndex + 6] = GetTickVelocity(); // Tick velocity
        
        // 7-9. Market depth and liquidity proxies
        features[startIndex + 7] = GetPriceImpact(); // Price impact estimate
        features[startIndex + 8] = GetMarketEfficiency(); // Market efficiency measure
        features[startIndex + 9] = GetVolatilityCluster(); // Volatility clustering
    }
    
    void ExtractTemporalFeatures(double &features[], int startIndex)
    {
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        // 0-3. Time of day features
        features[startIndex + 0] = dt.hour; // Hour (0-23)
        features[startIndex + 1] = dt.min / 60.0; // Minute as fraction of hour
        features[startIndex + 2] = MathSin(2 * M_PI * dt.hour / 24.0); // Hour sine
        features[startIndex + 3] = MathCos(2 * M_PI * dt.hour / 24.0); // Hour cosine
        
        // 4-5. Day of week features
        features[startIndex + 4] = dt.day_of_week; // Day of week (0-6)
        features[startIndex + 5] = MathSin(2 * M_PI * dt.day_of_week / 7.0); // Day sine
        
        // 6-7. Trading session features
        features[startIndex + 6] = GetTradingSession(); // Current session (0=Asian, 1=European, 2=American)
        features[startIndex + 7] = GetSessionOverlap(); // Session overlap indicator
        
        // 8-9. Market timing features
        features[startIndex + 8] = IsMarketOpen() ? 1.0 : 0.0; // Market open indicator
        features[startIndex + 9] = GetTimeToClose() / 3600.0; // Hours to market close
    }
    
    // Helper methods for technical indicators
    double GetMomentum(int period)
    {
        double current = iClose(Symbol(), PERIOD_CURRENT, 0);
        double past = iClose(Symbol(), PERIOD_CURRENT, period);
        return past > 0 ? (current - past) / past * 100.0 : 0.0;
    }
    
    double GetWilliamsR(int period)
    {
        double highest = 0, lowest = DBL_MAX;
        for(int i = 0; i < period; i++)
        {
            double high = iHigh(Symbol(), PERIOD_CURRENT, i);
            double low = iLow(Symbol(), PERIOD_CURRENT, i);
            if(high > highest) highest = high;
            if(low < lowest) lowest = low;
        }
        double close = iClose(Symbol(), PERIOD_CURRENT, 0);
        return highest > lowest ? (highest - close) / (highest - lowest) * (-100.0) : 0.0;
    }
    
    double GetROC(int period)
    {
        double current = iClose(Symbol(), PERIOD_CURRENT, 0);
        double past = iClose(Symbol(), PERIOD_CURRENT, period);
        return past > 0 ? (current - past) / past * 100.0 : 0.0;
    }
    
    double GetStdDev(int period)
    {
        double sum = 0, sumSq = 0;
        for(int i = 0; i < period; i++)
        {
            double price = iClose(Symbol(), PERIOD_CURRENT, i);
            sum += price;
            sumSq += price * price;
        }
        double mean = sum / period;
        double variance = (sumSq / period) - (mean * mean);
        return MathSqrt(MathMax(variance, 0.0));
    }
    
    double GetTrueRange()
    {
        double high = iHigh(Symbol(), PERIOD_CURRENT, 0);
        double low = iLow(Symbol(), PERIOD_CURRENT, 0);
        double prevClose = iClose(Symbol(), PERIOD_CURRENT, 1);
        
        double tr1 = high - low;
        double tr2 = MathAbs(high - prevClose);
        double tr3 = MathAbs(low - prevClose);
        
        return MathMax(tr1, MathMax(tr2, tr3));
    }
    
    // Helper methods for market microstructure
    long GetAverageVolume(int period)
    {
        long sum = 0;
        for(int i = 0; i < period; i++)
        {
            sum += iVolume(Symbol(), PERIOD_CURRENT, i);
        }
        return sum / period;
    }
    
    double GetTickCount(int seconds)
    {
        // Simplified tick count estimation
        return MathRand() % 100 + 50; // Placeholder - would need tick data in real implementation
    }
    
    double GetTickVelocity()
    {
        // Simplified tick velocity
        return (MathRand() % 20 + 10) / 10.0; // Placeholder
    }
    
    double GetPriceImpact()
    {
        double spread = SymbolInfoDouble(Symbol(), SYMBOL_ASK) - SymbolInfoDouble(Symbol(), SYMBOL_BID);
        double close = iClose(Symbol(), PERIOD_CURRENT, 0);
        return close > 0 ? spread / close * 10000.0 : 0.0;
    }
    
    double GetMarketEfficiency()
    {
        // Measure of price efficiency (simplified)
        double volatility = GetStdDev(20);
        double avgVolume = GetAverageVolume(20);
        return avgVolume > 0 ? volatility / MathLog(avgVolume + 1) : 0.0;
    }
    
    double GetVolatilityCluster()
    {
        // Volatility clustering measure
        double currentVol = GetStdDev(5);
        double avgVol = GetStdDev(20);
        return avgVol > 0 ? currentVol / avgVol : 1.0;
    }
    
    // Helper methods for temporal features
    int GetTradingSession()
    {
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        // Simplified session detection (UTC time)
        if(dt.hour >= 0 && dt.hour < 8) return 0;  // Asian session
        if(dt.hour >= 8 && dt.hour < 16) return 1; // European session
        return 2; // American session
    }
    
    double GetSessionOverlap()
    {
        int session = GetTradingSession();
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        // Check for session overlaps
        if((dt.hour >= 7 && dt.hour <= 9) || (dt.hour >= 15 && dt.hour <= 17))
            return 1.0; // Overlap period
        return 0.0;
    }
    
    bool IsMarketOpen()
    {
        // Simplified market open check
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        return (dt.day_of_week >= 1 && dt.day_of_week <= 5); // Monday to Friday
    }
    
    double GetTimeToClose()
    {
        // Simplified time to market close (in seconds)
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        if(dt.day_of_week == 5) // Friday
        {
            if(dt.hour >= 22) return 0; // Market closed
            return (22 - dt.hour) * 3600 - dt.min * 60 - dt.sec;
        }
        
        return 24 * 3600; // Full day if not Friday evening
    }
    
    void InitializeNormalizationStats()
    {
        // تهيئة إحصائيات التطبيع بقيم افتراضية معقولة
        
        // Price features - typical ranges for price-based features
        for(int i = 0; i < 10; i++)
        {
            m_priceMean[i] = 0.0;
            m_priceStd[i] = i < 4 ? 2.0 : 5.0; // Price changes: smaller std, ratios: larger std
        }
        
        // Technical indicators - typical ranges
        for(int i = 0; i < 20; i++)
        {
            m_techMean[i] = 0.0;
            if(i < 2) m_techStd[i] = 30.0;      // RSI-based
            else if(i < 5) m_techStd[i] = 0.001; // MACD-based  
            else if(i < 8) m_techStd[i] = 20.0;  // BB-based
            else if(i < 10) m_techStd[i] = 40.0; // Stochastic
            else if(i < 14) m_techStd[i] = 2.0;  // ATR, CCI
            else m_techStd[i] = 10.0;            // Others
        }
        
        // Market microstructure - typical ranges
        for(int i = 0; i < 10; i++)
        {
            m_microMean[i] = 0.0;
            if(i < 2) m_microStd[i] = 5.0;       // Spread features
            else if(i < 5) m_microStd[i] = 2.0;  // Volume features
            else if(i < 7) m_microStd[i] = 50.0; // Tick features
            else m_microStd[i] = 1.0;            // Others
        }
        
        // Temporal features - typical ranges
        for(int i = 0; i < 10; i++)
        {
            m_temporalMean[i] = 0.0;
            if(i < 2) m_temporalStd[i] = 12.0;   // Time features
            else if(i < 6) m_temporalStd[i] = 1.0; // Sine/cosine, day features
            else m_temporalStd[i] = 2.0;         // Session and market features
        }
    }
    
    void CalculateGroupStats(double data[][], int dataSize, int startIdx, int groupSize, 
                           double &means[], double &stds[])
    {
        // حساب المتوسط
        for(int feature = 0; feature < groupSize; feature++)
        {
            double sum = 0.0;
            for(int sample = 0; sample < dataSize; sample++)
            {
                sum += data[sample][startIdx + feature];
            }
            means[feature] = sum / dataSize;
        }
        
        // حساب الانحراف المعياري
        for(int feature = 0; feature < groupSize; feature++)
        {
            double sumSq = 0.0;
            for(int sample = 0; sample < dataSize; sample++)
            {
                double diff = data[sample][startIdx + feature] - means[feature];
                sumSq += diff * diff;
            }
            stds[feature] = MathSqrt(sumSq / (dataSize - 1));
            
            // تجنب الانحراف المعياري الصفري
            if(stds[feature] < 0.0001)
                stds[feature] = 1.0;
        }
    }
    
    void Cleanup()
    {
        if(m_rsiHandle != INVALID_HANDLE) IndicatorRelease(m_rsiHandle);
        if(m_macdHandle != INVALID_HANDLE) IndicatorRelease(m_macdHandle);
        if(m_bbHandle != INVALID_HANDLE) IndicatorRelease(m_bbHandle);
        if(m_ma5Handle != INVALID_HANDLE) IndicatorRelease(m_ma5Handle);
        if(m_ma10Handle != INVALID_HANDLE) IndicatorRelease(m_ma10Handle);
        if(m_ma20Handle != INVALID_HANDLE) IndicatorRelease(m_ma20Handle);
        if(m_ma50Handle != INVALID_HANDLE) IndicatorRelease(m_ma50Handle);
        if(m_stochHandle != INVALID_HANDLE) IndicatorRelease(m_stochHandle);
        if(m_atrHandle != INVALID_HANDLE) IndicatorRelease(m_atrHandle);
        if(m_cciHandle != INVALID_HANDLE) IndicatorRelease(m_cciHandle);
    }
};
