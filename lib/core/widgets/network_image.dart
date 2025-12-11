import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

class NetworkImageWithRetry extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int maxRetries;
  final Duration retryDuration;

  const NetworkImageWithRetry({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.maxRetries = 3,
    this.retryDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImageUtils.loadImage(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      useCache: true,
    );
  }
}