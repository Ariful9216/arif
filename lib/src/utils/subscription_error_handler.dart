import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/widget/subscription_popup.dart';

class SubscriptionErrorHandler {
  // Handle subscription-related API errors
  static bool handleSubscriptionError(dynamic error) {
    try {
      // Check if this is a subscription-related error
      String? errorMessage = error?.response?.data?['message'];
      int? statusCode = error?.response?.statusCode;
      
      if (statusCode == 401 && errorMessage != null) {
        if (errorMessage.contains('not verified') || 
            errorMessage.contains('subscription') ||
            errorMessage.contains('User is not verified')) {
          
          // Show subscription popup based on the API endpoint
          String featureName = _getFeatureNameFromUrl(error?.requestOptions?.uri?.path ?? '');
          _showSubscriptionPopup(featureName);
          return true; // Error handled
        }
      }
      
      return false; // Not a subscription error
    } catch (e) {
      print('Error in subscription error handler: $e');
      return false;
    }
  }
  
  // Get feature name from API URL
  static String _getFeatureNameFromUrl(String url) {
    if (url.contains('recharge') || url.contains('offers')) {
      return 'Recharge & Offers';
    } else if (url.contains('affiliate')) {
      return 'Affiliate Program';
    } else if (url.contains('referral')) {
      return 'Referral System';
    } else {
      return 'Premium Feature';
    }
  }
  
  // Show appropriate subscription popup
  static void _showSubscriptionPopup(String featureName) {
    String description;
    IconData icon;
    
    switch (featureName) {
      case 'Recharge & Offers':
        description = 'Access exclusive recharge offers, internet packages, and special deals.';
        icon = Icons.local_offer;
        break;
      case 'Affiliate Program':
        description = 'Share products and earn commissions when someone buys through your links.';
        icon = Icons.share;
        break;
      case 'Referral System':
        description = 'Invite friends and earn rewards when they join using your referral code.';
        icon = Icons.people;
        break;
      default:
        description = 'Access premium features and exclusive content.';
        icon = Icons.star;
    }
    
    SubscriptionPopup.show(
      featureName: featureName,
      description: description,
      icon: icon,
    );
  }
}
