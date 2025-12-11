import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

Widget pendingCard({required String mobileNum, required num price, required num discount, required String description, required String status, VoidCallback? onClickCancel,required num validity, required String date}) {
  DateTime dateTime = DateTime.parse(date).toLocal(); // Convert to local

  String formattedDate = DateFormat('d/M/yyyy').format(dateTime);
  String formattedTime = DateFormat('hh:mm:ss a').format(dateTime);
  return Container(
    margin: EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.copy, color: AppColors.primaryColor),
              Text(mobileNum, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              Text("Price ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("৳ $price", style: TextStyle(color: Colors.black, fontSize: 14)),
              SizedBox(width: 10),
              Text("Discount ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("৳ $discount", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("Validity ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("$validity Day", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold,fontSize: 14)),
              // TextButton(
              //   style: TextButton.styleFrom(
              //     backgroundColor: Colors.red.shade600,
              //     foregroundColor: Colors.white,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //   ),
              //   onPressed: onClickCancel,
              //   child: Text("Cancel",style: TextStyle(fontSize: 14),),
              // ),
              Row(
                children: [
                  Text("$formattedDate",style: TextStyle(fontSize: 10,color: Colors.black),),
                  SizedBox(width: 20,),
                  Text("$formattedTime",style: TextStyle(fontSize: 10,color: Colors.black),),
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}
