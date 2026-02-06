import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:flutter_utils/sisitech_themes/format_theme_name.dart';
import 'package:flutter_utils/sisitech_themes/theme_controller.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
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
    final theme = Theme.of(context);
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 45, right: 25, bottom: 25, left: 25),
      child: Center(
        child: Column(
          children: [
            Text(
              'Choose A Theme',
              style: Get.textTheme.headlineSmall,
            ),
            buildCardWidget(
              theme: theme,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                children: themeController.m3Themes
                    .map((m3Theme) => themeBox(m3Theme, context))
                    .toList(),
              ),
            ),
            buildGradientButton(
              theme: theme,
              width: double.infinity,
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
              label: 'Apply Theme',
              iconPath: Icons.color_lens,
            )
          ],
        ),
      ),
    );

    if (isPartOfAPage || isOnBoarding) {
      return Scaffold(
        body: SafeArea(child: content),
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
        body: SafeArea(top: false, child: content),
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
                    : Theme.of(context).colorScheme.onSurface,
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
    return buildGlassWidget(
      theme: Get.theme,
      borderRadius: BorderRadius.circular(20),
      width: mainBoxSize,
      height: mainBoxSize,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Center(
        child: Stack(
          children: <Widget>[
            paletteBox(m3Colors),
            Obx(
              () => themeController.currentScheme.value == m3Theme.flexScheme
                  ? Container(
                      decoration: BoxDecoration(
                        color:
                            m3Colors.secondaryContainer.withValues(alpha: 0.6),
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

  Widget paletteBox(ColorScheme m3Colors) {
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
