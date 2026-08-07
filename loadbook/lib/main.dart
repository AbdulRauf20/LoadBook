import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'data/local/database.dart';
import 'features/daily/screens/daily_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LoadBookApp());
}

class LoadBookApp extends StatelessWidget {
  const LoadBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final database = LoadBookDatabase();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoadBook',
      theme: AppTheme.lightTheme,
      home: DailyScreen(database: database),
    );
  }
}
