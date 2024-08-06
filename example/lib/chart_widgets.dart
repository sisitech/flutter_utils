import 'package:flutter/material.dart';
import 'package:flutter_utils/charts/bar_chart_beta/bar_chart_beta.dart';
import 'package:flutter_utils/charts/stacked_donut_chart.dart';
import 'package:flutter_utils/charts/bar_chart/bar_chart.dart';
import 'package:flutter_utils/charts/pie_donut_chart/pie_donut_chart.dart';
import 'package:flutter_utils/charts/linear_percent_chart.dart';

class ChartWidgetsScreen extends StatefulWidget {
  final routeName = "/chart-widgets";
  const ChartWidgetsScreen({super.key});

  @override
  State<ChartWidgetsScreen> createState() => _ChartWidgetsScreenState();
}

class _ChartWidgetsScreenState extends State<ChartWidgetsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Widgets'),
        automaticallyImplyLeading: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchStackedDonutChart(
                  chartTitle: "Stacked Donut Chart Widget",
                  dataSeries: [90, 40, 80, 30, 20],
                  dtLabels: ["One", "Two", "Three", "Four", "Five"],
                  useIndIcons: true,
                  centerWidget: Text("Ola!"),
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchBarChartBeta(
                  chartTitle: "Bar Chart Double Series",
                  dataSeries: [
                    [20, 30, 50, 60],
                    [40, 60, 70, 10],
                  ],
                  seriesLabels: ["Expenses", "Income"],
                  xAxisLabels: ["One", "Two", "Three", "Four"],
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchPieDonutChart(
                  chartTitle: "Donut Chart",
                  dataSeries: [50, 60, 70, 80],
                  pieLabels: ["One", "Two", "Three", "Four"],
                  donutCenterRadius: 20,
                  chartDirection: Axis.horizontal,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchPieDonutChart(
                  chartTitle: "Pie Chart",
                  dataSeries: [50, 60, 70, 80],
                  pieLabels: ["One", "Two", "Three", "Four"],
                  donutCenterRadius: 0,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchPieDonutChart(
                  chartTitle: "Pie Chart",
                  dataSeries: [50, 60, 70],
                  pieLabels: ["Household", "Shopping", "Tech"],
                  useIndIcons: true,
                  donutCenterRadius: 0,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SistchLinearPercentChart(
                  chartTitle: "Linear Percent Chart",
                  dataSeries: [50, 60, 70, 80, 200],
                  chartLabels: ["One", "Two", "Three", "Four", "Five"],
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
