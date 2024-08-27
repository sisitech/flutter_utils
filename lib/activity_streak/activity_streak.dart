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

  const SistchTagStreakIndicator({
    super.key,
    this.activityTitle = "Tag Streak",
    this.activityDescription = "Tag Streak",
    this.currentCount = 0,
    this.activitySubTitle = " done",
    this.activitySeparator = " / ",
    this.totalCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.dialog(SistchTagStreakDialog(
          activityTitle: activityTitle,
          activityDescription: activityDescription,
          activitySeparator: activitySeparator,
          activitySubTitle: activitySubTitle,
          currentCount: currentCount,
          totalCount: totalCount,
        ));
      },
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 5.0,
            animation: true,
            animationDuration: 1000,
            percent: 1,
            center: Icon(
              FontAwesomeIcons.fire,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            progressColor: Theme.of(context).colorScheme.primaryContainer,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 2),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: formatNumber(currentCount),
              style: Get.theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: " left".ctr,
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

  const SistchTagStreakDialog({
    super.key,
    this.activityTitle = "Tag Streak",
    this.activityDescription = "Tag Streak",
    this.currentCount = 0,
    this.activitySubTitle = " done",
    this.activitySeparator = " / ",
    this.totalCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    var balanceCount = totalCount - currentCount;
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
                        text: activitySubTitle, // " transactions tagged!",
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
                percent: 1,
                center: Icon(
                  FontAwesomeIcons.fire,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                progressColor: Theme.of(context).colorScheme.primaryContainer,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: formatNumber(balanceCount), // "50",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                        text: " TO GO".ctr,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  activityDescription,
                  // "Keep tagging your transactions to get the most out of Wavvy Wallet's insights and features!",
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // await taggingCtrl.getUnTaggedTransactions();
                    // Get.off(() => const UnTaggedTransactionsScreen());
                  },
                  child: Text('Tag Transactions'.ctr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
