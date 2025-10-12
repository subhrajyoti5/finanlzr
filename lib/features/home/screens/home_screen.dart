import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 24.0 : screenWidth * 0.1,
            vertical: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AI Stock Analysis Prototype',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: isSmallScreen ? double.infinity : 400,
                child: TextField(
                  controller: _tickerController,
                  decoration: const InputDecoration(
                    hintText: 'Enter ticker symbol (e.g., AAPL, RELIANCE.NS)',
                    labelText: 'Ticker Symbol',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 15,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: isSmallScreen ? double.infinity : 400,
                child: ElevatedButton(
                  onPressed: _analyzeTicker,
                  child: const Text('Analyze'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: isSmallScreen ? double.infinity : 400,
                child: OutlinedButton(
                  onPressed: () => context.go('/portfolio'),
                  child: const Text('My Portfolio'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: isSmallScreen ? double.infinity : 400,
                child: OutlinedButton(
                  onPressed: () => context.go('/comparison'),
                  child: const Text('Compare Stocks'),
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
