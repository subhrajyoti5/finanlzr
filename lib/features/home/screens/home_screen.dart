import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _tickerController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'finanlzr',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'AI Stock Analysis Prototype',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  hintText: 'Enter ticker symbol (e.g., AAPL)',
                  labelText: 'Ticker Symbol',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _analyzeTicker,
                  child: const Text('Analyze'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _analyzeTicker() {
    final ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a ticker symbol')),
      );
      return;
    }
    // Navigate to results - will implement later
    context.go('/results?ticker=$ticker');
  }
}
