import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mirai/mirai.dart';

import 'package:elka/app/admin/home_page.dart';
import 'package:elka/app/global/login_page.dart';
import 'package:elka/app/global/splash_page.dart';



Future<void> main() async {
  await Mirai.initialize();
  await Supabase.initialize(
    url: 'https://ljnvlapaekfwuopurbdf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqbnZsYXBhZWtmd3VvcHVyYmRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI5NjU0MTcsImV4cCI6MjAzODU0MTQxN30.IZRunEB23nVNpMi1bUl1adTwyZUAcf_Yq7ZGYDtfQ20',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;


class SupabaseHelper {
  final SupabaseClient _supabaseClient;

  SupabaseHelper(this._supabaseClient);

  Future<List<dynamic>> fetchData(String tableName) async {
    try {
      final data = await _supabaseClient
          .from(tableName)
          .select('*');
      return data;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<int> insertMarker(String tableName, String title, String description, double lat, double lng) async {
    final response = await _supabaseClient
        .from(tableName)
        .insert({'name': title, 'description': description, 'lat': lat, 'lng': lng})
        .select('id')
        .single();

    return response['id'];
  }
  Future<List<dynamic>> findMarkerbyID(String tableName, int id) async {
    try {
      print(id);
      final data = await _supabaseClient
          .from(tableName)
          .select()
          .eq('id', id);
      return data;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

}

final supabaseHelper = SupabaseHelper(supabase);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ёlka',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SSPage(),
        '/login': (_) => const LoginPage(),
        '/account': (_) => const  HomePage(),
      },
    );
  }
}