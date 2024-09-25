import 'package:flutter/material.dart';

class SistchTabBarScaffold extends StatefulWidget {
  final List<Widget> tabWidgets;
  final List<String> tabLabels;
  final List<IconData>? tabIcons;
  final double? height;
  final Function(int? val)? onIndexChange;
  final bool isScrollable;

  const SistchTabBarScaffold({
    super.key,
    required this.tabWidgets,
    required this.tabLabels,
    this.tabIcons,
    this.height,
    this.onIndexChange,
    this.isScrollable = true,
  });

  @override
  State<SistchTabBarScaffold> createState() => _SistchTabBarScaffoldState();
}

class _SistchTabBarScaffoldState extends State<SistchTabBarScaffold>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: widget.tabLabels.length);
  }

  onTabIndexChange(int? val) {
    if (widget.onIndexChange != null) {
      widget.onIndexChange!(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? MediaQuery.sizeOf(context).height * 0.9,
      child: SafeArea(
        child: CustomScrollView(
          shrinkWrap: widget.isScrollable ? false : true,
          physics:
              widget.isScrollable ? null : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: TabBar(
                controller: tabController,
                onTap: onTabIndexChange,
                dividerColor: Theme.of(context).colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                tabs: widget.tabLabels.asMap().entries.map((entry) {
                  int index = entry.key;
                  String label = entry.value;
                  return Tab(
                    text: label,
                    icon: (widget.tabIcons != null &&
                            widget.tabIcons!.isNotEmpty &&
                            widget.tabIcons!.length == widget.tabLabels.length)
                        ? Icon(widget.tabIcons![index])
                        : null,
                  );
                }).toList(),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: tabController,
                children: widget.tabWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
