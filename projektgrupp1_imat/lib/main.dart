import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';
import 'package:projektgrupp1_imat/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMat - Projektgrupp 1',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
