import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseHelper {
  static const String projectUrl = 'https://xmusudcccmrqdteugbje.supabase.co';
  // Replace with your actual Supabase project URL
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtdXN1ZGNjY21ycWR0ZXVnYmplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzU0NDgsImV4cCI6MjA3MTYxMTQ0OH0.2YQbLQZv2oi6DWv2cxRxSJcPM9vsHCVMveoUmyx3CZs';
  // Replace with your actual Supabase anon key
  static Future init() async {
    await Supabase.initialize(url: projectUrl, anonKey: apiKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
