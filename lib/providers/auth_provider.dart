import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _userProfile;
  bool _isLoading = false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.user.listen((user) async {
      if (user != null) {
        if (user.emailVerified) {
          _userProfile = await _authService.getUserProfile(user.uid);
          notifyListeners();
        } else {
          // If logged in but not verified, show as logged out or handle appropriately
          // Usually we sign them out or let them access limited features
          // Here we just don't set the profile so the app remains in "login" state
          _userProfile = null;
          notifyListeners();
        }
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Sign In
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _authService.signIn(email, password);
      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          await _authService.signOut();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Please verify your email address before logging in.',
          );
        }

        _userProfile = await _authService.getUserProfile(user.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Up
  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(email, password, name);
      // We don't sign in automatically because they need to verify email
      await _authService.signOut();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _userProfile = null;
    notifyListeners();
  }

  // Reload and check email verification status (useful after user verifies email)
  Future<void> checkEmailVerification() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Reload the user to get fresh verification status
      await currentUser.reload();
      final updatedUser = _authService.currentUser;

      if (updatedUser == null) {
        throw Exception('User data not available');
      }

      if (!updatedUser.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Email not verified yet. Please check your email and verify your account.',
        );
      }

      // Email is verified, load the profile
      _userProfile = await _authService.getUserProfile(updatedUser.uid);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update Notification Preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_userProfile == null) return;
    try {
      await _authService.updateNotificationPreference(
        _userProfile!.uid,
        enabled,
      );
      // Update local state
      _userProfile = UserProfile(
        uid: _userProfile!.uid,
        email: _userProfile!.email,
        displayName: _userProfile!.displayName,
        locationNotificationsEnabled: enabled,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
