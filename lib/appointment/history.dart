import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/appointment/appointment_service.dart';
import 'package:project/auth/auth_service.dart';
import 'package:project/home/homepage.dart';
import 'package:project/theme/app_colors.dart';
import 'package:project/theme/theme_provider.dart';
import 'package:intl/intl.dart';

class HistoryAppointment extends StatefulWidget {
  const HistoryAppointment({super.key});

  @override
  State<HistoryAppointment> createState() => _HistoryAppointmentState();
}

class _HistoryAppointmentState extends State<HistoryAppointment> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        final bgColor = themeMode == ThemeMode.dark
            ? const Color(0xFF121212)
            : AppColors.primaryDark;
        final cardColor = themeMode == ThemeMode.dark
            ? AppColors.accentDarkGrey
            : AppColors.cardBackground;
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
            ),
            title: const Text(
              'Appointment History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: appointmentService.value.getUserAppointments(
              authService.value.currentUser!.uid,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No appointments found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              // Sort appointments by date (newest first)
              var appointments = snapshot.data!.docs.toList();
              appointments.sort((a, b) {
                var aData = a.data() as Map<String, dynamic>;
                var bData = b.data() as Map<String, dynamic>;

                // Try to sort by createdAt first, if not available use date
                if (aData['createdAt'] != null && bData['createdAt'] != null) {
                  Timestamp aTimestamp = aData['createdAt'] as Timestamp;
                  Timestamp bTimestamp = bData['createdAt'] as Timestamp;
                  return bTimestamp.compareTo(aTimestamp); // Descending order
                } else if (aData['date'] != null && bData['date'] != null) {
                  Timestamp aDate = aData['date'] as Timestamp;
                  Timestamp bDate = bData['date'] as Timestamp;
                  return bDate.compareTo(aDate); // Descending order
                }
                return 0;
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var doc = appointments[index];
                  var appointment = doc.data() as Map<String, dynamic>;
                  String appointmentId = doc.id;

                  DateTime date = (appointment['date'] as Timestamp).toDate();
                  String formattedDate = DateFormat('dd MMM yyyy').format(date);
                  String status = appointment['status'] ?? 'pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Info
                                  FutureBuilder<Map<String, dynamic>?>(
                                    future: authService.value.getUserDetails(
                                      appointment['userId'] ?? '',
                                    ),
                                    builder: (context, userSnapshot) {
                                      String username = 'Loading...';
                                      if (userSnapshot.hasData &&
                                          userSnapshot.data != null) {
                                        username =
                                            userSnapshot.data!['username'] ??
                                            'Unknown User';
                                      }
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: themeMode == ThemeMode.dark
                                              ? AppColors.primaryLight
                                              : AppColors.buttonBlue,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.person,
                                              size: 14,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Requested by: $username',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    appointment['doctorName'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appointment['doctorSpecialty'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: $formattedDate',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Time: ${appointment['time']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                //color: _getStatusColor(status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (status == 'pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await appointmentService.value
                                        .updateAppointmentStatus(
                                          appointmentId,
                                          'approved',
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Appointment approved'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await appointmentService.value
                                        .updateAppointmentStatus(
                                          appointmentId,
                                          'rejected',
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Appointment rejected'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}