import 'package:get/get.dart';

import 'sistch_progress_indicator.dart';

class ProgressBarController extends GetxController {
  final SisitechProgressOptions options;

  ProgressBarController({required this.options});

  var progress = 0.0.obs; // Observable progress value
  var currentTransaction = 0.obs; // Observable transaction count
  var totalSteps = 0.obs;

  // Method to increment the progress and update the transaction count
  void incrementProgress({int nextStep = 1}) {
    currentTransaction.value = nextStep;
    if (currentTransaction.value < totalSteps.value) {
      currentTransaction.value++;
      progress.value = currentTransaction.value / totalSteps.value;
    }
  }
}
