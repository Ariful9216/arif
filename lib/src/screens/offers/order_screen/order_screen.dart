import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/validator_constants.dart';

import 'controller/order_screen_controller.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController controller = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: Text("Order", style: TextStyle(color: Colors.white)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.orderKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                offerCard(),
                SizedBox(height: 20),
                buildTextField(
                  Icons.phone,
                  "Phone Number",
                  controller.phoneNumber,
                  false,
                  (p0) => Validators.validateMobile(controller.phoneNumber.text),
                  max: 11,
                  keyboard: TextInputType.number
                ),
                buildTextField(Icons.monetization_on_outlined, "Amount", controller.amount,true,(p0) => null,),
                buildTextField(Icons.sim_card, "Robi", controller.operator,true,(p0) => null,),

                buildDropdownField(
                  Icons.location_on,
                  "State Division",
                  controller.stateList,
                  controller.selectedState,
                  (value) {
                    controller.selectedState = value!;
                  },
                  (value) => Validators.validateRequired(controller.selectedState??'', "State Division"),
                ),
                SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.confirmOrder(context: context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('Confirm Order', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField(
      IconData icon,
      String hint,
      List<String> items,
      String? selectedValue,
      void Function(String?)? onChanged,
      String? Function(String?)? validator,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        ))
            .toList(),
      ),
    );
  }


  Widget offerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.offerData.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("Price ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("৳ ${controller.offerData.price}", style: TextStyle(color: AppColors.primaryColor, fontSize: 12)),
                      SizedBox(width: 10),
                      Text("Discount ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("৳ ${controller.offerData.discountAmount}", style: TextStyle(color: AppColors.primaryColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.offerData.description,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text("৳ ${controller.offerData.actualPrice.toStringAsFixed(2)}\nBUY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hint, TextEditingController controller, bool isReadOnly, String? Function(String?)? validator,{int? max, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        maxLength: max,
        readOnly: isReadOnly,
        controller: controller,
        keyboardType: keyboard??TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}
