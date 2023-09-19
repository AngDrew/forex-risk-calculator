// ignore_for_file: prefer-match-file-name

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:risk_calculator/src/calculator/models/calculator_data_model.dart';

import 'src/calculator/calculator_view.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CalculatorDataModelAdapter());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Risk Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const CalculatorView(),
    );
  }
}
