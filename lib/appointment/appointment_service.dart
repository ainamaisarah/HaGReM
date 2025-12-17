import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

ValueNotifier<AppointmentService> appointmentService = ValueNotifier(
  AppointmentService(),
);

class AppointmentService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createBooking({
    required String userId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime date,
    required String time,
  }) async {
    await firestore.collection('appointments').add({
      'userId': userId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date,
      'time': time,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all appointments (for admin)
  Stream<QuerySnapshot> getAllAppointments() {
    return firestore
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get appointments for a specific user
  Stream<QuerySnapshot> getUserAppointments(String userId) {
    return firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  // Get user's upcoming approved appointment
  Stream<QuerySnapshot> getUserUpcomingAppointment(String userId) {
    return firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }
}