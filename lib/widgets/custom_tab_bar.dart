import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SistchTabBarScaffold extends StatefulWidget {
  final List<Widget> tabWidgets;
  final List<String> tabLabels;
  final List<IconData>? tabIcons;
  final double? height;
  final Function(int? val)? onIndexChange;
  final bool isScrollable;
  final bool useWantKeepAlive;
  final int startTabIdx;
  final bool showUnViewedIndicator;

  const SistchTabBarScaffold({
    super.key,
    required this.tabWidgets,
    required this.tabLabels,
    this.tabIcons,
    this.height,
    this.onIndexChange,
    this.isScrollable = true,
    this.useWantKeepAlive = true,
    this.showUnViewedIndicator = true,
    this.startTabIdx = 0,
  });

  @override
  State<SistchTabBarScaffold> createState() => _SistchTabBarScaffoldState();
}

class _SistchTabBarScaffoldState extends State<SistchTabBarScaffold>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<SistchTabBarScaffold> {
  late TabController tabController;
  RxList<bool> viewedTabs = RxList([]);

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: widget.tabLabels.length,
      initialIndex: widget.startTabIdx,
    );

    // set viewed notification dots
    viewedTabs.value = List.generate(
      widget.tabWidgets.length,
      (i) => widget.showUnViewedIndicator ? false : true,
    );
    updateViewedTabs(widget.startTabIdx);
  }

  onTabIndexChange(int? val) {
    if (val != null) {
      updateViewedTabs(val);
      if (widget.onIndexChange != null) widget.onIndexChange!(val);
    }
  }

  updateViewedTabs(int idx) {
    if (idx >= 0 && idx < viewedTabs.length) {
      viewedTabs[idx] = true;
    }
  }

  @override
  void didUpdateWidget(SistchTabBarScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("777 :::::::: Running didUpdateWidget on SistchTabBarScaffold");

    if (widget.tabWidgets.length != oldWidget.tabWidgets.length ||
        widget.tabLabels.length != oldWidget.tabLabels.length) {
      tabController.dispose();
      tabController = TabController(
        vsync: this,
        length: widget.tabLabels.length,
        initialIndex: widget.startTabIdx,
      );

      viewedTabs.value = List.generate(
        widget.tabWidgets.length,
        (i) => widget.showUnViewedIndicator ? false : true,
      );
      updateViewedTabs(tabController.index);
    }
  }

  @override
  bool get wantKeepAlive => widget.useWantKeepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: widget.height ?? MediaQuery.sizeOf(context).height * 0.9,
      child: SafeArea(
        child: CustomScrollView(
          shrinkWrap: widget.isScrollable ? false : true,
          physics:
              widget.isScrollable ? null : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Obx(
                () => TabBar(
                  controller: tabController,
                  onTap: onTabIndexChange,
                  dividerColor: Theme.of(context).colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                  tabs: widget.tabLabels.asMap().entries.map((entry) {
                    int index = entry.key;
                    String label = entry.value;

                    return Tab(
                      icon: (widget.tabIcons != null &&
                              widget.tabIcons!.isNotEmpty &&
                              widget.tabIcons!.length ==
                                  widget.tabLabels.length)
                          ? Icon(widget.tabIcons![index])
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label),
                          if (!viewedTabs[index])
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(left: 5.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
