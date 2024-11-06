import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SistchCarousel extends StatefulWidget {
  final List<Widget> children;
  final int waitTime;
  final bool autoPlay;
  final bool isScrollable;
  const SistchCarousel({
    super.key,
    required this.children,
    this.waitTime = 7,
    this.autoPlay = true,
    this.isScrollable = true,
  });

  @override
  State<SistchCarousel> createState() => _SistchCarouselState();
}

class _SistchCarouselState extends State<SistchCarousel> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  RxDouble scrollPosition = 0.0.obs;
  final double _scrollIncrement = Get.width * 0.5;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.isScrollable) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer =
        Timer.periodic(Duration(seconds: widget.waitTime), (timer) {
      if (_scrollController.hasClients) {
        scrollPosition.value = scrollPosition.value + _scrollIncrement;
        if (scrollPosition >= _scrollController.position.maxScrollExtent) {
          // If we've reached the end, reset to start
          scrollPosition.value = 0.0;
        }

        _scrollController.animateTo(
          scrollPosition.value,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      physics: widget.isScrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: Row(
        children: widget.children,
      ),
    );
  }
}
