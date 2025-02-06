import 'package:flutter/material.dart';
import 'package:flutter_utils/svg_widget/svg_widget.dart';

class SvgWidgetDemo extends StatefulWidget {
  static const routeName = "/svg-demo";

  const SvgWidgetDemo({super.key});

  @override
  State<SvgWidgetDemo> createState() => _SvgWidgetDemoState();
}

class _SvgWidgetDemoState extends State<SvgWidgetDemo> {
  int currentIndex = 0;
  List<String> svgPaths = [
    'assets/svgs/chama.svg',
    'assets/svgs/expenses.svg',
    'assets/svgs/import.svg',
    'assets/svgs/literacy.svg',
    'assets/svgs/notifications.svg',
    'assets/svgs/privacy.svg',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Widget Demo'),
        automaticallyImplyLeading: true,
      ),
      body: PageView.builder(
        itemCount: svgPaths.length,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: SistchSvgWidget(
                    // useThemeColors: false,
                    svgPath: svgPaths[index],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      svgPaths.length, (index) => buildDot(index, context)),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: currentIndex == index
            ? Theme.of(context).indicatorColor
            : Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
