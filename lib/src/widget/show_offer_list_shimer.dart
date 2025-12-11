import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

Widget showOfferListShimer(){
  return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer(
        color: Colors.grey,
        colorOpacity: 0.5,
        child: Container(
          width: 60,
          height: 120,
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      )
  );
}