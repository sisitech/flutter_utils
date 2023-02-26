import 'package:url_launcher/url_launcher.dart';

triggerPhoneCall(String phone) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phone,
  );
  await launchUrl(launchUri);
}
