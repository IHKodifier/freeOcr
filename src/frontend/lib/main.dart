import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/hero_dropzone.dart';

void main() {
  runApp(const FreeOcrApp());
}

class FreeOcrApp extends StatelessWidget {
  const FreeOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'freeOCR.me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('freeOCR.me'),
        backgroundColor: colorScheme.surfaceContainer,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.document_scanner,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Scanned PDF to Searchable PDF/Text',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '100% Free & Privacy Ephemeral • Zero Registration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 24),
                const HeroDropzone(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

