import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class DatabaseService {
  final CollectionReference _listingsCollection = FirebaseFirestore.instance
      .collection('listings');

  // Create
  Future<void> addListing(Listing listing) async {
    await _listingsCollection.doc(listing.id).set(listing.toMap());
  }

  // Read (Stream)
  Stream<List<Listing>> get listings {
    return _listingsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Listing.fromDocument(doc)).toList();
        });
  }

  // Update
  Future<void> updateListing(Listing listing) async {
    await _listingsCollection.doc(listing.id).update(listing.toMap());
  }

  // Delete
  Future<void> deleteListing(String id) async {
    await _listingsCollection.doc(id).delete();
  }
}
