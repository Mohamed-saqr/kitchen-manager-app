import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/chef_details_screen.dart';
import '../../data/models/chef_model.dart';

class ChefCard extends StatelessWidget {
  final ChefModel chef;
  final String currentUserRole;

  const ChefCard({
    super.key,
    required this.chef,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChefDetailsScreen(
              chef: chef,
              docId: chef.id,
              userRole: currentUserRole,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chef.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chef.position,
                    style: const TextStyle(
                      color: Color(0xFFFF4D00),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRatingStars(chef.averageRating),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildChefImage(chef.image),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < rating.floor() ? Icons.star : Icons.star_border,
        size: 18,
        color: Colors.amber,
      )),
    );
  }

  Widget _buildChefImage(String imagePath) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: imagePath.isNotEmpty
            ? (imagePath.startsWith('http')
            ? Image.network(imagePath, fit: BoxFit.cover)
            : Image.file(File(imagePath), fit: BoxFit.cover))
            : const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
    );
  }
}