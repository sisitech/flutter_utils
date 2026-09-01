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
    final accent = iconColor ?? colorScheme.tertiary;

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
                margin: const EdgeInsets.symmetric(vertical: 5),
                borderRadius: BorderRadius.circular(14),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                mainColor: isSelected
                    ? selectedColor ?? colorScheme.surfaceContainerHighest
                    : null,
                child: GestureDetector(
                  onTap: () {
                    if (onTileTap != null) {
                      onTileTap!(item.label);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.icon != null) ...[
                            buildGlassContainer(
                              mainColor: accent,
                              padding: const EdgeInsets.all(7),
                              child: buildMappedIcon(
                                item.icon,
                                size: 16,
                                color: accent,
                                fallback: Icons.category,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (trailingIcon != null && onTileTap != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                trailingIcon,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      if (item.amounts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.07),
                          ),
                        ),
                      // One line per currency, they are never added up
                      ...item.amounts.map(
                        (amount) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text(
                                amount.code,
                                style: textTheme.labelSmall!.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  compactValues
                                      ? getThousandsNumber(amount.value)
                                      : addThousandSeparators(amount.value),
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleSmall!.copyWith(
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
