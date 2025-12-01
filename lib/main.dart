import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/app.dart';
import 'package:life_stream/providers/storage_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage before running the app
  final container = ProviderContainer();
  try {
    await container.read(initStorageProvider.future);
  } catch (e) {
    debugPrint('Storage initialization error: $e');
  }

  runApp(
    ProviderScope(
      child: const LifeStreamApp(),
    ),
  );
}
