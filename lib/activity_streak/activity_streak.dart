import 'package:flutter/material.dart';
import 'package:flutter_utils/internalization/extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../utils/functions.dart';

class SistchTagStreakIndicator extends StatelessWidget {
  final String activityTitle;
  final String activityDescription;
  final String activitySeparator;
  final String activitySubTitle;
  final int currentCount;
  final int totalCount;
  final String slug;
  final bool enableMixpanel;
  final String balanceLabel; // Added parameter

  const SistchTagStreakIndicator({
    super.key,
    this.activityTitle = "Tag Streak",
    this.activityDescription = "Tag Streak",
    this.currentCount = 0,
    this.activitySubTitle = " done",
    this.activitySeparator = " / ",
    this.slug = "defaultTagStreak",
    this.enableMixpanel = true,
    this.totalCount = 1,
    this.balanceLabel = " un-tagged", // Default value
  });

  @override
  Widget build(BuildContext context) {
    var percent = 0.0;
    var balance = totalCount - currentCount;
    try {
      percent = totalCount > 0 ? currentCount / totalCount : 0.0;
    } catch (e) {}
    return GestureDetector(
      onTap: () {
        if (enableMixpanel) {
          mixpanelTrackEvent('tag_streak_${slug}_clicked');
        }
        Get.dialog(SistchTagStreakDialog(
          activityTitle: activityTitle,
          activityDescription: activityDescription,
          activitySeparator: activitySeparator,
          activitySubTitle: activitySubTitle,
          currentCount: currentCount,
          totalCount: totalCount,
          percent: percent,
          balanceCount: balance,
          balanceTextLabel: balanceLabel, // Pass the label to the dialog
        ));
      },
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 5.0,
            animation: true,
            animationDuration: 1000,
            percent: percent,
            center: Icon(
              FontAwesomeIcons.fire,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            progressColor: Theme.of(context).colorScheme.primary,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 2),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: formatNumber(balance),
              style: Get.theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: balanceLabel.ctr,
                  style: Get.theme.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SistchTagStreakDialog extends StatelessWidget {
  final String activityTitle;
  final String activityDescription;
  final String activitySeparator;
  final String activitySubTitle;
  final int currentCount;
  final int totalCount;
  final double percent;
  final int balanceCount;
  final String balanceTextLabel; // Added parameter

  const SistchTagStreakDialog({
    super.key,
    this.activityTitle = "Tag Streak",
    this.activityDescription = "Tag Streak",
    this.currentCount = 0,
    this.activitySubTitle = " done",
    this.activitySeparator = " / ",
    this.totalCount = 1,
    this.percent = 0.0,
    this.balanceCount = 0,
    this.balanceTextLabel = "LEFT", // Default value
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activityTitle.ctr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: formatNumber(currentCount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                        text: activitySeparator,
                        style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(
                        text: formatNumber(totalCount),
                        style: Theme.of(context).textTheme.bodySmall),
                    TextSpan(
                        text: activitySubTitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CircularPercentIndicator(
                radius: 70.0,
                lineWidth: 15.0,
                animation: true,
                animationDuration: 1000,
                percent: percent,
                center: Icon(
                  FontAwesomeIcons.fire,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                progressColor: Theme.of(context).colorScheme.primary,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: formatNumber(balanceCount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: balanceTextLabel.ctr.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Other widgets remain unchanged...
            ],
          ),
        ),
      ),
    );
  }
}
