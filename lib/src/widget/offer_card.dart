import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

Widget offerCard({
  required String title,
  void Function()? onTap,
  required num price,
  required num actualPrice,
  required num discountAmount,
  required String description,
  required num validity,
  required Color colorTheme
}) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    // Price Info
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Price: ",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: "৳ $price",
                            style: TextStyle(
                              color: colorTheme,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Discount Info
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Discount: ",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: "৳ $discountAmount",
                            style: TextStyle(
                              color: colorTheme,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Validity Info
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Validity: ",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: "$validity ${validity == 1 ? 'Day' : 'Days'}",
                        style: TextStyle(
                          color: colorTheme,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(color: colorTheme, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text("৳ ${actualPrice.toStringAsFixed(2)}\nBUY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    ),
  );
}
