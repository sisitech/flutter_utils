import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models.dart';

class BottomNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  Widget selectedTab(List<BottomNavigationItem> tabs) {
    if (tabs.isEmpty) {
      return Center(child: Text("Empty Bottom Navigation".tr));
    }
    return tabs[selectedIndex.value].widget;
  }

  selectTab(int index, Function? onTap) {
    selectedIndex.value = index;
    if (onTap != null) {
      onTap(index);
    }
  }
}
