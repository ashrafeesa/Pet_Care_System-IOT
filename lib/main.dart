import 'package:flutter/material.dart';
import 'package:todoapp/Pages/splash_page.dart';
import 'package:todoapp/helpers/MqttService.dart';
import 'package:todoapp/helpers/SupabaseMqttHelper.dart';
import 'package:todoapp/helpers/supabase_helper.dart';

// Global MQTT client instance
MQTTClientWrapper? globalMqttService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseHelper.init();
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('⚠️ Error initializing Supabase: $e');
    return; // Exit if Supabase initialization fails
  }
  
globalMqttService = MQTTClientWrapper(
  broker: "4723e46507764654bb8fa2e9e29ff1d3.s1.eu.hivemq.cloud",
  port: 8883,
  clientId: "pet_feeder_client",
  username: "hivemq.webclient.1756488166052",
  password: "dv653>?.1A!QyYbZTwFa",
);

await globalMqttService!.prepareMqttClient();
globalMqttService!.subscribeToTopic("pet/feeder/food/command");

// // Listen for changes in the food table
SupabaseMqttHelper.listenForFoodChanges(globalMqttService!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.purple.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
