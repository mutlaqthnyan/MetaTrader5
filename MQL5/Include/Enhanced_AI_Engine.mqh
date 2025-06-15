//+------------------------------------------------------------------+
//|                                           Enhanced_AI_Engine.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Neural Network Architecture Constants                             |
//+------------------------------------------------------------------+
#define INPUT_SIZE 50
#define HIDDEN1_SIZE 30
#define HIDDEN2_SIZE 20
#define OUTPUT_SIZE 3

#define BATCH_SIZE 32
#define MAX_EPOCHS 1000
#define EARLY_STOPPING_PATIENCE 10
#define TARGET_ACCURACY 0.65
#define LEARNING_RATE_DECAY 0.95
#define MOMENTUM 0.9

//+------------------------------------------------------------------+
//| Matrix Operations Helper Functions                               |
//+------------------------------------------------------------------+
class CMatrixOps
{
public:
    static void MatrixMultiply(double &result[][], const double &a[][], const double &b[][]);
    static void VectorMatrixMultiply(double &result[], const double &vector[], const double &matrix[][]);
    static void AddBias(double &vector[], const double &bias[]);
    static double ReLU(double x);
    static void ReLUActivation(double &vector[]);
    static void Softmax(double &vector[]);
    static double ReLUDerivative(double x);
    static void InitializeWeights(double &weights[][], int rows, int cols);
    static void InitializeBias(double &bias[]);
};

//+------------------------------------------------------------------+
//| ReLU Activation Function                                         |
//+------------------------------------------------------------------+
double CMatrixOps::ReLU(double x)
{
    return MathMax(0.0, x);
}

//+------------------------------------------------------------------+
//| ReLU Derivative                                                  |
//+------------------------------------------------------------------+
double CMatrixOps::ReLUDerivative(double x)
{
    return x > 0.0 ? 1.0 : 0.0;
}

//+------------------------------------------------------------------+
//| Apply ReLU to entire vector                                      |
//+------------------------------------------------------------------+
void CMatrixOps::ReLUActivation(double &vector[])
{
    int size = ArraySize(vector);
    for(int i = 0; i < size; i++)
    {
        vector[i] = ReLU(vector[i]);
    }
}

//+------------------------------------------------------------------+
//| Softmax Activation Function                                      |
//+------------------------------------------------------------------+
void CMatrixOps::Softmax(double &vector[])
{
    int size = ArraySize(vector);
    double max_val = vector[0];
    
    for(int i = 1; i < size; i++)
    {
        if(vector[i] > max_val)
            max_val = vector[i];
    }
    
    double sum = 0.0;
    for(int i = 0; i < size; i++)
    {
        vector[i] = MathExp(vector[i] - max_val);
        sum += vector[i];
    }
    
    for(int i = 0; i < size; i++)
    {
        vector[i] /= sum;
    }
}

//+------------------------------------------------------------------+
//| Vector-Matrix Multiplication                                     |
//+------------------------------------------------------------------+
void CMatrixOps::VectorMatrixMultiply(double &result[], const double &vector[], const double &matrix[][])
{
    int input_size = ArraySize(vector);
    int output_size = ArrayRange(matrix, 1);
    
    ArrayResize(result, output_size);
    ArrayInitialize(result, 0.0);
    
    for(int j = 0; j < output_size; j++)
    {
        for(int i = 0; i < input_size; i++)
        {
            result[j] += vector[i] * matrix[i][j];
        }
    }
}

//+------------------------------------------------------------------+
//| Add Bias to Vector                                               |
//+------------------------------------------------------------------+
void CMatrixOps::AddBias(double &vector[], const double &bias[])
{
    int size = ArraySize(vector);
    for(int i = 0; i < size; i++)
    {
        vector[i] += bias[i];
    }
}

//+------------------------------------------------------------------+
//| Initialize Weights with Xavier/Glorot initialization            |
//+------------------------------------------------------------------+
void CMatrixOps::InitializeWeights(double &weights[][], int rows, int cols)
{
    double limit = MathSqrt(6.0 / (rows + cols));
    
    for(int i = 0; i < rows; i++)
    {
        for(int j = 0; j < cols; j++)
        {
            weights[i][j] = (MathRand() / 32767.0 * 2.0 - 1.0) * limit;
        }
    }
}

