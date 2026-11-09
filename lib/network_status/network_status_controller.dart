import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../flutter_utils.dart';

/// Optimistic network status: any Wi-Fi/mobile transport is treated as online
/// right away, and background probes only downgrade to offline after
/// [disconnectionThreshold] consecutive failures.
class NetworkStatusController extends SuperController {
  static const defaultCheckUrls = [
    "https://www.google.com/generate_204",
    "https://connectivitycheck.gstatic.com/generate_204",
    "https://captive.apple.com/hotspot-detect.html",
  ];

  Rx<ConnectivityResult> connectionStatus = Rx(ConnectivityResult.none);
  var isDeviceConnected = false.obs;
  var isCheckingConnection = false.obs;
  var connectionSource = "".obs;

  int checkTimeoutSeconds;
  int connectedCheckIntervalSeconds;
  int disconnectedCheckIntervalSeconds;
  String? checkUrl;
  List<String> checkUrls;
  int disconnectionThreshold;

  NetworkStatusController({
    this.checkTimeoutSeconds = 8,
    this.connectedCheckIntervalSeconds = 120,
    this.disconnectedCheckIntervalSeconds = 2,
    this.checkUrl,
    this.checkUrls = defaultCheckUrls,
    this.disconnectionThreshold = 2,
  });

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  // Long-lived client so keep-alive reuses the TLS connection between checks.
  http.Client _client = http.Client();
  Timer? _timer;
  Future<bool>? _inflight;
  int _generation = 0;
  int _failureCount = 0;
  bool _hasTransport = false;
  bool _paused = false;

  @override
  void onInit() {
    super.onInit();
    setupCheckInterntet();
  }

  setupCheckInterntet() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _onConnectivityChanged(await _connectivity.checkConnectivity(),
        debounce: false);
  }

  void _onConnectivityChanged(List<ConnectivityResult> result,
      {bool debounce = true}) {
    dprint("Connectivity changed $result");
    connectionSource.value = getConnectivityName(result);
    _hasTransport = !result.contains(ConnectivityResult.none);
    _failureCount = 0;
    // Sockets bound to the previous interface would hang until timeout.
    _generation++;
    _client.close();
    _client = http.Client();
    if (!_hasTransport) {
      _timer?.cancel();
      return;
    }
    isDeviceConnected.value = true;
    // Android emits a burst of events during a handover.
    _schedule(debounce ? const Duration(milliseconds: 500) : Duration.zero);
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    if (_paused || !_hasTransport) return;
    _timer = Timer(delay, _check);
  }

  Future<bool> _check() =>
      _inflight ??= _runCheck().whenComplete(() => _inflight = null);

  Future<bool> _runCheck() async {
    _timer?.cancel();
    final generation = _generation;
    final ok = await _probeAll();
    if (generation != _generation) {
      _schedule(const Duration(milliseconds: 500));
      return ok;
    }
    if (ok) {
      _failureCount = 0;
      isDeviceConnected.value = true;
    } else if (++_failureCount >= disconnectionThreshold) {
      isDeviceConnected.value = false;
    }
    dprint("Network check ok=$ok failures=$_failureCount");
    // Healthy: check rarely. Any failure: re-check fast to confirm or recover.
    _schedule(Duration(
        seconds: _failureCount == 0
            ? connectedCheckIntervalSeconds
            : disconnectedCheckIntervalSeconds));
    return ok;
  }

  /// Completes true on the first successful probe, false once all fail.
  Future<bool> _probeAll() {
    final urls = [if (checkUrl != null) checkUrl!, ...checkUrls];
    if (urls.isEmpty) return Future.value(false);
    final done = Completer<bool>();
    final watch = Stopwatch()..start();
    var pending = urls.length;
    for (final url in urls) {
      _probe(Uri.parse(url)).then((ok) {
        if (done.isCompleted) return;
        if (ok) {
          dprint("Network check via $url in ${watch.elapsedMilliseconds}ms");
          done.complete(true);
        } else if (--pending == 0) {
          done.complete(false);
        }
      });
    }
    return done.future;
  }

  Future<bool> _probe(Uri uri) async {
    try {
      final request = http.Request('HEAD', uri)..followRedirects = false;
      final response = await _client
          .send(request)
          .timeout(Duration(seconds: checkTimeoutSeconds));
      response.stream.listen(null).cancel();
      // Captive portals answer generate_204 with 200/302, not 204.
      if (uri.path.endsWith("generate_204")) return response.statusCode == 204;
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkIntenetConnection() async {
    isCheckingConnection.value = true;
    final ok = await _check();
    isCheckingConnection.value = false;
    return ok;
  }

  checkUpdateNetworkStatus() async {
    connectionSource.value =
        getConnectivityName(await _connectivity.checkConnectivity());
    await checkIntenetConnection();
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
    _connectivitySubscription?.cancel();
    _timer?.cancel();
    _client.close();
    super.onClose();
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    _paused = true;
    _timer?.cancel();
  }

  @override
  void onResumed() {
    _paused = false;
    _schedule(Duration.zero);
  }

  @override
  void onHidden() {}
}
