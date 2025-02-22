import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';

import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.isDarkMode,
    required this.onThemeToggle,
    Key? key,
  }) : super(key: key);

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;

  void _incrementCounter() {
    setState(() {
      _count++;
    });
    SnaplyReporter.instance.log(message: 'Increment Counter: $_count');
  }

  void _decrementCounter() {
    setState(() {
      _count--;
    });
    SnaplyReporter.instance.log(message: 'Decrement Counter: $_count');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snaply Demo'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Counter Value',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _decrementCounter,
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrease'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('Increase'),
                  ),
                ],
              ),
              const Spacer(),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Send result'),
                  subtitle: const Text('Submit your counter value'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FormPage(counterValue: _count),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
