import 'package:get/get.dart';
import 'package:arif_mart/core/model/address_model.dart';
import 'package:arif_mart/core/services/address_service.dart';

class AddressController extends GetxController {
  late AddressService _addressService;

  // Address state
  final RxList<AddressData> addresses = <AddressData>[].obs;
  final Rx<AddressData?> defaultAddress = Rx<AddressData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _addressService = Get.find<AddressService>();
    loadAddresses();
  }

  // Load all addresses
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _addressService.getUserAddresses();
      
      if (response != null && response.success) {
        addresses.value = response.data ?? [];
        // Find default address
        defaultAddress.value = addresses.firstWhereOrNull((addr) => addr.isDefault);
        print('Loaded ${addresses.length} addresses');
      } else {
        addresses.clear();
        defaultAddress.value = null;
        errorMessage.value = response?.message ?? 'Failed to load addresses';
      }
    } catch (e) {
      print('Error loading addresses: $e');
      addresses.clear();
      defaultAddress.value = null;
      errorMessage.value = 'Error loading addresses: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh addresses (alias for loadAddresses)
  Future<void> refreshAddresses() async {
    await loadAddresses();
  }

  // Load default address
  Future<void> loadDefaultAddress() async {
    try {
      final response = await _addressService.getDefaultAddress();
      
      if (response != null && response.success && response.data != null) {
        defaultAddress.value = response.data;
        print('Default address loaded: ${response.data!.name}');
      } else {
        defaultAddress.value = null;
        print('No default address found');
      }
    } catch (e) {
      print('Error loading default address: $e');
      defaultAddress.value = null;
    }
  }

  // Create new address
  Future<bool> createAddress({
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
      final response = await _addressService.createAddress(
        name: name,
        phone: phone,
        district: district,
        thana: thana,
        village: village,
        fullAddress: fullAddress,
        landmark: landmark,
        postalCode: postalCode,
        addressType: addressType,
        isDefault: isDefault,
      );
      
      if (response != null && response.success && response.data != null) {
        // Add to local list
        addresses.add(response.data!);
        
        // If this is set as default, update default address
        if (isDefault) {
          // Remove default from other addresses
          for (int i = 0; i < addresses.length - 1; i++) {
            if (addresses[i].isDefault) {
              addresses[i] = addresses[i].copyWith(isDefault: false);
            }
          }
          defaultAddress.value = response.data;
        }
        
        print('Address created successfully: ${response.data!.name}');
        return true;
      } else {
        errorMessage.value = response?.message ?? 'Failed to create address';
        return false;
      }
    } catch (e) {
      print('Error creating address: $e');
      errorMessage.value = 'Error creating address: $e';
      return false;
    }
  }

  // Update address
  Future<bool> updateAddress({
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
      final response = await _addressService.updateAddress(
        addressId: addressId,
        name: name,
        phone: phone,
        district: district,
        thana: thana,
        village: village,
        fullAddress: fullAddress,
        landmark: landmark,
        postalCode: postalCode,
        addressType: addressType,
        isDefault: isDefault,
      );
      
      if (response != null && response.success && response.data != null) {
        // Update in local list
        final index = addresses.indexWhere((addr) => addr.id == addressId);
        if (index != -1) {
          addresses[index] = response.data!;
        }
        
        // If this is set as default, update default address
        if (isDefault) {
          // Remove default from other addresses
          for (int i = 0; i < addresses.length; i++) {
            if (addresses[i].id != addressId && addresses[i].isDefault) {
              addresses[i] = addresses[i].copyWith(isDefault: false);
            }
          }
          defaultAddress.value = response.data;
        }
        
        print('Address updated successfully: ${response.data!.name}');
        return true;
      } else {
        errorMessage.value = response?.message ?? 'Failed to update address';
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      errorMessage.value = 'Error updating address: $e';
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final success = await _addressService.deleteAddress(addressId);
      
      if (success) {
        // Remove from local list
        addresses.removeWhere((addr) => addr.id == addressId);
        
        // If deleted address was default, clear default
        if (defaultAddress.value?.id == addressId) {
          defaultAddress.value = null;
        }
        
        print('Address deleted successfully');
        return true;
      } else {
        errorMessage.value = 'Failed to delete address';
        return false;
      }
    } catch (e) {
      print('Error deleting address: $e');
      errorMessage.value = 'Error deleting address: $e';
      return false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final success = await _addressService.setDefaultAddress(addressId);
      
      if (success) {
        // Update local state
        for (int i = 0; i < addresses.length; i++) {
          if (addresses[i].id == addressId) {
            addresses[i] = addresses[i].copyWith(isDefault: true);
            defaultAddress.value = addresses[i];
          } else if (addresses[i].isDefault) {
            addresses[i] = addresses[i].copyWith(isDefault: false);
          }
        }
        
        print('Default address set successfully');
        return true;
      } else {
        errorMessage.value = 'Failed to set default address';
        return false;
      }
    } catch (e) {
      print('Error setting default address: $e');
      errorMessage.value = 'Error setting default address: $e';
      return false;
    }
  }

  // Get address by ID
  AddressData? getAddressById(String addressId) {
    try {
      return addresses.firstWhere((addr) => addr.id == addressId);
    } catch (e) {
      return null;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }


  // Helper getters
  bool get hasAddresses => addresses.isNotEmpty;
  bool get hasDefaultAddress => defaultAddress.value != null;
  int get addressCount => addresses.length;
  
  // Get addresses by type
  List<AddressData> getAddressesByType(String type) {
    return addresses.where((addr) => addr.addressType.toLowerCase() == type.toLowerCase()).toList();
  }
  
  // Get home addresses
  List<AddressData> get homeAddresses => getAddressesByType('home');
  
  // Get work addresses
  List<AddressData> get workAddresses => getAddressesByType('work');
  
  // Get other addresses
  List<AddressData> get otherAddresses => getAddressesByType('other');
}
