import 'package:mixpanel_flutter/mixpanel_flutter.dart';

Future<Mixpanel> initMixpanel(token, {trackAutomaticEvents=true}) async {
    // dprint('mixpanel init');
    var mixpanel = await Mixpanel.init(token, trackAutomaticEvents: trackAutomaticEvents);
    return mixpanel;
  }