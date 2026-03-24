import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // For demo purposes, we can try to get location, or default to Kigali Center
    // to avoid permission issues during the video if the browser blocks it.
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Ignore errors for demo smoothness
      print("Location error: $e");
    }
  }

  String _calculateDistance(double lat, double lng) {
    // Default to Kigali Center if no location found (mock for video)
    double startLat = _currentPosition?.latitude ?? -1.9441;
    double startLng = _currentPosition?.longitude ?? 30.0619;

    double distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      lat,
      lng,
    );

    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toStringAsFixed(0)} m";
    } else {
      return "${(distanceInMeters / 1000).toStringAsFixed(1)} km";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final listings = listingProvider.listings;
    final selectedCategory = listingProvider.selectedCategory;
    final theme = Theme.of(context);

    // Sort by distance if we have location, otherwise just sort by name or recent
    // For demo, we just show them as is.

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: Column(
          children: [
            // Custom Header Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Discover Kigali",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout now?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).signOut();
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search places...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) =>
                          listingProvider.searchListings(value),
                    ),
                  ),
                ],
              ),
            ),

            // Categories Filter (Horizontal Scroll)
            Container(
              height: 100,
              padding: const EdgeInsets.only(top: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryItem(
                    context,
                    label: 'All',
                    icon: Icons.grid_view,
                    isSelected: selectedCategory == null,
                    onTap: () => listingProvider.filterByCategory(null),
                  ),
                  ...ListingProvider.categories.map((category) {
                    return _buildCategoryItem(
                      context,
                      label: category,
                      // You could map specific icons here if you wanted, referencing _getIconForCategory from somewhere or moving it to utils
                      icon: Icons.place,
                      isSelected: selectedCategory == category,
                      onTap: () => listingProvider.filterByCategory(
                        selectedCategory == category ? null : category,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Listings Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nearby Places",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See All",
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),

            // Listings List
            Expanded(
              child: listingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No places found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        final distance = _calculateDistance(
                          listing.latitude,
                          listing.longitude,
                        );
                        return ListingCard(
                          listing: listing,
                          distance: distance,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
