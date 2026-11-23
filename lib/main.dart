import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pr_2/pages/notes_pages.dart';
import 'package:pr_2/provider/notes_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(),
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Заметки',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}
