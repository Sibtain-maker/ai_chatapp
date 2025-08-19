import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://fxabxciuxmnjhqzdehtf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4YWJ4Y2l1eG1uamhxemRlaHRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1NTI5OTksImV4cCI6MjA3MTEyODk5OX0.Maungq6tRtDlqhK7M-l2ivFiXCD3xjbVJ78_43pKeHs',
  );
  
  runApp(
    ProviderScope(
      child: LuminAIApp(),
    ),
  );
}

