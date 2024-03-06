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
    // Check if the scroll position is at the bottom
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      hideFab();
    } else {
      showFab();
    }
  }

  void hideOptions() {
    showOptions.value = false;
  }

  void hideFab() {
    isFABVisible.value = false;
    hideOptions();
  }

  void showFab() {
    isFABVisible.value = true;
  }
}
