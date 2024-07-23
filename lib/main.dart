import 'package:flutter/material.dart';

void main() {
  runApp(const CMFNixApp());
}

class CMFNixApp extends StatelessWidget {
  const CMFNixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMF Nix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CMF Nix'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Nothing Earbuds Control'),
      ),
    );
  }
}