//+------------------------------------------------------------------+
//| Initialize Bias to zeros                                         |
//+------------------------------------------------------------------+
void CMatrixOps::InitializeBias(double &bias[])
{
    ArrayInitialize(bias, 0.0);
}

//+------------------------------------------------------------------+
//| Data Preprocessor Class                                          |
//+------------------------------------------------------------------+
class CDataPreprocessor
{
private:
    double m_feature_means[INPUT_SIZE];
    double m_feature_stds[INPUT_SIZE];
    bool m_is_fitted;

public:
    CDataPreprocessor();
    void ExtractFeatures(double &features[]);
    void NormalizeData(double &data[]);
    void FitNormalization(double &data[][], int samples);
    void TransformData(double &data[]);
    
private:
    void ExtractPriceFeatures(double &features[], int start_idx);
    void ExtractTechnicalIndicators(double &features[], int start_idx);
    void ExtractMarketMicrostructure(double &features[], int start_idx);
    void ExtractTemporalFeatures(double &features[], int start_idx);
};

//+------------------------------------------------------------------+
//| Data Preprocessor Constructor                                    |
//+------------------------------------------------------------------+
CDataPreprocessor::CDataPreprocessor()
{
    m_is_fitted = false;
    ArrayInitialize(m_feature_means, 0.0);
    ArrayInitialize(m_feature_stds, 1.0);
}

//+------------------------------------------------------------------+
//| Extract all 50 features                                         |
//+------------------------------------------------------------------+
void CDataPreprocessor::ExtractFeatures(double &features[])
{
    ArrayResize(features, INPUT_SIZE);
    
    ExtractPriceFeatures(features, 0);           // Features 0-9
    ExtractTechnicalIndicators(features, 10);    // Features 10-29
    ExtractMarketMicrostructure(features, 30);   // Features 30-39
    ExtractTemporalFeatures(features, 40);       // Features 40-49
}

//+------------------------------------------------------------------+
//| Extract Price Features (10 features)                            |
//+------------------------------------------------------------------+
void CDataPreprocessor::ExtractPriceFeatures(double &features[], int start_idx)
{
    double close_prices[20];
    for(int i = 0; i < 20; i++)
    {
        close_prices[i] = iClose(_Symbol, PERIOD_CURRENT, i);
    }
    
    features[start_idx + 0] = (close_prices[0] - close_prices[1]) / close_prices[1] * 100; // Price change %
    features[start_idx + 1] = (close_prices[0] - close_prices[4]) / close_prices[4] * 100; // 5-period change %
    features[start_idx + 2] = close_prices[0] / iMA(_Symbol, PERIOD_CURRENT, 5, 0, MODE_SMA, PRICE_CLOSE, 0); // Price/MA5 ratio
    features[start_idx + 3] = close_prices[0] / iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_SMA, PRICE_CLOSE, 0); // Price/MA10 ratio
    features[start_idx + 4] = close_prices[0] / iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0); // Price/MA20 ratio
    features[start_idx + 5] = (iHigh(_Symbol, PERIOD_CURRENT, 0) - iLow(_Symbol, PERIOD_CURRENT, 0)) / close_prices[0]; // High-Low range
    features[start_idx + 6] = (close_prices[0] - iOpen(_Symbol, PERIOD_CURRENT, 0)) / iOpen(_Symbol, PERIOD_CURRENT, 0); // Open-Close change
    features[start_idx + 7] = iMA(_Symbol, PERIOD_CURRENT, 5, 0, MODE_SMA, PRICE_CLOSE, 0) / iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 0); // MA5/MA20 ratio
    features[start_idx + 8] = close_prices[0] / (iHigh(_Symbol, PERIOD_CURRENT, 0) + iLow(_Symbol, PERIOD_CURRENT, 0)) * 2; // Price position in range
    features[start_idx + 9] = (close_prices[0] - close_prices[9]) / close_prices[9] * 100; // 10-period change %
}

