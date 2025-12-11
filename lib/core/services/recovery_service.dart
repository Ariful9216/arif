import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/model/recovery_model.dart';
import 'package:dio/dio.dart' as diox;

class RecoveryService {
  /// Send recovery request with user credentials
  static Future<RecoveryResponse> sendRecoveryRequest(RecoveryRequest request) async {
    try {
      final response = await DioApiHelper(isTokeNeeded: false).post(
        url: Apis.recovery,
        body: request.toJson(),
      );
      return RecoveryResponse.fromJson(response);
    } on diox.DioException catch (e) {
      // Handle DioException - check if it's actually a successful response
      if (e.response?.statusCode == 200 && e.response?.data != null) {
        // This is actually a successful response, parse it normally
        return RecoveryResponse.fromJson(e.response!.data);
      }
      
      // Handle DioException specifically to extract API error message
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message')) {
          return RecoveryResponse(
            success: false,
            message: responseData['message'] as String,
            data: null,
          );
        }
      }
      
      // If we can't extract a specific message, return a generic error
      return RecoveryResponse(
        success: false,
        message: 'Failed to send recovery request. Please try again.',
        data: null,
      );
    } catch (e) {
      // Handle any other exceptions
      return RecoveryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: null,
      );
    }
  }

  /// Reset password using recovery token
  static Future<ResetPasswordResponse> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // Create a custom DioApiHelper instance with authorization header
      final dioHelper = DioApiHelper(isTokeNeeded: false);
      // Add authorization header to the existing headers
      dioHelper.header['Authorization'] = 'Bearer $token';
      
      final response = await dioHelper.post(
        url: Apis.recoveryResetPassword,
        body: ResetPasswordRequest(newPassword: newPassword).toJson(),
      );

      return ResetPasswordResponse.fromJson(response);
    } on diox.DioException catch (e) {
      // Handle DioException specifically to extract API error message
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message')) {
          return ResetPasswordResponse(
            success: false,
            message: responseData['message'] as String,
            data: null,
          );
        }
      }
      
      // If we can't extract a specific message, return a generic error
      return ResetPasswordResponse(
        success: false,
        message: 'Failed to reset password. Please try again.',
        data: null,
      );
    } catch (e) {
      // Handle any other exceptions
      return ResetPasswordResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: null,
      );
    }
  }
}
