import 'package:flutter/widgets.dart';
import 'package:flutter_utils/firebase_analytics/firebase_analytics_controller.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';

/// One-line analytics calls for any app, mirroring `mixpanelTrackEvent`.
///
/// Each helper is a no-op until the app registers a [FirebaseAnalyticsController],
/// and never throws — analytics must not interrupt the flow it observes. That is
/// what lets shared libraries call them unconditionally.
void _withAnalytics(void Function(FirebaseAnalyticsController a) action) {
  if (!Get.isRegistered<FirebaseAnalyticsController>()) return;
  try {
    action(Get.find<FirebaseAnalyticsController>());
  } catch (e) {
    dprint(e);
  }
}

/// Firebase accepts only String and num parameter values, strings of at most 100
/// characters. Nulls are dropped, bools become 1/0, anything else is stringified.
Map<String, Object> analyticsParams(Map<String, dynamic>? params) {
  final out = <String, Object>{};
  params?.forEach((key, value) {
    if (value == null) return;
    if (value is bool) {
      out[key] = value ? 1 : 0;
    } else if (value is num) {
      out[key] = value;
    } else {
      final text = "$value";
      out[key] = text.length > 100 ? text.substring(0, 100) : text;
    }
  });
  return out;
}

analyticsLogEvent(String name, [Map<String, dynamic>? params]) =>
    _withAnalytics((a) => a.logEvent(name, parameters: analyticsParams(params)));

analyticsSetUser() => _withAnalytics((a) => a.setLoggedInUser());

analyticsLogin({String? method}) => _withAnalytics((a) {
      a.userLogsIn(method: method);
      a.setLoggedInUser();
    });

analyticsSignUp({required String method}) => _withAnalytics((a) {
      a.userSignsUp(method: method);
      a.setLoggedInUser();
    });

/// Logs `logout` and clears the user id. Call it before the auth state is reset.
analyticsLogout() => _withAnalytics((a) => a.logoutUser());

analyticsScreen(String name, {String? screenClass}) =>
    _withAnalytics((a) => a.logScreen(name, screenClass: screenClass));

analyticsSearch(String term) =>
    _withAnalytics((a) => a.searchesTransactions(term));

analyticsTutorialBegin() => _withAnalytics((a) => a.tutorialBegin());

analyticsTutorialComplete() => _withAnalytics((a) => a.tutorialComplete());

analyticsShare(
        {required String contentType,
        required String itemId,
        required String method}) =>
    _withAnalytics((a) => a.sharesContent(
        contentType: contentType, itemId: itemId, method: method));

/// Logs a `screen_view` per page route, named after the route (leading `/`
/// stripped). Unlike `FirebaseAnalyticsController.observer` it can be built
/// before Firebase has initialized, since it goes through [analyticsScreen].
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _log(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final name = route.settings.name;
    if (name == null || name == "/" || name.isEmpty) return;
    analyticsScreen(name.startsWith("/") ? name.substring(1) : name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Closing a sheet or dialog is not a return to the page beneath it.
    if (route is PageRoute) _log(previousRoute);
  }
}