//+------------------------------------------------------------------+
//| Extract Technical Indicators (20 features)                      |
//+------------------------------------------------------------------+
void CDataPreprocessor::ExtractTechnicalIndicators(double &features[], int start_idx)
{
    features[start_idx + 0] = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE, 0);
    features[start_idx + 1] = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
    features[start_idx + 2] = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
    features[start_idx + 3] = iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
    features[start_idx + 4] = iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
    features[start_idx + 5] = iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH, MODE_MAIN, 0);
    features[start_idx + 6] = iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH, MODE_SIGNAL, 0);
    features[start_idx + 7] = iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_TYPICAL, 0);
    features[start_idx + 8] = iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE, MODE_MAIN, 0);
    features[start_idx + 9] = iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
    features[start_idx + 10] = iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE, MODE_MINUSDI, 0);
    features[start_idx + 11] = iWPR(_Symbol, PERIOD_CURRENT, 14, 0);
    features[start_idx + 12] = iMomentum(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE, 0);
    features[start_idx + 13] = iRSI(_Symbol, PERIOD_CURRENT, 7, PRICE_CLOSE, 0);  // Fast RSI
    features[start_idx + 14] = iRSI(_Symbol, PERIOD_CURRENT, 21, PRICE_CLOSE, 0); // Slow RSI
    features[start_idx + 15] = iMA(_Symbol, PERIOD_CURRENT, 5, 0, MODE_EMA, PRICE_CLOSE, 0);
    features[start_idx + 16] = iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
    features[start_idx + 17] = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
    features[start_idx + 18] = iATR(_Symbol, PERIOD_CURRENT, 14, 0);
    features[start_idx + 19] = iDeMarker(_Symbol, PERIOD_CURRENT, 14, 0);
}

//+------------------------------------------------------------------+
//| Extract Market Microstructure (10 features)                     |
//+------------------------------------------------------------------+
void CDataPreprocessor::ExtractMarketMicrostructure(double &features[], int start_idx)
{
    features[start_idx + 0] = MarketInfo(_Symbol, MODE_SPREAD);
    features[start_idx + 1] = iVolume(_Symbol, PERIOD_CURRENT, 0);
    features[start_idx + 2] = iVolume(_Symbol, PERIOD_CURRENT, 1);
    features[start_idx + 3] = MarketInfo(_Symbol, MODE_BID);
    features[start_idx + 4] = MarketInfo(_Symbol, MODE_ASK);
    features[start_idx + 5] = MarketInfo(_Symbol, MODE_POINT);
    features[start_idx + 6] = MarketInfo(_Symbol, MODE_DIGITS);
    features[start_idx + 7] = (MarketInfo(_Symbol, MODE_ASK) - MarketInfo(_Symbol, MODE_BID)) / MarketInfo(_Symbol, MODE_POINT);
    features[start_idx + 8] = iVolume(_Symbol, PERIOD_CURRENT, 0) / iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_VOLUME, 0);
    features[start_idx + 9] = MarketInfo(_Symbol, MODE_TICKVALUE);
}

//+------------------------------------------------------------------+
//| Extract Temporal Features (10 features)                         |
//+------------------------------------------------------------------+
void CDataPreprocessor::ExtractTemporalFeatures(double &features[], int start_idx)
{
    datetime current_time = TimeCurrent();
    MqlDateTime time_struct;
    TimeToStruct(current_time, time_struct);
    
    features[start_idx + 0] = time_struct.hour / 24.0;
    features[start_idx + 1] = time_struct.day_of_week / 7.0;
    features[start_idx + 2] = time_struct.day / 31.0;
    features[start_idx + 3] = time_struct.mon / 12.0;
    features[start_idx + 4] = (time_struct.hour >= 8 && time_struct.hour <= 17) ? 1.0 : 0.0; // Trading session
    features[start_idx + 5] = (time_struct.day_of_week >= 1 && time_struct.day_of_week <= 5) ? 1.0 : 0.0; // Weekday
    features[start_idx + 6] = MathSin(2 * M_PI * time_struct.hour / 24.0); // Cyclical hour
    features[start_idx + 7] = MathCos(2 * M_PI * time_struct.hour / 24.0);
    features[start_idx + 8] = MathSin(2 * M_PI * time_struct.day_of_week / 7.0); // Cyclical day of week
    features[start_idx + 9] = MathCos(2 * M_PI * time_struct.day_of_week / 7.0);
}

