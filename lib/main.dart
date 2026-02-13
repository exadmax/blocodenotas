import 'package:flutter/material.dart';
import 'screens/notepad_screen.dart';

void main() {
  runApp(const BlocoDeNotasApp());
}

class BlocoDeNotasApp extends StatelessWidget {
  const BlocoDeNotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloco de Notas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotepadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
