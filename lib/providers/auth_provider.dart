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
        // For browser/recording: Allow access. In production, check emailVerified
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
        // For browser/demo: Allow immediate access
        // In production, add email verification check here:
        // if (!user.emailVerified) { ... }

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
