import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:async';

class ExtendedFABController extends GetxController {
  final showOptions = false.obs;
  final isFABVisible = true.obs;
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void toggleOptions() {
    showOptions.value = !showOptions.value;
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection != ScrollDirection.idle) {
      hideFABTemporarily();
    }
  }

  void hideFABTemporarily() {
    isFABVisible.value = false;
    Timer(Duration(seconds: 2), () => isFABVisible.value = true);
  }
}
