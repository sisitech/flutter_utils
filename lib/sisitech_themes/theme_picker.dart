import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/sisitech_themes/format_theme_name.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:get/get.dart';

class SistchThemePicker extends StatelessWidget {
  final Function()? onThemeChange;
  static const routeName = "/theme-picker";
  final ThemeController themeController = Get.find<ThemeController>();
  final String title = "Theme Picker";
  final bool isPartOfAPage;
  final bool isOnBoarding;

  SistchThemePicker({
    Key? key,
    this.onThemeChange,
    this.isPartOfAPage = false,
    this.isOnBoarding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 45, right: 25, bottom: 25, left: 25),
      child: Center(
        child: Column(
          children: [
            Text(
              'Choose A Theme',
              style: Get.textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: themeController.m3Themes
                    .map((m3Theme) => themeBox(m3Theme, context))
                    .toList(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  if (onThemeChange != null) {
                    onThemeChange!();
                  }
                  // Handle navigation based on flags
                  if (!isPartOfAPage && !isOnBoarding) {
                    Get.back();
                    Get.back();
                  }
                },
                child: const Text(
                  'Apply Theme',
                ),
              ),
            )
          ],
        ),
      ),
    );

    if (isPartOfAPage || isOnBoarding) {
      return Scaffold(
        body: content,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            title.ctr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        body: content,
      );
    }
  }

  Widget themeBox(M3Theme m3Theme, BuildContext context) {
    return GestureDetector(
      onTap: () {
        themeController.changeTheme(m3Theme.flexScheme);
      },
      child: Column(
        children: [
          themeColorBox(m3Theme),
          const SizedBox(
            height: 5,
          ),
          Obx(
            () => Text(
              formatThemeName(m3Theme.flexScheme.toString().split(".").last),
              style: TextStyle(
                color: themeController.currentScheme.value == m3Theme.flexScheme
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onBackground,
                fontWeight:
                    themeController.currentScheme.value == m3Theme.flexScheme
                        ? FontWeight.bold
                        : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget themeColorBox(M3Theme m3Theme) {
    double mainBoxSize = 85.0;

    ColorScheme m3Colors = m3Theme.colorScheme;
    return Container(
      width: mainBoxSize,
      height: mainBoxSize,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Stack(
          children: <Widget>[
            palletteBox(m3Colors),
            Obx(
              () => themeController.currentScheme.value == m3Theme.flexScheme
                  ? Container(
                      decoration: BoxDecoration(
                        color: m3Colors.secondaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: m3Colors.primary,
                          size: 40,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget palletteBox(ColorScheme m3Colors) {
    double colorBoxSize = 38.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: colorBoxSize,
              height: colorBoxSize,
              decoration: BoxDecoration(
                color: m3Colors.primary,
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(20)),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Container(
              width: colorBoxSize,
              height: colorBoxSize,
              decoration: BoxDecoration(
                color: m3Colors.secondary,
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(20)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: colorBoxSize,
              height: colorBoxSize,
              decoration: BoxDecoration(
                color: m3Colors.primaryContainer,
                borderRadius:
                    const BorderRadius.only(bottomLeft: Radius.circular(20)),
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            Container(
              width: colorBoxSize,
              height: colorBoxSize,
              decoration: BoxDecoration(
                color: m3Colors.tertiary,
                borderRadius:
                    const BorderRadius.only(bottomRight: Radius.circular(20)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
