# Kigali City Services & Places Directory

A Flutter mobile application for locating and navigating to essential public services and leisure locations in Kigali.

## Features
- **User Authentication**: Secure signup/login using Firebase Auth.
- **Directory**: searchable list of places categorized by type (Hospital, Police, Restaurant, etc.).
- **Map Integration**: Google Maps view displaying all location markers.
- **CRUD Operations**: Users can add, edit, and delete their own listings.
- **Real-time Updates**: Changes sync instantly across devices using Cloud Firestore.

## Architecture
This project follows a Clean Architecture approach using the **Provider** pattern for state management.
- **Models**: Data definitions (`Listing`, `UserProfile`).
- **Services**: dedicated classes for API interaction (`AuthService`, `DatabaseService`).
- **Providers**: State containers that call services and notify UI (`AuthProvider`, `ListingProvider`).
- **Screens**: UI components separated by feature.

## Database Structure (Firestore)
**Collection: `users`**
- `uid`: String (Document ID)
- `email`: String
- `displayName`: String
- `locationNotificationsEnabled`: Boolean

**Collection: `listings`**
- `id`: String (Document ID)
- `name`: String
- `category`: String
- `address`: String
- `contactNumber`: String
- `description`: String
- `latitude`: Number
- `longitude`: Number
- `createdBy`: String (User UID)
- `timestamp`: Timestamp

## Setup
1. **Firebase**:
   - Run `flutterfire configure` to link your Firebase project.
   - Enabling Email/Password Auth and Firestore in Firebase Console.
2. **Google Maps**:
   - Add your API Key to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`.
3. **Run**:
   - `flutter pub get`
   - `flutter run`
