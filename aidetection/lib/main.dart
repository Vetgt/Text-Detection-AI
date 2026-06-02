import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/prediction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: const VeritasApp(),
    ),
  );
}

class VeritasApp extends StatelessWidget {
  const VeritasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veritas — AI Detector',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
