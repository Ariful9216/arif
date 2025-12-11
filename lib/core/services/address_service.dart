import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/model/address_model.dart';

class AddressService {
  // Get all user addresses
  Future<AddressModel?> getUserAddresses() async {
    try {
      print('Fetching user addresses');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.addresses);
      
      if (data != null && data['success'] == true) {
        print('User addresses API response: ${data.toString()}');
        return AddressModel.fromJson(data);
      } else {
        print('Failed to fetch addresses: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching addresses: $e');
      return null;
    }
  }

  // Get default address
  Future<SingleAddressModel?> getDefaultAddress() async {
    try {
      print('Fetching default address');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.defaultAddress);
      
      if (data != null && data['success'] == true) {
        print('Default address API response: ${data.toString()}');
        return SingleAddressModel.fromJson(data);
      } else {
        print('Failed to fetch default address: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching default address: $e');
      return null;
    }
  }

  // Create new address
  Future<SingleAddressModel?> createAddress({
    required String name,
    required String phone,
    required String district,
    required String thana,
    required String village,
    required String fullAddress,
    String? landmark,
    String? postalCode,
    String addressType = 'home',
    bool isDefault = false,
  }) async {
    try {
      print('Creating new address for: $name');
      Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'district': district,
        'thana': thana,
        'village': village,
        'fullAddress': fullAddress,
        'landmark': landmark ?? '',
        'postalCode': postalCode ?? '',
        'addressType': addressType,
        'isDefault': isDefault,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.addresses, body: requestBody);
      
      if (data != null && data['success'] == true) {
        print('Create address API response: ${data.toString()}');
        return SingleAddressModel.fromJson(data);
      } else {
        print('Failed to create address: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error creating address: $e');
      return null;
    }
  }

  // Update address
  Future<SingleAddressModel?> updateAddress({
    required String addressId,
    required String name,
    required String phone,
    required String district,
    required String thana,
    required String village,
    required String fullAddress,
    String? landmark,
    String? postalCode,
    String addressType = 'home',
    bool isDefault = false,
  }) async {
    try {
      print('Updating address: $addressId');
      Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'district': district,
        'thana': thana,
        'village': village,
        'fullAddress': fullAddress,
        'landmark': landmark ?? '',
        'postalCode': postalCode ?? '',
        'addressType': addressType,
        'isDefault': isDefault,
      };
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .put(url: '${Apis.addresses}/$addressId', body: requestBody);
      
      if (data != null && data['success'] == true) {
        print('Update address API response: ${data.toString()}');
        return SingleAddressModel.fromJson(data);
      } else {
        print('Failed to update address: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error updating address: $e');
      return null;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      print('Deleting address: $addressId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .delete(url: '${Apis.addresses}/$addressId');
      
      if (data != null && data['success'] == true) {
        print('Delete address API response: ${data.toString()}');
        return true;
      } else {
        print('Failed to delete address: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      print('Setting default address: $addressId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .patch(url: '${Apis.addresses}/$addressId/set-default', body: {});
      
      if (data != null && data['success'] == true) {
        print('Set default address API response: ${data.toString()}');
        return true;
      } else {
        print('Failed to set default address: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }

  // Get addresses for order (optimized for checkout)
  Future<AddressModel?> getAddressesForOrder() async {
    try {
      print('Fetching addresses for order');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.addressesForOrder);
      
      if (data != null && data['success'] == true) {
        print('Addresses for order API response: ${data.toString()}');
        // Parse addresses for order with different structure
        return AddressModel(
          success: data['success'] ?? false,
          message: data['message'] ?? '',
          data: data['data'] != null 
              ? List<AddressData>.from(
                  data['data'].map((x) => AddressData.fromJson(x))
                )
              : null,
        );
      } else {
        print('Failed to fetch addresses for order: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching addresses for order: $e');
      return null;
    }
  }
}
