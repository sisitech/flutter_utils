import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mixpanel/mixpanel_controller.dart';

class SisitechDrawerItem {
  final String title;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final IconData? trailingIcon;

  SisitechDrawerItem({
    required this.title,
    required this.onTap,
    required this.leadingIcon,
    this.trailingIcon,
  });
}

class SisitechDrawerHeader extends StatelessWidget {
  const SisitechDrawerHeader({
    super.key,
    required this.headerBackgroundColor,
    required this.headerText,
    required this.headerSubText,
    this.headerImage,
  });

  final Color headerBackgroundColor;
  final String headerText;
  final String headerSubText;
  final String? headerImage;

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (headerImage != null && headerImage!.isNotEmpty) {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(headerImage!),
      );
    } else {
      // If headerImage is null or empty, fallback to using the first letter of the headerText
      String firstLetter =
          headerSubText.isNotEmpty ? headerSubText[0].toUpperCase() : '';
      avatar = CircleAvatar(
        child: Text(
          firstLetter,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return DrawerHeader(
      decoration: BoxDecoration(
        color: headerBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatar,
          const SizedBox(height: 16),
          Text(headerText, style: const TextStyle(color: Colors.white)),
          Text(headerSubText ?? '',
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class SisitechDrawer extends StatelessWidget {
  final Color? headerBackgroundColor;
  final String? headerText;
  final String? headerSubText;
  final String? headerImage;
  final List<SisitechDrawerItem> items;
  final Widget? headerWidget;

  const SisitechDrawer({
    Key? key,
    required this.items,
    this.headerWidget,
    this.headerBackgroundColor,
    this.headerText,
    this.headerImage,
    this.headerSubText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool mixPanelEnabled = false;
    MixPanelController? mixCont;
    try {
      mixCont = Get.find<MixPanelController>();
      mixPanelEnabled = true;
    } catch (e) {
      mixPanelEnabled = false;
    }
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          headerWidget ??
              SisitechDrawerHeader(
                  headerBackgroundColor: headerBackgroundColor ?? Colors.black,
                  headerText: headerText ?? '',
                  headerSubText: headerSubText ?? '',
                  headerImage: headerImage ?? ''),
          ...items
              .map(
                (item) => ListTile(
                  leading: Icon(item.leadingIcon),
                  title: Text(item.title),
                  trailing: item.trailingIcon != null
                      ? Icon(item.trailingIcon)
                      : null,
                  onTap: () {
                    item.onTap();
                    mixCont?.track(
                      "drawer_item_pressed",
                      properties: {"item_title": item.title},
                    );
                  },
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
