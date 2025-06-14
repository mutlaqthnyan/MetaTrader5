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
#define MAX_CACHED_INDICATORS 50
#define CACHE_EXPIRY_SECONDS 30

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

struct IndicatorCache
{
   string            symbol;
   string            indicatorType;
   int               period;
   int               handle;
   datetime          lastUpdate;
   double            values[];
   bool              isValid;
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

//+------------------------------------------------------------------+
//| Neural Network Class - Real Implementation                       |
//+------------------------------------------------------------------+
class CNeuralNetwork
{
private:
    // Network architecture: 50-30-20-3
    double m_weights1[50][30];    // Input -> Hidden1
    double m_weights2[30][20];    // Hidden1 -> Hidden2  
    double m_weights3[20][3];     // Hidden2 -> Output
    double m_biases1[30];         // Hidden1 biases
    double m_biases2[20];         // Hidden2 biases
    double m_biases3[3];          // Output biases
    
    // Training parameters
    double m_learningRate;
    double m_initialLearningRate;
    double m_learningRateDecay;
    double m_momentum;
    bool m_isInitialized;
    double m_lastAccuracy;
    int m_trainingEpoch;
    
    // Temporary arrays for forward/backward pass
    double m_hidden1[30];
    double m_hidden2[20];
    double m_output[3];
    
    // Intermediate calculations for detailed forward pass
    double m_z1[30];  // Pre-activation layer 1
    double m_a1[30];  // Post-activation layer 1
    double m_z2[20];  // Pre-activation layer 2
    double m_a2[20];  // Post-activation layer 2
    double m_z3[3];   // Pre-activation output
    
    // Momentum arrays for weight updates
    double m_momentum_weights1[50][30];
    double m_momentum_weights2[30][20];
    double m_momentum_weights3[20][3];
    double m_momentum_biases1[30];
    double m_momentum_biases2[20];
    double m_momentum_biases3[3];
    
    // Activation functions
    double ReLU(double x) { return MathMax(0.0, x); }
    double ReLUDerivative(double x) { return (x > 0) ? 1.0 : 0.0; }
    
    void Softmax(double inputs[], double outputs[], int size)
    {
        double sum = 0;
        double maxVal = inputs[0];
        
        // Find max for numerical stability
        for(int i = 1; i < size; i++)
            if(inputs[i] > maxVal) maxVal = inputs[i];
        
        // Calculate softmax
        for(int i = 0; i < size; i++)
        {
            outputs[i] = MathExp(inputs[i] - maxVal);
            sum += outputs[i];
        }
        
        for(int i = 0; i < size; i++)
            outputs[i] /= sum;
    }
    
    void NormalizeInputs(double inputs[], int size)
    {
        double mean = 0, variance = 0;
        
        // Calculate mean
        for(int i = 0; i < size; i++)
            mean += inputs[i];
        mean /= size;
        
        // Calculate variance
        for(int i = 0; i < size; i++)
            variance += MathPow(inputs[i] - mean, 2);
        variance /= size;
        
        double stdDev = MathSqrt(variance + 1e-8); // Add small epsilon
        
        // Normalize
        for(int i = 0; i < size; i++)
            inputs[i] = (inputs[i] - mean) / stdDev;
    }

public:
    CNeuralNetwork()
    {
        m_learningRate = 0.001;
        m_initialLearningRate = 0.001;
        m_learningRateDecay = 0.95;
        m_momentum = 0.9;
        m_isInitialized = false;
        m_lastAccuracy = 0.0;
        m_trainingEpoch = 0;
    }
    
    bool Initialize(double learningRate = 0.001)
    {
        m_learningRate = learningRate;
        
        // Initialize weights with Xavier initialization
        double limit1 = MathSqrt(6.0 / (50 + 30));
        double limit2 = MathSqrt(6.0 / (30 + 20));
        double limit3 = MathSqrt(6.0 / (20 + 3));
        
        // Initialize weights1 (50x30)
        for(int i = 0; i < 50; i++)
        {
            for(int j = 0; j < 30; j++)
            {
                m_weights1[i][j] = (MathRand() / 16383.5 - 1.0) * limit1;
            }
        }
        
        // Initialize weights2 (30x20)
        for(int i = 0; i < 30; i++)
        {
            for(int j = 0; j < 20; j++)
            {
                m_weights2[i][j] = (MathRand() / 16383.5 - 1.0) * limit2;
            }
        }
        
        // Initialize weights3 (20x3)
        for(int i = 0; i < 20; i++)
        {
            for(int j = 0; j < 3; j++)
            {
                m_weights3[i][j] = (MathRand() / 16383.5 - 1.0) * limit3;
            }
        }
        
        // Initialize biases to zero
        ArrayInitialize(m_biases1, 0.0);
        ArrayInitialize(m_biases2, 0.0);
        ArrayInitialize(m_biases3, 0.0);
        
        // Initialize momentum arrays to zero
        for(int i = 0; i < 50; i++)
            for(int j = 0; j < 30; j++)
                m_momentum_weights1[i][j] = 0.0;
                
        for(int i = 0; i < 30; i++)
            for(int j = 0; j < 20; j++)
                m_momentum_weights2[i][j] = 0.0;
                
        for(int i = 0; i < 20; i++)
            for(int j = 0; j < 3; j++)
                m_momentum_weights3[i][j] = 0.0;
                
        ArrayInitialize(m_momentum_biases1, 0.0);
        ArrayInitialize(m_momentum_biases2, 0.0);
        ArrayInitialize(m_momentum_biases3, 0.0);
        
        m_isInitialized = true;
        return true;
    }
    
    double Forward(double inputs[])
    {
        double outputs[3];
        ForwardDetailed(inputs, outputs);
        
        // Return the index of highest probability as confidence score
        int maxIndex = 0;
        for(int i = 1; i < 3; i++)
            if(outputs[i] > outputs[maxIndex]) maxIndex = i;
        
        // Convert to trading score: Buy=100, Hold=50, Sell=0
        if(maxIndex == 0) return outputs[0] * 100;      // Buy probability
        else if(maxIndex == 2) return outputs[2] * 100; // Sell probability  
        else return 50.0;                               // Hold
    }
    
