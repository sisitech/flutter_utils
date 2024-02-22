import 'package:get/get.dart';

class ProgressBarController extends GetxController {
  var progress = 0.0.obs; // Observable progress value
  var currentTransaction = 0.obs; // Observable transaction count
  final int totalTransactions = 5; // Total number of transactions to import

  // Method to increment the progress and update the transaction count
  void incrementProgress() {
    if (currentTransaction.value < totalTransactions) {
      currentTransaction.value++;
      progress.value = currentTransaction.value / totalTransactions;
    }
  }
}
