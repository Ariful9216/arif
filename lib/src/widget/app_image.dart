import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget assetImage(String image,
    {double? height, double? width, Color? color, BoxFit? fit, double? scale}) {
  return Image.asset(
    scale: scale,
    image,
    color: color,
    height: height,
    width: width,
    fit: fit,
  );
}

Widget svgImage(String image,
    {double? height, double? width, Color? color, BoxFit? fit}) {
  return SvgPicture.asset(image,
      fit: fit ?? BoxFit.none, color: color, height: height, width: width);
}

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image;
    
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      // Network image
      image = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      // Asset image
      image = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      // Treat as network URL without protocol
      final fullUrl = imageUrl.startsWith('/') 
          ? 'https://ecommerce.arifmart.app$imageUrl'
          : imageUrl;
      
      image = Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
          ),
        );
  }
}
