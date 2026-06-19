import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_utils/firebase_analytics/firebase_analytics.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/utils/functions.dart';
import 'package:get/get.dart';

class FirebaseAnalyticsOptions {
  final bool enabled;
  final bool disableInDebug;
  final bool analyticsCollectionEnabled;
  // Hash the user email/id before sending it as the Firebase user id.
  final bool enableAnonymous;
  // Requires manual calling of initialize() somewhere in your project if enabled
  final bool enableManualInit;
  const FirebaseAnalyticsOptions({
    this.enabled = true,
    this.disableInDebug = true,
    this.analyticsCollectionEnabled = true,
    this.enableAnonymous = true,
    this.enableManualInit = false,
  });
}

/// Thin Firebase Analytics wrapper mirroring [MixPanelController]: a GetX
/// service with an options class, auth-aware user identification, a generic
/// [logEvent] passthrough and intent-revealing helpers for the predefined
/// Firebase events plus app-specific (e.g. M-Pesa) custom events.
class FirebaseAnalyticsController extends GetxController {
  late FirebaseOptions firebaseOptions;
  late FirebaseAnalyticsOptions options;
  FirebaseAnalytics? _analytics;
  AuthController authController = Get.find<AuthController>();

  FirebaseAnalyticsController({
    required this.firebaseOptions,
    this.options = const FirebaseAnalyticsOptions(),
  });

  @override
  void onInit() {
    super.onInit();
    dprint("FirebaseAnalytics OnInit");
    if (!options.enableManualInit) {
      initialize();
    }
  }

  FirebaseAnalytics? get analytics {
    return _analytics;
  }

  /// Navigator observer for automatic `screen_view` events. Add it to
  /// `GetMaterialApp.navigatorObservers`.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics!);

  get isDisAbled {
    if (options.disableInDebug) {
      return false;
    }
    return !options.enabled;
  }

  getUser() {
    var anymousProfile = {"username": "Anonymous"};
    Map<String, dynamic> profile;
    if (authController.isAuthenticated$.value != null) {
      profile = authController.profile.value ?? anymousProfile;
    } else {
      profile = anymousProfile;
    }

    if (options.enableAnonymous) {
      profile["username"] = generateMd5(profile["email"] ?? "");
    }
    dprint("Username: ${profile["username"]}");

    return profile;
  }

  setLoggedInUser() {
    if (_analytics == null) {
      dprint("No initialized _analytics instance found");
      return;
    }
    var profile = getUser();
    _analytics?.setUserId(id: profile["username"]);
    if (profile["email"] != null) {
      _analytics?.setUserProperty(name: "email", value: profile["email"]);
    }
    if (profile["subscription_tier"] != null) {
      _analytics?.setUserProperty(
          name: "subscription_tier", value: "${profile["subscription_tier"]}");
    }
    dprint(profile);
  }

  logoutUser() {
    _analytics?.resetAnalyticsData();
  }

  initialize() async {
    dprint("Initializing FirebaseAnalytics");
    if (isDisAbled) {
      dprint(
          "FirebaseAnalytics disabled,disableInDebug:${options.disableInDebug} enabled:${options.enabled}");
      return;
    }
    try {
      _analytics = await initFirebaseAnalytics(firebaseOptions);
      await _analytics
          ?.setAnalyticsCollectionEnabled(options.analyticsCollectionEnabled);
    } catch (e) {
      dprint("Init failed.");
      dprint(e);
    }
    setLoggedInUser();
  }

  // ---------------------------------------------------------------------------
  // Generic passthrough (any app / any custom event)
  // ---------------------------------------------------------------------------

  logEvent(String name, {Map<String, Object>? parameters}) {
    _analytics?.logEvent(name: name, parameters: parameters);
  }

  logScreen(String screenName, {String? screenClass}) {
    _analytics?.logScreenView(
        screenName: screenName, screenClass: screenClass);
  }

  setUserProperty(String name, String? value) {
    _analytics?.setUserProperty(name: name, value: value);
  }

  setUserId(String? id) {
    _analytics?.setUserId(id: id);
  }

  // ---------------------------------------------------------------------------
  // Predefined Firebase events (auth, onboarding & subscription/monetization)
  // ---------------------------------------------------------------------------

  userLogsIn({String? method}) {
    _analytics?.logLogin(loginMethod: method);
  }

  userSignsUp({required String method}) {
    _analytics?.logSignUp(signUpMethod: method);
  }

  tutorialBegin() {
    _analytics?.logTutorialBegin();
  }

  tutorialComplete() {
    _analytics?.logTutorialComplete();
  }

  // Browsing the available subscription tiers.
  viewsPlans(List<AnalyticsEventItem> items,
      {String? listId, String? listName}) {
    _analytics?.logViewItemList(
        items: items, itemListId: listId, itemListName: listName);
  }

  // Picking a subscription tier.
  selectsPlan(AnalyticsEventItem item, {String? listId, String? listName}) {
    _analytics?.logSelectItem(
        items: [item], itemListId: listId, itemListName: listName);
  }

  beginsCheckout(
      {double? value,
      String? currency,
      List<AnalyticsEventItem>? items,
      String? coupon}) {
    _analytics?.logBeginCheckout(
        value: value, currency: currency, items: items, coupon: coupon);
  }

  addsPaymentInfo(
      {String? paymentType, double? value, String? currency, String? coupon}) {
    _analytics?.logAddPaymentInfo(
        paymentType: paymentType,
        value: value,
        currency: currency,
        coupon: coupon);
  }

  // Subscription paid / renewed.
  subscribes(
      {double? value,
      String? currency,
      String? transactionId,
      String? coupon,
      List<AnalyticsEventItem>? items}) {
    _analytics?.logPurchase(
        value: value,
        currency: currency,
        transactionId: transactionId,
        coupon: coupon,
        items: items);
  }

  refunds({double? value, String? currency, String? transactionId}) {
    _analytics?.logRefund(
        value: value, currency: currency, transactionId: transactionId);
  }

  // ---------------------------------------------------------------------------
  // Engagement
  // ---------------------------------------------------------------------------

  searchesTransactions(String term) {
    _analytics?.logSearch(searchTerm: term);
  }

  selectsContent({required String contentType, required String itemId}) {
    _analytics?.logSelectContent(contentType: contentType, itemId: itemId);
  }

  sharesContent(
      {required String contentType,
      required String itemId,
      required String method}) {
    _analytics?.logShare(
        contentType: contentType, itemId: itemId, method: method);
  }

  // ---------------------------------------------------------------------------
  // Custom M-Pesa / Wavvy domain events (thin wrappers over logEvent).
  // The generic logEvent above supports any other custom event.
  // ---------------------------------------------------------------------------

  logSmsParsed({int? count}) {
    logEvent("sms_parsed", parameters: {if (count != null) "count": count});
  }

  logTransactionSynced({String? source, int? count}) {
    logEvent("transaction_synced", parameters: {
      if (source != null) "source": source,
      if (count != null) "count": count,
    });
  }

  logTransactionCategorized({String? category}) {
    logEvent("transaction_categorized",
        parameters: {if (category != null) "category": category});
  }

  logStatementImported({String? period}) {
    logEvent("statement_imported",
        parameters: {if (period != null) "period": period});
  }

  logReportExported({String? format}) {
    logEvent("report_exported",
        parameters: {if (format != null) "format": format});
  }

  logBudgetCreated({double? amount, String? currency}) {
    logEvent("budget_created", parameters: {
      if (amount != null) "amount": amount,
      if (currency != null) "currency": currency,
    });
  }
}
