import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

Widget getBottomSheetScaffold(
    {required List<Widget> widgetList,
    required double height,
    bool isScrollable = true}) {
  final scrollCtrl = ScrollController();
  return Container(
    height: height,
    decoration: BoxDecoration(color: Get.theme.colorScheme.surface),
    padding: const EdgeInsets.all(15),
    child: Scrollbar(
      controller: scrollCtrl,
      thumbVisibility: isScrollable,
      child: SingleChildScrollView(
        controller: scrollCtrl,
        physics: isScrollable
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetList,
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
}) {
  final textTheme = Get.theme.textTheme;
  return GestureDetector(
    onTap: () {
      if (onTap != null) onTap(title);
    },
    child: Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: Get.width * 0.35,
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
                  width: Get.width * 0.2,
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
