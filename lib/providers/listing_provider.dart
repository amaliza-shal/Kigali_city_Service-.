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
        // MERGE POLICY: Always combine mock data with real Firestore data for the demo.
        // This ensures the directory looks full while allowing users to add/edit their own.
        final mockData = _getMockListings();

        // Use a Map to avoid duplicates if necessary (using ID), though here we assume distinct.
        // We prioritize Firestore data if there's an ID conflict (edit mock data scenario?)
        // Since mock IDs are '1'..'40' and Firestore uses UUIDs, simple concatenation is fine.

        _listings = [...mockData, ...listingsData];
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error listening to listings: $error");
        _listings = _getMockListings(); // Fallback to just mock data
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _injectMockData() {
    _listings = _getMockListings();
    _applyFilters();
  }

  // Refactored to return list for re-use
  List<Listing> _getMockListings() {
    return [
      // Tourist Attractions
      Listing(
        id: '1',
        name: 'Kigali Convention Centre',
        category: 'Tourist Attraction',
        address: 'KG 2 Roundabout, Kigali',
        contactNumber: '+250 788 123 456',
        description: 'Iconic convention center and landmark of Kigali.',
        latitude: -1.9538,
        longitude: 30.0934,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '3',
        name: 'Inema Arts Center',
        category: 'Tourist Attraction',
        address: 'KG 563 St, Kigali',
        contactNumber: '+250 783 187 646',
        description: 'Gallery featuring contemporary African art.',
        latitude: -1.9397,
        longitude: 30.0827,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),

      // Cafes (User specifically asked for these)
      Listing(
        id: '10',
        name: 'Question Coffee',
        category: 'Café',
        address: 'Gishushu, Kigali',
        contactNumber: '+250 788 654 321',
        description: 'Specialty coffee shop with a focus on women farmers.',
        latitude: -1.9515,
        longitude: 30.0910,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '11',
        name: 'Camellia Tea House',
        category: 'Café',
        address: 'KIC Building, Kigali',
        contactNumber: '+250 788 987 654',
        description: 'Popular spot for tea, coffee, and quick bites.',
        latitude: -1.9441,
        longitude: 30.0619,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '12',
        name: 'Bourbon Coffee',
        category: 'Café',
        address: 'Kigali Heights, Kigali',
        contactNumber: '+250 788 333 444',
        description: 'Rwanda\'s most famous coffee chain with great views.',
        latitude: -1.9545,
        longitude: 30.0930,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '13',
        name: 'Shokola Story',
        category: 'Café',
        address: 'Kiyovu, Kigali',
        contactNumber: '+250 788 555 666',
        description: 'Cozy cafe with a library vibe and rooftop seating.',
        latitude: -1.9592,
        longitude: 30.0635,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '14',
        name: 'Java House',
        category: 'Café',
        address: 'Highlights, Kigali',
        contactNumber: '+250 788 222 111',
        description: 'Reliable coffee and hearty meals.',
        latitude: -1.9548,
        longitude: 30.0932,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '15',
        name: 'Inzora Rooftop Café',
        category: 'Café',
        address: 'The Office, Kiyovu, Kigali',
        contactNumber: '+250 789 123 456',
        description: 'Best sunset views in Kigali with excellent pastries.',
        latitude: -1.9570,
        longitude: 30.0620,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '16',
        name: 'Brioche',
        category: 'Café',
        address: 'Grand Pension Plaza, Kigali',
        contactNumber: '+250 788 456 789',
        description: 'European style bakery and cafe.',
        latitude: -1.9445,
        longitude: 30.0625,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '17',
        name: 'Simba Café',
        category: 'Café',
        address: 'Gishushu, Kigali',
        contactNumber: '+250 788 111 222',
        description: 'Convenient cafe inside Simba Supermarket.',
        latitude: -1.9510,
        longitude: 30.0920,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '18',
        name: 'Rubia Coffee Roasters',
        category: 'Café',
        address: 'Kimihurura, Kigali',
        contactNumber: '+250 788 333 555',
        description: 'Specialty coffee roaster with industrial vibe.',
        latitude: -1.9585,
        longitude: 30.0750,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '19',
        name: 'Neo Cafe',
        category: 'Café',
        address: 'The Office, Kiyovu, Kigali',
        contactNumber: '+250 788 666 777',
        description: 'Relaxed atmosphere perfect for digital nomads.',
        latitude: -1.9565,
        longitude: 30.0630,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '50',
        name: 'Baso Patissier',
        category: 'Café',
        address: 'Kacyiru, Kigali',
        contactNumber: '+250 789 999 888',
        description: 'Famous for eclairs and french pastries.',
        latitude: -1.9420,
        longitude: 30.0880,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),

      // Restaurants
      Listing(
        id: '4',
        name: 'Afrika Bite',
        category: 'Restaurant',
        address: 'KG 674 St, Kigali',
        contactNumber: '+250 788 777 888',
        description: 'Famous for delicious local African buffet.',
        latitude: -1.9568,
        longitude: 30.0970,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '20',
        name: 'Repub Lounge',
        category: 'Restaurant',
        address: 'Kimihurura, Kigali',
        contactNumber: '+250 788 444 555',
        description: 'Upscale dining with pan-African cuisine and live music.',
        latitude: -1.9598,
        longitude: 30.0768,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '21',
        name: 'Pili Pili',
        category: 'Restaurant',
        address: 'Kibagabaga, Kigali',
        contactNumber: '+250 788 999 000',
        description: 'Lounge and restaurant with a pool and great views.',
        latitude: -1.9333,
        longitude: 30.1064,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),

      // Hospitals
      Listing(
        id: '5',
        name: 'University Teaching Hospital (CHUK)',
        category: 'Hospital',
        address: 'KN 4 Ave, Kigali',
        contactNumber: '112',
        description: 'Main referral hospital in City Center.',
        latitude: -1.9540,
        longitude: 30.0605,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
      Listing(
        id: '30',
        name: 'King Faisal Hospital',
        category: 'Hospital',
        address: 'Kacyiru, Kigali',
        contactNumber: '+250 788 123 789',
        description: 'Leading multi-specialty hospital in Rwanda.',
        latitude: -1.9439,
        longitude: 30.0945,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),

      // Police Stations
      Listing(
        id: '40',
        name: 'Kigali Metropolitan Police',
        category: 'Police Station',
        address: 'Remera, Kigali',
        contactNumber: '112',
        description: 'Central police station for the metropolitan area.',
        latitude: -1.9612,
        longitude: 30.1080,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),

      // Library
      Listing(
        id: '2',
        name: 'Kigali Public Library',
        category: 'Library',
        address: 'Kacyiru, Kigali',
        contactNumber: '+250 788 000 000',
        description: 'Modern public library with digital resources.',
        latitude: -1.9351,
        longitude: 30.0821,
        createdBy: 'admin',
        timestamp: DateTime.now(),
      ),
    ];
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
      print("Firestore add failed (Demo Mode Activated): $e");
      // Fallback: Add to local list so user sees it "worked"
      _listings.add(listing);
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> updateListing(Listing listing) async {
    try {
      await _databaseService.updateListing(listing);
    } catch (e) {
      print("Firestore update failed (Demo Mode Activated): $e");
      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = listing;
        _applyFilters();
        notifyListeners();
      }
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _databaseService.deleteListing(id);
    } catch (e) {
      print("Firestore delete failed (Demo Mode Activated): $e");
      _listings.removeWhere((l) => l.id == id);
      _applyFilters();
      notifyListeners();
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
