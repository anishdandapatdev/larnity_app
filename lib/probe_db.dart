import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    "https://lppxrbkgnajekulxpuce.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwcHhyYmtnbmFqZWt1bHhwdWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNTczMTAsImV4cCI6MjA2MTgzMzMxMH0.YohBuSrDqT3nc1KzLeWO1wGjFKrpNzxyrdi9fbzjXg4",
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
