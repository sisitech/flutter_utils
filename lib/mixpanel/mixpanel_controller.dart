

import 'package:flutter_auth/flutter_auth_controller.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixpanel/mixpanel.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelOptions {
  final bool enableAnonymous;
  final bool persistentAnonymous;
  const MixpanelOptions({ this.enableAnonymous=true,this.persistentAnonymous=true});
}

class MixPanelController extends GetxController{
  late String mixpanelToken;
  Mixpanel? _mixpanel;
  late MixpanelOptions options;
  MixPanelController({required this.mixpanelToken,this.options=const MixpanelOptions()});


  @override
  void onInit() {
    super.onInit();
    initializeMixPanel(options);
  }

  get mixpanel{
    return _mixpanel;
  } 

  getAnonymouseuser(MixpanelOptions options){
    // Save a unique id to local storage and use it everytime
      // The key should be passed when initializing.
      return "Anonymous";
  }
  initializeMixPanel(MixpanelOptions options) async{
    AuthController authController = Get.find<AuthController>();
    _mixpanel=await initMixpanel(mixpanelToken);
     if(authController.isAuthenticated$.value){
      dprint("Mixpanel User ${authController.profile.value?["username"]} initialized.");
      _mixpanel?.identify(authController.profile.value?["username"]);
     }else {
      dprint("Mixpanel Anonymous initialized.");
      _mixpanel?.identify(getAnonymouseuser(options));
     }
    //  Get.put(_mixpanel);
  }

  track(String eventName, {Map<String, dynamic>? properties}){
  _mixpanel?.track(eventName,properties:properties);
  }


}