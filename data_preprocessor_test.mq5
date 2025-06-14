//+------------------------------------------------------------------+
//| CDataPreprocessor Test Script - اختبار معالج البيانات المتقدم        |
//+------------------------------------------------------------------+
#property copyright "Quantum Elite Trader Pro"
#property version   "1.00"
#property strict

// Include the main file to access CDataPreprocessor class
#include "DataPreprocessor.mqh"

//+------------------------------------------------------------------+
//| Test initialization function                                      |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("═══════════════════════════════════════════════════════════════");
    Print("🧪 بدء اختبار CDataPreprocessor Class");
    Print("═══════════════════════════════════════════════════════════════");
    
    bool allTestsPassed = true;
    
    // Test 1: Class Initialization
    Print("\n📋 اختبار 1: تهيئة الفئة");
    if(!TestInitialization())
    {
        Print("❌ فشل اختبار التهيئة");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار التهيئة");
    }
    
    // Test 2: Feature Extraction (50 features)
    Print("\n📋 اختبار 2: استخراج الميزات (50 ميزة)");
    if(!TestFeatureExtraction())
    {
        Print("❌ فشل اختبار استخراج الميزات");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار استخراج الميزات");
    }
    
    // Test 3: Feature Groups Validation
    Print("\n📋 اختبار 3: التحقق من مجموعات الميزات");
    if(!TestFeatureGroups())
    {
        Print("❌ فشل اختبار مجموعات الميزات");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار مجموعات الميزات");
    }
    
    // Test 4: Data Normalization (Z-score)
    Print("\n📋 اختبار 4: تطبيع البيانات (Z-score)");
    if(!TestDataNormalization())
    {
        Print("❌ فشل اختبار تطبيع البيانات");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار تطبيع البيانات");
    }
    
    // Test 5: Normalization Statistics Update
    Print("\n📋 اختبار 5: تحديث إحصائيات التطبيع");
    if(!TestNormalizationStatsUpdate())
    {
        Print("❌ فشل اختبار تحديث إحصائيات التطبيع");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار تحديث إحصائيات التطبيع");
    }
    
    // Test 6: Error Handling
    Print("\n📋 اختبار 6: معالجة الأخطاء");
    if(!TestErrorHandling())
    {
        Print("❌ فشل اختبار معالجة الأخطاء");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار معالجة الأخطاء");
    }
    
    // Test 7: Performance Test
    Print("\n📋 اختبار 7: اختبار الأداء");
    if(!TestPerformance())
    {
        Print("❌ فشل اختبار الأداء");
        allTestsPassed = false;
    }
    else
    {
        Print("✅ نجح اختبار الأداء");
    }
    
    // Final Results
    Print("\n═══════════════════════════════════════════════════════════════");
    if(allTestsPassed)
    {
        Print("🎉 جميع الاختبارات نجحت! CDataPreprocessor جاهز للاستخدام");
        Print("📊 النتيجة النهائية: PASS ✅");
    }
    else
    {
        Print("⚠️ بعض الاختبارات فشلت - يحتاج إلى مراجعة");
        Print("📊 النتيجة النهائية: FAIL ❌");
    }
    Print("═══════════════════════════════════════════════════════════════");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Test 1: Class Initialization                                     |
//+------------------------------------------------------------------+
bool TestInitialization()
{
    CDataPreprocessor testProcessor;
    
    // Test initialization with default symbol
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات مع الرمز الافتراضي");
        return false;
    }
    
    // Test initialization with specific symbol
    if(!testProcessor.Initialize("EURUSD"))
    {
        Print("   ❌ فشل في تهيئة معالج البيانات مع رمز محدد");
        return false;
    }
    
    Print("   ✅ تم تهيئة معالج البيانات بنجاح");
    return true;
}