//+------------------------------------------------------------------+
//| Fit normalization parameters                                    |
//+------------------------------------------------------------------+
void CDataPreprocessor::FitNormalization(double &data[][], int samples)
{
    ArrayInitialize(m_feature_means, 0.0);
    ArrayInitialize(m_feature_stds, 0.0);
    
    for(int i = 0; i < samples; i++)
    {
        for(int j = 0; j < INPUT_SIZE; j++)
        {
            m_feature_means[j] += data[i][j];
        }
    }
    
    for(int j = 0; j < INPUT_SIZE; j++)
    {
        m_feature_means[j] /= samples;
    }
    
    for(int i = 0; i < samples; i++)
    {
        for(int j = 0; j < INPUT_SIZE; j++)
        {
            double diff = data[i][j] - m_feature_means[j];
            m_feature_stds[j] += diff * diff;
        }
    }
    
    for(int j = 0; j < INPUT_SIZE; j++)
    {
        m_feature_stds[j] = MathSqrt(m_feature_stds[j] / samples);
        if(m_feature_stds[j] < 1e-8)
            m_feature_stds[j] = 1.0;
    }
    
    m_is_fitted = true;
}

//+------------------------------------------------------------------+
//| Transform data using fitted parameters                          |
//+------------------------------------------------------------------+
void CDataPreprocessor::TransformData(double &data[])
{
    if(!m_is_fitted)
    {
        Print("Error: Normalization parameters not fitted!");
        return;
    }
    
    for(int i = 0; i < INPUT_SIZE; i++)
    {
        data[i] = (data[i] - m_feature_means[i]) / m_feature_stds[i];
    }
}

//+------------------------------------------------------------------+
//| Neural Network Class                                             |
//+------------------------------------------------------------------+
class CNeuralNetwork
{
private:
    double m_weights1[INPUT_SIZE][HIDDEN1_SIZE];
    double m_weights2[HIDDEN1_SIZE][HIDDEN2_SIZE];
    double m_weights3[HIDDEN2_SIZE][OUTPUT_SIZE];
    
    double m_biases1[HIDDEN1_SIZE];
    double m_biases2[HIDDEN2_SIZE];
    double m_biases3[OUTPUT_SIZE];
    
    double m_momentum_weights1[INPUT_SIZE][HIDDEN1_SIZE];
    double m_momentum_weights2[HIDDEN1_SIZE][HIDDEN2_SIZE];
    double m_momentum_weights3[HIDDEN2_SIZE][OUTPUT_SIZE];
    
    double m_momentum_biases1[HIDDEN1_SIZE];
    double m_momentum_biases2[HIDDEN2_SIZE];
    double m_momentum_biases3[OUTPUT_SIZE];
    
    double m_hidden1[HIDDEN1_SIZE];
    double m_hidden2[HIDDEN2_SIZE];
    double m_output[OUTPUT_SIZE];
    double m_last_input[INPUT_SIZE];
    
    double m_learning_rate;
    bool m_is_initialized;

public:
    CNeuralNetwork();
    ~CNeuralNetwork();
    
    bool Initialize(double learning_rate = 0.001);
    void Forward(const double &inputs[], double &outputs[]);
    void Backward(const double &target[], double learning_rate);
    bool Train(double &data[][], double &labels[][], int samples, int epochs);
    bool SaveModel(string filename);
    bool LoadModel(string filename);
    
    double CalculateAccuracy(double &data[][], double &labels[][], int samples);
    int Predict(const double &inputs[]);
    
private:
    void InitializeWeights();
    double CalculateLoss(const double &predicted[], const double &target[]);
};

