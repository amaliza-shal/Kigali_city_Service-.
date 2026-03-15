import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/database_service.dart';

class ListingProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<Listing>>? _listingsSubscription;

  List<Listing> _listings = [];
  bool _isLoading = false;

  // Filtering & Search
  List<Listing> _filteredListings = [];
  String _searchQuery = '';
  String? _selectedCategory;

  List<Listing> get listings =>
      _searchQuery.isEmpty && _selectedCategory == null
      ? _listings
      : _filteredListings;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  // Categories list based on requirements
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  // Initialize stream listener
  ListingProvider() {
    _subscribeToListings();
  }

  void _subscribeToListings() {
    _isLoading = true;
    notifyListeners();

    _listingsSubscription = _databaseService.listings.listen(
      (listingsData) {
        _listings = listingsData;
        _applyFilters(); // Re-apply filters whenever data updates
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error listening to listings: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addListing(Listing listing) async {
    try {
      await _databaseService.addListing(listing);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateListing(Listing listing) async {
    try {
      await _databaseService.updateListing(listing);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _databaseService.deleteListing(id);
    } catch (e) {
      rethrow;
    }
  }

  void searchListings(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredListings = _listings.where((listing) {
      final matchesSearch = listing.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    notifyListeners();
  }
}