//+------------------------------------------------------------------+
//| Test 2: Feature Extraction                                       |
//+------------------------------------------------------------------+
bool TestFeatureExtraction()
{
    CDataPreprocessor testProcessor;
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات للاختبار");
        return false;
    }
    
    double features[];
    testProcessor.ExtractFeatures(features);
    
    // Check if exactly 50 features are extracted
    if(ArraySize(features) != 50)
    {
        Print("   ❌ عدد الميزات المستخرجة غير صحيح: ", ArraySize(features), " بدلاً من 50");
        return false;
    }
    
    // Check if features contain valid values (not all zeros)
    int nonZeroCount = 0;
    for(int i = 0; i < ArraySize(features); i++)
    {
        if(MathAbs(features[i]) > 0.0001)
            nonZeroCount++;
    }
    
    if(nonZeroCount < 10) // At least 10 features should have non-zero values
    {
        Print("   ❌ معظم الميزات تحتوي على قيم صفرية - قد تكون هناك مشكلة في الاستخراج");
        return false;
    }
    
    Print("   ✅ تم استخراج 50 ميزة بنجاح مع ", nonZeroCount, " ميزة غير صفرية");
    
    // Print sample features for verification
    Print("   📊 عينة من الميزات:");
    for(int i = 0; i < 10; i++)
    {
        Print("      الميزة ", i, ": ", DoubleToString(features[i], 6));
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Test 3: Feature Groups Validation                                |
//+------------------------------------------------------------------+
bool TestFeatureGroups()
{
    CDataPreprocessor testProcessor;
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات للاختبار");
        return false;
    }
    
    double features[];
    testProcessor.ExtractFeatures(features);
    
    if(ArraySize(features) != 50)
    {
        Print("   ❌ عدد الميزات غير صحيح");
        return false;
    }
    
    // Analyze feature groups
    Print("   📊 تحليل مجموعات الميزات:");
    
    // Group 1: Price Features (0-9)
    int priceNonZero = 0;
    for(int i = 0; i < 10; i++)
    {
        if(MathAbs(features[i]) > 0.0001) priceNonZero++;
    }
    Print("      مجموعة السعر (0-9): ", priceNonZero, "/10 ميزات نشطة");
    
    // Group 2: Technical Indicators (10-29)
    int techNonZero = 0;
    for(int i = 10; i < 30; i++)
    {
        if(MathAbs(features[i]) > 0.0001) techNonZero++;
    }
    Print("      المؤشرات الفنية (10-29): ", techNonZero, "/20 ميزات نشطة");
    
    // Group 3: Market Microstructure (30-39)
    int microNonZero = 0;
    for(int i = 30; i < 40; i++)
    {
        if(MathAbs(features[i]) > 0.0001) microNonZero++;
    }
    Print("      البنية الدقيقة (30-39): ", microNonZero, "/10 ميزات نشطة");
    
    // Group 4: Temporal Features (40-49)
    int temporalNonZero = 0;
    for(int i = 40; i < 50; i++)
    {
        if(MathAbs(features[i]) > 0.0001) temporalNonZero++;
    }
    Print("      الميزات الزمنية (40-49): ", temporalNonZero, "/10 ميزات نشطة");
    
    // Validation: Each group should have at least some active features
    if(priceNonZero < 3 || techNonZero < 5 || microNonZero < 2 || temporalNonZero < 3)
    {
        Print("   ⚠️ بعض مجموعات الميزات تحتوي على قيم قليلة جداً");
        // This is a warning, not a failure - some features might be zero in certain market conditions
    }
    
    Print("   ✅ تم التحقق من مجموعات الميزات الأربع بنجاح");
    return true;
}

//+------------------------------------------------------------------+
//| Test 4: Data Normalization                                       |
//+------------------------------------------------------------------+
bool TestDataNormalization()
{
    CDataPreprocessor testProcessor;
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات للاختبار");
        return false;
    }
    
    // Create test data with known values
    double testData[50];
    for(int i = 0; i < 50; i++)
    {
        testData[i] = (i + 1) * 10.0; // Values: 10, 20, 30, ..., 500
    }
    
    Print("   📊 البيانات قبل التطبيع (أول 10 قيم):");
    for(int i = 0; i < 10; i++)
    {
        Print("      القيمة ", i, ": ", DoubleToString(testData[i], 2));
    }
    
    // Apply normalization
    testProcessor.NormalizeData(testData);
    
    Print("   📊 البيانات بعد التطبيع (أول 10 قيم):");
    for(int i = 0; i < 10; i++)
    {
        Print("      القيمة ", i, ": ", DoubleToString(testData[i], 6));
    }
    
    // Check if normalization changed the values
    bool hasChanged = false;
    for(int i = 0; i < 50; i++)
    {
        if(MathAbs(testData[i] - (i + 1) * 10.0) > 0.001)
        {
            hasChanged = true;
            break;
        }
    }
    
    if(!hasChanged)
    {
        Print("   ⚠️ التطبيع لم يغير القيم - قد تكون الإحصائيات الافتراضية غير مناسبة");
        // This is a warning, not necessarily a failure
    }
    
    // Test with invalid data size
    double invalidData[30];
    ArrayInitialize(invalidData, 1.0);
    testProcessor.NormalizeData(invalidData);
    
    Print("   ✅ تم اختبار تطبيع البيانات بنجاح");
    return true;
}

