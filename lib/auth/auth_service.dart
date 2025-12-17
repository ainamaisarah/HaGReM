import 'package:flutter/material.dart';
// Import Firebase Cloud Firestore package - used for storing user data in the database
import 'package:cloud_firestore/cloud_firestore.dart';
// Import Firebase Authentication package - used for user login/signup functionality
import 'package:firebase_auth/firebase_auth.dart';

// Global instance of AuthService wrapped in ValueNotifier
// This allows the app to listen to changes in the auth service throughout the app
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

/// AuthService class handles all authentication and user management operations
/// This is the main service that communicates with Firebase Auth and Firestore
class AuthService {
  // Firebase Authentication instance - handles user login, signup, and authentication state
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Firebase Firestore instance - handles database operations for storing user data
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Getter to access the currently logged-in user
  // Returns null if no user is logged in, otherwise returns the User object
  User? get currentUser => firebaseAuth.currentUser;

  // Stream that notifies listeners whenever the authentication state changes
  // This is useful for automatically updating UI when user logs in or out
  // Returns a stream of User objects (null when logged out, User when logged in)
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Creates a new user account with email and password
  /// Also stores additional user information in Firestore database
  ///
  /// Parameters:
  /// - email: User's email address
  /// - password: User's password
  /// - fullName: User's full name
  /// - username: User's chosen username
  /// - phoneNumber: User's phone number
  ///
  /// Returns: UserCredential object containing the newly created user information
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phoneNumber,
  }) async {
    // Step 1: Create authentication account in Firebase Auth
    // This creates the user's login credentials
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    // Step 2: Store additional user information in Firestore database
    // We use the user's UID (unique ID) from Firebase Auth as the document ID
    // This links the authentication account with the user's profile data
    await firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid, // Store the user's unique ID
      'email': email, // Store the email address
      'fullName': fullName, // Store the full name
      'username': username, // Store the username
      'phoneNumber': phoneNumber, // Store the phone number
      'createdAt':
          FieldValue.serverTimestamp(), // Store account creation time (set by server)
    });

    // Return the user credential for further use
    return userCredential;
  }

  /// Signs in an existing user with email and password
  ///
  /// Parameters:
  /// - email: User's registered email address
  /// - password: User's password
  ///
  /// Returns: UserCredential object containing the signed-in user information
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    // Authenticate the user with Firebase Auth
    // This will throw an error if credentials are incorrect
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the currently logged-in user
  /// After this, currentUser will be null and authStateChanges will emit null
  Future<void> signOut() async {
    return await firebaseAuth.signOut();
  }

  /// Sends a password reset email to the user
  /// The user will receive an email with a link to reset their password
  ///
  /// Parameters:
  /// - email: The email address to send the reset link to
  Future<void> resetPassword({required String email}) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Updates the user's password
  /// For security reasons, the user must re-authenticate before changing password
  ///
  /// Parameters:
  /// - currentPassword: The user's current password (for verification)
  /// - newPassword: The new password to set
  /// - email: The user's email address (needed for re-authentication)
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    // Step 1: Create credentials with current email and password
    // This is needed to verify the user's identity before making security changes
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    // Step 2: Re-authenticate the user with their current credentials
    // This confirms they know their current password
    await currentUser!.reauthenticateWithCredential(credential);

    // Step 3: Update to the new password
    // This only works if re-authentication was successful
    return await currentUser!.updatePassword(newPassword);
  }

  /// Updates user profile details in Firestore
  ///
  /// Parameters:
  /// - uid: The unique ID of the user whose details to update
  /// - updates: A Map containing the fields to update (e.g., fullName, age, gender, profileImagePath)
  ///
  /// This method updates the user document in Firestore with the provided fields
  Future<void> updateUserDetails(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    // Update the user document in the 'users' collection
    await firestore.collection('users').doc(uid).update(updates);
  }

  /// Retrieves user details from Firestore database
  ///
  /// Parameters:
  /// - uid: The unique ID of the user whose details to fetch
  ///
  /// Returns: A Map containing user data, or null if user doesn't exist
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    // Fetch the user document from the 'users' collection using their UID
    DocumentSnapshot doc = await firestore.collection('users').doc(uid).get();

    // Check if the document exists in the database
    if (doc.exists) {
      // Convert the document data to a Map and return it
      return doc.data() as Map<String, dynamic>?;
    }
    // Return null if the user document doesn't exist
    return null;
  }
}