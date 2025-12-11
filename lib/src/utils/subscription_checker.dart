import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/widget/subscription_popup.dart';
import 'package:arif_mart/core/constants/var_constants.dart';

class SubscriptionChecker {
  // Check if user has subscription for premium features
  static bool hasSubscription() {
    final profile = VarConstants.myProfileModel.value.data;
    return profile?.isVerified == true;
  }

  // Show subscription popup for specific features
  static void checkSubscriptionAndShowPopup({
    required String featureName,
    required String description,
    required IconData icon,
    required VoidCallback onSubscribed,
  }) {
    if (hasSubscription()) {
      // User has subscription, proceed with the action
      onSubscribed();
    } else {
      // User doesn't have subscription, show popup
      SubscriptionPopup.show(
        featureName: featureName,
        description: description,
        icon: icon,
      );
    }
  }

  // Specific methods for different premium features
  static void checkAffiliateFeature(VoidCallback onSubscribed) {
    checkSubscriptionAndShowPopup(
      featureName: 'Affiliate Program',
      // description: 'Share products and earn commissions when someone buys through your links.',
      description: 'পণ্যগুলি শেয়ার করুন এবং কেউ আপনার লিঙ্কের মাধ্যমে কিনলে কমিশন অর্জন করুন।',
      icon: Icons.share,
      onSubscribed: onSubscribed,
    );
  }

  static void checkReferralFeature(VoidCallback onSubscribed) {
    checkSubscriptionAndShowPopup(
      featureName: 'Referral System',
      // description: 'Invite friends and earn rewards when they join using your referral code.',
      description: 'আপনার রেফারেল কোড ব্যবহার করে যখন তারা যোগ দেয় তখন বন্ধুদের আমন্ত্রণ জানান এবং পুরস্কার অর্জন করুন।',
      icon: Icons.people,
      onSubscribed: onSubscribed,
    );
  }

  static void checkInternetOffersFeature(VoidCallback onSubscribed) {
    checkSubscriptionAndShowPopup(
      featureName: 'Internet Offers',
      // description: 'Access exclusive internet data packages and special offers.',
      description: 'এক্সক্লুসিভ ইন্টারনেট ডেটা প্যাকেজ এবং বিশেষ অফার অ্যাক্সেস করুন।',
      icon: Icons.wifi,
      onSubscribed: onSubscribed,
    );
  }

  static void checkMinuteOffersFeature(VoidCallback onSubscribed) {
    checkSubscriptionAndShowPopup(
      featureName: 'Minute Offers',
      // description: 'Get special call minute packages and voice offers.',
      description: 'বিশেষ কল মিনিট প্যাকেজ এবং ভয়েস অফার পান।',
      icon: Icons.phone,
      onSubscribed: onSubscribed,
    );
  }

  static void checkComboOffersFeature(VoidCallback onSubscribed) {
    checkSubscriptionAndShowPopup(
      featureName: 'Combo Offers',
      // description: 'Access exclusive combo packages with internet and minutes.',
      description: 'ইন্টারনেট এবং মিনিট সহ এক্সক্লুসিভ কম্বো প্যাকেজ অ্যাক্সেস করুন।',
      icon: Icons.all_inclusive,
      onSubscribed: onSubscribed,
    );
  }
}
