import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';

/// API Network Debugging Helper
/// 
/// Provides utilities to test API connectivity and diagnose network issues
class ApiDebugHelper {
  /// Show a debug dialog with API configuration and connectivity tests
  static Future<void> showDebugDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => _ApiDebugDialog(),
    );
  }
  
  /// Test connectivity to a specific backend
  static Future<Map<String, dynamic>> testBackendConnection(String url) async {
    try {
      debugPrint('🔌 Testing connection to: $url');
      
      final client = dio.Dio();
      client.options.connectTimeout = const Duration(seconds: 5);
      client.options.receiveTimeout = const Duration(seconds: 5);
      
      final response = await client.head(url);
      
      return {
        'status': 'success',
        'statusCode': response.statusCode,
        'message': 'Backend is reachable',
        'url': url,
      };
    } catch (e) {
      debugPrint('❌ Connection error: $e');
      return {
        'status': 'error',
        'message': e.toString(),
        'url': url,
      };
    }
  }
  
  /// Test all backends
  static Future<Map<String, Map<String, dynamic>>> testAllBackends() async {
    debugPrint('🧪 Testing all backends...');
    
    return {
      'main': await testBackendConnection(Apis.baseUrl),
      'ecommerce': await testBackendConnection(Apis.ecommerceBaseUrl),
      'recharge': await testBackendConnection(Apis.rechargeBaseUrl),
    };
  }
  
  /// Print current API configuration to console
  static void printConfig() {
    debugPrint('═' * 70);
    debugPrint('🔧 API CONFIGURATION');
    debugPrint('═' * 70);
    debugPrint('Environment: ${Apis.getEnvironmentName()}');
    debugPrint('Main Backend: ${Apis.baseUrl}');
    debugPrint('Ecommerce Backend: ${Apis.ecommerceBaseUrl}');
    debugPrint('Recharge Backend: ${Apis.rechargeBaseUrl}');
    debugPrint('═' * 70);
  }
  
  /// Switch API environment
  static void switchEnvironment(ApiEnvironment environment) {
    Apis.setEnvironment(environment);
    ApiDebugHelper.printConfig();
    Get.snackbar(
      'API Environment Changed',
      'Now using: ${Apis.getEnvironmentName()}',
      duration: const Duration(seconds: 3),
    );
  }
}

class _ApiDebugDialog extends StatefulWidget {
  @override
  State<_ApiDebugDialog> createState() => _ApiDebugDialogState();
}

class _ApiDebugDialogState extends State<_ApiDebugDialog> {
  late Future<Map<String, Map<String, dynamic>>> _testFuture;

  @override
  void initState() {
    super.initState();
    _testFuture = ApiDebugHelper.testAllBackends();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Debug Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Environment Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Environment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ApiDebugHelper.switchEnvironment(ApiEnvironment.production);
                              setState(() => _testFuture = ApiDebugHelper.testAllBackends());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Apis.getEnvironment() == ApiEnvironment.production
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            child: const Text('Production'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ApiDebugHelper.switchEnvironment(ApiEnvironment.development);
                              setState(() => _testFuture = ApiDebugHelper.testAllBackends());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Apis.getEnvironment() == ApiEnvironment.development
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            child: const Text('Development'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Base URLs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Base URLs',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildUrlRow('Main', Apis.baseUrl),
                    const SizedBox(height: 8),
                    _buildUrlRow('Ecommerce', Apis.ecommerceBaseUrl),
                    const SizedBox(height: 8),
                    _buildUrlRow('Recharge', Apis.rechargeBaseUrl),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Connectivity Tests
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backend Connectivity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<Map<String, Map<String, dynamic>>>(
                      future: _testFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        
                        final results = snapshot.data ?? {};
                        return Column(
                          children: [
                            for (final entry in results.entries)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _buildTestResult(entry.key, entry.value),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    ApiDebugHelper.printConfig();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuration printed to console')),
                    );
                  },
                  child: const Text('Print Config'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _testFuture = ApiDebugHelper.testAllBackends());
                  },
                  child: const Text('Retry Tests'),
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

  Widget _buildUrlRow(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[50],
          ),
          child: Text(
            url,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTestResult(String name, Map<String, dynamic> result) {
    final isSuccess = result['status'] == 'success';
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error_circle,
                color: isSuccess ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result['message'] ?? 'Unknown status',
            style: const TextStyle(fontSize: 11),
          ),
          if (result['statusCode'] != null)
            Text(
              'Status Code: ${result['statusCode']}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
