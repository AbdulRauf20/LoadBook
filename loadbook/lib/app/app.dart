import 'package:flutter/material.dart';

import 'theme.dart';

class LoadBookApp extends StatelessWidget {
  final Widget home;

  const LoadBookApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoadBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home,
    );
  }
}