    void ForwardDetailed(double inputs[], double outputs[])
    {
        if(!m_isInitialized) return;
        
        // Normalize inputs
        double normalizedInputs[50];
        ArrayCopy(normalizedInputs, inputs, 0, 0, 50);
        NormalizeInputs(normalizedInputs, 50);
        
        // Layer 1: Input -> Hidden1
        // z1 = weights1 × inputs + biases1
        for(int j = 0; j < 30; j++)
        {
            m_z1[j] = m_biases1[j];
            for(int i = 0; i < 50; i++)
            {
                m_z1[j] += normalizedInputs[i] * m_weights1[i][j];
            }
            // a1 = ReLU(z1)
            m_a1[j] = ReLU(m_z1[j]);
            m_hidden1[j] = m_a1[j];
        }
        
        // Layer 2: Hidden1 -> Hidden2
        // z2 = weights2 × a1 + biases2
        for(int j = 0; j < 20; j++)
        {
            m_z2[j] = m_biases2[j];
            for(int i = 0; i < 30; i++)
            {
                m_z2[j] += m_a1[i] * m_weights2[i][j];
            }
            // a2 = ReLU(z2)
            m_a2[j] = ReLU(m_z2[j]);
            m_hidden2[j] = m_a2[j];
        }
        
        // Layer 3: Hidden2 -> Output
        // z3 = weights3 × a2 + biases3
        for(int j = 0; j < 3; j++)
        {
            m_z3[j] = m_biases3[j];
            for(int i = 0; i < 20; i++)
            {
                m_z3[j] += m_a2[i] * m_weights3[i][j];
            }
        }
        
        // output = Softmax(z3)
        Softmax(m_z3, outputs, 3);
        ArrayCopy(m_output, outputs, 0, 0, 3);
    }
    
    void Backward(double target[], double learning_rate)
    {
        if(!m_isInitialized) return;
        
        // Apply learning rate decay
        double current_lr = learning_rate * MathPow(m_learningRateDecay, m_trainingEpoch / 100.0);
        
        // حساب الخطأ - Calculate Error
        // Output layer gradients (dL/dz3)
        double outputGradients[3];
        for(int i = 0; i < 3; i++)
        {
            outputGradients[i] = m_output[i] - target[i];
        }
        
        // تطبيق chain rule - Apply Chain Rule
        // Hidden2 gradients (dL/dz2)
        double hidden2Gradients[20];
        for(int i = 0; i < 20; i++)
        {
            hidden2Gradients[i] = 0;
            for(int j = 0; j < 3; j++)
            {
                hidden2Gradients[i] += outputGradients[j] * m_weights3[i][j];
            }
            hidden2Gradients[i] *= ReLUDerivative(m_z2[i]);
        }
        
        // Hidden1 gradients (dL/dz1)
        double hidden1Gradients[30];
        for(int i = 0; i < 30; i++)
        {
            hidden1Gradients[i] = 0;
            for(int j = 0; j < 20; j++)
            {
                hidden1Gradients[i] += hidden2Gradients[j] * m_weights2[i][j];
            }
            hidden1Gradients[i] *= ReLUDerivative(m_z1[i]);
        }
        
        // تحديث الأوزان والانحيازات - Update Weights and Biases
        // استخدم momentum = 0.9 - Use momentum = 0.9
        
        // Update weights3 and biases3 with momentum
        for(int i = 0; i < 20; i++)
        {
            for(int j = 0; j < 3; j++)
            {
                double gradient = outputGradients[j] * m_a2[i];
                m_momentum_weights3[i][j] = m_momentum * m_momentum_weights3[i][j] + current_lr * gradient;
                m_weights3[i][j] -= m_momentum_weights3[i][j];
            }
        }
        for(int i = 0; i < 3; i++)
        {
            m_momentum_biases3[i] = m_momentum * m_momentum_biases3[i] + current_lr * outputGradients[i];
            m_biases3[i] -= m_momentum_biases3[i];
        }
        
        // Update weights2 and biases2 with momentum
        for(int i = 0; i < 30; i++)
        {
            for(int j = 0; j < 20; j++)
            {
                double gradient = hidden2Gradients[j] * m_a1[i];
                m_momentum_weights2[i][j] = m_momentum * m_momentum_weights2[i][j] + current_lr * gradient;
                m_weights2[i][j] -= m_momentum_weights2[i][j];
            }
        }
        for(int i = 0; i < 20; i++)
        {
            m_momentum_biases2[i] = m_momentum * m_momentum_biases2[i] + current_lr * hidden2Gradients[i];
            m_biases2[i] -= m_momentum_biases2[i];
        }
        
        // Update weights1 and biases1 with momentum
        for(int i = 0; i < 50; i++)
        {
            for(int j = 0; j < 30; j++)
            {
                double gradient = hidden1Gradients[j] * m_a1[i];
                m_momentum_weights1[i][j] = m_momentum * m_momentum_weights1[i][j] + current_lr * gradient;
                m_weights1[i][j] -= m_momentum_weights1[i][j];
            }
        }
        for(int i = 0; i < 30; i++)
        {
            m_momentum_biases1[i] = m_momentum * m_momentum_biases1[i] + current_lr * hidden1Gradients[i];
            m_biases1[i] -= m_momentum_biases1[i];
        }
        
        // Increment training epoch for learning rate decay
        m_trainingEpoch++;
    }
    
    // Training statistics
    double m_bestValAccuracy;
    int m_epochsWithoutImprovement;
    double m_trainingLoss;
    double m_validationLoss;
    