//+------------------------------------------------------------------+
//| Neural Network Constructor                                       |
//+------------------------------------------------------------------+
CNeuralNetwork::CNeuralNetwork()
{
    m_learning_rate = 0.001;
    m_is_initialized = false;
    
    ArrayInitialize(m_momentum_weights1, 0.0);
    ArrayInitialize(m_momentum_weights2, 0.0);
    ArrayInitialize(m_momentum_weights3, 0.0);
    ArrayInitialize(m_momentum_biases1, 0.0);
    ArrayInitialize(m_momentum_biases2, 0.0);
    ArrayInitialize(m_momentum_biases3, 0.0);
}

//+------------------------------------------------------------------+
//| Neural Network Destructor                                       |
//+------------------------------------------------------------------+
CNeuralNetwork::~CNeuralNetwork()
{
}

//+------------------------------------------------------------------+
//| Initialize Neural Network                                        |
//+------------------------------------------------------------------+
bool CNeuralNetwork::Initialize(double learning_rate = 0.001)
{
    m_learning_rate = learning_rate;
    InitializeWeights();
    m_is_initialized = true;
    return true;
}

//+------------------------------------------------------------------+
//| Initialize Weights and Biases                                   |
//+------------------------------------------------------------------+
void CNeuralNetwork::InitializeWeights()
{
    CMatrixOps::InitializeWeights(m_weights1, INPUT_SIZE, HIDDEN1_SIZE);
    CMatrixOps::InitializeWeights(m_weights2, HIDDEN1_SIZE, HIDDEN2_SIZE);
    CMatrixOps::InitializeWeights(m_weights3, HIDDEN2_SIZE, OUTPUT_SIZE);
    
    CMatrixOps::InitializeBias(m_biases1);
    CMatrixOps::InitializeBias(m_biases2);
    CMatrixOps::InitializeBias(m_biases3);
}

//+------------------------------------------------------------------+
//| Forward Propagation                                              |
//+------------------------------------------------------------------+
void CNeuralNetwork::Forward(const double &inputs[], double &outputs[])
{
    if(!m_is_initialized)
    {
        Print("Error: Neural network not initialized!");
        return;
    }
    
    ArrayResize(outputs, OUTPUT_SIZE);
    
    // Store input for backpropagation
    for(int i = 0; i < INPUT_SIZE; i++)
    {
        m_last_input[i] = inputs[i];
    }
    
    // Layer 1: Input -> Hidden1
    // z1 = weights1 × inputs + biases1
    CMatrixOps::VectorMatrixMultiply(m_hidden1, inputs, m_weights1);
    CMatrixOps::AddBias(m_hidden1, m_biases1);
    // a1 = ReLU(z1)
    CMatrixOps::ReLUActivation(m_hidden1);
    
    // Layer 2: Hidden1 -> Hidden2
    // z2 = weights2 × a1 + biases2
    CMatrixOps::VectorMatrixMultiply(m_hidden2, m_hidden1, m_weights2);
    CMatrixOps::AddBias(m_hidden2, m_biases2);
    // a2 = ReLU(z2)
    CMatrixOps::ReLUActivation(m_hidden2);
    
    // Layer 3: Hidden2 -> Output
    // z3 = weights3 × a2 + biases3
    CMatrixOps::VectorMatrixMultiply(m_output, m_hidden2, m_weights3);
    CMatrixOps::AddBias(m_output, m_biases3);
    // output = Softmax(z3)
    CMatrixOps::Softmax(m_output);
    
    // Copy to output array
    for(int i = 0; i < OUTPUT_SIZE; i++)
    {
        outputs[i] = m_output[i];
    }
}

