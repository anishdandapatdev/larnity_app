import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    "https://qtbaoqrrxupwkyofcjqp.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF0YmFvcXJyeHVwd2t5b2ZjanFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MTI1ODcsImV4cCI6MjA2MjM4ODU4N30.VKMGNtNnoBiKVs4BE18quwHejpEoPscMXyYRTakluqc",
  );
  try {
    final response = await supabase.from('Course').select().limit(1);
    debugPrint(
      "KEYS returned: ${response.isNotEmpty ? response.first.keys.toList() : 'No records'}",
    );
    debugPrint("RECORD returned: $response");
  } catch (e) {
    debugPrint("DB error: $e");
  }
}
