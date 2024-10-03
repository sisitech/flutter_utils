import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/stacked_donut_chart.dart';
import 'package:flutter_utils/charts/bar_chart.dart';
import 'package:flutter_utils/charts/card_grid_chart.dart';
import 'package:flutter_utils/charts/pie_donut_chart.dart';
import 'package:flutter_utils/charts/linear_percent_chart.dart';
import 'package:flutter_utils/charts/time_lapse_chart.dart';
import 'package:flutter_utils/charts/block_chart.dart';
import 'package:flutter_utils/charts/utils.dart';
import 'package:flutter_utils/utils/icon_mapper.dart';
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
    [100, 90, 80, 70], // series 0
    [40, 30, 20, 10] // series 1
  ];
  List<List<String>> chartLabels = [
    ["One", "Two", "Three", "Four"], // series 0
    ["Six", "Seven", "Eight", "Nine"] // series 1
  ];
  void updateChart() {
    debugPrint("calling updateChart");
    useFirstChartSeries = !useFirstChartSeries;
    currentChartIdx = useFirstChartSeries ? 0 : 1;
    setState(() {});
  }

  /// Linear Percent Chart
  RxString selectedTile = RxString('');
  onLinearPercChartTileTap(String val) {
    if (selectedTile.value == val) {
      selectedTile.value = '';
      return;
    }
    selectedTile.value = val;
  }

  /// Actionable Indicators
  RxString selectedIndicator = RxString('');
  onIndicatorTap(String val) {
    if (selectedIndicator.value == val) {
      selectedIndicator.value = '';
      return;
    }
    selectedIndicator.value = val;
  }

  @override
  Widget build(BuildContext context) {
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
                  // hideIndicators: true,
                  // firstStartAngle: 335,
                ),
              ),
              chartScaffold(
                chartWidget:
                    //
                    //   Obx(
                    // () =>
                    SistchPieDonutChart(
                  chartTitle: "Donut Chart",
                  dataSeries: chartData[currentChartIdx],
                  pieLabels: chartLabels[currentChartIdx],
                  donutCenterRadius: 50,
                  // selectedIndicator: selectedIndicator.value,
                  // onIndicatorTap: onIndicatorTap,
                  // hideIndicators: true,
                  chartDirection: Axis.horizontal,
                ),
                // ),
              ),
              chartScaffold(
                chartWidget:
                    //
                    Obx(
                  () => SistchPieDonutChart(
                    chartTitle: "Pie Chart",
                    dataSeries: chartData[currentChartIdx],
                    pieLabels: chartLabels[currentChartIdx],
                    donutCenterRadius: 0,
                    indicatorPrefix: 'KES. ',
                    selectedIndicator: selectedIndicator.value,
                    onIndicatorTap: onIndicatorTap,
                    // hideIndicators: true,
                    pieColors: defaultChartColors.reversed
                        .toList()
                        .sublist(0, chartData[currentChartIdx].length),
                  ),
                ),
              ),
              chartScaffold(
                chartWidget:
                    //
                    Obx(
                  () => SistchPieDonutChart(
                    chartTitle: "Half Arc Chart",
                    isHalfArcChart: true,
                    chartDirection: Axis.horizontal,
                    sectionsSpace: 0,
                    dataSeries: chartData[currentChartIdx],
                    pieLabels: chartLabels[currentChartIdx],
                    centerWidget: const Text('Ola'),
                    selectedIndicator: selectedIndicator.value,
                    onIndicatorTap: onIndicatorTap,
                  ),
                ),
              ),
              chartScaffold(
                chartWidget: Obx(
                  () => Column(
                    children: [
                      SistchLinearPercentChart(
                        chartTitle: "Linear Percent Chart",
                        dataSeries: chartData[currentChartIdx],
                        chartLabels: chartLabels[currentChartIdx],
                        selectedTile: selectedTile.value,
                        onChartTileTap: onLinearPercChartTileTap,
                        // tileHeight: 50.0,
                        // selectedColor: theme.colorScheme.primaryContainer,
                        leadingWidgets: defaultIconMapper.values
                            .toList()
                            .sublist(0, chartData[currentChartIdx].length)
                            .map((e) => Icon(e))
                            .toList(),
                        // trailingWidgets: chartData[currentChartIdx]
                        //     .map((e) => Text('KES. ${e.toString()}'))
                        //     .toList(),
                      ),
                      const SizedBox(height: 4),
                      Text('Selected: ${selectedTile.value}'),
                    ],
                  ),
                ),
              ),
              chartScaffold(
                chartWidget:
                    //
                    const
                    //
                    Padding(
                  padding: EdgeInsets.all(5),
                  child: SistchTimeLapseChart(
                    chartTitle: "Time Lapse Chart",
                    dataSeries: [
                      1000,
                      60000,
                      400000,
                      30000,
                      1000000,
                      2000,
                      80000
                    ],
                    timeLabels: [
                      '03AM - 06AM',
                      '06AM - 09AM',
                      '09AM - 12PM',
                      '12PM - 03PM',
                      '03PM - 06PM',
                      '06PM - 09PM',
                      '09PM - 12AM'
                    ],
                    // dataSeries: chartData[currentChartIdx],
                    // timeLabels: chartLabels[currentChartIdx],
                    prefix: 'KES. ',
                    useSunColors: true,
                  ),
                ),
              ),
              chartScaffold(
                chartWidget: SistchDuoBlockChart(
                  chartTitle: 'Two Block Chart',
                  values: chartData[currentChartIdx].sublist(0, 2),
                  labels: chartLabels[currentChartIdx].sublist(0, 2),
                  valuePrefix: 'KES.',
                ),
              ),
              chartScaffold(
                chartWidget: Obx(
                  () => Column(
                    children: [
                      SistchStackedDonutChart(
                        chartTitle: "Actionable Indicators",
                        dataSeries: chartData[currentChartIdx],
                        chartLabels: chartLabels[currentChartIdx],
                        useIndIcons: true,
                        centerWidget: const Text("Ola!"),
                        selectedIndicator: selectedIndicator.value,
                        onIndicatorTap: onIndicatorTap,
                      ),
                      const SizedBox(height: 4),
                      Text('Selected: ${selectedIndicator.value}'),
                    ],
                  ),
                ),
              ),
              chartScaffold(
                chartWidget: Obx(
                  () => Column(
                    children: [
                      SistchCardGridView(
                        chartTitle: "Card Grid Chart",
                        valuePrefix: 'KES.',
                        dataSeries: chartData[currentChartIdx],
                        chartLabels: chartLabels[currentChartIdx],
                        cardIcons: defaultIconMapper.values
                            .toList()
                            .sublist(0, chartData[currentChartIdx].length),
                        onCardTap: onIndicatorTap,
                        // showPercentages: false,
                      ),
                      const SizedBox(height: 4),
                      Text('Selected: ${selectedIndicator.value}'),
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
