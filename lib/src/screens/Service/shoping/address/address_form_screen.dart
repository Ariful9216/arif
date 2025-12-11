import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/address_model.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/controller/address_controller.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressData? address;
  
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _thanaController = TextEditingController();
  final _villageController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String _selectedAddressType = 'home';
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final address = widget.address!;
    _nameController.text = address.name;
    _phoneController.text = address.phone;
    _districtController.text = address.district;
    _thanaController.text = address.thana;
    _villageController.text = address.village;
    _fullAddressController.text = address.fullAddress;
    _landmarkController.text = address.landmark;
    _postalCodeController.text = address.postalCode;
    _selectedAddressType = address.addressType;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _thanaController.dispose();
    _villageController.dispose();
    _fullAddressController.dispose();
    _landmarkController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
    final isEditing = widget.address != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add New Address'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address Type Selection
            _buildSectionTitle('Address Type'),
            _buildAddressTypeSelector(),
            
            const SizedBox(height: 20),
            
            // Personal Information
            _buildSectionTitle('Personal Information'),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Location Information
            _buildSectionTitle('Location Information'),
            _buildTextField(
              controller: _districtController,
              label: 'District',
              hint: 'Enter district name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'District is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _thanaController,
              label: 'Thana/Upazila',
              hint: 'Enter thana or upazila name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Thana/Upazila is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _villageController,
              label: 'Village/Area',
              hint: 'Enter village or area name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Village/Area is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Address Details
            _buildSectionTitle('Address Details'),
            _buildTextField(
              controller: _fullAddressController,
              label: 'Full Address',
              hint: 'Enter complete address details',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full address is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _landmarkController,
              label: 'Landmark (Optional)',
              hint: 'Enter nearby landmark',
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _postalCodeController,
              label: 'Postal Code (Optional)',
              hint: 'Enter postal code',
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 20),
            
            // Default Address Option
            if (!isEditing || !widget.address!.isDefault)
              _buildDefaultAddressOption(),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveAddress(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Address' : 'Save Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAddressType,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: 'home',
              child: Row(
                children: [
                  Text('🏠'),
                  SizedBox(width: 8),
                  Text('Home'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'work',
              child: Row(
                children: [
                  Text('🏢'),
                  SizedBox(width: 8),
                  Text('Work'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Row(
                children: [
                  Text('📍'),
                  SizedBox(width: 8),
                  Text('Other'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedAddressType = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDefaultAddressOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set as Default Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'This address will be used for future orders',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAddress(AddressController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      
      if (widget.address != null) {
        // Update existing address
        success = await controller.updateAddress(
          addressId: widget.address!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          district: _districtController.text.trim(),
          thana: _thanaController.text.trim(),
          village: _villageController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          landmark: _landmarkController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          addressType: _selectedAddressType,
          isDefault: _isDefault,
        );
      } else {
        // Create new address
        success = await controller.createAddress(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          district: _districtController.text.trim(),
          thana: _thanaController.text.trim(),
          village: _villageController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          landmark: _landmarkController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          addressType: _selectedAddressType,
          isDefault: _isDefault,
        );
      }

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          widget.address != null 
              ? 'Address updated successfully' 
              : 'Address created successfully',
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
