import 'dart:io';

class ErrorHandler {
  static String getReadableErrorMessage(Object error) {
    String errorString = error.toString();

    // Firebase Auth Errors
    if (errorString.contains('firebase_auth/invalid-credential') ||
        errorString.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Incorrect email or password.';
    }
    if (errorString.contains('firebase_auth/user-not-found')) {
      return 'No user found with this email.';
    }
    if (errorString.contains('firebase_auth/wrong-password')) {
      return 'Incorrect password.';
    }
    if (errorString.contains('firebase_auth/email-already-in-use')) {
      return 'Email is already registered. Please login instead.';
    }
    if (errorString.contains('firebase_auth/weak-password')) {
      return 'The password provided is too weak.';
    }
    if (errorString.contains('firebase_auth/invalid-email')) {
      return 'The email address is invalid.';
    }
    if (errorString.contains('firebase_auth/network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorString.contains('firebase_auth/too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    // Network Errors
    if (error is SocketException || errorString.contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    }

    // Generic Fallback
    // Ideally log this locally or to a service for debugging
    return 'An unexpected error occurred. Please try again.';
  }
}
