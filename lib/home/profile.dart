import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/app/webview_page.dart';
import 'package:project/appointment/docdetails.dart';
import 'package:project/appointment/history.dart';
import 'package:project/auth/auth_service.dart';
import 'package:project/auth/login.dart';
import 'package:project/home/homepage.dart';
import 'package:project/theme/app_colors.dart';
import 'package:project/theme/theme_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0; // Profile is at index 0
  Map<String, dynamic>? userDetails;
  bool isLoading = true;
  bool isEditMode = false;

  // Controllers and state for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  File? _selectedImage;
  String? _profileImageBase64;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Load current user's details from Firestore
  Future<void> _loadUserDetails() async {
    var user = authService.value.currentUser;
    if (user != null) {
      var details = await authService.value.getUserDetails(user.uid);
      setState(() {
        userDetails = details;
        isLoading = false;

        // Initialize controllers with existing data
        _nameController.text = details?['fullName'] ?? '';
        _ageController.text = details?['age']?.toString() ?? '';
        _selectedGender = details?['gender'] ?? 'Male';
        _profileImageBase64 = details?['profileImage'];
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      if (isEditMode) {
        // Cancel editing - reload original data
        _nameController.text = userDetails?['fullName'] ?? '';
        _ageController.text = userDetails?['age']?.toString() ?? '';
        _selectedGender = userDetails?['gender'] ?? 'Male';
        _selectedImage = null;
      }
      isEditMode = !isEditMode;
    });
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  /// Save profile changes to Firestore
  Future<void> _saveProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int? age = int.tryParse(_ageController.text);
    if (age == null || age < 0 || age > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      var user = authService.value.currentUser;
      if (user != null) {
        Map<String, dynamic> updates = {
          'fullName': _nameController.text.trim(),
          'age': age,
          'gender': _selectedGender,
        };

        // If new image selected, convert to base64 and save
        if (_selectedImage != null) {
          try {
            // Read image file as bytes
            List<int> imageBytes = await _selectedImage!.readAsBytes();
            // Convert to base64 string
            String base64Image = base64Encode(imageBytes);
            updates['profileImage'] = base64Image;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing image: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              isLoading = false;
            });
            return;
          }
        }

        await authService.value.updateUserDetails(user.uid, updates);

        // Reload user details
        await _loadUserDetails();

        setState(() {
          isEditMode = false;
          isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle bottom navigation bar taps
  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      // Navigate to Appointment
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

  /// Handle logout
  Future<void> _logout() async {
    await authService.value.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
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
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (!isLoading)
                IconButton(
                  icon: Icon(
                    isEditMode ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: _toggleEditMode,
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Image
                        GestureDetector(
                          onTap: isEditMode ? _pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                child: ClipOval(child: _buildProfileImage()),
                              ),
                              if (isEditMode)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name Field
                        if (isEditMode)
                          _buildEditField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                          )
                        else
                          Text(
                            userDetails?['fullName'] ?? 'User Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Age and Gender Row
                        if (isEditMode)
                          Row(
                            children: [
                              Expanded(
                                child: _buildEditField(
                                  controller: _ageController,
                                  label: 'Age',
                                  icon: Icons.cake,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildGenderDropdown()),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_ageController.text.isEmpty ? "N/A" : _ageController.text} years old',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                _selectedGender ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 30),

                        // Save and Cancel Buttons (only in edit mode)
                        if (isEditMode) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _toggleEditMode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Menu Items
                        _buildProfileMenuItem(
                          icon: Icons.bar_chart,
                          label: 'Appointment History',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HistoryAppointment(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildProfileMenuItem(
                          icon: Icons.info_outline,
                          label: 'About RIOT',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebViewPage(
                                  url: 'https://riot.iium.iolayerz.com/#about',
                                  title: 'About RIOT',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildProfileMenuItem(
                          icon: Icons.calendar_today,
                          label: 'Appointment',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DoctorDetailsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildProfileMenuItem(
                          icon: Icons.article_outlined,
                          label: 'Terms & Condition',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebViewPage(
                                  url:
                                      'https://www.termsfeed.com/blog/sample-terms-and-conditions-template/',
                                  title: 'Terms & Condition',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Sign Out Button
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _logout,
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
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: themeMode == ThemeMode.dark
                ? Colors.white
                : Colors.black,
            unselectedItemColor: themeMode == ThemeMode.dark
                ? Colors.white70
                : Colors.black,
            backgroundColor: themeMode == ThemeMode.dark
                ? AppColors.accentDarkGrey
                : AppColors.backgroundBeige,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  /// Build profile image widget
  Widget _buildProfileImage() {
    // Priority: selected image > saved base64 > placeholder
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 160,
        height: 160,
        fit: BoxFit.cover,
      );
    } else if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_profileImageBase64!),
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 80,
              color: AppColors.primaryDark,
            );
          },
        );
      } catch (e) {
        return const Icon(Icons.person, size: 80, color: AppColors.primaryDark);
      }
    } else {
      return const Icon(Icons.person, size: 80, color: AppColors.primaryDark);
    }
  }

  /// Build edit text field
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        final fieldBgColor = themeMode == ThemeMode.dark
            ? AppColors.accentDarkGrey
            : AppColors.backgroundLightBlue;
        final textColor = themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(color: textColor, fontSize: 16),
            decoration: InputDecoration(
              icon: Icon(icon, color: textColor.withOpacity(0.7)),
              labelText: label,
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              border: InputBorder.none,
            ),
          ),
        );
      },
    );
  }

  /// Build gender dropdown
  Widget _buildGenderDropdown() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        final fieldBgColor = themeMode == ThemeMode.dark
            ? AppColors.accentDarkGrey
            : AppColors.backgroundLightBlue;
        final textColor = themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: fieldBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            isExpanded: true,
            decoration: InputDecoration(
              icon: Icon(
                Icons.person_outline,
                color: textColor.withOpacity(0.7),
              ),
              labelText: 'Gender',
              labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              border: InputBorder.none,
            ),
            dropdownColor: fieldBgColor,
            style: TextStyle(color: textColor, fontSize: 16),
            items: ['Male', 'Female'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
          ),
        );
      },
    );
  }

  /// Build a profile menu item
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        final itemBgColor = themeMode == ThemeMode.dark
            ? AppColors.accentDarkGrey
            : AppColors.backgroundLightBlue;
        final contentColor = themeMode == ThemeMode.dark
            ? Colors.white
            : Colors.black;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 28, color: contentColor),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: contentColor,
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