    bool Train(double data[][], double labels[], int epochs)
    {
        if(!m_isInitialized) return false;
        
        int dataSize = ArrayRange(data, 0);
        if(dataSize < 10) return false;
        
        // تقسيم البيانات: 80% training, 20% validation
        int trainSize = (int)(dataSize * 0.8);
        int valSize = dataSize - trainSize;
        
        if(trainSize < 5 || valSize < 2) return false;
        
        // إنشاء مصفوفات التدريب والتحقق
        double trainData[][], trainLabels[], valData[][], valLabels[];
        ArrayResize(trainData, trainSize);
        ArrayResize(trainLabels, trainSize);
        ArrayResize(valData, valSize);
        ArrayResize(valLabels, valSize);
        
        for(int i = 0; i < trainSize; i++)
        {
            ArrayResize(trainData[i], 50);
            for(int j = 0; j < 50; j++) trainData[i][j] = data[i][j];
            trainLabels[i] = labels[i];
        }
        
        for(int i = 0; i < valSize; i++)
        {
            ArrayResize(valData[i], 50);
            for(int j = 0; j < 50; j++) valData[i][j] = data[trainSize + i][j];
            valLabels[i] = labels[trainSize + i];
        }
        
        return TrainWithValidation(trainData, trainLabels, valData, valLabels, epochs);
    }
    
    bool TrainWithValidation(double trainData[][], double trainLabels[], double valData[][], double valLabels[], int epochs)
    {
        if(!m_isInitialized) return false;
        
        int trainSize = ArraySize(trainLabels);
        int valSize = ArraySize(valLabels);
        int batchSize = 32; // Batch size = 32 كما هو مطلوب
        
        m_bestValAccuracy = 0.0;
        m_epochsWithoutImprovement = 0;
        
        Print("🚀 بدء التدريب المتقدم:");
        Print("   📊 Training samples: ", trainSize);
        Print("   📊 Validation samples: ", valSize);
        Print("   📊 Batch size: ", batchSize);
        Print("   🎯 Target accuracy: >65%");
        
        for(int epoch = 0; epoch < epochs; epoch++)
        {
            // تدريب بـ mini-batches
            double epochTrainLoss = 0;
            int numBatches = (trainSize + batchSize - 1) / batchSize; // Ceiling division
            
            // خلط البيانات في كل epoch (محاكاة)
            for(int shuffle = 0; shuffle < 3; shuffle++)
            {
                int idx1 = (int)(MathRand() / 32767.0 * trainSize);
                int idx2 = (int)(MathRand() / 32767.0 * trainSize);
                
                // تبديل العينات
                double tempLabel = trainLabels[idx1];
                trainLabels[idx1] = trainLabels[idx2];
                trainLabels[idx2] = tempLabel;
                
                for(int j = 0; j < 50; j++)
                {
                    double tempData = trainData[idx1][j];
                    trainData[idx1][j] = trainData[idx2][j];
                    trainData[idx2][j] = tempData;
                }
            }
            
            for(int batch = 0; batch < numBatches; batch++)
            {
                int batchStart = batch * batchSize;
                int batchEnd = MathMin(batchStart + batchSize, trainSize);
                double batchLoss = 0;
                
                // تدريب على الـ batch الحالي
                for(int i = batchStart; i < batchEnd; i++)
                {
                    double inputs[50], outputs[3];
                    for(int j = 0; j < 50; j++) inputs[j] = trainData[i][j];
                    
                    // Forward pass
                    ForwardDetailed(inputs, outputs);
                    
                    // Prepare target
                    double target[3] = {0, 0, 0};
                    int labelIndex = (int)trainLabels[i];
                    if(labelIndex >= 0 && labelIndex < 3) target[labelIndex] = 1.0;
                    
                    // Backward pass
                    Backward(target, m_learningRate);
                    
                    // حساب خطأ الـ batch
                    for(int k = 0; k < 3; k++)
                        batchLoss += (target[k] - outputs[k]) * (target[k] - outputs[k]);
                }
                
                epochTrainLoss += batchLoss / (batchEnd - batchStart);
            }
            
            m_trainingLoss = epochTrainLoss / numBatches;
            
            // تقييم على بيانات التحقق كل 5 epochs
            if(epoch % 5 == 0)
            {
                double valLoss = 0;
                int correctPredictions = 0;
                
                for(int i = 0; i < valSize; i++)
                {
                    double inputs[50], outputs[3];
                    for(int j = 0; j < 50; j++) inputs[j] = valData[i][j];
                    
                    ForwardDetailed(inputs, outputs);
                    
                    // حساب الدقة
                    int predictedClass = 0;
                    double maxOutput = outputs[0];
                    for(int k = 1; k < 3; k++)
                    {
                        if(outputs[k] > maxOutput)
                        {
                            maxOutput = outputs[k];
                            predictedClass = k;
                        }
                    }
                    
                    if(predictedClass == (int)valLabels[i])
                        correctPredictions++;
                    
                    // حساب خطأ التحقق
                    double target[3] = {0, 0, 0};
                    int labelIndex = (int)valLabels[i];
                    if(labelIndex >= 0 && labelIndex < 3) target[labelIndex] = 1.0;
                    
                    for(int k = 0; k < 3; k++)
                        valLoss += (target[k] - outputs[k]) * (target[k] - outputs[k]);
                }
                
                m_validationLoss = valLoss / (valSize * 3);
                double valAccuracy = (double)correctPredictions / valSize * 100.0;
                
                Print("📈 Epoch ", epoch, ":");
                Print("   🔥 Train Loss: ", DoubleToString(m_trainingLoss, 6));
                Print("   📊 Val Loss: ", DoubleToString(m_validationLoss, 6));
                Print("   🎯 Val Accuracy: ", DoubleToString(valAccuracy, 2), "%");
                
                // Early stopping logic
                if(valAccuracy > m_bestValAccuracy)
                {
                    m_bestValAccuracy = valAccuracy;
                    m_epochsWithoutImprovement = 0;
                    
                    // حفظ أفضل model حسب validation accuracy
                    SaveModel("best_model.dat");
                    Print("   ✅ أفضل نموذج محفوظ - دقة: ", DoubleToString(valAccuracy, 2), "%");
                }
                else
                {
                    m_epochsWithoutImprovement++;
                    
                    // Early stopping عند عدم التحسن لـ 10 epochs
                    if(m_epochsWithoutImprovement >= 10)
                    {
                        Print("   ⏹️ إيقاف مبكر - لا تحسن لـ 10 epochs");
                        LoadModel("best_model.dat"); // استرجاع أفضل نموذج
                        break;
                    }
                }
                
                // الهدف: accuracy > 65%
                if(valAccuracy > 65.0)
                {
                    Print("   🏆 تم الوصول للهدف - دقة: ", DoubleToString(valAccuracy, 2), "%");
                    return true;
                }
            }
            else if(epoch % 1 == 0) // تقرير مبسط كل epoch
            {
                Print("Epoch ", epoch, " - Train Loss: ", DoubleToString(m_trainingLoss, 6));
            }
        }
        
        Print("🏁 انتهاء التدريب:");
        Print("   🏆 أفضل دقة: ", DoubleToString(m_bestValAccuracy, 2), "%");
        Print("   📊 Epochs بدون تحسن: ", m_epochsWithoutImprovement);
        
        return m_bestValAccuracy > 50.0; // نجح إذا كانت الدقة > 50%
    }
    
