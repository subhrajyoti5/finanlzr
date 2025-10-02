import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finanlzr/core/theme/app_theme.dart';
import 'package:finanlzr/core/router/app_router.dart';

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'finanlzr',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
