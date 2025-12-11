import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';

class RatingService {
  /// Rate a product
  static Future<Map<String, dynamic>> rateProduct({
    required String productId,
    required int rating,
  }) async {
    try {
      final response = await EcommerceDioHelper(isTokenNeeded: true).patch(
        url: '${Apis.products}/$productId/rating',
        body: {'rating': rating},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
