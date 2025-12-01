import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/pages/auth/forgot_password_page.dart';
import 'package:life_stream/pages/auth/login_page.dart';
import 'package:life_stream/pages/auth/signup_page.dart';
import 'package:life_stream/pages/detail/detail_page.dart';
import 'package:life_stream/pages/home/home_page.dart';
import 'package:life_stream/pages/list/list_page.dart';
import 'package:life_stream/pages/notifications/notifications_page.dart';
import 'package:life_stream/pages/profile/profile_page.dart';
import 'package:life_stream/pages/search/search_page.dart';
import 'package:life_stream/pages/settings/settings_page.dart';
import 'package:life_stream/pages/splash/splash_page.dart';
import 'package:life_stream/providers/auth_provider.dart';

// Route guard
Future<String?> authGuard(BuildContext context, GoRouterState state, WidgetRef ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) {
    return '/login';
  }
  return null;
}

// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) => const ListPage(),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DetailPage(itemId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
