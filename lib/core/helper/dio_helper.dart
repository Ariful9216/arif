import 'dart:io';

import 'package:dio/dio.dart' as diox;
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'dart:convert';

import '../../src/widget/custom_loader.dart';
import '../../src/widget/custom_toast.dart';
import '../../src/utils/subscription_error_handler.dart';
import '../constants/api.dart';
import '../constants/routes/routes.dart';
import 'hive_helper.dart';

final logger = Logger();

class DioApiHelper {
  late Map<String, dynamic> header;
  final diox.Dio dio = diox.Dio();

  DioApiHelper({bool? isTokeNeeded}) {
    header =
        isTokeNeeded == false
            ? {'Content-Type': 'application/json', 'Accept': 'application/json'}
            : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${HiveHelper.getToken}',
              'Accept': 'application/json',
            };

    // Configure Dio timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.post(
        Apis.baseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      Loader.closeLoader();
      return response.data;
    } on diox.DioException catch (e) {
      Loader.closeLoader();
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data}",
      );
      // if (e.response?.statusCode == 401) {
      //   // HiveHelper.clearHive();
      //   bool sessionExtended = await extendSession();
      //   if (sessionExtended) {
      //     return await retryRequest(url, body, true);
      //   } else {
      //     Get.offAllNamed(Routes.onboardingScreen);
      //   }
      // }
      if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went to wrong',
          );
        } else if (e.response?.statusCode == 401) {
          // Silent redirect to login - do not show toast to user when unauthorized
          logger.w("401 Unauthorized - silently redirecting to login");
          if (Get.context != null) {
            Get.offAllNamed(Routes.login);
          } else {
            await _clearAuthenticationData();
          }
        } else {
          showToast('Something went to wrong');
        }
      } else {
        Get.log(e.toString());
      }
      rethrow;
    }
  }

  Future<dynamic> get({
    required String url,
    bool? showErrorToast = true,
    Map<String, dynamic>? body,
    bool? addBaseUrl = true,
  }) async {
    try {
      diox.Response response = await dio.get(
        '${addBaseUrl == true ? Apis.baseUrl : ""}$url',
        data: body,
        options: diox.Options(headers: header),
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)} \nHeader : ${jsonEncode(response.requestOptions.headers)}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Loader.closeLoader();
        return response.data;
      } else {
        if (showErrorToast == true) {
          showToast(response.data['message']);
        }
        logger.e(response.data);
      }
    } on diox.DioException catch (e) {
      Loader.closeLoader();
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.response?.requestOptions.uri} \nBody : ${e.response?.requestOptions.data} \nResponse : ${jsonEncode(e.response?.data)} \nHeader : ${jsonEncode(e.response?.requestOptions.headers)}",
      );

      if (e.response?.statusCode == 401) {
        Get.log("++++++++++++++++++++++++++++++++++++++++401");

        // Check if this is a subscription error and handle it
        if (SubscriptionErrorHandler.handleSubscriptionError(e)) {
          return null; // Subscription popup shown, return null
        }

        // HiveHelper.clearHive();
        bool sessionExtended = await extendSession();
        if (sessionExtended) {
          // Retry the original request with the new token
          return await retryRequest(url, body, addBaseUrl);
        } else {
          // Don't navigate during app initialization - let the app handle this
          if (Get.context != null) {
            // Only navigate if GetMaterialApp is already initialized and context is available
            Get.offAllNamed(Routes.login);
          } else {
            // During app initialization, just clear data and let main.dart handle routing
            logger.e(
              "Authentication failed during app initialization - will redirect to login",
            );
            await _clearAuthenticationData();
          }
        }
      }

      // Handle 404 errors gracefully for specific endpoints (like sliders, banners)
      if (e.response?.statusCode == 404) {
        String? errorMessage = e.response?.data?['message']?.toString();
        // Don't show toast or throw error for "not found" responses on optional data
        if (errorMessage != null &&
            (errorMessage.contains('No sliders found') ||
                errorMessage.contains('No banners found') ||
                errorMessage.contains('not found'))) {
          Get.log(
            "ℹ️ Optional data not found (404): $errorMessage - returning null",
          );
          return null;
        }
      }

      if (e.response?.data['message'] != null &&
          e.response?.data['message'].runtimeType == String) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          if (showErrorToast == true) {
            showToast(
              e.response?.data['message'].toString() ??
                  'Something went to wrong',
            );
          }
        } else if (e.response?.statusCode != 404 &&
            e.response?.statusCode != 401) {
          // Don't show toast for 404 or 401
          if (showErrorToast == true) {
            showToast(
              e.response?.data['message']?.toString() ?? 'Something went wrong',
            );
          }
        }
      } else {
        logger.e(e);
      }

      rethrow;
    }
    return null;
  }

  Future<bool> extendSession() async {
    try {
      Get.log("++++++++++++++++++++++++++++++++++++++++extendSession");

      String? refreshToken = HiveHelper.getRefreshToken;
      logger.e("🔄 Current Refresh Token: $refreshToken");
      if (refreshToken == null || refreshToken.isEmpty) {
        logger.e("Refresh token is null or empty");
        // Clear all authentication data
        await _clearAuthenticationData();
        return false;
      }

      diox.Response response = await dio.post(
        "${Apis.baseUrl}/api/token/refresh/",
        options: diox.Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({"refresh": refreshToken}),
      );

      logger.i(
        "🔄 Refresh API Response: ${response.statusCode} - ${response.data}",
      );

      Get.log(
        "StatusCode: ${response.statusCode} \nAPI: ${response.requestOptions.uri} \nBody: ${jsonEncode(response.requestOptions.data)} \nResponse: ${jsonEncode(response.data)} \nHeader: ${jsonEncode(response.requestOptions.headers)}",
      );
      String newToken = response.data['access'];
      String refreshNewToken = response.data['refresh'];
      await HiveHelper.setAccessToken(newToken);
      await HiveHelper.setRefreshToken(refreshNewToken);
      if (response.statusCode == 200 && response.data != null) {
        String newToken = response.data['access'];
        String refreshNewToken = response.data['refresh'];

        if (newToken.isNotEmpty && refreshNewToken.isNotEmpty) {
          header['Authorization'] = 'Bearer $newToken';

          // Store the new tokens

          logger.i("✅ New Access Token: $newToken");
          logger.i("✅ New Refresh Token: $refreshNewToken");
          await HiveHelper.setAccessToken(newToken);
          await HiveHelper.setRefreshToken(refreshNewToken);

          return true;
        }
      } else {
        logger.e("Unexpected response: ${response.data}");
        logger.e("❌ Unexpected response from refresh API: ${response.data}");
      }
    } catch (e) {
      Get.log("++++++++++++++++++++++++++++++++++++++++error");
      logger.e("Failed to extend session: $e");
    }
    return false;
  }

  Future<dynamic> retryRequest(
    String url,
    Map<String, dynamic>? body,
    bool? addBaseUrl,
  ) async {
    Get.log("++++++++++++++++++++++++++++++++++++++++retryRequest");
    try {
      diox.Response response = await dio.get(
        '${addBaseUrl == true ? Apis.baseUrl : ""}$url',
        data: body,
        options: diox.Options(headers: header),
      );
      return response.data;
    } catch (e) {
      logger.e("Retry failed: $e");
      return null;
    }
  }

  Future<dynamic> put({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.put(
        Apis.baseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)} \nHeader : ${jsonEncode(response.headers)}",
      );
      if (response.data["success"] == true) {
        logger.i(
          "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)} \nHeader : ${jsonEncode(response.headers)}",
        );
        Loader.closeLoader();
        return response.data;
      } else {
        Loader.closeLoader();
        logger.e(
          "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${response.data} \nHeader : ${response.headers}",
        );
        if (response.data['message'] != null) {
          showToast(response.data['message'].toString());
        } else {
          Get.log(response.data);
        }
      }
    } on diox.DioException catch (e) {
      Loader.closeLoader();
      Get.log(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data} ",
      );
      if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went to wrong',
          );
        } else if (e.response?.statusCode == 401) {
          HiveHelper.clearHive();
          Get.offAllNamed(Routes.login);
        } else {
          showToast('Something went to wrong');
        }
      } else {
        logger.e(e);
      }
      rethrow;
    }
    return null;
  }

  // Future<dynamic> patch(
  //     {required String url, required Map<String, dynamic> body}) async {
  //   try {
  //     diox.Response response = await dio.patch(Apis.baseUrl + url, options: diox.Options(headers: header), data: body);
  //     logger.i("StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)} \nHeader : $header");
  //     Get.log("this");
  //     Get.log("${response.data}");
  //     if (response.data != null) {
  //       Get.log("");
  //       Loader.closeLoader();
  //       return response.data;
  //     } else {
  //       Loader.closeLoader();
  //       logger.i(
  //           "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${response.data}");
  //       // if (response.data['message'] != null) {
  //       //   showToast(response.data['message'].toString());
  //       // } else {
  //       //   logger.i(response.data);
  //       // }
  //     }
  //   } on diox.DioException catch (e) {
  //     Loader.closeLoader();
  //     logger.e(
  //         "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data} \n header: $header");
  //     if (e.response?.data['message'] != null) {
  //       if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
  //         showToast(e.response?.data['message'].toString() ??
  //             'Something went to wrong');
  //       } else if (e.response?.statusCode == 401) {
  //         // HiveHelper.clearHive();
  //         // Get.offAllNamed(Routes.onboardingScreen);
  //         Get.log("++++++++++++++++++++++++++++++++++++++++401");
  //         // HiveHelper.clearHive();
  //         bool sessionExtended = await extendSession();
  //         if (sessionExtended) {
  //           // Retry the original request with the new token
  //           return await retryRequest(url, body, true);
  //         } else {
  //           // Redirect to login if session extension fails
  //           Get.offAllNamed(Routes.onboardingScreen);
  //         }
  //       } else {
  //         showToast('Something went to wrong');
  //       }
  //     } else {
  //       logger.e(e);
  //     }
  //     rethrow;
  //   }
  //   return null;
  // }
  Future<dynamic> patch({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.patch(
        Apis.baseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );

      logger.i(
        "StatusCode : ${response.statusCode} \n"
        "Api : ${response.requestOptions.uri} \n"
        "Body : ${response.requestOptions.data} \n"
        "Response : ${jsonEncode(response.data ?? 'No content')} \n"
        "Header : $header",
      );
      // ✅ Handle 204 No Content explicitly
      if (response.statusCode == 204) {
        Loader.closeLoader();
        return {"message": "updated successfully"};
      }

      if (response.data != null) {
        Loader.closeLoader();
        return response.data;
      } else {
        Loader.closeLoader();
        logger.i(
          "StatusCode : ${response.statusCode} \n"
          "Api : ${response.requestOptions.uri} \n"
          "Body : ${response.requestOptions.data} \n"
          "Response : ${response.data}",
        );
      }
    } on diox.DioException catch (e) {
      Loader.closeLoader();
      logger.e(
        "StatusCode : ${e.response?.statusCode} \n"
        "Api : ${e.requestOptions.uri} \n"
        "Body : ${e.requestOptions.data} \n"
        "Response : ${e.response?.data} \n"
        "Header : $header",
      );

      if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        } else if (e.response?.statusCode == 401) {
          // ✅ Ensure extendSession() returns a boolean
          bool sessionExtended = await extendSession();

          if (sessionExtended) {
            return await retryRequest(url, body, true);
          } else {
            Get.offAllNamed(Routes.login);
          }
        } else {
          showToast('Something went wrong');
        }
      } else {
        logger.e(e);
      }
      rethrow;
    }
    return null;
  }

  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? body,
    bool? addBaseUrl,
  }) async {
    try {
      diox.Response response = await dio.delete(
        Apis.baseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      if (response.data["message"] ==
          "Activity has been soft deleted successfully.") {
        logger.i(
          "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
        );
        Loader.closeLoader();
        return response.data;
      } else {
        Loader.closeLoader();
        logger.e(
          "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${response.data}",
        );
        if (response.data['message'] != null) {
          // showToast(response.data['message'].toString());
        } else {
          logger.e(response.data);
        }
      }
    } on diox.DioException catch (e) {
      Loader.closeLoader();
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went to wrong',
          );
        } else if (e.response?.statusCode == 401) {
          // HiveHelper.clearHive();
          bool sessionExtended = await extendSession();
          if (sessionExtended) {
            // Retry the original request with the new token
            return await retryRequest(url, body, addBaseUrl);
          } else {
            // Redirect to login if session extension fails
            Get.offAllNamed(Routes.login);
          }
        } else {
          showToast('Something went to wrong');
        }
      } else {
        logger.e(e);
      }
      rethrow;
    }
    return null;
  }

  Future<Map<String, dynamic>?> multipartPost({
    required diox.FormData data,
    required String url,
    String? method,
  }) async {
    try {
      diox.Response response = await dio.request(
        '${Apis.baseUrl}$url',
        options: diox.Options(method: method ?? 'POST', headers: header),
        data: data,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)} \nHeader : ${jsonEncode(response.requestOptions.headers)}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } on diox.DioException catch (e) {
      logger.i(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.response?.requestOptions.uri} \nBody : ${e.response?.requestOptions.data} \nResponse : ${jsonEncode(e.response?.data)} \nHeader : ${jsonEncode(e.response?.requestOptions.headers)}",
      );
      if (e.response?.data != null &&
          e.response?.data is Map<String, dynamic>) {
        Map<String, dynamic> errorData =
            e.response?.data as Map<String, dynamic>;

        if (errorData.containsKey('message') &&
            errorData['message'] is String) {
          showToast(errorData['message']);
        } else {
          for (var entry in errorData.entries) {
            if (entry.value is List && entry.value.isNotEmpty) {
              showToast(entry.value[0]);
              break;
            }
          }
        }
      }
      return e.response?.data;
    }
    return null;
  }

  Future<diox.Response?> uploadProfilePicture(String filePath) async {
    File file = File(filePath);
    String fileName = file.path.split('/').last;

    diox.FormData formData = diox.FormData.fromMap({
      'profile_picture': await diox.MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: diox.DioMediaType('image', 'jpeg'),
      ),
    });

    try {
      diox.Response response = await dio.patch(
        '${Apis.baseUrl}/api/users/update-me/',
        data: formData,
        options: diox.Options(
          headers: {
            'Authorization': 'Bearer ${HiveHelper.getAccessToken}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      Get.log('Response: ${response.statusCode}');
      if (response.statusCode == 204) {
        showToast("Profile Picture Updated Successfully");
      }
      return response;
    } catch (e) {
      Get.log('Upload error: $e');
    }
    return null;
  }

  // Helper method to clear authentication data
  Future<void> _clearAuthenticationData() async {
    try {
      await HiveHelper.setToken(null);
      await HiveHelper.setRefreshToken(null);
      await HiveHelper.setIsLogin(false);
      logger.i("Authentication data cleared due to session expiry");
    } catch (e) {
      logger.e("Error clearing authentication data: $e");
    }
  }
}

// Ecommerce API Helper class
class EcommerceDioHelper {
  late Map<String, dynamic> header;
  final diox.Dio dio = diox.Dio();

  EcommerceDioHelper({bool? isTokenNeeded}) {
    header =
        isTokenNeeded == false
            ? {'Content-Type': 'application/json', 'Accept': 'application/json'}
            : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${HiveHelper.getToken}',
              'Accept': 'application/json',
            };

    // Configure Dio timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.post(
        Apis.ecommerceBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        } else if (e.response?.statusCode == 401) {
          // Silent redirect to login - do not show toast when unauthorized
          logger.w(
            "401 Unauthorized (Ecommerce) - silently redirecting to login",
          );
          if (Get.context != null) {
            Get.offAllNamed(Routes.login);
          }
        }
      }
      rethrow;
    }
  }

  Future<dynamic> get({
    required String url,
    bool? showErrorToast = true,
    Map<String, dynamic>? body,
  }) async {
    try {
      diox.Response response = await dio.get(
        '${Apis.ecommerceBaseUrl}$url',
        options: diox.Options(headers: header),
        queryParameters: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nResponse : ${e.response?.data}",
      );
      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Ecommerce GET) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (showErrorToast == true &&
          e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }

  Future<dynamic> put({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.put(
        Apis.ecommerceBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.data['message'] != null) {
        showToast(
          e.response?.data['message'].toString() ?? 'Something went wrong',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> delete({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      diox.Response response = await dio.delete(
        Apis.ecommerceBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nResponse : ${e.response?.data}",
      );
      print("EcommerceDioHelper DELETE error: $e");
      print("Server response data: ${e.response?.data}");
      print("Server response status: ${e.response?.statusCode}");
      if (e.response?.data != null && e.response?.data['message'] != null) {
        showToast(
          e.response?.data['message'].toString() ?? 'Something went wrong',
        );
      }
      rethrow;
    }
  }

  Future<dynamic> patch({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.patch(
        Apis.ecommerceBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.requestOptions.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Ecommerce PATCH) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }
}

class RechargeDioHelper {
  late Map<String, dynamic> header;
  final diox.Dio dio = diox.Dio();

  RechargeDioHelper({bool? isTokenNeeded}) {
    header =
        isTokenNeeded == false
            ? {'Content-Type': 'application/json', 'Accept': 'application/json'}
            : {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${HiveHelper.getToken}',
              'Accept': 'application/json',
            };

    // Configure Dio timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
  }

  Future<dynamic> post({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.post(
        Apis.rechargeBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.response?.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Recharge POST) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }

  Future<dynamic> get({required String url}) async {
    try {
      diox.Response response = await dio.get(
        Apis.rechargeBaseUrl + url,
        options: diox.Options(headers: header),
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nResponse : ${e.response?.data}",
      );

      // Check if this is a subscription error and handle it
      if (SubscriptionErrorHandler.handleSubscriptionError(e)) {
        return null; // Subscription popup shown, return null
      }

      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Recharge GET) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }

  Future<dynamic> put({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.put(
        Apis.rechargeBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.response?.data} \nResponse : ${e.response?.data}",
      );

      // Check if this is a subscription error and handle it
      if (SubscriptionErrorHandler.handleSubscriptionError(e)) {
        return null; // Subscription popup shown, return null
      }

      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Recharge PUT) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }

  Future<dynamic> patch({
    required String url,
    required Map<String, dynamic> body,
  }) async {
    try {
      diox.Response response = await dio.patch(
        Apis.rechargeBaseUrl + url,
        options: diox.Options(headers: header),
        data: body,
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nBody : ${response.requestOptions.data} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nBody : ${e.response?.data} \nResponse : ${e.response?.data}",
      );
      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Recharge PATCH) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }

  Future<dynamic> delete({required String url}) async {
    try {
      diox.Response response = await dio.delete(
        Apis.rechargeBaseUrl + url,
        options: diox.Options(headers: header),
      );
      logger.i(
        "StatusCode : ${response.statusCode} \nApi : ${response.requestOptions.uri} \nResponse : ${jsonEncode(response.data)}",
      );
      return response.data;
    } on diox.DioException catch (e) {
      logger.e(
        "StatusCode : ${e.response?.statusCode} \nApi : ${e.requestOptions.uri} \nResponse : ${e.response?.data}",
      );
      if (e.response?.statusCode == 401) {
        // Silent redirect to login - do not show toast when unauthorized
        logger.w(
          "401 Unauthorized (Recharge DELETE) - silently redirecting to login",
        );
        if (Get.context != null) {
          Get.offAllNamed(Routes.login);
        }
      } else if (e.response?.data['message'] != null) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 403) {
          showToast(
            e.response?.data['message'].toString() ?? 'Something went wrong',
          );
        }
      }
      rethrow;
    }
  }
}
