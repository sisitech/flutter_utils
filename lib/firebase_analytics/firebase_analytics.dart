import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// Initializes Firebase and returns the [FirebaseAnalytics] instance.
///
/// [options] are provided by the consuming app (its generated
/// `firebase_options.dart`) so this package stays app-agnostic.
Future<FirebaseAnalytics> initFirebaseAnalytics(FirebaseOptions options) async {
  await Firebase.initializeApp(options: options);
  return FirebaseAnalytics.instance;
}
