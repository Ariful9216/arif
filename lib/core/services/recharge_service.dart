import 'package:get/get.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/model/recharge_model.dart';
import 'package:arif_mart/core/model/recharge_operator_model.dart';

class RechargeService extends GetxService {
  static RechargeService get to => Get.find();

  // Get recharge operators list
  Future<RechargeOperatorModel?> getRechargeOperators({bool? isActive}) async {
    try {
      String url = Apis.rechargeOperators;
      if (isActive != null) {
        url += '?isActive=${isActive.toString()}';
      }
      
      Map<String, dynamic>? data = await RechargeDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      if (data != null) {
        RechargeOperatorModel operatorModel = RechargeOperatorModel.fromJson(data);
        return operatorModel;
      }
      return null;
    } catch (e) {
      print('RechargeService Error: $e');
      return null;
    }
  }

  // Submit recharge request
  Future<Map<String, dynamic>?> submitRecharge({
    required String operator,
    required String phoneNumber,
    required num amount,
  }) async {
    try {
      print('RechargeService: Submitting recharge request');
      print('Operator: $operator');
      print('Phone: $phoneNumber');
      print('Amount: $amount');
      
      Map<String, dynamic> requestBody = {
        'operator': operator,
        'phoneNumber': phoneNumber,
        'amount': amount,
      };
      
      print('Request body: $requestBody');
      print('API URL: ${Apis.rechargeBaseUrl}${Apis.recharge}');
      
      Map<String, dynamic>? data = await RechargeDioHelper(isTokenNeeded: true)
          .post(url: Apis.recharge, body: requestBody);
      
      print('API Response: $data');
      return data;
    } catch (e) {
      print('RechargeService Error: $e');
      return null;
    }
  }

  // Get recharge history with pagination (ONLY THIS METHOD)
  Future<RechargeModel?> getRechargeHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('RechargeService: Fetching recharge history - page: $page, limit: $limit');
      String url = '${Apis.recharge}?page=$page&limit=$limit';
      print('RechargeService: URL: $url');
      
      Map<String, dynamic>? data = await RechargeDioHelper(isTokenNeeded: true)
          .get(url: url);
      
      if (data != null) {
        print('RechargeService: Raw API response: $data');
        
        try {
          RechargeModel rechargeModel = RechargeModel.fromJson(data);
          print('RechargeService: Successfully parsed ${rechargeModel.data?.length ?? 0} recharges');
          print('RechargeService: Pagination - Page: ${rechargeModel.pagination?.page}, Total: ${rechargeModel.pagination?.total}');
          return rechargeModel;
        } catch (parseError) {
          print('RechargeService: Error parsing JSON response: $parseError');
          print('RechargeService: Data structure: ${data.runtimeType}');
          rethrow;
        }
      }
      print('RechargeService: No data received from API');
      return null;
    } catch (e) {
      print('RechargeService: Error fetching recharge history: $e');
      print('RechargeService: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Get active recharge operators only
  Future<RechargeOperatorModel?> getActiveRechargeOperators() async {
    return await getRechargeOperators(isActive: true);
  }

  // Get all recharge operators (active and inactive)
  Future<RechargeOperatorModel?> getAllRechargeOperators() async {
    return await getRechargeOperators();
  }
}
