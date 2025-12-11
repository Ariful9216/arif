import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/address_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/controller/address_controller.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/address_form_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const AddressFormScreen()),
            icon: const Icon(Icons.add),
            tooltip: 'Add New Address',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (controller.addresses.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: controller.refreshAddresses,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return _buildAddressCard(address, controller);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddressFormScreen()),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Addresses Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddressFormScreen()),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressData address, AddressController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: address.isDefault 
            ? BorderSide(color: AppColors.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and default badge
            Row(
              children: [
                Text(
                  address.addressTypeIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.addressTypeDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Name and phone
            Text(
              address.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Address details
            Text(
              address.displayAddress,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            if (address.landmark.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Landmark: ${address.landmark}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                if (!address.isDefault)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSetDefaultDialog(address, controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    child: const Text(
                      'Set Default',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                if (!address.isDefault) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => AddressFormScreen(address: address)),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(address, controller),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSetDefaultDialog(AddressData address, AddressController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Set Default Address'),
        content: Text('Set "${address.name}" as your default address?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.setDefaultAddress(address.id);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Default address updated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Set Default'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AddressData address, AddressController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteAddress(address.id);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Address deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  controller.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
