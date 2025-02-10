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

Future<dynamic> getBottomSheet({
  required List<Widget> children,
  required ThemeData theme,
  double heightFactor = 0.9,
}) async {
  return Get.bottomSheet(
    backgroundColor: theme.colorScheme.tertiary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    Container(
      width: Get.width,
      height: Get.height * heightFactor,
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
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
            ...children
          ],
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
                  backgroundColor: mainColor.withOpacity(0.3),
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
                  backgroundColor: mainColor.withOpacity(0.3),
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

Widget buildSmallBtn({
  required void Function() onPressed,
  required ThemeData theme,
  required String title,
  IconData? iconPath,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            theme.scaffoldBackgroundColor,
          ),
        ),
        icon: Icon(iconPath ?? Icons.refresh),
        label: Text(title),
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
            percent: percent,
            animation: true,
            progressColor: progressColor,
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
