import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/social_media_model.dart';

class SocialMediaCard extends StatelessWidget {
  final SocialMediaItem socialMedia;
  final VoidCallback? onTap;

  const SocialMediaCard({
    super.key,
    required this.socialMedia,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print("Loading social media logo: ${socialMedia.logoUrl}"); // Debug URL
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68, // Reduced from 72 to fit 4 items per row
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  socialMedia.logoUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              socialMedia.name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 