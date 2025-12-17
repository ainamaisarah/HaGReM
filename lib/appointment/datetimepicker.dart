import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/appointment/appointment_service.dart';
import 'package:project/auth/auth_service.dart';
import 'package:project/home/homepage.dart';
import 'package:project/theme/app_colors.dart';
import 'package:project/theme/theme_provider.dart';

class DateTimePickerPage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;

  const DateTimePickerPage({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
  });

  @override
  State<DateTimePickerPage> createState() => _DateTimePickerPageState();
}

class _DateTimePickerPageState extends State<DateTimePickerPage> {
  int selectedDay = 15; // Default selected day
  String selectedTime = '12:30 PM'; // Default selected time
  late int currentMonth;
  late int currentYear;

Widget _calendarNavButton(IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    DateTime now = DateTime.now();
    currentMonth = now.month;
    currentYear = now.year;
    selectedDay = now.day;
  }

  // Get number of days in a month
  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Get the weekday of the first day of the month (1 = Monday, 7 = Sunday)
  int getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  // Get month name
  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Navigate to previous month
  void previousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
      // Reset selected day if it exceeds days in new month
      int daysInMonth = getDaysInMonth(currentYear, currentMonth);
      if (selectedDay > daysInMonth) {
        selectedDay = daysInMonth;
      }
    });
  }

  // Navigate to next month
  void nextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
      // Reset selected day if it exceeds days in new month
      int daysInMonth = getDaysInMonth(currentYear, currentMonth);
      if (selectedDay > daysInMonth) {
        selectedDay = daysInMonth;
      }
    });
  }

  final List<String> timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:30 PM',
    '02:00 PM',
    '03:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
  ];

  // Firebase implementation to book appointment
  void bookAppointment() async {
    User? user = authService.value.currentUser;
    if (user != null) {
      DateTime appointmentDate = DateTime(
        currentYear,
        currentMonth,
        selectedDay,
      );
      await appointmentService.value.createBooking(
        userId: user.uid,
        doctorName: widget.doctorName,
        doctorSpecialty: widget.doctorSpecialty,
        date: appointmentDate,
        time: selectedTime,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: themeNotifier.value == ThemeMode.dark
                  ? const Color(0xFF121212)
                  : AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 40,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Booking Successful!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your appointment has been successfully booked.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to HomePage and remove all previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } else {
      // Handle not logged in (should not happen in this flow but good safety)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        final bgColor = themeMode == ThemeMode.dark
            ? const Color(0xFF121212)
            : AppColors.primaryDark;
        // final containerBgColor = themeMode == ThemeMode.dark
        //     ? AppColors.accentDarkGrey
        //     : Colors.white;
        final textColor = themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black;
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Appointment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Calendar Card
Container(
  margin: const EdgeInsets.only(top: 8),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: themeMode == ThemeMode.dark
          ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF2A2A2A),
            ]
          : [
              Colors.white,
              const Color(0xFFF7F9FC),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Column(
    children: [
      // 🌙 Floating Month Header
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryLight,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${getMonthName(currentMonth)} $currentYear',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                _calendarNavButton(Icons.chevron_left, previousMonth),
                const SizedBox(width: 6),
                _calendarNavButton(Icons.chevron_right, nextMonth),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // 🗓 Week Days
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map(
              (day) => Text(
                day,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: (day == 'Sun' || day == 'Sat')
                      ? Colors.redAccent
                      : textColor.withOpacity(0.6),
                ),
              ),
            )
            .toList(),
      ),

      const SizedBox(height: 18),

      // 📆 Days Grid
      Builder(
        builder: (context) {
          int daysInMonth =
              getDaysInMonth(currentYear, currentMonth);
          int firstDayOfWeek =
              getFirstDayOfMonth(currentYear, currentMonth);
          int offset = firstDayOfWeek % 7;
          int totalCells = daysInMonth + offset;
          DateTime today = DateTime.now();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox();

              int day = index - offset + 1;
              bool isSelected = day == selectedDay;
              bool isToday = day == today.day &&
                  currentMonth == today.month &&
                  currentYear == today.year;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedDay = day);
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !isSelected && isToday
                          ? AppColors.accentGold.withOpacity(0.25)
                          : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                             BoxShadow(
                        color: Colors.black.withOpacity(0.1), // lighter, subtle shadow
                        blurRadius: 6, // smaller blur
                        offset: const Offset(0, 3), // softer offset
                      ),

                            ]
                          : [],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppColors.primaryDark
                                      : textColor,
                            ),
                          ),
                          if (isToday && !isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ],
  ),
),

                const SizedBox(height: 24),

                // Section Title
                Text(
                  'Select Consultation Time',
                  style: TextStyle(
                    color: themeMode == ThemeMode.dark ? Colors.white : AppColors.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

// Time Slots Grid
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    childAspectRatio: 3,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: timeSlots.length,
  itemBuilder: (context, index) {
    String time = timeSlots[index];
    bool isSelected = time == selectedTime;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTime = time;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : (themeMode == ThemeMode.dark ? AppColors.accentDarkGrey : Colors.white),
          borderRadius: BorderRadius.circular(30), // pill shape
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : (themeMode == ThemeMode.dark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (themeMode == ThemeMode.dark ? Colors.white70 : AppColors.primaryDark),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  },
),
                const SizedBox(height: 24),

                // Book Appointment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold, // Gold/Yellow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}