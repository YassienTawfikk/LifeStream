import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/services/storage_service.dart';

// Storage service provider (singleton) - properly initialized
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final storage = StorageService();
  await storage.init();
  return storage;
});

// Initialize storage - used at app startup
final initStorageProvider = FutureProvider<void>((ref) async {
  await ref.watch(storageServiceProvider.future);
});
