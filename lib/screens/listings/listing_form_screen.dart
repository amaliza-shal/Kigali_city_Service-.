import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class ListingFormScreen extends StatefulWidget {
  final Listing? listing; // If not null, we are editing

  const ListingFormScreen({super.key, this.listing});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing?.name ?? '');
    _addressController = TextEditingController(
      text: widget.listing?.address ?? '',
    );
    _contactController = TextEditingController(
      text: widget.listing?.contactNumber ?? '',
    );
    _descController = TextEditingController(
      text: widget.listing?.description ?? '',
    );
    // Default to Kigali Center if new listing, to avoid 0.0 or empty
    _latController = TextEditingController(
      text: widget.listing?.latitude.toString() ?? '-1.9441',
    );
    _lngController = TextEditingController(
      text: widget.listing?.longitude.toString() ?? '30.0619',
    );

    _selectedCategory = widget.listing?.category;
    if (_selectedCategory == null && ListingProvider.categories.isNotEmpty) {
      _selectedCategory = ListingProvider.categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      _latController.text = position.latitude.toString();
      _lngController.text = position.longitude.toString();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not get location. Check permissions.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() => _isLoading = true);

    final user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error: Not authenticated")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final double lat = double.tryParse(_latController.text) ?? 0.0;
      final double lng = double.tryParse(_lngController.text) ?? 0.0;

      final newListing = Listing(
        id: widget.listing?.id ?? const Uuid().v4(), // Generate ID if new
        name: _nameController.text,
        category: _selectedCategory!,
        address: _addressController.text,
        contactNumber: _contactController.text,
        description: _descController.text,
        latitude: lat,
        longitude: lng,
        createdBy: user.uid,
        timestamp: DateTime.now(),
      );

      final provider = Provider.of<ListingProvider>(context, listen: false);

      if (widget.listing == null) {
        await provider.addListing(newListing);
      } else {
        await provider.updateListing(newListing);
      }

      if (mounted) {
        // Clear search and filters so user sees their new listing immediately
        provider.searchListings('');
        provider.filterByCategory(null);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.listing == null
                  ? '✅ Listing Created! View on Home & Map'
                  : '✏️ Listing Updated!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.listing != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Listing' : 'Add New Place',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Basic Information"),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        'Place Name',
                        Icons.store_mall_directory,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('Category', Icons.category),
                      items: ListingProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: 30),

                    _buildSectionHeader("Location"),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration(
                        'Address',
                        Icons.location_on,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter an address' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: _inputDecoration(
                              'Latitude',
                              Icons.explore,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            decoration: _inputDecoration(
                              'Longitude',
                              Icons.explore,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Use Current Location"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildSectionHeader("Details"),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _contactController,
                      decoration: _inputDecoration(
                        'Contact Number',
                        Icons.phone,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      decoration:
                          _inputDecoration(
                            'Description',
                            Icons.description,
                          ).copyWith(
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        isEditing ? 'Update Listing' : 'Create Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
