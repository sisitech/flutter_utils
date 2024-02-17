import 'package:flutter/material.dart';

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
    this.headerSubText,
    this.headerImage,
  });

  final Color headerBackgroundColor;
  final String headerText;
  final String? headerSubText;
  final String? headerImage;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: headerBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage:
                headerImage != null ? NetworkImage(headerImage!) : null,
            // NetworkImage('https://example.com/user_profile_pic.jpg'),
          ),
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
              .map((item) => ListTile(
                    leading: Icon(item.leadingIcon),
                    title: Text(item.title),
                    trailing: item.trailingIcon != null
                        ? Icon(item.trailingIcon)
                        : null,
                    onTap: item.onTap,
                  ))
              .toList(),
        ],
      ),
    );
  }
}
