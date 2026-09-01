import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/currency_card_grid.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';

/// Tile list that shows every currency of a row instead of one figure.
///
/// Use this over [SistchLinearPercentChart] whenever the rows can hold more
/// than one currency: a percentage of a mixed currency total is undefined, so
/// these tiles carry no bar and no share, only the amounts themselves.
class SistchCurrencyListView extends StatelessWidget {
  final List<CurrencyCardData> items;

  /// Tapping a tile hands back its label, as the percent chart does.
  final Function(String val)? onTileTap;

  /// Shown at the end of a tile, only when it can be tapped.
  final IconData? trailingIcon;
  final Color? iconColor;
  final String? selectedTile;
  final Color? selectedColor;
  final String? chartTitle;

  /// Abbreviates amounts, eg "97K".
  final bool compactValues;

  const SistchCurrencyListView({
    super.key,
    required this.items,
    this.onTileTap,
    this.trailingIcon,
    this.iconColor,
    this.selectedTile,
    this.selectedColor,
    this.chartTitle,
    this.compactValues = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chartTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                chartTitle!,
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...items.map((item) {
            bool isSelected = selectedTile == item.label;

            return buildFadeAnimateWidget(
              child: buildGlassWidget(
                theme: theme,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                mainColor: isSelected
                    ? selectedColor ?? colorScheme.surfaceContainerHighest
                    : null,
                child: GestureDetector(
                  onTap: () {
                    if (onTileTap != null) {
                      onTileTap!(item.label);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.icon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 2),
                          child: buildMappedIcon(
                            item.icon,
                            size: 16,
                            color: iconColor ?? colorScheme.tertiary,
                            fallback: Icons.category,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // One line per currency, they are never added up
                            ...item.amounts.map(
                              (amount) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      amount.code,
                                      style: textTheme.labelSmall!.copyWith(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      child: Text(
                                        compactValues
                                            ? getThousandsNumber(amount.value)
                                            : addThousandSeparators(
                                                amount.value),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            textTheme.labelMedium!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailingIcon != null && onTileTap != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            trailingIcon,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
