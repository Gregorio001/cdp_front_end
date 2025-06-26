import 'package:cdp_contract_comparison/providers/analysis_provider.dart';
import 'package:cdp_contract_comparison/screens/analysis_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Il ChangeNotifierProvider rende lo stato disponibile a tutti i widget sottostanti
    return ChangeNotifierProvider(
      create: (context) => AnalysisProvider(),
      child: MaterialApp(
        title: 'CDP Analisi Contratti',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF003D7A), // Un blu istituzionale
            primary: const Color(0xFF003D7A),
            secondary: const Color(0xFFE57200), // Un arancione per contrasto
            background: const Color(0xFFF5F5F5),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF003D7A),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AnalysisScreen(),
      ),
    );
  }
}