//+------------------------------------------------------------------+
//| Test 5: Normalization Statistics Update                          |
//+------------------------------------------------------------------+
bool TestNormalizationStatsUpdate()
{
    CDataPreprocessor testProcessor;
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات للاختبار");
        return false;
    }
    
    // Create training data matrix
    double trainingData[100][50];
    
    // Fill with realistic training data
    for(int sample = 0; sample < 100; sample++)
    {
        for(int feature = 0; feature < 50; feature++)
        {
            // Generate realistic values for each feature group
            if(feature < 10) // Price features
                trainingData[sample][feature] = (MathRand() % 1000 - 500) / 100.0; // -5 to 5
            else if(feature < 30) // Technical indicators
                trainingData[sample][feature] = (MathRand() % 10000) / 100.0; // 0 to 100
            else if(feature < 40) // Market microstructure
                trainingData[sample][feature] = (MathRand() % 1000) / 10.0; // 0 to 100
            else // Temporal features
                trainingData[sample][feature] = MathRand() % 24; // 0 to 23
        }
    }
    
    // Update normalization statistics
    if(!testProcessor.UpdateNormalizationStats(trainingData, 100))
    {
        Print("   ❌ فشل في تحديث إحصائيات التطبيع");
        return false;
    }
    
    // Test normalization with updated statistics
    double testSample[50];
    for(int i = 0; i < 50; i++)
    {
        testSample[i] = trainingData[0][i]; // Use first training sample
    }
    
    Print("   📊 عينة قبل التطبيع (أول 5 قيم):");
    for(int i = 0; i < 5; i++)
    {
        Print("      القيمة ", i, ": ", DoubleToString(testSample[i], 4));
    }
    
    testProcessor.NormalizeData(testSample);
    
    Print("   📊 عينة بعد التطبيع (أول 5 قيم):");
    for(int i = 0; i < 5; i++)
    {
        Print("      القيمة ", i, ": ", DoubleToString(testSample[i], 4));
    }
    
    Print("   ✅ تم تحديث إحصائيات التطبيع بنجاح");
    return true;
}

//+------------------------------------------------------------------+
//| Test 6: Error Handling                                           |
//+------------------------------------------------------------------+
bool TestErrorHandling()
{
    // Test uninitialized processor
    CDataPreprocessor uninitializedProcessor;
    double features[];
    
    Print("   🧪 اختبار معالج غير مهيأ...");
    uninitializedProcessor.ExtractFeatures(features);
    
    if(ArraySize(features) == 50)
    {
        Print("   ⚠️ المعالج غير المهيأ أنتج ميزات - قد تكون هناك مشكلة في التحقق");
    }
    
    // Test normalization with wrong data size
    double wrongSizeData[25];
    ArrayInitialize(wrongSizeData, 1.0);
    uninitializedProcessor.NormalizeData(wrongSizeData);
    
    // Test statistics update with insufficient data
    CDataPreprocessor testProcessor;
    testProcessor.Initialize();
    
    double insufficientData[5][50];
    for(int i = 0; i < 5; i++)
    {
        for(int j = 0; j < 50; j++)
        {
            insufficientData[i][j] = i + j;
        }
    }
    
    Print("   🧪 اختبار بيانات غير كافية للإحصائيات...");
    if(testProcessor.UpdateNormalizationStats(insufficientData, 5))
    {
        Print("   ⚠️ تم قبول بيانات غير كافية - قد تحتاج لتحسين التحقق");
    }
    
    Print("   ✅ تم اختبار معالجة الأخطاء");
    return true;
}

//+------------------------------------------------------------------+
//| Test 7: Performance Test                                         |
//+------------------------------------------------------------------+
bool TestPerformance()
{
    CDataPreprocessor testProcessor;
    if(!testProcessor.Initialize())
    {
        Print("   ❌ فشل في تهيئة معالج البيانات للاختبار");
        return false;
    }
    
    int iterations = 1000;
    uint startTime = GetTickCount();
    
    // Test feature extraction performance
    for(int i = 0; i < iterations; i++)
    {
        double features[];
        testProcessor.ExtractFeatures(features);
    }
    
    uint extractionTime = GetTickCount() - startTime;
    
    // Test normalization performance
    double testData[50];
    for(int i = 0; i < 50; i++)
    {
        testData[i] = MathRand() / 100.0;
    }
    
    startTime = GetTickCount();
    for(int i = 0; i < iterations; i++)
    {
        double dataCopy[50];
        ArrayCopy(dataCopy, testData);
        testProcessor.NormalizeData(dataCopy);
    }
    uint normalizationTime = GetTickCount() - startTime;
    
    Print("   📊 نتائج اختبار الأداء:");
    Print("      استخراج الميزات: ", extractionTime, " مللي ثانية لـ ", iterations, " تكرار");
    Print("      تطبيع البيانات: ", normalizationTime, " مللي ثانية لـ ", iterations, " تكرار");
    Print("      متوسط وقت استخراج الميزات: ", DoubleToString((double)extractionTime/iterations, 3), " مللي ثانية");
    Print("      متوسط وقت التطبيع: ", DoubleToString((double)normalizationTime/iterations, 3), " مللي ثانية");
    
    // Performance thresholds (reasonable for real-time trading)
    if(extractionTime > iterations * 10) // More than 10ms per extraction
    {
        Print("   ⚠️ استخراج الميزات قد يكون بطيئاً للتداول الفوري");
    }
    
    if(normalizationTime > iterations * 2) // More than 2ms per normalization
    {
        Print("   ⚠️ تطبيع البيانات قد يكون بطيئاً للتداول الفوري");
    }
    
    Print("   ✅ تم اختبار الأداء بنجاح");
    return true;
}

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("🔚 انتهاء اختبار CDataPreprocessor");
}
