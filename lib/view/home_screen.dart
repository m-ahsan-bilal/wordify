import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wordify'), centerTitle: true),
      body: const Center(child: Text('Your Vocabulary Journey Starts Here!')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/add-word'),
        label: const Text('Add Word'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
