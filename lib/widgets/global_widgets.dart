import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

Widget getIconBtn(
    {Color? bgColor,
    Color? fgColor,
    Function? action,
    required IconData iconPath}) {
  return InkWell(
    onTap: () {
      if (action != null) {
        action();
      }
    },
    child: Ink(
      decoration: ShapeDecoration(
        color: bgColor,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          iconPath,
          color: fgColor,
        ),
      ),
    ),
  );
}

Widget getChipsWidget({
  required List<String> chipLabels,
  required Function(int val) onChipSelected,
  required int? selectedIdx,
  List<IconData>? chipIcons,
  String? title,
  double? width,
  Color? bgColor,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: bgColor ?? Get.theme.colorScheme.primaryContainer,
    ),
    width: width,
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title,
            style: Get.theme.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        Wrap(
          spacing: 4.0,
          children: chipLabels.asMap().entries.map((entry) {
            int index = entry.key;
            String label = entry.value;
            return ChoiceChip(
              label: Text(
                label,
                style: Get.theme.textTheme.labelSmall,
              ),
              labelPadding: EdgeInsets.zero,
              avatar: (chipIcons != null &&
                      chipIcons.isNotEmpty &&
                      chipIcons.length == chipLabels.length)
                  ? Icon(chipIcons[index])
                  : null,
              selected: index == selectedIdx,
              onSelected: (bool selected) {
                onChipSelected(index);
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Widget getDropDownFormField({
  required int? selectedValue,
  required List<DropdownMenuItem<int>> items,
  required Function(int? val) onChanged,
  String? label,
  double? width,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(label),
        ),
      SizedBox(
        width: width,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            // alignedDropdown: true,
            child: DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: Get.theme.textTheme.displaySmall,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                contentPadding: const EdgeInsets.all(6),
              ),
              value: selectedValue,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: Get.theme.textTheme.bodyMedium,
              onChanged: (int? value) {
                onChanged(value);
              },
              items: items,
              validator: (value) {
                return null;
              },
            ),
          ),
        ),
      ),
    ],
  );
}

Future<dynamic> getBottomSheetScaffold({
  required List<Widget> children,
  required ThemeData theme,
  String? preTitle,
  String? title,
  double heightFactor = 0.8,
}) async {
  return Get.bottomSheet(
    backgroundColor: theme.colorScheme.tertiary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    SafeArea(
      top: false,
      child: Container(
        height: Get.size.height * heightFactor,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (preTitle != null)
              Text(
                preTitle,
                style: theme.textTheme.bodySmall!
                    .copyWith(color: theme.primaryColor),
                textAlign: TextAlign.center,
              ),
            if (title != null)
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            if (preTitle != null || title != null) const Divider(),
            ...children
          ],
        ),
      ),
    ),
    ),
  );
}

Widget getHeaderWidget({
  required String title,
  TextStyle? style,
  Widget? leadingWidget,
  Widget? trailingWidget,
}) {
  return Row(
    children: [
      if (leadingWidget != null)
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: leadingWidget,
        ),
      Text(
        title,
        style: style ?? Get.theme.textTheme.titleSmall,
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Divider(
            color: Get.theme.colorScheme.outline,
          ),
        ),
      ),
      if (trailingWidget != null) trailingWidget,
    ],
  );
}

Widget getSummaryCard({
  required IconData iconPath,
  required String title,
  String? subtitle,
  required String tag,
  required Color mainColor,
  String? prefix,
  Function(String title)? onTap,
  double? width,
  Color? bgColor,
}) {
  final textTheme = Get.theme.textTheme;
  return GestureDetector(
    onTap: () {
      if (onTap != null) onTap(title);
    },
    child: Card(
      color: bgColor ?? Get.theme.cardColor,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: width ?? Get.width * 0.35,
        height: Get.width * 0.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: mainColor.withValues(alpha: 0.3),
                  child: Icon(iconPath, color: mainColor, size: 18),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: (width ?? Get.width * 0.35) * 0.65,
                  child: Text(
                    title,
                    overflow: TextOverflow.clip,
                    maxLines: 2,
                    style: textTheme.labelSmall!.copyWith(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: prefix == null ? '' : '$prefix ',
                    style: textTheme.labelSmall!.copyWith(
                      color: Get.theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: tag,
                        style: textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: mainColor.withValues(alpha: 0.3),
                  child: Icon(
                    Icons.call_made,
                    size: 16,
                    color: mainColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildHalfArcPercentChart({
  required ThemeData theme,
  required Color progressColor,
  required double percent,
  Widget? center,
}) {
  double chartRadius = Get.height * 0.15;
  return Stack(
    children: [
      ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 0.5,
          child: CircularPercentIndicator(
            radius: chartRadius,
            lineWidth: 40,
            percent: (percent / 2) * 0.01,
            animation: true,
            progressColor: progressColor,
            animationDuration: 800,
            startAngle: 270,
          ),
        ),
      ),
      if (center != null)
        Positioned(
          bottom: chartRadius * 0.1,
          left: 0,
          right: 0,
          child: center,
        ),
    ],
  );
}

Widget buildScaleAnimateWidget({
  required Widget child,
  int durationInMs = 800,
  Curve curve = Curves.easeOutBack,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.95, end: 1.0),
    duration: Duration(milliseconds: durationInMs),
    curve: curve,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: child,
      );
    },
    child: child,
  );
}

Widget buildFadeAnimateWidget({
  required Widget child,
  int durationInMs = 800,
  Curve curve = Curves.easeOut,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: durationInMs),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: child,
      );
    },
    child: child,
  );
}

