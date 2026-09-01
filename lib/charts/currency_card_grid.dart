import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

/// One currency's amount on a [CurrencyCardData].
class CurrencyAmount {
  /// Code shown on the left of the pill, eg "KES".
  final String code;

  /// Human name, eg "Kenyan Shilling". Unused by the grid, carried for callers
  /// that render the same data elsewhere.
  final String? name;
  final double value;

  const CurrencyAmount({required this.code, required this.value, this.name});
}

/// A single card: a label, an optional icon and one amount per currency.
class CurrencyCardData {
  final String label;
  final MappedIcon? icon;
  final List<CurrencyAmount> amounts;

  const CurrencyCardData({
    required this.label,
    required this.amounts,
    this.icon,
  });
}

/// Card grid that shows every currency of a card instead of one figure.
///
/// Amounts in different currencies can never be added up, so each card lists
/// them as separate rows. Use [SistchCardGridView] where a card only ever holds
/// a single value.
class SistchCurrencyCardGridView extends StatelessWidget {
  final List<CurrencyCardData> cards;
  final List<Color>? cardColors;
  final List<Color>? onCardColors;
  final Function(String val)? onCardTap;
  final int crossCount;
  final String? chartTitle;
  final double spacing;
  final double? cardAspectRatio;

  /// Abbreviates amounts, eg "97K". Off by default, the pills have room for
  /// the full figure.
  final bool compactValues;

  const SistchCurrencyCardGridView({
    super.key,
    required this.cards,
    this.crossCount = 2,
    this.cardColors,
    this.onCardColors,
    this.onCardTap,
    this.cardAspectRatio,
    this.chartTitle,
    this.spacing = 8,
    this.compactValues = false,
  });

  /// A grid cannot size itself to its tallest card, so the ratio follows the
  /// card with the most currencies.
  double get _aspectRatio {
    if (cardAspectRatio != null) return cardAspectRatio!;
    if (crossCount == 1) return 3;
    var rows = cards.fold<int>(
        1, (most, card) => card.amounts.length > most ? card.amounts.length : most);
    if (rows <= 1) return 1.3;
    if (rows == 2) return 0.95;
    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;

    List<Color> bgColors = cardColors ?? getChartColors(cards.length);
    List<Color> fgColors = onCardColors ?? getOnChartColors(cards.length);

    return Column(
      children: [
        if (chartTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              chartTitle!,
              style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        GridView.count(
          crossAxisCount: crossCount,
          childAspectRatio: _aspectRatio,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards.asMap().entries.map((e) {
            return getCurrencyCardWidget(
              card: e.value,
              bgColor: bgColors[e.key],
              fgColor: fgColors[e.key],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget getCurrencyCardWidget({
    required CurrencyCardData card,
    required Color bgColor,
    required Color fgColor,
  }) {
    final textTheme = Get.theme.textTheme;

    return GestureDetector(
      onTap: () {
        if (onCardTap != null) {
          onCardTap!(card.label);
        }
      },
      child: buildScaleAnimateWidget(
        child: buildGradientWidget(
          theme: Get.theme,
          borderRadius: BorderRadius.circular(16),
          gradientColors: [
            bgColor.withValues(alpha: 0.9),
            bgColor.withValues(alpha: 0.6),
          ],
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.icon != null)
                    buildGlassContainer(
                      mainColor: fgColor,
                      child: buildMappedIcon(card.icon, size: 20, color: fgColor),
                    ),
                  const Spacer(),
                  if (onCardTap != null)
                    buildGlassIcon(
                      iconPath: Icons.keyboard_arrow_right_rounded,
                      color: fgColor,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                card.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
              const Spacer(),
              ...card.amounts.map(
                (amount) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: buildGlassContainer(
                    mainColor: fgColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          amount.code,
                          style: textTheme.labelMedium!.copyWith(
                            color: fgColor.withValues(alpha: 0.75),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            compactValues
                                ? getThousandsNumber(amount.value)
                                : addThousandSeparators(amount.value),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: fgColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
