import 'package:flutter/material.dart';
import 'package:arif_mart/core/utils/image_utils.dart';
import 'package:arif_mart/core/utils/image_debug_helper.dart';
import 'package:arif_mart/src/widget/cached_image_widget.dart';

/// Example screen showing how to use the image debugging and loading utilities
class ImageLoadingExampleScreen extends StatefulWidget {
  const ImageLoadingExampleScreen({Key? key}) : super(key: key);

  @override
  State<ImageLoadingExampleScreen> createState() =>
      _ImageLoadingExampleScreenState();
}

class _ImageLoadingExampleScreenState extends State<ImageLoadingExampleScreen> {
  final _baseUrlController = TextEditingController(
    text: ImageUtils.getBaseUrl(),
  );

  late Future<bool> _connectionTest;
  bool _connectionStatus = false;

  @override
  void initState() {
    super.initState();
    _connectionTest = ImageUtils.testServerConnection();
    _connectionTest.then((value) {
      setState(() => _connectionStatus = value);
    });
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  void _updateBaseUrl() {
    ImageUtils.setBaseUrl(_baseUrlController.text);
    setState(() {
      _connectionTest = ImageUtils.testServerConnection();
      _connectionTest.then((value) {
        setState(() => _connectionStatus = value);
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base URL updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loading Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Server Connection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _connectionStatus ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _connectionStatus ? '✅ Connected' : '❌ Disconnected',
                          style: TextStyle(
                            color:
                                _connectionStatus ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Base URL Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Base URL Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _baseUrlController,
                      decoration: InputDecoration(
                        hintText: 'Enter base URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _updateBaseUrl,
                            icon: const Icon(Icons.check),
                            label: const Text('Update URL'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _baseUrlController.text =
                                'http://10.0.2.2:5000';
                            _updateBaseUrl();
                          },
                          icon: const Icon(Icons.devices),
                          label: const Text('Emulator'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _baseUrlController.text =
                            'https://ecommerce.arifmart.app';
                        _updateBaseUrl();
                      },
                      icon: const Icon(Icons.cloud),
                      label: const Text('Production'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ImageDebugHelper.showDebugDialog(
                            context,
                            imageUrls: [
                              'products/image1.jpg',
                              'banners/banner1.jpg',
                              'variants/variant1.jpg',
                            ],
                          );
                        },
                        icon: const Icon(Icons.bug_report),
                        label: const Text('Show Debug Dialog'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ImageDebugHelper.printDiagnostics();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Diagnostics printed to console'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print Diagnostics'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ImageUtils.clearCache();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image cache cleared'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Clear Cache'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image Examples',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Product Image',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    CachedImageWidget(
                      imageUrl: 'products/sample-image.jpg',
                      width: double.infinity,
                      height: 150,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Banner Image',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    CachedSliderImage(
                      imageUrl: 'banners/sample-banner.jpg',
                      width: double.infinity,
                      height: 120,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // URL Construction Examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'URL Construction Examples',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUrlExample('products/image.jpg'),
                    const SizedBox(height: 8),
                    _buildUrlExample('banners/banner.jpg'),
                    const SizedBox(height: 8),
                    _buildUrlExample('variants/variant.jpg'),
                    const SizedBox(height: 8),
                    _buildUrlExample('/images/products/image.jpg'),
                    const SizedBox(height: 8),
                    _buildUrlExample(
                      'https://httpbin.org/image/jpeg',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlExample(String inputUrl) {
    final outputUrl = ImageUtils.getFullImageUrl(inputUrl);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input:',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            inputUrl,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Output:',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            outputUrl,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