    bool SaveModel(string filename)
    {
        int handle = FileOpen(filename, FILE_WRITE|FILE_BIN);
        if(handle == INVALID_HANDLE)
        {
            Print("خطأ في حفظ النموذج: ", filename);
            return false;
        }
        
        // Save network architecture info
        FileWriteInteger(handle, 50); // Input size
        FileWriteInteger(handle, 30); // Hidden1 size
        FileWriteInteger(handle, 20); // Hidden2 size
        FileWriteInteger(handle, 3);  // Output size
        
        // Save weights and biases
        for(int i = 0; i < 50; i++)
            for(int j = 0; j < 30; j++)
                FileWriteDouble(handle, m_weights1[i][j]);
                
        for(int i = 0; i < 30; i++)
            for(int j = 0; j < 20; j++)
                FileWriteDouble(handle, m_weights2[i][j]);
                
        for(int i = 0; i < 20; i++)
            for(int j = 0; j < 3; j++)
                FileWriteDouble(handle, m_weights3[i][j]);
        
        for(int i = 0; i < 30; i++)
            FileWriteDouble(handle, m_biases1[i]);
        for(int i = 0; i < 20; i++)
            FileWriteDouble(handle, m_biases2[i]);
        for(int i = 0; i < 3; i++)
            FileWriteDouble(handle, m_biases3[i]);
        
        FileWriteDouble(handle, m_learningRate);
        FileWriteDouble(handle, m_lastAccuracy);
        
        FileClose(handle);
        Print("تم حفظ النموذج: ", filename);
        return true;
    }
    
    bool LoadModel(string filename)
    {
        int handle = FileOpen(filename, FILE_READ|FILE_BIN);
        if(handle == INVALID_HANDLE)
        {
            Print("خطأ في تحميل النموذج: ", filename);
            return false;
        }
        
        // Verify architecture
        int inputSize = FileReadInteger(handle);
        int hidden1Size = FileReadInteger(handle);
        int hidden2Size = FileReadInteger(handle);
        int outputSize = FileReadInteger(handle);
        
        if(inputSize != 50 || hidden1Size != 30 || hidden2Size != 20 || outputSize != 3)
        {
            Print("خطأ: بنية النموذج غير متطابقة");
            FileClose(handle);
            return false;
        }
        
        // Load weights and biases
        for(int i = 0; i < 50; i++)
            for(int j = 0; j < 30; j++)
                m_weights1[i][j] = FileReadDouble(handle);
                
        for(int i = 0; i < 30; i++)
            for(int j = 0; j < 20; j++)
                m_weights2[i][j] = FileReadDouble(handle);
                
        for(int i = 0; i < 20; i++)
            for(int j = 0; j < 3; j++)
                m_weights3[i][j] = FileReadDouble(handle);
        
        for(int i = 0; i < 30; i++)
            m_biases1[i] = FileReadDouble(handle);
        for(int i = 0; i < 20; i++)
            m_biases2[i] = FileReadDouble(handle);
        for(int i = 0; i < 3; i++)
            m_biases3[i] = FileReadDouble(handle);
        
        m_learningRate = FileReadDouble(handle);
        m_lastAccuracy = FileReadDouble(handle);
        
        FileClose(handle);
        m_isInitialized = true;
        Print("تم تحميل النموذج: ", filename, " - الدقة: ", DoubleToString(m_lastAccuracy, 2), "%");
        return true;
    }
    
    double GetAccuracy() { return m_lastAccuracy; }
    string GetPredictionString(double outputs[])
    {
        if(outputs[0] > outputs[1] && outputs[0] > outputs[2])
            return "شراء (" + DoubleToString(outputs[0]*100, 1) + "%)";
        else if(outputs[1] > outputs[0] && outputs[1] > outputs[2])
            return "بيع (" + DoubleToString(outputs[1]*100, 1) + "%)";
        else
            return "انتظار (" + DoubleToString(outputs[2]*100, 1) + "%)";
    }
};

//+------------------------------------------------------------------+
//| CDataPreprocessor Class - معالج البيانات المتقدم                    |
//+------------------------------------------------------------------+
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

// Global neural network instance
CNeuralNetwork g_neuralNetwork;

// Global data preprocessor instance
CDataPreprocessor g_dataPreprocessor;

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
IndicatorCache            g_indicatorCache[];
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
   ArrayResize(g_indicatorCache, 0);

   if(!InitializeSubsystems())
   {
      Print("❌ فشلت تهيئة الأنظمة الفرعية!");
      return INIT_FAILED;
   }

   // Initialize Neural Network
   if(InpEnableMLPrediction)
   {
      if(!g_neuralNetwork.Initialize(0.001))
      {
         Print("❌ خطأ في تهيئة الشبكة العصبية");
         return INIT_FAILED;
      }
      
      // Try to load existing model
      if(!g_neuralNetwork.LoadModel("QuantumNN_Model.bin"))
      {
         Print("⚠️ لم يتم العثور على نموذج محفوظ - سيتم استخدام أوزان عشوائية");
         Print("💡 يُنصح بتدريب النموذج لتحسين الأداء");
      }
      else
      {
         Print("✅ تم تحميل النموذج المحفوظ بنجاح");
      }
   }

