import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const SocialLoginButton({super.key, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Image.network(
          imageUrl,
          height: 35,
          width: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 35, color: Colors.grey),
        ),
      ),
    );
  }
}