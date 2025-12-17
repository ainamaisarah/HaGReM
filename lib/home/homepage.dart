import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/app/handopposition.dart';
import 'package:project/app/handstrength.dart';
import 'package:project/app/webview_page.dart';
import 'package:project/appointment/appointment_service.dart';
import 'package:project/appointment/docdetails.dart';
import 'package:project/appointment/history.dart';
import 'package:project/auth/auth_service.dart';
import 'package:project/auth/login.dart';
import 'package:project/home/about.dart';
import 'package:project/home/collaborators.dart';
import 'package:project/home/profile.dart';
import 'package:project/theme/app_colors.dart';
import 'package:project/theme/theme_provider.dart';
import 'package:project/app/videoguided.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
final ScrollController _pageScrollController = ScrollController();
final ScrollController _carouselController = ScrollController();

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Default to Home
  String? currentUserId;
  String? username;

void _startAutoScrollCarousel() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_carouselController.hasClients) return;

    final maxScroll = _carouselController.position.maxScrollExtent;

    Future.doWhile(() async {
      if (!_carouselController.hasClients) return false;

      await _carouselController.animateTo(
        maxScroll,
        duration: const Duration(seconds: 300),
        curve: Curves.linear,
      );

      if (!_carouselController.hasClients) return false;

      _carouselController.jumpTo(0);
      return true;
    });
  });
}

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeMode themeMode,
  }) {
    final bgColor = themeMode == ThemeMode.dark
        ? AppColors.accentDarkGrey
        : AppColors.backgroundLightBlue;

    final iconBg = themeMode == ThemeMode.dark
        ? AppColors.primaryLight.withOpacity(0.2)
        : AppColors.primaryDark.withOpacity(0.15);

    final textColor = themeMode == ThemeMode.dark
        ? Colors.white
        : AppColors.primaryDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: textColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
  super.initState();
  _initializeUser();
  _startAutoScrollCarousel();
}

  void _initializeUser() async {
    var user = authService.value.currentUser;
    if (user != null) {
      var userDetails = await authService.value.getUserDetails(user.uid);
      setState(() {
        currentUserId = user.uid;
        username = userDetails?['username'];
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorDetailsPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void logout() async {
    await authService.value.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  // void _scrollToCarousel() {
  //   _scrollController.animateTo(
  //     450,
  //     duration: const Duration(seconds: 40),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        // Gradient colors for light & dark mode
        final gradientColors = themeMode == ThemeMode.dark
            ? [Color(0xFF121212), Color(0xFF1E1E1E)]
            : [AppColors.primaryDark, AppColors.backgroundBeige];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: themeMode == ThemeMode.dark
                        ? const Color(0xFF121212)
                        : AppColors.primaryDark,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            IconButton(
                              icon: Icon(
                                themeMode == ThemeMode.dark
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Colors.white,
                              ),
                              onPressed: () => ThemeProvider.toggleTheme(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/pics/logo.jpg',
                              height: 50,
                            ),
                            const SizedBox(height: 8),
                            if (username != null)
                              Text(
                                '@$username',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDrawerMenuItem(
                  icon: Icons.person,
                  title: 'Profile',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.calendar_today,
                  title: 'Appointment',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorDetailsPage()),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.back_hand,
                  title: 'Hand Opposition',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HandOppositionPage()),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.back_hand,
                  title: 'Hand Strengthening',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HandStrengtheningPage()),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.handshake_rounded,
                  title: 'Collaborators',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CollaboratorsPage()),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.info,
                  title: 'About Us',
                  themeMode: themeMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
                const Spacer(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _pageScrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Hi, ${username ?? 'Welcome'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Calendar & Appointment Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: currentUserId == null
                                ? const Center(
                                    child: Text(
                                      'Please log in',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: appointmentService.value
                                        .getUserUpcomingAppointment(currentUserId!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: themeMode == ThemeMode.dark
                                                ? AppColors.accentDarkGrey
                                                : AppColors.backgroundLightBlue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No upcoming appointments',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: themeMode == ThemeMode.dark
                                                    ? Colors.white
                                                    : AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      var appointments = snapshot.data!.docs;
                                      appointments.sort((a, b) {
                                        var aData = a.data() as Map<String, dynamic>;
                                        var bData = b.data() as Map<String, dynamic>;
                                        DateTime aDate =
                                            (aData['date'] as Timestamp).toDate();
                                        DateTime bDate =
                                            (bData['date'] as Timestamp).toDate();
                                        return aDate.compareTo(bDate);
                                      });

                                      var appointmentDoc = appointments.first;
                                      String appointmentId = appointmentDoc.id;
                                      var appointment =
                                          appointmentDoc.data() as Map<String, dynamic>;
                                      DateTime date = (appointment['date'] as Timestamp).toDate();
                                      String formattedDate = DateFormat('dd MMMM yyyy').format(date);

                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: themeMode == ThemeMode.dark
                                                  ? AppColors.accentDarkGrey
                                                  : AppColors.backgroundLightBlue,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Upcoming Appointment',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: themeMode == ThemeMode.dark
                                                        ? Colors.white
                                                        : AppColors.primaryDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildAppointmentRow(
                                                  Icons.access_time,
                                                  '$formattedDate\n${appointment['time']}',
                                                ),
                                                const SizedBox(height: 4),
                                                _buildAppointmentRow(
                                                  Icons.person,
                                                  appointment['doctorName'] ?? 'Unknown',
                                                ),
                                                const SizedBox(height: 4),
                                                _buildAppointmentRow(
                                                  Icons.medical_services,
                                                  appointment['doctorSpecialty'] ?? '',
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await appointmentService.value
                                                  .updateAppointmentStatus(
                                                    appointmentId,
                                                    'completed',
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Appointment marked as completed',
                                                    ),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.accentGreen,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              minimumSize: const Size(double.infinity, 30),
                                            ),
                                            child: const Text(
                                              'Complete',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Carousel Section
                      SizedBox(
                          height: 120,
                          child: ListView(
                            controller: _carouselController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCarouselItem(
                                'assets/pics/rehab.jpg',
                                url: 'https://www.physio-pedia.com/Rehabilitation',
                                title: 'Rehabilitation Guide',
                              ),
                              _buildCarouselItem(
                                'assets/pics/appointment.jpg',
                                url:
                                    'https://www.healthline.com/health/how-to-prepare-for-doctors-appointment',
                                title: 'Appointment Tips',
                              ),
                              _buildCarouselItem(
                                'assets/pics/history.jpg',
                                url: 'https://www.who.int/health-topics',
                                title: 'Health Topics',
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                      // Grid Menu
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuItem(
                            Icons.video_settings,
                            'Video Guided',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VideoGuidedPage(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            Icons.calendar_month,
                            'Appointment',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DoctorDetailsPage(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            Icons.bar_chart,
                            'History \nAppointment',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryAppointment(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            Icons.back_hand,
                            'Hand\nStrengthening',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HandStrengtheningPage(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            Icons.back_hand,
                            'Hand\nOpposition',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HandOppositionPage(),
                                ),
                              );
                            },
                          ),
                          _buildMenuItem(
                            Icons.info,
                            'About',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutPage()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Info Card Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeMode == ThemeMode.dark
                              ? AppColors.accentDarkGrey
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RIOT',
                              style: TextStyle(
                                color: themeMode == ThemeMode.dark
                                    ? AppColors.primaryLight
                                    : const Color.fromARGB(255, 232, 216, 196),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Revolutionizing hand therapy with cutting-edge technology',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'RIOT innovates hand therapy with advanced technology, enhancing treatment precision and patient outcomes through cutting-edge solutions in diagnostics, rehabilitation, and monitoring.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WebViewPage(
                                      url: 'https://riot.iium.iolayerz.com',
                                      title: 'About RIOT',
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryDark,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Read More',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryDark,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildAppointmentRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(String imagePath, {required String url, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(url: url, title: title),
            ),
          );
        },
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black38,
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
           border: Border.all(
      color: AppColors.primaryDark.withOpacity(0.25),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.primaryDark),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
