import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lppxrbkgnajekulxpuce.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwcHhyYmtnbmFqZWt1bHhwdWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYyNTczMTAsImV4cCI6MjA2MTgzMzMxMH0.YohBuSrDqT3nc1KzLeWO1wGjFKrpNzxyrdi9fbzjXg4',
  );
  try {
    final response = await supabase.from('ProductAndService').insert({
      'name': 'Test',
      'description': 'Desc',
      'price': 10,
      'whatsappNumber': '+919999999999',
      'imageUrl': 'url',
      'groupId': '00000000-0000-0000-0000-000000000000',
      'type': 'PRODUCT',
      'rating': 5,
    }).select();
    debugPrint(response.toString());
  } catch (e) {
    debugPrint('Error: ');
  }
}
