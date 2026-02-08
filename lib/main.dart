import 'package:flutter/material.dart';

import 'screens/label_screen.dart';

void main() {
  runApp(const LabelPrinterApp());
}

/// Címkenyomtató alkalmazás belépési pontja.
class LabelPrinterApp extends StatelessWidget {
  const LabelPrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Címkenyomtató',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LabelScreen(),
    );
  }
}