   // Initialize Data Preprocessor
   if(InpEnableMLPrediction)
   {
      if(!g_dataPreprocessor.Initialize())
      {
         Print("❌ خطأ في تهيئة معالج البيانات");
         return INIT_FAILED;
      }
      else
      {
         Print("✅ تم تهيئة معالج البيانات بنجاح");
      }
   }

   EventSetTimer(5);

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
   
   static datetime lastTraining = 0;
   static datetime lastCacheUpdate = 0;
   
   // Update indicator cache every 5 seconds
   if(TimeCurrent() - lastCacheUpdate >= 5)
   {
      UpdateIndicatorCache();
      lastCacheUpdate = TimeCurrent();
   }
   
   // Train neural network once per day (24 hours = 86400 seconds)
   if(InpEnableMLPrediction && g_neuralNetwork.m_isInitialized && 
      TimeCurrent() - lastTraining >= 86400)
   {
      Print("بدء التدريب الدوري للشبكة العصبية...");
      TrainNeuralNetwork();
      lastTraining = TimeCurrent();
   }
   
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

//+------------------------------------------------------------------+
//| Prepare 50 Neural Network Input Features                         |
//+------------------------------------------------------------------+
bool PrepareNeuralInputs(string symbol, double inputs[])
{
    if(ArraySize(inputs) < 50) ArrayResize(inputs, 50);
    ArrayInitialize(inputs, 0.0);
    
    // Get market data
    double close[], high[], low[], open[], volume[];
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(volume, true);
    
    if(CopyClose(symbol, PERIOD_CURRENT, 0, 20, close) <= 0 ||
       CopyHigh(symbol, PERIOD_CURRENT, 0, 20, high) <= 0 ||
       CopyLow(symbol, PERIOD_CURRENT, 0, 20, low) <= 0 ||
       CopyOpen(symbol, PERIOD_CURRENT, 0, 20, open) <= 0 ||
       CopyTickVolume(symbol, PERIOD_CURRENT, 0, 20, volume) <= 0)
    {
        Print("خطأ في جلب بيانات السوق للرمز: ", symbol);
        return false;
    }
    
    int idx = 0;
    
    // Group 1: Price Data (15 features)
    // Features 0-4: Price changes for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(close)-1; i++)
    {
        inputs[idx++] = (close[i] - close[i+1]) / close[i+1];
    }
    
    // Features 5-9: Close/Open ratios for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(close); i++)
    {
        inputs[idx++] = (close[i] - open[i]) / open[i];
    }
    
    // Features 10-14: High/Low ratios for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(high); i++)
    {
        inputs[idx++] = (high[i] - low[i]) / low[i];
    }
    
    // Group 2: Technical Indicators (20 features)
    // Features 15-17: Moving Averages
    double ma20[], ma50[], ma200[];
    ArraySetAsSeries(ma20, true);
    ArraySetAsSeries(ma50, true);
    ArraySetAsSeries(ma200, true);
    
    int ma20_handle = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
    int ma50_handle = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
    int ma200_handle = iMA(symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
    
    if(ma20_handle != INVALID_HANDLE && CopyBuffer(ma20_handle, 0, 0, 3, ma20) > 0)
        inputs[idx++] = (close[0] - ma20[0]) / close[0];
    else inputs[idx++] = 0;
    
    if(ma50_handle != INVALID_HANDLE && CopyBuffer(ma50_handle, 0, 0, 3, ma50) > 0)
        inputs[idx++] = (close[0] - ma50[0]) / close[0];
    else inputs[idx++] = 0;
    
    if(ma200_handle != INVALID_HANDLE && CopyBuffer(ma200_handle, 0, 0, 3, ma200) > 0)
        inputs[idx++] = (close[0] - ma200[0]) / close[0];
    else inputs[idx++] = 0;
    
    // Features 18-20: RSI, MACD, Stochastic
    double rsi[], macd_main[], macd_signal[], stoch_main[], stoch_signal[];
    ArraySetAsSeries(rsi, true);
    ArraySetAsSeries(macd_main, true);
    ArraySetAsSeries(macd_signal, true);
    ArraySetAsSeries(stoch_main, true);
    ArraySetAsSeries(stoch_signal, true);
    
    
    int rsi_handle = iRSI(symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    int macd_handle = iMACD(symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    int stoch_handle = iStochastic(symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
    
    if(rsi_handle != INVALID_HANDLE && CopyBuffer(rsi_handle, 0, 0, 1, rsi) > 0)
        inputs[idx++] = (rsi[0] - 50.0) / 50.0; // Normalize RSI
    else inputs[idx++] = 0;
    
    if(macd_handle != INVALID_HANDLE && 
       CopyBuffer(macd_handle, 0, 0, 1, macd_main) > 0 &&
       CopyBuffer(macd_handle, 1, 0, 1, macd_signal) > 0)
        inputs[idx++] = (macd_main[0] - macd_signal[0]) / close[0];
    else inputs[idx++] = 0;
    
    if(stoch_handle != INVALID_HANDLE && CopyBuffer(stoch_handle, 0, 0, 1, stoch_main) > 0)
        inputs[idx++] = (stoch_main[0] - 50.0) / 50.0; // Normalize Stochastic
    else inputs[idx++] = 0;
    
    // Features 21-23: Bollinger Bands
    double bb_upper[], bb_middle[], bb_lower[];
    ArraySetAsSeries(bb_upper, true);
    ArraySetAsSeries(bb_middle, true);
    ArraySetAsSeries(bb_lower, true);
    
    int bb_handle = iBands(symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    if(bb_handle != INVALID_HANDLE && 
       CopyBuffer(bb_handle, 0, 0, 1, bb_middle) > 0 &&
       CopyBuffer(bb_handle, 1, 0, 1, bb_upper) > 0 &&
       CopyBuffer(bb_handle, 2, 0, 1, bb_lower) > 0)
    {
        inputs[idx++] = (close[0] - bb_upper[0]) / (bb_upper[0] - bb_lower[0]);
        inputs[idx++] = (close[0] - bb_middle[0]) / bb_middle[0];
        inputs[idx++] = (close[0] - bb_lower[0]) / (bb_upper[0] - bb_lower[0]);
    }
    else
    {
        inputs[idx++] = 0; inputs[idx++] = 0; inputs[idx++] = 0;
    }
    
    // Features 24-26: ATR, ADX, CCI
    double atr[], adx[], cci[];
    ArraySetAsSeries(atr, true);
    ArraySetAsSeries(adx, true);
    ArraySetAsSeries(cci, true);
    
    int atr_handle = iATR(symbol, PERIOD_CURRENT, 14);
    int adx_handle = iADX(symbol, PERIOD_CURRENT, 14);
    int cci_handle = iCCI(symbol, PERIOD_CURRENT, 14, PRICE_TYPICAL);
    
    if(atr_handle != INVALID_HANDLE && CopyBuffer(atr_handle, 0, 0, 1, atr) > 0)
        inputs[idx++] = atr[0] / close[0];
    else inputs[idx++] = 0;
    
    if(adx_handle != INVALID_HANDLE && CopyBuffer(adx_handle, 0, 0, 1, adx) > 0)
        inputs[idx++] = (adx[0] - 25.0) / 75.0; // Normalize ADX
    else inputs[idx++] = 0;
    
    if(cci_handle != INVALID_HANDLE && CopyBuffer(cci_handle, 0, 0, 1, cci) > 0)
        inputs[idx++] = MathMax(-1.0, MathMin(1.0, cci[0] / 200.0)); // Normalize CCI
    else inputs[idx++] = 0;
    
    // Features 27-29: Williams %R, MFI, OBV (simplified)
    inputs[idx++] = (close[0] - high[0]) / (high[0] - low[0]); // Williams %R approximation
    inputs[idx++] = volume[0] > volume[1] ? 1.0 : -1.0; // MFI direction approximation
    inputs[idx++] = (close[0] > close[1]) ? volume[0] : -volume[0]; // OBV approximation
    
    // Features 30-34: Additional technical features
    for(int i = 30; i < 35; i++)
        inputs[idx++] = 0; // Placeholder for future indicators
    
    // Group 3: Volume and Liquidity Data (10 features)
    // Features 35-39: Volume for last 5 candles (normalized)
    double avgVolume = 0;
    for(int i = 0; i < 10 && i < ArraySize(volume); i++)
        avgVolume += volume[i];
    avgVolume /= 10;
    
    for(int i = 0; i < 5 && i < ArraySize(volume); i++)
    {
        inputs[idx++] = (volume[i] - avgVolume) / avgVolume;
    }
    
    // Features 40-44: Volume-related features
    inputs[idx++] = volume[0] / volume[1]; // Volume ratio
    inputs[idx++] = (volume[0] - volume[1]) / volume[1]; // Volume change
    inputs[idx++] = SymbolInfoDouble(symbol, SYMBOL_ASK) - SymbolInfoDouble(symbol, SYMBOL_BID); // Spread
    inputs[idx++] = SymbolInfoDouble(symbol, SYMBOL_VOLUME) / 1000000.0; // Market depth approximation
    inputs[idx++] = close[0]; // VWAP approximation (simplified)
    
    // Group 4: Time and Session Context (5 features)
    // Features 45-49: Time-based features
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    inputs[idx++] = dt.hour / 24.0; // Hour of day (0-1)
    inputs[idx++] = dt.day_of_week / 7.0; // Day of week (0-1)
    inputs[idx++] = GetSessionVolatilityFactor(); // Session factor
    inputs[idx++] = GetVolatilityMultiplier(symbol); // Volatility multiplier
    inputs[idx++] = AnalyzeTrendDirection(symbol) / 100.0; // Trend strength
    
    // Release indicator handles
    if(ma20_handle != INVALID_HANDLE) IndicatorRelease(ma20_handle);
    if(ma50_handle != INVALID_HANDLE) IndicatorRelease(ma50_handle);
    if(ma200_handle != INVALID_HANDLE) IndicatorRelease(ma200_handle);
    if(rsi_handle != INVALID_HANDLE) IndicatorRelease(rsi_handle);
    if(macd_handle != INVALID_HANDLE) IndicatorRelease(macd_handle);
    if(stoch_handle != INVALID_HANDLE) IndicatorRelease(stoch_handle);
    if(bb_handle != INVALID_HANDLE) IndicatorRelease(bb_handle);
    if(atr_handle != INVALID_HANDLE) IndicatorRelease(atr_handle);
    if(adx_handle != INVALID_HANDLE) IndicatorRelease(adx_handle);
    if(cci_handle != INVALID_HANDLE) IndicatorRelease(cci_handle);
    
    return true;
}

bool GenerateSignal(string symbol, TradingSignal &signal)
{
   double score = g_marketEngine.AnalyzeSymbolComplete(symbol);
   
   if(InpEnableQuantumAnalysis)
   {
      score += g_marketEngine.GetQuantumAnalysisScore(symbol);
   }
   
   // Neural Network Integration with High-Confidence Override
   int direction = 0;
   string signalStrength = "";
   bool neuralNetworkUsed = false;
   
   if(InpEnableMLPrediction && g_neuralNetwork.m_isInitialized)
   {
      // Get neural network probabilities
      double inputs[50];
      if(PrepareNeuralInputs(symbol, inputs))
      {
          double nnOutputs[3];
          g_neuralNetwork.ForwardDetailed(inputs, nnOutputs);
          
          // Use neural network probabilities if confidence is high
          if(nnOutputs[0] > 0.7) // Strong Buy signal
          {
              direction = 1;
              signalStrength = "شراء قوي (NN: " + DoubleToString(nnOutputs[0]*100, 1) + "%)";
              score = nnOutputs[0] * 100;
              neuralNetworkUsed = true;
          }
          else if(nnOutputs[1] > 0.7) // Strong Sell signal
          {
              direction = -1;
              signalStrength = "بيع قوي (NN: " + DoubleToString(nnOutputs[1]*100, 1) + "%)";
              score = nnOutputs[1] * 100;
              neuralNetworkUsed = true;
          }
          else if(nnOutputs[0] > 0.6) // Moderate Buy
          {
              direction = 1;
              signalStrength = "شراء متوسط (NN: " + DoubleToString(nnOutputs[0]*100, 1) + "%)";
              score = nnOutputs[0] * 100;
              neuralNetworkUsed = true;
          }
          else if(nnOutputs[1] > 0.6) // Moderate Sell
          {
              direction = -1;
              signalStrength = "بيع متوسط (NN: " + DoubleToString(nnOutputs[1]*100, 1) + "%)";
              score = nnOutputs[1] * 100;
              neuralNetworkUsed = true;
          }
          else if(nnOutputs[2] > 0.8) // Strong Hold signal
          {
              // Neural network strongly suggests holding - no trade
              return false;
          }
          else
          {
              // Neural network confidence is low, use traditional scoring
              score += GetMLPrediction(symbol);
          }
      }
      else
      {
          // Fallback to traditional ML prediction if PrepareNeuralInputs fails
          score += GetMLPrediction(symbol);
      }
   }
   else if(InpEnableMLPrediction)
   {
      // Neural network not initialized, use traditional ML
      score += GetMLPrediction(symbol);
   }
   
   // If neural network didn't provide a strong signal, use traditional scoring
   if(!neuralNetworkUsed)
   {
       // Balanced 5-zone scoring system
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

int GetCachedIndicator(string symbol, string indicatorType, int period)
{
   for(int i = 0; i < ArraySize(g_indicatorCache); i++)
   {
      if(g_indicatorCache[i].symbol == symbol && 
         g_indicatorCache[i].indicatorType == indicatorType && 
         g_indicatorCache[i].period == period &&
         g_indicatorCache[i].isValid &&
         TimeCurrent() - g_indicatorCache[i].lastUpdate < CACHE_EXPIRY_SECONDS)
      {
         return g_indicatorCache[i].handle;
      }
   }
   return INVALID_HANDLE;
}

void UpdateIndicatorCache(string symbol, string indicatorType, int period, int handle)
{
   int cacheIndex = -1;
   for(int i = 0; i < ArraySize(g_indicatorCache); i++)
   {
      if(g_indicatorCache[i].symbol == symbol && 
         g_indicatorCache[i].indicatorType == indicatorType && 
         g_indicatorCache[i].period == period)
      {
         cacheIndex = i;
         break;
      }
   }
   
   if(cacheIndex == -1)
   {
      cacheIndex = ArraySize(g_indicatorCache);
      ArrayResize(g_indicatorCache, cacheIndex + 1);
   }
   
   g_indicatorCache[cacheIndex].symbol = symbol;
   g_indicatorCache[cacheIndex].indicatorType = indicatorType;
   g_indicatorCache[cacheIndex].period = period;
   g_indicatorCache[cacheIndex].handle = handle;
   g_indicatorCache[cacheIndex].lastUpdate = TimeCurrent();
   g_indicatorCache[cacheIndex].isValid = (handle != INVALID_HANDLE);
}

double AnalyzeTrendDirection(string symbol)
{
   int handleEMA20 = GetCachedIndicator(symbol, "EMA", 20);
   if(handleEMA20 == INVALID_HANDLE)
   {
      handleEMA20 = iMA(symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
      UpdateIndicatorCache(symbol, "EMA", 20, handleEMA20);
   }
   
   int handleEMA50 = GetCachedIndicator(symbol, "EMA", 50);
   if(handleEMA50 == INVALID_HANDLE)
   {
      handleEMA50 = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
      UpdateIndicatorCache(symbol, "EMA", 50, handleEMA50);
   }
   
   int handleEMA200 = GetCachedIndicator(symbol, "SMA", 200);
   if(handleEMA200 == INVALID_HANDLE)
   {
      handleEMA200 = iMA(symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
      UpdateIndicatorCache(symbol, "SMA", 200, handleEMA200);
   }
   
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
   int handleATR = GetCachedIndicator(symbol, "ATR", period);
   if(handleATR == INVALID_HANDLE)
   {
      handleATR = iATR(symbol, PERIOD_CURRENT, period);
      UpdateIndicatorCache(symbol, "ATR", period, handleATR);
   }
   
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
      return 0.0;
   }
   
   double result = atrBuffer[0];
   
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
    double inputs[50];
    if(!PrepareNeuralInputs(symbol, inputs))
    {
        Print("خطأ في تحضير مدخلات الشبكة العصبية للرمز: ", symbol);
        return 50.0; // Neutral score
    }
    
    if(!g_neuralNetwork.m_isInitialized)
    {
        Print("تحذير: الشبكة العصبية غير مهيأة، استخدام النموذج التقليدي");
        return ProcessTraditionalML(inputs);
    }
    
    double outputs[3];
    g_neuralNetwork.ForwardDetailed(inputs, outputs);
    
    // Convert probabilities to trading score
    // Buy probability contributes positively, Sell negatively
    double score = (outputs[0] * 100) - (outputs[1] * 100) + 50;
    
    // Ensure score is within valid range
    score = MathMax(0.0, MathMin(100.0, score));
    
    // Log prediction for debugging
    static datetime lastLog = 0;
    if(TimeCurrent() - lastLog > 300) // Log every 5 minutes
    {
        Print("تنبؤ الشبكة العصبية - ", symbol, ": ", 
              g_neuralNetwork.GetPredictionString(outputs), 
              " النتيجة: ", DoubleToString(score, 1));
        lastLog = TimeCurrent();
    }
    
    return score;
}

double ProcessTraditionalML(double &inputs[])
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
   
   return layerOutput * 50;
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

//+------------------------------------------------------------------+
//| Train Neural Network with Historical Data                        |
//+------------------------------------------------------------------+
void TrainNeuralNetwork()
{
    Print("بدء تدريب الشبكة العصبية...");
    
    string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD"};
    int totalSamples = 0;
    
    // Prepare training data
    double trainingData[1000][50];
    double trainingLabels[1000][3];
    
    for(int s = 0; s < ArraySize(symbols); s++)
    {
        string symbol = symbols[s];
        
        // Get historical data for training
        double close[], high[], low[];
        ArraySetAsSeries(close, true);
        ArraySetAsSeries(high, true);
        ArraySetAsSeries(low, true);
        
        if(CopyClose(symbol, PERIOD_H1, 0, 500, close) <= 0) continue;
        if(CopyHigh(symbol, PERIOD_H1, 0, 500, high) <= 0) continue;
        if(CopyLow(symbol, PERIOD_H1, 0, 500, low) <= 0) continue;
        
        // Create training samples
        for(int i = 50; i < ArraySize(close) - 10 && totalSamples < 1000; i++)
        {
            // Prepare inputs for this historical point
            double inputs[50];
            if(!PrepareNeuralInputsHistorical(symbol, inputs, i))
                continue;
            
            // Copy inputs to training data
            for(int j = 0; j < 50; j++)
                trainingData[totalSamples][j] = inputs[j];
            
            // Create labels based on future price movement
            double currentPrice = close[i];
            double futurePrice = close[i-5]; // 5 periods ahead
            double priceChange = (futurePrice - currentPrice) / currentPrice;
            
            // Initialize labels
            trainingLabels[totalSamples][0] = 0; // Buy
            trainingLabels[totalSamples][1] = 0; // Sell  
            trainingLabels[totalSamples][2] = 0; // Hold
            
            // Set labels based on price movement
            if(priceChange > 0.001) // 0.1% increase = Buy
                trainingLabels[totalSamples][0] = 1.0;
            else if(priceChange < -0.001) // 0.1% decrease = Sell
                trainingLabels[totalSamples][1] = 1.0;
            else // Small movement = Hold
                trainingLabels[totalSamples][2] = 1.0;
            
            totalSamples++;
        }
    }
    
    if(totalSamples < 100)
    {
        Print("عدد عينات التدريب قليل جداً: ", totalSamples);
        return;
    }
    
    Print("عدد عينات التدريب: ", totalSamples);
    
    // Train the network
    if(g_neuralNetwork.Train(trainingData, trainingLabels, totalSamples, 100))
    {
        // Save the trained model
        g_neuralNetwork.SaveModel("QuantumNN_Model.bin");
        Print("تم حفظ النموذج المدرب بنجاح");
    }
    else
    {
        Print("فشل في تدريب الشبكة العصبية");
    }
}

//+------------------------------------------------------------------+
//| Prepare Neural Inputs for Historical Data                        |
//+------------------------------------------------------------------+
bool PrepareNeuralInputsHistorical(string symbol, double inputs[], int shift)
{
    if(ArraySize(inputs) < 50) ArrayResize(inputs, 50);
    ArrayInitialize(inputs, 0.0);
    
    // Get historical market data with shift
    double close[], high[], low[], open[], volume[];
    ArraySetAsSeries(close, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(volume, true);
    
    if(CopyClose(symbol, PERIOD_H1, shift, 20, close) <= 0 ||
       CopyHigh(symbol, PERIOD_H1, shift, 20, high) <= 0 ||
       CopyLow(symbol, PERIOD_H1, shift, 20, low) <= 0 ||
       CopyOpen(symbol, PERIOD_H1, shift, 20, open) <= 0 ||
       CopyTickVolume(symbol, PERIOD_H1, shift, 20, volume) <= 0)
    {
        return false;
    }
    
    int idx = 0;
    
    // Group 1: Price Data (15 features)
    // Features 0-4: Price changes for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(close)-1; i++)
    {
        inputs[idx++] = (close[i] - close[i+1]) / close[i+1];
    }
    
    // Features 5-9: Close/Open ratios for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(close); i++)
    {
        inputs[idx++] = (close[i] - open[i]) / open[i];
    }
    
    // Features 10-14: High/Low ratios for last 5 candles
    for(int i = 0; i < 5 && i < ArraySize(high); i++)
    {
        inputs[idx++] = (high[i] - low[i]) / low[i];
    }
    
    // Group 2: Technical Indicators (20 features) - Simplified for historical data
    // Features 15-17: Simple moving averages
    double ma5 = 0, ma10 = 0, ma20 = 0;
    for(int i = 0; i < 5 && i < ArraySize(close); i++) ma5 += close[i];
    for(int i = 0; i < 10 && i < ArraySize(close); i++) ma10 += close[i];
    for(int i = 0; i < 20 && i < ArraySize(close); i++) ma20 += close[i];
    
    ma5 /= 5; ma10 /= 10; ma20 /= 20;
    
    inputs[idx++] = (close[0] - ma5) / close[0];
    inputs[idx++] = (close[0] - ma10) / close[0];
    inputs[idx++] = (close[0] - ma20) / close[0];
    
    // Features 18-34: Simplified technical indicators
    for(int i = 18; i < 35; i++)
        inputs[idx++] = 0; // Placeholder for complex indicators
    
    // Group 3: Volume and Liquidity Data (10 features)
    // Features 35-39: Volume for last 5 candles (normalized)
    double avgVolume = 0;
    for(int i = 0; i < 10 && i < ArraySize(volume); i++)
        avgVolume += volume[i];
    avgVolume /= 10;
    
    for(int i = 0; i < 5 && i < ArraySize(volume); i++)
    {
        inputs[idx++] = (volume[i] - avgVolume) / avgVolume;
    }
    
    // Features 40-44: Volume-related features
    inputs[idx++] = volume[0] / volume[1]; // Volume ratio
    inputs[idx++] = (volume[0] - volume[1]) / volume[1]; // Volume change
    inputs[idx++] = 0; // Spread (not available historically)
    inputs[idx++] = 0; // Market depth (not available historically)
    inputs[idx++] = close[0]; // VWAP approximation (simplified)
    
    // Group 4: Time and Session Context (5 features)
    // Features 45-49: Time-based features (simplified for historical data)
    MqlDateTime dt;
    TimeToStruct(TimeCurrent() - shift * 3600, dt); // Approximate historical time
    
    inputs[idx++] = dt.hour / 24.0; // Hour of day (0-1)
    inputs[idx++] = dt.day_of_week / 7.0; // Day of week (0-1)
    inputs[idx++] = 1.0; // Session factor (default)
    inputs[idx++] = 1.0; // Volatility multiplier (default)
    inputs[idx++] = 0.5; // Trend strength (neutral)
    
    return true;
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
