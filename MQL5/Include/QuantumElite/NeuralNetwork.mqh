//+------------------------------------------------------------------+
//|                                                NeuralNetwork.mqh |
//|                           QUANTUM ELITE TRADER PRO v4.0         |
//|                         نظام التداول الكمي المتطور              |
//|                    Copyright 2024, Quantum Trading Systems       |
//|                         https://quantumelite.trading             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Trading Systems"
#property link      "https://quantumelite.trading"
#property version   "4.00"

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
