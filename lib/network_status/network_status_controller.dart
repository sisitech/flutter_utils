import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../flutter_utils.dart';

class NetworkStatusController extends SuperController {
  Rx<ConnectivityResult> connectionStatus = Rx(ConnectivityResult.none);
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var isDeviceConnected = false.obs;
  var isCheckingConnection = false.obs;

  var connectionSource = "".obs;

  int checkTimeoutSeconds;
  int checkIntervalSeconds;
  NetworkStatusController({
    this.checkIntervalSeconds = 6,
    this.checkTimeoutSeconds = 6,
  });
  late InternetConnectionChecker internetCheckerInstance;
  late StreamSubscription<InternetConnectionStatus> listener;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    internetCheckerInstance = createCustomInternetChecker();
    setupCheckInterntet();
  }

  createCustomInternetChecker() {
    final InternetConnectionChecker customInstance =
        InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 6),
      checkInterval: const Duration(seconds: 6),
    );

    return customInstance;
  }

  Future<bool> checkIntenetConnection() async {
    isCheckingConnection.value = true;
    var result = await internetCheckerInstance.hasConnection;
    isCheckingConnection.value = false;
    return result;
  }

  checkUpdateNetworkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    connectionSource.value = getConnectivityName(connectivityResult);
    isDeviceConnected.value = await checkIntenetConnection();
    dprint("Connection1 ${connectivityResult}");
  }

  setupCheckInterntet() async {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      dprint(result);
      connectionSource.value = getConnectivityName(result);
    });

    listener = internetCheckerInstance.onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            dprint('Data connection is available.');
            isDeviceConnected.value = true;
            break;
          case InternetConnectionStatus.disconnected:
            isDeviceConnected.value = false;
            dprint('You are disconnected from the internet.');
            break;
        }
      },
    );
    final connectivityResult = await Connectivity().checkConnectivity();
    connectionSource.value = getConnectivityName(connectivityResult);
    isDeviceConnected.value = await checkIntenetConnection();
    dprint("Connection1 ${connectivityResult}");
  }

  getConnectivityName(List<ConnectivityResult> connectivityResult) {
    String name = "none";
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
    } else {
      var connectivityString = connectivityResult.map((e) => e.toString());
      name = connectivityString.first.replaceAll("ConnectivityResult.", "");
    }

    if (name == "none") {
      isDeviceConnected.value = false;
    }
    return name == "none" ? "Disconnected" : name;
  }

  @override
  void onClose() {
    // scroll.removeListener(_listener);
    _connectivitySubscription?.cancel();
    listener?.cancel();
    super.onClose();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }
  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
