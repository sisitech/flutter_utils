import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// Initializes Firebase and returns the [FirebaseAnalytics] instance.
///
/// [options] are provided by the consuming app (its generated
/// `firebase_options.dart`) so this package stays app-agnostic. Leave them null
/// to initialize from the native config files instead (`google-services.json`
/// on Android, `GoogleService-Info.plist` on iOS). An app Firebase already
/// initialized elsewhere is reused.
Future<FirebaseAnalytics> initFirebaseAnalytics(
    [FirebaseOptions? options]) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
  }
  return FirebaseAnalytics.instance;
}
