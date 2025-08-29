import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todoapp/helpers/MqttService.dart';

class SupabaseMqttHelper {
  static final _client = Supabase.instance.client;

  /// ✅ الاستماع لأي صف جديد أو تعديل في جدول food
  static void listenForFoodChanges(MQTTClientWrapper mqtt) {
    print("👂 Starting Supabase stream listener on 'food'...");

    _client
        .from('food')
        .stream(primaryKey: ['id']) // لازم تحدد الـ PK
        .listen((data) {
      print("📩 New stream event received from Supabase!");
      if (data.isEmpty) {
        print("⚠️ Stream event was empty, skipping...");
        return;
      }

      // ✅ آخر صف مضاف (Supabase بيرجع List كاملة)
      final lastRow = data.last;
      print("🆕 Last row from food table: $lastRow");

      // 🥗 جلب القيم من الجدول
      final int meals = lastRow['meals_count'] ?? 0;
      final int portionSize = lastRow['portion_size_grams'] ?? 0;
      // final int gapHours = lastRow['gap_hours'] ?? 0;
      final int water = lastRow['water_level'] ?? 0;
      final String firstMealTime = lastRow['first_meal_time'] ?? '';

      // ✉️ صياغة الرسالة
      final message =
          "SETTINGS:MEALS=$meals;PORTION=$portionSize;WATER=$water;FIRST_MEAL_TIME=$firstMealTime";

      print("📤 Preparing to publish MQTT message: $message");

      try {
        mqtt.publishMessage("pet/feeder/food/command", message);
        print("✅ Published successfully to topic pet/feeder/food/command");
      } catch (e) {
        print("❌ Error publishing to MQTT: $e");
      }
    });
  }
}