//+------------------------------------------------------------------+
//| Backpropagation                                                  |
//+------------------------------------------------------------------+
void CNeuralNetwork::Backward(const double &target[], double learning_rate)
{
    if(!m_is_initialized)
    {
        Print("Error: Neural network not initialized!");
        return;
    }
    
    // Calculate output layer gradients (softmax + cross-entropy)
    double output_gradients[OUTPUT_SIZE];
    for(int i = 0; i < OUTPUT_SIZE; i++)
    {
        output_gradients[i] = m_output[i] - target[i];
    }
    
    // Calculate hidden layer 2 gradients
    double hidden2_gradients[HIDDEN2_SIZE];
    ArrayInitialize(hidden2_gradients, 0.0);
    
    for(int i = 0; i < HIDDEN2_SIZE; i++)
    {
        for(int j = 0; j < OUTPUT_SIZE; j++)
        {
            hidden2_gradients[i] += output_gradients[j] * m_weights3[i][j];
        }
        hidden2_gradients[i] *= CMatrixOps::ReLUDerivative(m_hidden2[i]);
    }
    
    // Calculate hidden layer 1 gradients
    double hidden1_gradients[HIDDEN1_SIZE];
    ArrayInitialize(hidden1_gradients, 0.0);
    
    for(int i = 0; i < HIDDEN1_SIZE; i++)
    {
        for(int j = 0; j < HIDDEN2_SIZE; j++)
        {
            hidden1_gradients[i] += hidden2_gradients[j] * m_weights2[i][j];
        }
        hidden1_gradients[i] *= CMatrixOps::ReLUDerivative(m_hidden1[i]);
    }
    
    // Update weights and biases with momentum
    // Update weights3 (hidden2 -> output)
    for(int i = 0; i < HIDDEN2_SIZE; i++)
    {
        for(int j = 0; j < OUTPUT_SIZE; j++)
        {
            double gradient = output_gradients[j] * m_hidden2[i];
            m_momentum_weights3[i][j] = MOMENTUM * m_momentum_weights3[i][j] - learning_rate * gradient;
            m_weights3[i][j] += m_momentum_weights3[i][j];
        }
    }
    
    // Update biases3
    for(int i = 0; i < OUTPUT_SIZE; i++)
    {
        m_momentum_biases3[i] = MOMENTUM * m_momentum_biases3[i] - learning_rate * output_gradients[i];
        m_biases3[i] += m_momentum_biases3[i];
    }
    
    // Update weights2 (hidden1 -> hidden2)
    for(int i = 0; i < HIDDEN1_SIZE; i++)
    {
        for(int j = 0; j < HIDDEN2_SIZE; j++)
        {
            double gradient = hidden2_gradients[j] * m_hidden1[i];
            m_momentum_weights2[i][j] = MOMENTUM * m_momentum_weights2[i][j] - learning_rate * gradient;
            m_weights2[i][j] += m_momentum_weights2[i][j];
        }
    }
    
    // Update biases2
    for(int i = 0; i < HIDDEN2_SIZE; i++)
    {
        m_momentum_biases2[i] = MOMENTUM * m_momentum_biases2[i] - learning_rate * hidden2_gradients[i];
        m_biases2[i] += m_momentum_biases2[i];
    }
    
    // Update weights1 (input -> hidden1)
    for(int i = 0; i < INPUT_SIZE; i++)
    {
        for(int j = 0; j < HIDDEN1_SIZE; j++)
        {
            double gradient = hidden1_gradients[j] * m_last_input[i];
            m_momentum_weights1[i][j] = MOMENTUM * m_momentum_weights1[i][j] - learning_rate * gradient;
            m_weights1[i][j] += m_momentum_weights1[i][j];
        }
    }
    
    // Update biases1
    for(int i = 0; i < HIDDEN1_SIZE; i++)
    {
        m_momentum_biases1[i] = MOMENTUM * m_momentum_biases1[i] - learning_rate * hidden1_gradients[i];
        m_biases1[i] += m_momentum_biases1[i];
    }
}

