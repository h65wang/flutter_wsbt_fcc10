/// Author: 名字难想好
/// https://github.com/zgm1992/flutterDemo/blob/main/lib/main_2.dart

import 'package:flutter/material.dart';

class MingZiDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("名字难想好 Demo"),
      ),
      body: Center(
        child: MyGridWidget(
          minCount: 1,
          maxCount: 10,
          showCount: 5,
        ),
      ),
    );
  }
}

class MyGridWidget extends StatefulWidget {
  final int minCount;
  final int maxCount;
  final int showCount;
  final Duration duration;

  MyGridWidget({
    Key? key,
    this.minCount = 1,
    this.duration = const Duration(seconds: 2),
    this.maxCount = 8,
    this.showCount = 5,
  }) : super(key: key);

  @override
  _MyGridWidgetState createState() => _MyGridWidgetState();
}

class _MyGridWidgetState extends State<MyGridWidget> {
  double scale = 1.0;

  late int showCount;

  @override
  void initState() {
    super.initState();
    showCount = widget.showCount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        // print("手势倍数量： ${details.scale}");
        setState(() {
          scale = details.scale;
          // if (showCount.toDouble() * scale == widget.maxCount.toDouble()) {
          //   print(
          //       "超出边界了 showCount.toDouble() * scale is ${showCount.toDouble() * scale}  widget.maxCount.toDouble() is ${widget.maxCount.toDouble()} ");
          //   scale = 1.0;
          // }
        });
      },
      onScaleEnd: (ScaleEndDetails details) {
        setState(() {
          showCount = showCount ~/ scale;

          if (showCount < widget.minCount) {
            showCount = widget.minCount;
          } else if (showCount >= widget.maxCount) {
            showCount = widget.maxCount;
          }

          scale = 1.0;
        });
      },
      child: Transform.scale(
        alignment: Alignment.topLeft,
        scale: (widget.maxCount.toDouble() / showCount.toDouble()) * scale,
        child: AnimatedSwitcher(
          duration: widget.duration,
          child: GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.maxCount),
            itemBuilder: (BuildContext context, int index) {
              int rowCount = index % widget.maxCount;

              var itemIndex =
                  ((index ~/ widget.maxCount) * showCount).toInt() + rowCount;
              // print(
              //     "index is $index  rowcount is ： ${rowCount}  (index / widget.maxCount) * showCount) is ${index ~/ widget.maxCount * showCount}");
              return AnimatedSwitcher(
                duration: widget.duration,
                child: rowCount > showCount
                    ? Container() // 屏幕外的内容
                    : Container(
                        key: ValueKey(itemIndex),
                        color: Colors
                            .primaries[itemIndex % Colors.primaries.length],
                        child: Center(child: Text("$itemIndex")),
                      ),
              );
              // return rowCount > showCount
              //     ? Container() // 屏幕外的内容
              //     : Container(
              //         key: ValueKey(itemIndex),
              //         color:
              //             Colors.primaries[itemIndex % Colors.primaries.length],
              //         child: Center(child: Text("$itemIndex")),
              //       );
            },
          ),
        ),
      ),
    );
  }
}
