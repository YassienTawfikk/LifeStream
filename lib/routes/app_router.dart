// File: LifeStream/lib/routes/app_router.dart (Modified Content - Added new imports and routes)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/pages/auth/forgot_password_page.dart' show ForgotPasswordPage;
import 'package:life_stream/pages/auth/login_page.dart' show LoginPage;
import 'package:life_stream/pages/auth/signup_page.dart' show SignupPage;
import 'package:life_stream/pages/detail/detail_page.dart' show DetailPage;
import 'package:life_stream/pages/home/home_page.dart' show HomePage;
import 'package:life_stream/pages/list/list_page.dart' show ListPage;
import 'package:life_stream/pages/notifications/notifications_page.dart' show NotificationsPage;
import 'package:life_stream/pages/profile/profile_page.dart' show ProfilePage;
import 'package:life_stream/pages/search/search_page.dart' show SearchPage;
// ... existing imports ...
import 'package:life_stream/pages/settings/settings_page.dart';
import 'package:life_stream/pages/splash/splash_page.dart';
import 'package:life_stream/providers/auth_provider.dart';

// NEW PAGES IMPORTS
import 'package:life_stream/pages/sos/sos_page.dart'; // NEW
import 'package:life_stream/pages/contacts/contacts_page.dart'; // NEW
import 'package:life_stream/pages/map/map_page.dart'; // NEW
// END NEW PAGES IMPORTS

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

      // Main Routes (Wearable-Specific)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(), // Now the Dashboard
      ),
      GoRoute(
        path: '/sos',
        builder: (context, state) => const SosPage(), // NEW
      ),
      GoRoute(
        path: '/emergency-contacts',
        builder: (context, state) => const EmergencyContactsPage(), // NEW
      ),
      GoRoute(
        path: '/live-map',
        builder: (context, state) => const LiveMapPage(), // NEW
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
      
      // Generic Starter App Routes (Can be removed later)
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
    ],
  );
});