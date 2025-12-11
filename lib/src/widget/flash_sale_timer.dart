import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arif_mart/core/model/product_model.dart';

class FlashSaleTimer extends StatefulWidget {
  final FlashSale flashSale;
  final TextStyle? style;
  final Color? backgroundColor;

  const FlashSaleTimer({
    super.key,
    required this.flashSale,
    this.style,
    this.backgroundColor,
  });

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  Timer? _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _timeRemaining = widget.flashSale.timeRemainingFormatted;
      });
      
      // Stop timer if expired
      if (!widget.flashSale.isCurrentlyActive) {
        _timer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.flashSale.isCurrentlyActive) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        _timeRemaining,
        style: widget.style ?? const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
