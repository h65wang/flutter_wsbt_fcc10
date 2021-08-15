/// Author: 檬柠木子
/// https://raw.githubusercontent.com/Nomeleel/awesome_flutter/master/lib/widget/gallery_view.dart

import 'package:flutter/material.dart';

class MengNingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("檬柠木子"),
      ),
      body: GalleryView.builder(
        itemCount: 101,
        minPreRow: 1,
        maxPreRow: 10,
        itemBuilder: (_, index) => Container(
          color: Colors.primaries[index % Colors.primaries.length],
          alignment: Alignment.center,
          child: Text("$index"),
        ),
      ),
    );
  }
}

class GalleryView extends StatelessWidget {
  const GalleryView.builder({
    Key? key,
    this.minPreRow = 2,
    this.maxPreRow = 5,
    this.duration = const Duration(milliseconds: 300),
    required this.itemCount,
    required this.itemBuilder,
  }) : super(key: key);

  final int minPreRow;
  final int maxPreRow;
  final Duration duration;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<double> count =
        ValueNotifier<double>(minPreRow.toDouble());
    double startCount = minPreRow.toDouble();
    return Scaffold(
      body: GestureDetector(
        onScaleStart: (e) => startCount = count.value,
        onScaleUpdate: (ScaleUpdateDetails details) {
          count.value = _getValidCount(startCount * (1.0 / details.scale));
        },
        onScaleEnd: (e) {
          count.value = _getValidCount(count.value.roundToDouble());
        },
        child: ValueListenableBuilder(
          valueListenable: count,
          builder: (_, double value, __) {
            final int crossAxisCount = count.value.ceil();
            return Transform.scale(
              scale: (crossAxisCount / count.value).toDouble(),
              alignment: Alignment.topLeft,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount),
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedSwitcher(
                    duration: duration,
                    child: Container(
                      // 位置变化才有淡入淡出动画 否者可以使用UniqueKey
                      key: ValueKey('${index ~/ value}-${index % value}'),
                      child: itemBuilder(context, index),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  double _getValidCount(double a) => a.clamp(minPreRow, maxPreRow).toDouble();
}
