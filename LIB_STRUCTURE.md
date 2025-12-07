# Lib Structure and Purpose

This document provides an overview of the file structure within the `lib` directory and the purpose of each file.

## Root Directory

- **`app.dart`**: Main application widget configuration, including theme setup and router initialization.
- **`main.dart`**: The entry point of the application. It initializes Flutter bindings, Firebase, and runs the app.
- **`firebase_options.dart`**: Auto-generated configuration file for initializing Firebase with platform-specific options.

## constants

Files for defining constant values used across the app to ensure consistency.

- **`app_colors.dart`**: Defines the application's color palette.
- **`app_constants.dart`**: General constants such as string literals, configuration keys, or magic numbers.
- **`app_text_styles.dart`**: Pre-defined text styles for uniform typography.
- **`index.dart`**: Barrel file for exporting constants.

## models

Data classes defining the structure of objects used in the application.

- **`emergency_contact.dart`**: Model representing an emergency contact.
- **`friend_request.dart`**: Model representing a friend request.
- **`item.dart`**: Generic data model, likely used for lists or templates.
- **`notification.dart`**: Model representing a user notification.
- **`user.dart`**: Model representing a user profile.
- **`index.dart`**: Barrel file for exporting models.

## pages

Contains the UI screens (pages) of the application, organized by feature.

- **`auth/`**
  - **`forgot_password_page.dart`**: Screen for users to reset their password.
  - **`login_page.dart`**: User login screen.
  - **`signup_page.dart`**: User registration screen.
- **`contacts/`**
  - **`contacts_page.dart`**: Screen creating and viewing emergency contacts.
- **`detail/`**
  - **`detail_page.dart`**: Generic detail view screen.
- **`home/`**
  - **`home_page.dart`**: Main dashboard or landing page of the app.
- **`list/`**
  - **`list_page.dart`**: Generic list view screen.
- **`map/`**
  - **`map_page.dart`**: Screen displaying map and location-related features.
- **`notifications/`**
  - **`notifications_page.dart`**: Screen displaying user notifications.
- **`profile/`**
  - **`profile_page.dart`**: User profile management screen.
- **`search/`**
  - **`search_page.dart`**: Search interface for finding users or contacts.
- **`settings/`**
  - **`change_password_page.dart`**: Screen for changing the current password.
  - **`settings_page.dart`**: Application settings screen.
- **`sos/`**
  - **`sos_page.dart`**: Critical specific screen for initializing SOS alerts.
- **`splash/`**
  - **`splash_page.dart`**: Initial screen shown while the app loads/checks auth state.

## providers

State management logic using Riverpod.

- **`api_provider.dart`**: Provides the API client (e.g., Dio or http client).
- **`auth_provider.dart`**: Manages authentication state (login, logout, user session).
- **`contacts_provider.dart`**: Manages the state of the contacts list.
- **`friends_provider.dart`**: Manages the state of friends and friend requests.
- **`heart_rate_history_provider.dart`**: Manages a history of heart rate readings for charting; listens to real-time updates.
- **`location_provider.dart`**: Streams the device's real-time geographical location using Geolocator.
- **`location_sync_provider.dart`**: Listens to location updates and synchronizes them to Firebase.
- **`notifications_provider.dart`**: Manages the state of notifications.
- **`pulse_provider.dart`**: Connects to specific Firebase paths to stream real-time BPM data.
- **`storage_provider.dart`**: Provides access to local storage (e.g., SharedPreferences).
- **`theme_provider.dart`**: Manages the application's theme mode (light/dark).

## routes

- **`app_router.dart`**: Defines the application's navigation configuration (likely using GoRouter).

## services

Business logic and external service integrations.

- **`api_service.dart`**: Handles direct network API calls.
- **`heart_rate_simulator.dart`**: Service to simulate heart rate data for testing purposes.
- **`storage_service.dart`**: Wrapper for managing local data persistence.

## utils

Helper functions and utilities.

- **`app_theme.dart`**: Defines the overall `ThemeData` for the app.
- **`error_handler.dart`**: Centralized error handling logic.
- **`snackbar_utils.dart`**: Utilities for displaying Snackbars (toast messages).

## widgets

Reusable UI components.

- **`buttons.dart`**: Custom button widgets.
- **`cards.dart`**: Custom card widgets.
- **`ecg_chart.dart`**: Widget for visualizing heart rate data (ECG style).
- **`index.dart`**: Barrel file for exporting widgets.