//+------------------------------------------------------------------+
//| Training System                                                  |
//+------------------------------------------------------------------+
bool CNeuralNetwork::Train(double &data[][], double &labels[][], int samples, int epochs)
{
    if(!m_is_initialized)
    {
        Print("Error: Neural network not initialized!");
        return false;
    }
    
    // Split data: 80% training, 20% validation
    int train_samples = (int)(samples * 0.8);
    int val_samples = samples - train_samples;
    
    double best_val_accuracy = 0.0;
    int patience_counter = 0;
    double current_learning_rate = m_learning_rate;
    
    Print("Starting training with ", samples, " samples (", train_samples, " train, ", val_samples, " validation)");
    
    for(int epoch = 0; epoch < epochs; epoch++)
    {
        // Training phase
        double total_loss = 0.0;
        int correct_predictions = 0;
        
        // Shuffle training data (simple implementation)
        for(int batch_start = 0; batch_start < train_samples; batch_start += BATCH_SIZE)
        {
            int batch_end = MathMin(batch_start + BATCH_SIZE, train_samples);
            
            for(int i = batch_start; i < batch_end; i++)
            {
                double outputs[OUTPUT_SIZE];
                Forward(data[i], outputs);
                
                // Calculate loss
                total_loss += CalculateLoss(outputs, labels[i]);
                
                // Check prediction accuracy
                int predicted_class = Predict(data[i]);
                int actual_class = 0;
                for(int j = 1; j < OUTPUT_SIZE; j++)
                {
                    if(labels[i][j] > labels[i][actual_class])
                        actual_class = j;
                }
                if(predicted_class == actual_class)
                    correct_predictions++;
                
                // Backpropagation
                Backward(labels[i], current_learning_rate);
            }
        }
        
        // Calculate training accuracy
        double train_accuracy = (double)correct_predictions / train_samples;
        
        // Validation phase
        double val_accuracy = 0.0;
        if(val_samples > 0)
        {
            int val_correct = 0;
            for(int i = train_samples; i < samples; i++)
            {
                int predicted_class = Predict(data[i]);
                int actual_class = 0;
                for(int j = 1; j < OUTPUT_SIZE; j++)
                {
                    if(labels[i][j] > labels[i][actual_class])
                        actual_class = j;
                }
                if(predicted_class == actual_class)
                    val_correct++;
            }
            val_accuracy = (double)val_correct / val_samples;
        }
        
        // Print progress every 10 epochs
        if(epoch % 10 == 0 || epoch == epochs - 1)
        {
            Print("Epoch ", epoch, "/", epochs, 
                  " - Loss: ", DoubleToString(total_loss / train_samples, 4),
                  " - Train Acc: ", DoubleToString(train_accuracy * 100, 2), "%",
                  " - Val Acc: ", DoubleToString(val_accuracy * 100, 2), "%",
                  " - LR: ", DoubleToString(current_learning_rate, 6));
        }
        
        // Early stopping and learning rate decay
        if(val_accuracy > best_val_accuracy)
        {
            best_val_accuracy = val_accuracy;
            patience_counter = 0;
            
            // Save best model
            SaveModel("best_model.bin");
        }
        else
        {
            patience_counter++;
            if(patience_counter >= EARLY_STOPPING_PATIENCE)
            {
                Print("Early stopping triggered. Best validation accuracy: ", 
                      DoubleToString(best_val_accuracy * 100, 2), "%");
                LoadModel("best_model.bin");
                break;
            }
        }
        
        // Learning rate decay
        if(epoch % 50 == 0 && epoch > 0)
        {
            current_learning_rate *= LEARNING_RATE_DECAY;
        }
        
        // Check target accuracy
        if(val_accuracy >= TARGET_ACCURACY)
        {
            Print("Target accuracy reached! Validation accuracy: ", 
                  DoubleToString(val_accuracy * 100, 2), "%");
            break;
        }
    }
    
    Print("Training completed. Best validation accuracy: ", 
          DoubleToString(best_val_accuracy * 100, 2), "%");
    
    return best_val_accuracy >= TARGET_ACCURACY;
}

//+------------------------------------------------------------------+
//| Calculate Loss (Cross-entropy)                                  |
//+------------------------------------------------------------------+
double CNeuralNetwork::CalculateLoss(const double &predicted[], const double &target[])
{
    double loss = 0.0;
    for(int i = 0; i < OUTPUT_SIZE; i++)
    {
        if(target[i] > 0.0)
        {
            loss -= target[i] * MathLog(MathMax(predicted[i], 1e-15));
        }
    }
    return loss;
}

