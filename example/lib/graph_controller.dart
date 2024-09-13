import 'package:flutter_utils/charts/bar_chart_beta/bar_chart_controller_beta.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:get/get.dart';

class ExampleGraphController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  updateGraph() {
    try {
      var graphCont = Get.find<BarChartControllerBeta>(tag: "bar1");
      graphCont.updateChart(dataSeries: [
        [43, 32, 52, 62],
        [11, 66, 76, 16],
      ], xAxisLabels: [
        "Five",
        "Six",
        "Seven",
        "Eight"
      ]);
    } catch (e) {
      dprint(e);
    }
  }
}
