import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/stacked_donut_chart.dart';
import 'package:flutter_utils/charts/bar_chart.dart';
import 'package:flutter_utils/charts/pie_donut_chart.dart';
import 'package:flutter_utils/charts/linear_percent_chart.dart';
import 'package:flutter_utils/charts/time_lapse_chart.dart';
import 'package:flutter_utils/widgets/global_widgets.dart';
import 'package:get/get.dart';

class ChartWidgetsScreen extends StatefulWidget {
  final routeName = "/chart-widgets";
  const ChartWidgetsScreen({super.key});

  @override
  State<ChartWidgetsScreen> createState() => _ChartWidgetsScreenState();
}

class _ChartWidgetsScreenState extends State<ChartWidgetsScreen> {
  ///Bar Chart
  /// Data & Controls
  bool useFirstBarChartSeries = true;
  int currentBarChartIdx = 0;
  List<List<List<double>>> barChartData = [
    [
      [100, 90, 80, 70],
      [40, 30, 20, 10]
    ], // series 0
    [
      [200, 180, 170, 160],
      [130, 120, 110, 100]
    ] // series 1
  ];
  List<List<String>> barChartLabels = [
    ["One", "Two", "Three", "Four"], // series 0
    ["Five", "Six", "Seven", "Eight"] // series 1
  ];
  void updateBarChart() {
    debugPrint("calling updateBarChart");
    useFirstBarChartSeries = !useFirstBarChartSeries;
    currentBarChartIdx = useFirstBarChartSeries ? 0 : 1;
    setState(() {});
  }

  /// Stacked Donut Chart, Pie Chart, Donut Chart & Linear Percent Chart
  /// Data & Controls
  bool useFirstChartSeries = true;
  int currentChartIdx = 0;
  List<List<double>> chartData = [
    [90, 80, 70, 60, 50], // series 0
    [40, 30, 20, 10] // series 1
  ];
  List<List<String>> chartLabels = [
    ["One", "Two", "Three", "Four", "Five"], // series 0
    ["Six", "Seven", "Eight", "Nine"] // series 1
  ];
  void updateChart() {
    debugPrint("calling updateChart");
    useFirstChartSeries = !useFirstChartSeries;
    currentChartIdx = useFirstChartSeries ? 0 : 1;
    setState(() {});
  }

  Rx<int> selectedTimeRange = Rx<int>(1);
  onTimeRangeSelected(int? val) {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Widgets'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              chartScaffold(
                updateChart: updateBarChart,
                chartWidget: SistchBarChart(
                  chartTitle: "Bar Chart Double Series",
                  dataSeries: barChartData[currentBarChartIdx],
                  xAxisLabels: barChartLabels[currentBarChartIdx],
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => updateChart(),
                    child: const Text('Update'),
                  ),
                ],
              ),
              chartScaffold(
                chartWidget: SistchStackedDonutChart(
                  chartTitle: "Stacked Donut Chart",
                  dataSeries: chartData[currentChartIdx],
                  chartLabels: chartLabels[currentChartIdx],
                  useIndIcons: true,
                  centerWidget: const Text("Ola!"),
                  firstStartAngle: 30,
                ),
              ),
              chartScaffold(
                chartWidget: SistchPieDonutChart(
                  chartTitle: "Donut Chart",
                  dataSeries: chartData[currentChartIdx],
                  pieLabels: chartLabels[currentChartIdx],
                  donutCenterRadius: 20,
                  chartDirection: Axis.horizontal,
                ),
              ),
              chartScaffold(
                chartWidget: SistchPieDonutChart(
                  chartTitle: "Pie Chart",
                  dataSeries: chartData[currentChartIdx],
                  pieLabels: chartLabels[currentChartIdx],
                  donutCenterRadius: 0,
                ),
              ),
              chartScaffold(
                chartWidget: SistchPieDonutChart(
                  chartTitle: "Half Arc Chart",
                  isHalfArcChart: true,
                  chartDirection: Axis.horizontal,
                  dataSeries: chartData[currentChartIdx],
                  pieLabels: chartLabels[currentChartIdx],
                ),
              ),
              chartScaffold(
                chartWidget: SistchLinearPercentChart(
                  chartTitle: "Linear Percent Chart",
                  dataSeries: chartData[currentChartIdx],
                  chartLabels: chartLabels[currentChartIdx],
                ),
              ),
              chartScaffold(
                chartWidget: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          getDropDownFormField(
                            theme: theme,
                            width: width * 0.4,
                            selectedValue: selectedTimeRange.value,
                            items: getTimeRangeDrpValues(),
                            onChanged: onTimeRangeSelected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SistchTimeLapseChart(
                        dataSeries: [1000, 60000, 400000, 30000, 1000000, 2000],
                        timeLabels: [
                          '6AM',
                          '9AM',
                          '12Noon',
                          '3PM',
                          '6PM',
                          '9PM'
                        ],
                        prefix: 'KES.',
                        // useSunColors: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chartScaffold({required Widget chartWidget, Function? updateChart}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (updateChart != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => updateChart(),
                child: const Text('Update'),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: chartWidget,
        ),
        const Divider(),
      ],
    );
  }
}

List<DropdownMenuItem<int>> getTimeRangeDrpValues() {
  List<DropdownMenuItem<int>> drpValues = [];
  List<String> timeRanges = ['Hourly', 'Time of Day', 'Day of Week'];

  for (int i = 0; i < timeRanges.length; i++) {
    drpValues.add(DropdownMenuItem(
      value: i,
      child: Text(timeRanges[i]),
    ));
  }

  return drpValues;
}
