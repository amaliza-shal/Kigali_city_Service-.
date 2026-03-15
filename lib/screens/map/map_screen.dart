import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../listings/listing_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final listings = Provider.of<ListingProvider>(context).listings;

    final Set<Marker> markers = listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        ),
      );
    }).toSet();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'City Map',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        toolbarHeight: 50,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 12.0,
            ),
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll add a custom button
            zoomControlsEnabled: false, // Cleaner look
            mapToolbarEnabled: false,
          ),

          // Floating Action Buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _buildMapFab(Icons.my_location, () {
                  // Logic to go to my location would require location package access here
                  // or controller.animateCamera to user location if available
                }),
                const SizedBox(height: 12),
                _buildMapFab(Icons.add, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }),
                const SizedBox(height: 12),
                _buildMapFab(Icons.remove, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFab(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.blue[800]),
        ),
      ),
    );
  }
}
