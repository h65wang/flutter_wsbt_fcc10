///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/7/9 10:24
///
/// https://raw.githubusercontent.com/AlexV525/flutter_test_app/master/lib/pages/test_animated_scalable_grid_view_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AlexList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TestAnimatedScalableGridViewPage();
  }
}

class TestAnimatedScalableGridViewPage extends StatefulWidget {
  const TestAnimatedScalableGridViewPage({Key? key}) : super(key: key);

  @override
  _TestAnimatedScalableGridViewPageState createState() =>
      _TestAnimatedScalableGridViewPageState();
}

class _TestAnimatedScalableGridViewPageState
    extends State<TestAnimatedScalableGridViewPage>
    with SingleTickerProviderStateMixin {
  static const List<Color> colors = Colors.primaries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZoomableGrid Demo')),
      body: ZoomableGrid.builder(
        itemCount: 202,
        initialCrossAxisCount: 4,
        minCrossAxisCount: 1,
        maxCrossAxisCount: 10,
        itemBuilder: (BuildContext c, int index) {
          return Container(
            alignment: Alignment.center,
            color: colors[index % colors.length],
            child: Text(index.toString()),
          );
        },
      ),
    );
  }
}

class ZoomableGrid extends StatefulWidget {
  const ZoomableGrid({
    Key? key,
    required this.children,
    this.initialCrossAxisCount = 6,
    this.minCrossAxisCount = 4,
    this.maxCrossAxisCount = 12,
    this.duration = const Duration(milliseconds: 300),
    this.controller,
  })  : itemCount = null,
        itemBuilder = null,
        super(key: key);

  const ZoomableGrid.builder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialCrossAxisCount = 6,
    this.minCrossAxisCount = 4,
    this.maxCrossAxisCount = 12,
    this.duration = const Duration(milliseconds: 300),
    this.controller,
  })  : children = null,
        super(key: key);

  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final List<Widget>? children;

  final int initialCrossAxisCount;
  final int minCrossAxisCount;
  final int maxCrossAxisCount;

  final Duration duration;
  final ScrollController? controller;

  @override
  _ZoomableGridState createState() => _ZoomableGridState();
}

class _ZoomableGridState extends State<ZoomableGrid>
    with SingleTickerProviderStateMixin {
  double _maxWidth = 0;
  late ScrollController _controller = widget.controller ?? ScrollController();
  late double _prevSize;
  late Size _maxItemSize, _minItemSize;

  late final AnimationController _size =
      AnimationController.unbounded(vsync: this);

  @override
  void didUpdateWidget(ZoomableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ??
          ScrollController(
            initialScrollOffset: oldWidget.controller?.offset ?? 0,
          );
      _scheduleToSetState();
      return;
    }
    if (widget.maxCrossAxisCount != oldWidget.maxCrossAxisCount ||
        widget.minCrossAxisCount != oldWidget.minCrossAxisCount) {
      _maxItemSize = Size.square(_maxWidth / widget.minCrossAxisCount);
      _minItemSize = Size.square(_maxWidth / widget.maxCrossAxisCount);
      _snapToGrid();
      _scheduleToSetState();
      return;
    }
  }

  @override
  void dispose() {
    _size.dispose();
    super.dispose();
  }

  void _scheduleToSetState() {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final double newSize = (_prevSize * details.scale).clamp(
      _minItemSize.width,
      _maxItemSize.width,
    );
    print(details.localFocalPoint);
    _controller.jumpTo(
      _calculateOffset(newSize, localOffsetY: details.localFocalPoint.dy),
    );
    _size.value = newSize;
  }

  void _snapToGrid() {
    final int countPerRow = (_maxWidth / _size.value)
        .round()
        .clamp(widget.minCrossAxisCount, widget.maxCrossAxisCount);
    final double newSize = _maxWidth / countPerRow;
    _controller.animateTo(
      _calculateOffset(newSize),
      curve: Curves.ease,
      duration: kThemeChangeDuration,
    );
    _size
        .animateTo(
          newSize,
          curve: Curves.ease,
          duration: kThemeChangeDuration,
        )
        .then((_) => _size.stop());
  }

  double _calculateOffset(double size, {double localOffsetY = 0}) {
    return _controller.offset +
        (_controller.offset + localOffsetY) /
            _size.value *
            (size - _size.value);
  }

  SliverChildDelegate _getDelegate(double size) {
    final int countPerRow = (_maxWidth / size).ceil();
    if (widget.children != null) {
      return SliverChildListDelegate(widget.children!);
    }
    return SliverChildBuilderDelegate(
      (BuildContext c, int i) {
        return OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Row(
            children: <Widget>[
              for (int j = 0; j < countPerRow; j++)
                if (i * countPerRow + j < widget.itemCount!)
                  _buildItem(c, i * countPerRow + j),
            ],
          ),
        );
      },
      childCount: (widget.itemCount! / countPerRow).ceil(),
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder<double>(
      valueListenable: _size,
      builder: (_, double size, __) => ListView.custom(
        controller: _controller,
        itemExtent: size,
        physics: const AlwaysScrollableScrollPhysics(),
        childrenDelegate: _getDelegate(size),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return ValueListenableBuilder<double>(
      valueListenable: _size,
      builder: (_, double size, __) => SizedBox.fromSize(
        size: Size.square(size),
        child: AnimatedSwitcher(
          duration: widget.duration,
          child: SizedBox.expand(
            key: ValueKey<int>(index),
            child: widget.itemBuilder!(context, index),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth != _maxWidth) {
          _maxWidth = constraints.maxWidth;
          _size.value = _maxWidth / widget.initialCrossAxisCount;
          _maxItemSize = Size.square(_maxWidth / widget.minCrossAxisCount);
          _minItemSize = Size.square(_maxWidth / widget.maxCrossAxisCount);
          SchedulerBinding.instance!.addPostFrameCallback((_) {
            _snapToGrid();
          });
        }
        return GestureDetector(
          onScaleStart: (_) => _prevSize = _size.value,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: (_) => _snapToGrid(),
          child: _buildListView(),
        );
      },
    );
  }
}
