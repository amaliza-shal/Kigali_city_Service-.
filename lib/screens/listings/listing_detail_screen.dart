import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import 'listing_form_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  Future<void> _launchMaps() async {
    final double lat = listing.latitude;
    final double lng = listing.longitude;
    // Try to launch native navigation intent (Android/Google Maps app)
    final Uri navigationUrl = Uri.parse("google.navigation:q=$lat,$lng");
    // Fallback to general map search URL (Web)
    final Uri webUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(navigationUrl)) {
      await launchUrl(navigationUrl);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl);
    } else {
      throw 'Could not launch maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userProfile;
    final isOwner = user?.uid == listing.createdBy;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar with Map
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                listing.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing.latitude, listing.longitude),
                  zoom: 15,
                ),
                liteModeEnabled: true,
                zoomControlsEnabled: false,
                markers: {
                  Marker(
                    markerId: MarkerId(listing.id),
                    position: LatLng(listing.latitude, listing.longitude),
                  ),
                },
              ),
            ),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Listing',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingFormScreen(listing: listing),
                          ),
                        );
                      },
                    ),
                  ]
                : null,
          ),

          // Content
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _launchMaps,
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text("Get Directions"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Address Section
                  _buildSectionTitle("Address"),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          listing.address,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Contact Section
                  _buildSectionTitle("Contact"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        color: Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        listing.contactNumber.isNotEmpty
                            ? listing.contactNumber
                            : "No contact info",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description Section
                  _buildSectionTitle("About"),
                  const SizedBox(height: 8),
                  Text(
                    listing.description.isNotEmpty
                        ? listing.description
                        : "No description provided for this place.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }
}
