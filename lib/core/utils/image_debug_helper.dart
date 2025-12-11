import 'package:flutter/material.dart';
import 'package:arif_mart/core/utils/image_utils.dart';

/// Helper widget to debug image loading issues
/// Add this to your app temporarily to diagnose problems
class ImageDebugHelper {
  /// Show a debug dialog with image loading diagnostics
  static Future<void> showDebugDialog(BuildContext context, {
    required List<String> imageUrls,
  }) async {
    showDialog(
      context: context,
      builder: (context) => _ImageDebugDialog(imageUrls: imageUrls),
    );
  }
  
  /// Print diagnostic information to console
  static void printDiagnostics() {
    debugPrint('═' * 60);
    debugPrint('📊 IMAGE LOADING DIAGNOSTICS');
    debugPrint('═' * 60);
    debugPrint('📌 Base URL: ${ImageUtils.getBaseUrl()}');
    debugPrint('📌 Sample URL construction:');
    debugPrint('   Input: products/image.jpg');
    debugPrint('   Output: ${ImageUtils.getFullImageUrl('products/image.jpg')}');
    debugPrint('   Input: /images/products/image.jpg');
    debugPrint('   Output: ${ImageUtils.getFullImageUrl('/images/products/image.jpg')}');
    debugPrint('═' * 60);
  }
}

class _ImageDebugDialog extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageDebugDialog({required this.imageUrls});

  @override
  State<_ImageDebugDialog> createState() => _ImageDebugDialogState();
}

class _ImageDebugDialogState extends State<_ImageDebugDialog> {
  late Future<Map<String, bool>> _testFuture;
  bool _serverConnected = false;

  @override
  void initState() {
    super.initState();
    _testFuture = _runTests();
  }

  Future<Map<String, bool>> _runTests() async {
    debugPrint('🧪 Starting image diagnostics...');
    
    // Test server connection
    _serverConnected = await ImageUtils.testServerConnection();
    if (mounted) setState(() {});
    
    // Test images
    final results = await ImageUtils.testImages(widget.imageUrls);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Image Debug Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow(
                    'Base URL',
                    ImageUtils.getBaseUrl(),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Server Status',
                    _serverConnected ? '✅ Connected' : '❌ Disconnected',
                    color: _serverConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Image URLs:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<Map<String, bool>>(
                    future: _testFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      
                      final results = snapshot.data ?? {};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in results.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildImageTestRow(
                                entry.key,
                                entry.value,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    ImageDebugHelper.printDiagnostics();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diagnostics printed to console'),
                      ),
                    );
                  },
                  child: const Text('Print Logs'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildImageTestRow(String imageUrl, bool isLoadable) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isLoadable ? Colors.green : Colors.red,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLoadable ? Icons.check_circle : Icons.error_circle,
                color: isLoadable ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  imageUrl,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Full: ${ImageUtils.getFullImageUrl(imageUrl)}',
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
