///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021/7/8 12:45
///
/// https://raw.githubusercontent.com/AlexV525/flutter_test_app/master/lib/pages/test_gallery_view_page.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AlexGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TestScalableGridViewPage();
  }
}

class TestScalableGridViewPage extends StatefulWidget {
  const TestScalableGridViewPage({Key? key}) : super(key: key);

  @override
  _TestScalableGridViewPageState createState() =>
      _TestScalableGridViewPageState();
}

class _TestScalableGridViewPageState extends State<TestScalableGridViewPage>
    with SingleTickerProviderStateMixin {
  static const List<Color> colors = Colors.primaries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScalableGridView Demo')),
      body: ScalableGridView.builder(
        minCrossAxisCount: 1,
        maxCrossAxisCount: 10,
        initialScale: ScalableGridViewInitialScale.min,
        itemCount: 202,
        itemBuilder: (BuildContext context, int index) {
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

/// Determine how does the grid view initialize the scale.
enum ScalableGridViewInitialScale { min, max }

/// A [GridView] that support scale based on
/// [maxCrossAxisCount] and [minCrossAxisCount].
/// 支持以 [maxCrossAxisCount] 和 [minCrossAxisCount] 为基础的可缩放的 [GridView]。
class ScalableGridView extends StatefulWidget {
  ScalableGridView({
    Key? key,
    List<Widget> children = const <Widget>[],
    this.minCrossAxisCount = 4,
    this.maxCrossAxisCount = 12,
    this.childAspectRatio = 1.0,
    this.initialScale = ScalableGridViewInitialScale.max,
  })  : childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  ScalableGridView.builder({
    Key? key,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.minCrossAxisCount = 4,
    this.maxCrossAxisCount = 12,
    this.childAspectRatio = 1.0,
    this.initialScale = ScalableGridViewInitialScale.max,
  })  : childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
        ),
        super(key: key);

  final int minCrossAxisCount;
  final int maxCrossAxisCount;
  final double childAspectRatio;
  final SliverChildDelegate childrenDelegate;
  final ScalableGridViewInitialScale initialScale;

  @override
  _ScalableGridViewState createState() => _ScalableGridViewState();
}

class _ScalableGridViewState extends State<ScalableGridView>
    with SingleTickerProviderStateMixin {
  int get minCrossAxisCount => widget.minCrossAxisCount;

  int get maxCrossAxisCount => widget.maxCrossAxisCount;

  late final AnimationController _scale = AnimationController.unbounded(
    value: widget.initialScale == ScalableGridViewInitialScale.max
        ? _maximumScale
        : 1,
    vsync: this,
  );
  late double _maxWidth;
  late double _maximumScale;
  late double _itemSize;
  double _lastScale = 1;

  @override
  void didUpdateWidget(ScalableGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.maxCrossAxisCount != oldWidget.maxCrossAxisCount ||
        widget.minCrossAxisCount != oldWidget.minCrossAxisCount) {
      // Aligned the grid when configurations of count have changed.
      // 当网格数量配置变化时，让网格重新对齐。
      _handleGridSelfAlign();
    }
  }

  @override
  void dispose() {
    _scale
      ..stop()
      ..dispose();
    super.dispose();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final double _delta = details.scale - _lastScale;
    // Don't handle invalid value.
    // 不要处理无效的值。
    if (_delta == 0) {
      return;
    }
    // Skip update if the scale value has already reached the limit and the new
    // scale value is going to cross the limit.
    // 当缩放值已经处于边界，而新的值想要超越边界时，忽略更新。
    if ((_scale.value == 1 && _delta < 0) ||
        (_scale.value == _maximumScale && _delta > 0)) {
      return;
    }
    // If the next scale is going to exceed to limit, set the scale to the lower
    // bound directly.
    // 如果下一次的值将小于下限，直接设置为下限。
    if (_delta < 0 && _scale.value + _delta < 1) {
      _scale.value = 1;
      _lastScale = details.scale;
      return;
    }
    // Similar to above.
    // 与上步同理。
    if (_delta > 0 && _scale.value + _delta > _maximumScale) {
      _scale.value = _maximumScale;
      _lastScale = details.scale;
      return;
    }
    _scale.value += _delta;
    _lastScale = details.scale;
  }

  /// Aligning to the rounded count.
  /// 四舍五入对齐
  void _handleGridSelfAlign() {
    final double currentColumnCount = _maxWidth / _itemSize / _scale.value;
    final double targetColumnCount = currentColumnCount.roundToDouble();
    final double targetScale = _maxWidth / targetColumnCount / _itemSize;
    _scale
        .animateTo(
          targetScale,
          curve: Curves.ease,
          duration: kThemeChangeDuration,
        )
        .then((_) => _scale.stop());
    _lastScale = 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _maxWidth = constraints.maxWidth;
        _itemSize = _maxWidth / maxCrossAxisCount;
        _maximumScale = _maxWidth / minCrossAxisCount / _itemSize;
        return GestureDetector(
          onScaleStart: (_) => _scale.stop(),
          onScaleEnd: (_) => _handleGridSelfAlign(),
          onScaleUpdate: _handleScaleUpdate,
          child: ValueListenableBuilder<double>(
            valueListenable: _scale,
            builder: (_, double value, __) => GridView.custom(
              gridDelegate: SliverGridDelegateWithScalableExtent(
                scale: (value - 1) / (_maximumScale - 1),
                maxCrossAxisCount: maxCrossAxisCount,
                minCrossAxisCount: minCrossAxisCount,
                childAspectRatio: widget.childAspectRatio,
              ),
              childrenDelegate: widget.childrenDelegate,
            ),
          ),
        );
      },
    );
  }
}

class SliverGridDelegateWithScalableExtent extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that scaling with
  /// [scale] and limited between [maxCrossAxisCount] and [minCrossAxisCount].
  const SliverGridDelegateWithScalableExtent({
    required this.scale,
    required this.maxCrossAxisCount,
    required this.minCrossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  })  : assert(scale >= 0 && scale <= 1),
        assert(maxCrossAxisCount > 0),
        assert(minCrossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(childAspectRatio > 0);

  /// The scale value for the whole grid currently.
  ///
  /// This value should be greater or equal to 0.0 and less or equal to 1.0.
  final double scale;

  /// The maximum cross axis count for the delegate.
  final int maxCrossAxisCount;

  /// The minimum cross axis count for the delegate.
  final int minCrossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The extent of each tile in the main axis. If provided it would define the
  /// logical pixels taken by each tile in the main-axis.
  ///
  /// If null, [childAspectRatio] is used instead.
  final double? mainAxisExtent;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(scale >= 0 && scale <= 1);
    assert(maxCrossAxisCount > 0);
    assert(minCrossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    // Use the magic number in interpolation. In order to keep the precision
    // without extra tiny tail in the number. :-)
    // 在这里使用一个奇妙的数字。用于保证计算结果不会出现长且多余的小数位。
    final double itemSize = ui.lerpDouble(
          constraints.crossAxisExtent / maxCrossAxisCount,
          constraints.crossAxisExtent / minCrossAxisCount,
          scale,
        )! +
        0.000000000000005;
    final int crossAxisCount = (constraints.crossAxisExtent / itemSize).ceil();
    final double crossAxisExtent = itemSize * crossAxisCount;
    final double childCrossAxisExtent = crossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithScalableExtent oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.maxCrossAxisCount != maxCrossAxisCount ||
        oldDelegate.minCrossAxisCount != minCrossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
  }
}
