/// Author: 更与何人说
/// https://github.com/xialisuper/gird_view_test.git

import 'package:flutter/material.dart';

class GengYuDemo extends StatelessWidget {
  const GengYuDemo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更与何人说 Demo'),
      ),
      body: MyGridView(maxCrossAxisCount: 10, minCrossAxisCount: 1),
    );
  }
}

class MyGridView extends StatefulWidget {
  MyGridView({
    Key? key,
    required this.maxCrossAxisCount,
    required this.minCrossAxisCount,
  }) : super(key: key);

  final int maxCrossAxisCount;
  final int minCrossAxisCount;

  @override
  _MyGridViewState createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView>
    with SingleTickerProviderStateMixin {
  int _currentAxisCount = 5;
  int _tempCount = 5;
  double _currentGestureScale = 1;

  bool _isScaleEnd = false;
  late Animation<double> _animation;
  late AnimationController _controller;
  late Tween<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _tween = Tween(begin: null, end: 1);
    _animation = _tween.animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        if (details.pointerCount != 2) {
          return;
        }
        _currentGestureScale = details.scale;
        setState(() {
          _currentAxisCount = _handleScaleUpdate(details);
        });
      },
      onScaleStart: (details) {
        _isScaleEnd = false;
        _tempCount = _currentAxisCount;
      },
      onScaleEnd: (details) {
        _tempCount = _currentAxisCount;
        //根据当前progress进行动画
        setState(() {
          _isScaleEnd = true;
        });
        _controller.forward();
      },
      child: Transform(
        origin: Offset(0, 0),
        transform: Matrix4.identity()..scale(_handleGridViewScale()),
        // transform: Matrix4.identity()..scale(1 / 1),

        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _currentAxisCount,
          ),
          itemCount: 300,
          itemBuilder: (context, index) {
            return MyGridItem(
              index: index,
            );
          },
        ),
      ),
    );
  }

  //计算gridview 缩放
  double _handleGridViewScale() {
    if (_isScaleEnd) {
      _tween.begin = _currentScale();
      return _animation.value;
    }
    return _currentScale();
  }

  double _currentScale() {
    return _currentAxisCount /
        (_tempCount / _currentGestureScale)
            .clamp(widget.minCrossAxisCount, widget.maxCrossAxisCount);
  }

  //计算当前行item个数
  int _handleScaleUpdate(ScaleUpdateDetails details) {
    final res = (_tempCount ~/ details.scale + 1)
        .clamp(widget.minCrossAxisCount, widget.maxCrossAxisCount);

    return res;
  }
}

class MyGridItem extends StatelessWidget {
  const MyGridItem({
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      child: Center(child: Text('$index')),
      color: Colors.primaries[index % 18],
    );
  }
}