//+------------------------------------------------------------------+
//| Make Prediction                                                  |
//+------------------------------------------------------------------+
int CNeuralNetwork::Predict(const double &inputs[])
{
    double outputs[OUTPUT_SIZE];
    Forward(inputs, outputs);
    
    int max_index = 0;
    for(int i = 1; i < OUTPUT_SIZE; i++)
    {
        if(outputs[i] > outputs[max_index])
            max_index = i;
    }
    
    return max_index; // 0=Hold, 1=Buy, 2=Sell
}

//+------------------------------------------------------------------+
//| Calculate Accuracy                                               |
//+------------------------------------------------------------------+
double CNeuralNetwork::CalculateAccuracy(double &data[][], double &labels[][], int samples)
{
    int correct_predictions = 0;
    
    for(int i = 0; i < samples; i++)
    {
        int predicted_class = Predict(data[i]);
        int actual_class = 0;
        
        for(int j = 1; j < OUTPUT_SIZE; j++)
        {
            if(labels[i][j] > labels[i][actual_class])
                actual_class = j;
        }
        
        if(predicted_class == actual_class)
            correct_predictions++;
    }
    
    return (double)correct_predictions / samples;
}

//+------------------------------------------------------------------+
//| Save Model to File                                               |
//+------------------------------------------------------------------+
bool CNeuralNetwork::SaveModel(string filename)
{
    int handle = FileOpen(filename, FILE_WRITE|FILE_BIN);
    if(handle == INVALID_HANDLE)
    {
        Print("Error: Cannot create file ", filename);
        return false;
    }
    
    // Save weights and biases
    FileWriteArray(handle, m_weights1);
    FileWriteArray(handle, m_weights2);
    FileWriteArray(handle, m_weights3);
    FileWriteArray(handle, m_biases1);
    FileWriteArray(handle, m_biases2);
    FileWriteArray(handle, m_biases3);
    
    // Save momentum arrays
    FileWriteArray(handle, m_momentum_weights1);
    FileWriteArray(handle, m_momentum_weights2);
    FileWriteArray(handle, m_momentum_weights3);
    FileWriteArray(handle, m_momentum_biases1);
    FileWriteArray(handle, m_momentum_biases2);
    FileWriteArray(handle, m_momentum_biases3);
    
    // Save learning rate and initialization status
    FileWriteDouble(handle, m_learning_rate);
    FileWriteInteger(handle, m_is_initialized ? 1 : 0);
    
    FileClose(handle);
    Print("Model saved successfully to ", filename);
    return true;
}

//+------------------------------------------------------------------+
//| Load Model from File                                             |
//+------------------------------------------------------------------+
bool CNeuralNetwork::LoadModel(string filename)
{
    int handle = FileOpen(filename, FILE_READ|FILE_BIN);
    if(handle == INVALID_HANDLE)
    {
        Print("Error: Cannot open file ", filename);
        return false;
    }
    
    // Load weights and biases
    FileReadArray(handle, m_weights1);
    FileReadArray(handle, m_weights2);
    FileReadArray(handle, m_weights3);
    FileReadArray(handle, m_biases1);
    FileReadArray(handle, m_biases2);
    FileReadArray(handle, m_biases3);
    
    // Load momentum arrays
    FileReadArray(handle, m_momentum_weights1);
    FileReadArray(handle, m_momentum_weights2);
    FileReadArray(handle, m_momentum_weights3);
    FileReadArray(handle, m_momentum_biases1);
    FileReadArray(handle, m_momentum_biases2);
    FileReadArray(handle, m_momentum_biases3);
    
    // Load learning rate and initialization status
    m_learning_rate = FileReadDouble(handle);
    m_is_initialized = FileReadInteger(handle) == 1;
    
    FileClose(handle);
    Print("Model loaded successfully from ", filename);
    return true;
}
