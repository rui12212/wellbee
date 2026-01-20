import 'package:flutter/material.dart';

/// Builds course image from S3 URL or falls back to asset image
Widget buildCourseImage(String? imageUrl, String? courseName) {
  const String fallbackAsset = 'lib/assets/invi_course_pic/female_fitness.png';

  if (imageUrl != null && imageUrl.isNotEmpty) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(fallbackAsset, fit: BoxFit.cover);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  // Fallback to asset image
  return Image.asset(fallbackAsset, fit: BoxFit.cover);
}
