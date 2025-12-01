import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_stream/services/api_service.dart';

// API service provider (singleton)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
