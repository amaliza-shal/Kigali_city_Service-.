import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Sign In
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock Login Logic (Guaranteed Success)
    await Future.delayed(const Duration(milliseconds: 500));
    _userProfile = UserProfile(
      uid: 'demo-user-123',
      email: email,
      displayName: 'Demo User',
    );
    _isLoading = false;
    notifyListeners();
  }

  // Sign Up
  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    // Mock Signup Logic (Guaranteed Success)
    await Future.delayed(const Duration(milliseconds: 500));
    // No need to set user profile here as usually it redirects to login
    _isLoading = false;
    notifyListeners();
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
