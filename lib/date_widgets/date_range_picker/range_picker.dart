import 'package:flutter/material.dart';
import 'package:flutter_utils/date_widgets/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class YearDatePicker extends StatelessWidget {
  final int lastYear;
  final Function(SelectedDateRange? val) onRangeSelected;
  final DateFormat chosenDateFormat;
  final bool enableMixpanel;

  const YearDatePicker({
    Key? key,
    required this.lastYear,
    required this.onRangeSelected,
    required this.chosenDateFormat,
    required this.enableMixpanel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollCtrl = ScrollController();

    DateTime today = DateTime.now();
    RxInt currentYear = DateTime.now().year.obs;
    RxMap<int, List<DateTime>> groupedDates =
        (groupDatesByMonth(currentYear.value)).obs;

    RxBool isNowAddingLastDate = RxBool(false);
    RxList<DateTime> selectedDates = RxList([]);

    onCustomDateChosen(DateTime dt) {
      // first date
      if (selectedDates.length == 2 || !isNowAddingLastDate.value) {
        selectedDates.value = [dt];
        isNowAddingLastDate.value = true;
        onRangeSelected(null);
      } else {
        // second date
        if (dt.isBefore(selectedDates.first)) {
          selectedDates.value = [dt];
          return;
        }
        selectedDates.add(dt);
        onRangeSelected(getDateRange(selectedDates));
        isNowAddingLastDate.value = false;
      }
    }

    onCustomDateDeleted(bool isClearLastDate) {
      if (isClearLastDate) {
        selectedDates.value = [selectedDates.first];
        isNowAddingLastDate.value = true;
      } else {
        selectedDates.value = [];
        isNowAddingLastDate.value = false;
      }
      onRangeSelected(null);
      if (enableMixpanel) {
        mixpanelTrackEvent(
            'clear range picker ${isClearLastDate ? "end" : "start"} date');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              today.year - lastYear,
              (i) {
                int yr = today.year - i;
                return Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(yr.toString()),
                      selected: yr == currentYear.value,
                      onSelected: (isSelected) {
                        currentYear.value = yr;
                        groupedDates.value =
                            groupDatesByMonth(currentYear.value);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(),
        Obx(
          () => Row(
            children: [
              if (selectedDates.isNotEmpty)
                buildActionChip(
                  theme: theme,
                  label: chosenDateFormat.format(selectedDates.first),
                  onDelete: () => onCustomDateDeleted(false),
                ),
              if (selectedDates.isNotEmpty)
                Text(
                  "to",
                  style: theme.textTheme.bodySmall,
                ),
              if (selectedDates.length == 2)
                buildActionChip(
                  theme: theme,
                  label: chosenDateFormat.format(selectedDates.last),
                  onDelete: () => onCustomDateDeleted(true),
                ),
            ],
          ),
        ),
        const Divider(),
        SizedBox(
          height: Get.height * 0.43,
          child: Scrollbar(
            controller: scrollCtrl,
            thumbVisibility: true,
            child: Obx(
              () => ListView.builder(
                controller: scrollCtrl,
                itemCount: groupedDates.keys.length,
                itemBuilder: (context, index) {
                  int month = groupedDates.keys.elementAt(index);
                  List<DateTime> dates = groupedDates[month]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          getMonthName(month),
                          style: theme.textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //
                      buildDayHeaders(theme),
                      //
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: dates.length +
                            dates.first.weekday -
                            1, // Offset for empty days
                        itemBuilder: (context, index) {
                          if (index < dates.first.weekday - 1) {
                            // Add empty containers for the days before the first date of the month
                            return const SizedBox.shrink();
                          }

                          DateTime date =
                              dates[index - (dates.first.weekday - 1)];

                          return Obx(
                            () {
                              bool isInCurrentPickedDates =
                                  selectedDates.length == 2 &&
                                      (date.isAfter(selectedDates.first) &&
                                          date.isBefore(selectedDates.last));
                              bool isSelected = selectedDates.contains(date);
                              bool isInvalidDate = (selectedDates.isNotEmpty &&
                                      (date.isBefore(selectedDates.first)) ||
                                  selectedDates.length == 2 &&
                                      date.isAfter(selectedDates.last));

                              return GestureDetector(
                                onTap: () => onCustomDateChosen(date),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          (isSelected || isInCurrentPickedDates)
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                    ),
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${date.day}",
                                      style:
                                          theme.textTheme.labelSmall!.copyWith(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : isInCurrentPickedDates
                                                ? theme.colorScheme.primary
                                                : isInvalidDate
                                                    ? theme.colorScheme.outline
                                                    : theme
                                                        .colorScheme.onSurface,
                                        fontWeight:
                                            isSelected ? FontWeight.bold : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      //
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
