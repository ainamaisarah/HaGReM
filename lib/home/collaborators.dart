import 'package:flutter/material.dart';
import 'package:project/theme/app_colors.dart';

class CollaboratorsPage extends StatelessWidget {
  const CollaboratorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborators'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: const [
            _CollaboratorCard(imagePath: 'assets/pics/kict_logo.png'),
            _CollaboratorCard(imagePath: 'assets/pics/ioteam.png'),
            _CollaboratorCard(imagePath: 'assets/pics/hospital_putrajaya.png'),
            _CollaboratorCard(imagePath: 'assets/pics/coexys.png'),
            _CollaboratorCard(imagePath: 'assets/pics/hospital_shahalam.png'),
          ],
        ),
      ),
    );
  }
}

class _CollaboratorCard extends StatelessWidget {
  final String imagePath;

  const _CollaboratorCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