Widget buildGlassWidget({
  required Widget child,
  required ThemeData theme,
  BoxShadow? shadow,
  Color? mainColor,
  Color? bgColor,
  EdgeInsets? margin,
  EdgeInsets? padding,
  BorderRadius? borderRadius,
  double? width,
  double? height,
}) {
  return Container(
    width: width,
    height: height,
    margin: margin ?? const EdgeInsets.all(16.0),
    padding: padding ?? const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: bgColor ?? theme.colorScheme.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      boxShadow: [
        shadow ??
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
      ],
      border: Border.all(
        color: mainColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
        width: 1,
      ),
    ),
    child: child,
  );
}

buildGradientWidget({
  required ThemeData theme,
  required Widget child,
  List<Color>? gradientColors,
  BoxShadow? shadow,
  Color? mainColor,
  BorderRadius? borderRadius,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? width,
  double? height,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(12.0),
      gradient: LinearGradient(
        colors: gradientColors ??
            [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        shadow ??
            BoxShadow(
              color: (mainColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
      ],
    ),
    margin: margin,
    padding: padding,
    child: child,
  );
}

buildCardWidget({
  required ThemeData theme,
  required Widget child,
  BoxShadow? shadow,
  Color? mainColor,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? width,
  double? height,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        shadow ??
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
      ],
      border: Border.all(
        color: (mainColor ?? theme.colorScheme.primary).withValues(alpha: 0.2),
        width: 1.5,
      ),
    ),
    margin: margin,
    padding: padding,
    child: child,
  );
}

buildGlassContainer({
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? width,
  double? height,
  Color? mainColor,
  required Widget child,
}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding ?? const EdgeInsets.all(6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: (mainColor ?? Colors.white).withValues(alpha: 0.2),
      border: Border.all(
        color: (mainColor ?? Colors.white).withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: child,
  );
}

buildGlassIcon({
  required IconData iconPath,
  double? size,
  Color? color,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? width,
  double? height,
}) {
  return Container(
    width: width,
    height: height,
    margin: margin,
    padding: padding ?? const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: 0.2),
      shape: BoxShape.circle,
      border: Border.all(
        color: (color ?? Colors.white).withValues(alpha: 0.1),
        width: 1.5,
      ),
    ),
    child: Icon(
      iconPath,
      size: size,
      color: color,
    ),
  );
}

PreferredSizeWidget buildAppBar({
  required ThemeData theme,
  required String title,
  String? subtitle,
  IconData? iconPath,
  List<Widget>? actions,
}) {
  return AppBar(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconPath != null)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(iconPath),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null)
              Text(subtitle, style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    ),
    actions: actions,
  );
}

buildGradientButton({
  required ThemeData theme,
  required Function() onPressed,
  required String label,
  IconData? iconPath,
  List<Color>? gradientColors,
  Color? mainColor,
  BorderRadius? borderRadius,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? width,
  Color? btnTxtColor,
}) {
  return buildGradientWidget(
    theme: theme,
    gradientColors: gradientColors,
    mainColor: mainColor,
    borderRadius: borderRadius,
    width: width,
    margin: margin ?? const EdgeInsets.all(5),
    padding: padding ??
        (width == null ? const EdgeInsets.symmetric(horizontal: 15) : null),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(label),
      icon: iconPath != null ? Icon(iconPath) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: btnTxtColor ?? theme.colorScheme.onPrimary,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
    ),
  );
}
