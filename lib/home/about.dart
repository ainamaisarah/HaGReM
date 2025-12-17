import 'package:flutter/material.dart';
import 'package:project/theme/app_colors.dart';

// Define a breakpoint for mobile vs. desktop/tablet view
const double kTabletBreakpoint = 800.0;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    
    // 1. Determine the Page Background Color
    final Color pageBackgroundColor;
    if (brightness == Brightness.dark) {
      // In Dark Mode, use the theme's default background color for consistency (usually very dark grey/black)
      pageBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    } else {
      // In Light Mode, use the specific light blue as requested
      pageBackgroundColor = AppColors.backgroundLightBlue;
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor, // Uses dark background in dark mode, light blue in light mode
      appBar: AppBar(
        title: const Text('About Us'),
        // AppBar colors are handled by the theme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass the determined background color down
            _StatisticsSection(pageBackgroundColor: pageBackgroundColor),
            const SizedBox(height: 40),

            const _AboutHeader(),
            const SizedBox(height: 40),
            const _AboutContent(),
          ],
        ),
      ),
    );
  }
}

/* ===================== STATISTICS SECTION ===================== */

class _StatisticsSection extends StatelessWidget {
  final Color pageBackgroundColor;

  const _StatisticsSection({required this.pageBackgroundColor});

  // Helper method to define the statistics blocks
  Widget _buildStatisticsGrid(BuildContext context) {
    // Card color uses the surface color from the ColorScheme (white in light, dark grey in dark)
    final cardColor = Theme.of(context).colorScheme.surface;

    // List of all four statistic blocks
    final List<Widget> stats = [
      _AnimatedStatisticBlock(
        targetPercentage: 96,
        icon: Icons.monitor_heart_outlined,
        description: 'of respondents prefer to use a system to monitor the progress in rehabilitation',
        iconColor: AppColors.accentGold,
        cardColor: cardColor,
      ),
      _AnimatedStatisticBlock(
        targetPercentage: 80,
        icon: Icons.lightbulb_outline,
        description: 'of respondents believe that integrating Internet of Things (IoT) technology into rehabilitation can improve overall quality of life post-stroke.',
        iconColor: AppColors.primaryDark,
        cardColor: cardColor,
      ),
      _AnimatedStatisticBlock(
        targetPercentage: 75,
        icon: Icons.house_outlined,
        description: 'of respondents prefer doing rehabilitation exercises and be monitored at home.',
        iconColor: AppColors.primaryDark,
        cardColor: cardColor,
      ),
      _AnimatedStatisticBlock(
        targetPercentage: 93,
        icon: Icons.settings_input_component,
        description: 'of respondents have confidence that technology can be integrated for stroke rehabilitation purposes.',
        iconColor: AppColors.accentGold,
        cardColor: cardColor,
      ),
    ];

    return Column(
      children: [
        // Top Row / First Two Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stats[0]),
            const SizedBox(width: 16),
            Expanded(child: stats[1]),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom Row / Last Two Stats
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stats[2]),
            const SizedBox(width: 16),
            Expanded(child: stats[3]),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBackground = pageBackgroundColor; // This is the color from the Scaffold

    final Color mobileCardColor = Theme.of(context).colorScheme.surface;
    final List<Widget> mobileStats = [
      _AnimatedStatisticBlock(
        targetPercentage: 96,
        icon: Icons.monitor_heart_outlined,
        description: 'of respondents prefer to use a system to monitor the progress in rehabilitation',
        iconColor: AppColors.accentGold,
        cardColor: mobileCardColor,
      ),
      const SizedBox(height: 20),
      _AnimatedStatisticBlock(
        targetPercentage: 80,
        icon: Icons.lightbulb_outline,
        description: 'of respondents believe that integrating Internet of Things (IoT) technology into rehabilitation can improve overall quality of life post-stroke.',
        iconColor: AppColors.primaryDark,
        cardColor: mobileCardColor,
      ),
      const SizedBox(height: 20),
      _AnimatedStatisticBlock(
        targetPercentage: 75,
        icon: Icons.house_outlined,
        description: 'of respondents prefer doing rehabilitation exercises and be monitored at home.',
        iconColor: AppColors.primaryDark,
        cardColor: mobileCardColor,
      ),
      const SizedBox(height: 20),
      _AnimatedStatisticBlock(
        targetPercentage: 93,
        icon: Icons.settings_input_component,
        description: 'of respondents have confidence that technology can be integrated for stroke rehabilitation purposes.',
        iconColor: AppColors.accentGold,
        cardColor: mobileCardColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kTabletBreakpoint) {
          // --- MOBILE/SMALL SCREEN LAYOUT (Stacked) ---
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StatisticsIllustration(width: 300, height: 300, fallbackColor: themeBackground),
              const SizedBox(height: 40),
              ...mobileStats,
            ],
          );
        } else {
          // --- DESKTOP/LARGE SCREEN LAYOUT (Side-by-Side Row) ---
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: _StatisticsIllustration(width: 300, height: 300, fallbackColor: themeBackground),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 2,
                child: _buildStatisticsGrid(context),
              ),
            ],
          );
        }
      },
    );
  }
}


