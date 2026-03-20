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
      if (user != null && user.emailVerified) {
        _userProfile = await _authService.getUserProfile(user.uid);
        notifyListeners();
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
        // Force refresh user data from Firebase
        await user.reload();
        // Wait a brief moment to ensure propagation
        await Future.delayed(const Duration(milliseconds: 500));

        // Get the reloaded user instance directly from FirebaseAuth
        // This is safer than relying on the old 'user' variable
        final refreshedUser = FirebaseAuth.instance.currentUser;

        if (refreshedUser != null && !refreshedUser.emailVerified) {
          await _authService.signOut();
          throw 'Email not verified yet. Please check your inbox (and spam folder) for the verification link.';
        }

        // Fetch user profile from Firestore
        if (refreshedUser != null) {
          _userProfile = await _authService.getUserProfile(refreshedUser.uid);
        }
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
