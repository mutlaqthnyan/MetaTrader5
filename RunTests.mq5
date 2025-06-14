//+------------------------------------------------------------------+
//|                                                     RunTests.mq5 |
//|                        Copyright 2024, Quantum Elite Trader Pro |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Quantum Elite Trader Pro"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include "test_Accelerator.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== بدء تشغيل اختبارات Accelerator ===");
   
   // تشغيل جميع الاختبارات
   RunAcceleratorTests();
   
   Print("=== انتهاء الاختبارات ===");
}
