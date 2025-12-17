import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:project/theme/app_colors.dart';

class VideoGuidedPage extends StatefulWidget {
  const VideoGuidedPage({super.key});

  @override
  State<VideoGuidedPage> createState() => _VideoGuidedPageState();
}

class _VideoGuidedPageState extends State<VideoGuidedPage> {
  late VideoPlayerController _oppositionController;
  late VideoPlayerController _jointController;

  @override
  void initState() {
    super.initState();
    // Initialize both controllers
    _oppositionController = VideoPlayerController.asset(
      'assets/video/video1.mp4',
    )..initialize().then((_) {
        if (mounted) setState(() {});
      });

    _jointController = VideoPlayerController.asset(
      'assets/video/video2.mp4',
    )..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _oppositionController.dispose();
    _jointController.dispose();
    super.dispose();
  }

  // Placeholder navigation function
  void _navigateToPage(String destinationFile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $destinationFile to start analysis.'),
        // Use the primary color from the theme for dynamic snacbar background
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Widget to build the Play/Pause and Reset controls
  Widget _buildVideoControls(BuildContext context, VideoPlayerController controller) {
    // Use theme colors for controls
    final controlsColor = Theme.of(context).colorScheme.primary; // Dynamic primary color
    final iconColorSecondary = Theme.of(context).colorScheme.onSurface.withOpacity(0.7); // Subdued color

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play/Pause Button
        IconButton(
          tooltip: controller.value.isPlaying ? 'Pause Video' : 'Play Video',
          icon: Icon(
            controller.value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
            size: 56, // Slightly larger icons
            color: controlsColor, // Use dynamic primary color
          ),
          onPressed: () {
            setState(() {
              controller.value.isPlaying ? controller.pause() : controller.play();
            });
          },
        ),
        const SizedBox(width: 40),
        // Reset Button
        IconButton(
          tooltip: 'Reset Video',
          icon: Icon(
            Icons.replay_circle_filled,
            size: 56,
            color: iconColorSecondary, // Use subdued theme color
          ),
          onPressed: () {
            controller.seekTo(Duration.zero);
            controller.pause();
            setState(() {});
          },
        ),
      ],
    );
  }

  // Refined Video Block Widget
  Widget _buildRefinedVideoBlock({
    required String title,
    required VideoPlayerController controller,
    required String destinationFile,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color cardBackgroundColor = colorScheme.surface; // White in Light, Dark Grey in Dark
    final Color titleColor = colorScheme.onSurface; // Text color on the card

    return Card(
      elevation: 6, // Increased elevation for a floating effect
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
      color: cardBackgroundColor, // Use theme surface color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: titleColor, // Dynamic text color
                  ),
            ),
            // Use accent color for divider, but ensure contrast by checking mode
            Divider(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.primaryLight 
                    : AppColors.primaryDark, 
                height: 25
            ),

            // Video Player Area
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // Soft shadow for depth, adapting to theme
                boxShadow: [
                  BoxShadow(
                    // Use a slightly softer primary color for the shadow
                    color: colorScheme.primary.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: controller.value.isInitialized
                      ? controller.value.aspectRatio
                      : 16 / 9,
                  child: controller.value.isInitialized
                      ? VideoPlayer(controller)
                      : Center(
                          child: CircularProgressIndicator(color: colorScheme.primary)
                      ),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Video Controls - pass context for color resolution
            _buildVideoControls(context, controller),

            const SizedBox(height: 25),

            // Instructions Header
            Text(
              'Try It Out: Guided Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor, // Dynamic text color
                  ),
            ),
            const SizedBox(height: 10),

            // List of Instructions
            // Pass the primary text color (onSurface) down to the list
            InstructionList(primaryTextColor: titleColor),

            const SizedBox(height: 25),

            // Action Button (Start Analysis)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPage(destinationFile),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text(
                  'START ANALYSIS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // Button styles are defined in AppTheme, so we can use styleFrom 
                // but let the theme handle the default colors (accentGreen in your theme)
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine Scaffold background color. Use theme background for Dark Mode, 
    // a light contrasting background for Light Mode.
    final Color scaffoldBackgroundColor;
    if (Theme.of(context).brightness == Brightness.dark) {
      scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    } else {
      // Use a subtle background for the light theme to avoid clash with cards
      scaffoldBackgroundColor = AppColors.backgroundLightBlue.withOpacity(0.5); 
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text(
          'Video Guided',
          // Text color should be handled by the theme's foregroundColor property in AppBarTheme
          style: Theme.of(context).appBarTheme.titleTextStyle ??
                 TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
        ),
        // AppBar background/elevation is handled by AppTheme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRefinedVideoBlock(
              title: 'Finger Opposition Count',
              controller: _oppositionController,
              destinationFile: 'handoposition.dart', 
            ),
            
            _buildRefinedVideoBlock(
              title: 'Finger Joint Distances',
              controller: _jointController,
              destinationFile: 'handstrength.dart', 
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for the instruction list
class InstructionList extends StatelessWidget {
  final Color primaryTextColor;

  const InstructionList({super.key, required this.primaryTextColor});

  @override
  Widget build(BuildContext context) {
    // Instructions related to the external analysis/camera
    final List<String> instructions = [
      'Click the **START ANALYSIS** button below to begin the detection process.',
      'Use the large **Play/Pause** icons to control the guide video.',
      'Follow the therapy movements shown in the video precisely.',
      'Click the **Reset** button (⟳) to start the video and calculations over.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions.map((text) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.check_circle_outline, size: 18, color: AppColors.accentGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: _parseInstructionText(context, text),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Text parser to highlight key terms
  TextSpan _parseInstructionText(BuildContext context, String text) {
    // Use the primaryTextColor passed from the card for regular text
    final defaultStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: primaryTextColor.withOpacity(0.8),
      height: 1.5,
    );
    
    // Bold style uses the dynamic primary color
    final boldStyle = defaultStyle?.copyWith(
      fontWeight: FontWeight.w900,
      color: Theme.of(context).colorScheme.primary,
    );

    final List<TextSpan> spans = [];
    final parts = text.split(RegExp(r'\*\*'));

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        // Bold text
        spans.add(TextSpan(
          text: parts[i],
          style: boldStyle,
        ));
      } else {
        // Regular text
        spans.add(TextSpan(
          text: parts[i],
          style: defaultStyle,
        ));
      }
    }
    return TextSpan(children: spans);
  }
}