class _StatisticsIllustration extends StatelessWidget {
  final double width;
  final double height;
  final Color fallbackColor; 

  const _StatisticsIllustration({this.width = 300, this.height = 300, required this.fallbackColor});

  @override
  Widget build(BuildContext context) {
    // Determine fallback text color based on the current background
    final Color fallbackTextColor;
    if (Theme.of(context).brightness == Brightness.dark) {
        fallbackTextColor = Colors.white; // Ensure visibility against dark background
    } else {
        fallbackTextColor = AppColors.textBlack; // Ensure visibility against light blue background
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/pics/rehab_about.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: fallbackColor,
              borderRadius: BorderRadius.circular(10),
              // Use a subtle border in dark mode for the fallback
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.accentGold : AppColors.primaryDark, 
                width: 2
              ), 
            ),
            child: Center(
              child: Text(
                'Image Missing\n(rehab_illustration.png)',
                textAlign: TextAlign.center,
                style: TextStyle(color: fallbackTextColor),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ===================== ANIMATED COUNTER WIDGET ===================== */

class _AnimatedStatisticBlock extends StatelessWidget {
  final int targetPercentage;
  final IconData icon;
  final String description;
  final Color iconColor;
  final Color cardColor;

  const _AnimatedStatisticBlock({
    required this.targetPercentage,
    required this.icon,
    required this.description,
    required this.iconColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    // Text colors will automatically use onSurface color from the theme, 
    // which is white in dark theme (surface: accentDarkGrey) and black/dark in light theme (surface: white).
    final headlineColor = Theme.of(context).colorScheme.onSurface;
    final descriptionColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor, // Uses theme.surface
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  // Keep iconColor fixed as per design (AppColors.accentGold or AppColors.primaryDark)
                  color: iconColor, 
                ),
                const SizedBox(width: 12),
                // The animated number counter
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: targetPercentage.toDouble()),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: headlineColor, 
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: descriptionColor, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== OTHER WIDGETS ===================== */

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    // These colors automatically adapt based on the theme (onBackground is white in dark, black in light)
    final headlineColor = Theme.of(context).colorScheme.onSurface;
    final descriptionColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rehabilitation Internet-of-Things (RIOT)',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: headlineColor, 
          ),
        ),
        const SizedBox(height: 8),
        // Divider line
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.8 : 400,
              height: 4,
              color: AppColors.accentGold, // Keep accent color consistent
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Empowering stroke survivors through smart rehabilitation technology.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: descriptionColor, 
          ),
        ),
      ],
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to switch from Row to Column on small screens
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kTabletBreakpoint) {
          // Mobile/Small Screen: Stack sections vertically
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeftSection(),
              SizedBox(height: 40),
              _RightSection(),
            ],
          );
        } else {
          // Desktop/Large Screen: Keep side-by-side Row
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _LeftSection()),
              SizedBox(width: 40),
              Expanded(child: _RightSection()),
            ],
          );
        }
      },
    );
  }
}

class _LeftSection extends StatelessWidget {
  const _LeftSection();

  @override
  Widget build(BuildContext context) {
    final headlineColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can RIOT help in your rehabilitation journey?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: headlineColor, 
          ),
        ),
        const SizedBox(height: 20),
        const FeaturePoint(text: 'Easy Hand Exercise Tracking'),
        const FeaturePoint(text: 'Support for Recovery'),
        const FeaturePoint(text: 'Easy to Use and Accessible'),
        const FeaturePoint(text: 'Detect Open Hand'),
        const FeaturePoint(text: 'Detect Close Hand'),
        const FeaturePoint(text: 'Guided Video Exercises'),
      ],
    );
  }
}

class _RightSection extends StatelessWidget {
  const _RightSection();

  @override
  Widget build(BuildContext context) {
    final descriptionColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

    return Text(
      'RIOT is a smart rehabilitation platform that uses hand gesture '
      'technology to help stroke patients practice hand movements and '
      'track their recovery progress in an engaging and interactive way.\n\n'
      'With only a camera and IoT integration, patients can perform exercises '
      'from home while therapists and caregivers monitor progress remotely. '
      'This approach encourages consistency, motivation, and better recovery '
      'outcomes.',
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: descriptionColor, 
      ),
    );
  }
}

class FeaturePoint extends StatelessWidget {
  final String text;

  const FeaturePoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.accentGreen, // Keep accent color for the checkmark
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}