/// Author: qmr777
/// https://dartpad.dev/?id=58ed597176d8959c33b3a9ec78956683&null_safety=true

import 'package:flutter/material.dart';

class Qmr777App extends StatelessWidget {
  const Qmr777App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('qmr777 Demo')),
      body: GalleryView(
        itemCount: 100,
        duration: Duration(seconds: 1),
        builder: (context, index) {
          Color color = Colors.primaries[index % 18];
          return Container(
            color: color,
            alignment: AlignmentDirectional.center,
            child: Text("$index"),
          );
        },
      ),
    );
  }
}

class GalleryView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final Duration duration;
  final int minColumnCount;
  final int maxColumnCount;
  final int defaultColumnCount;

  const GalleryView({
    Key? key,
    required this.itemCount,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.minColumnCount = 1,
    this.maxColumnCount = 10,
  })  : assert(minColumnCount > 0),
        assert(maxColumnCount > minColumnCount),
        defaultColumnCount = (minColumnCount + maxColumnCount) ~/ 2,
        super(key: key);

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late int _currentColumnCount;
  late int _tmpColumnCount;
  late int _prevColumnCount;

  int _modifyCount = 0;
  double _scaleRatio = 1;
  double _interpolation = 1;

  @override
  void initState() {
    super.initState();
    _currentColumnCount = widget.defaultColumnCount;
    _prevColumnCount = _currentColumnCount;
    _tmpColumnCount = _currentColumnCount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        if ((details.scale < 1 &&
                _currentColumnCount >= widget.maxColumnCount) ||
            (details.scale > 1 && _currentColumnCount <= widget.minColumnCount))
          return;
        if (details.scale != _scaleRatio) {
          int _cc = _calcColumnCount(_scaleRatio);
          setState(() {
            _scaleRatio = details.scale;
            if (_currentColumnCount != _cc) {
              _modifyCount++;
              _interpolation *= _cc / _currentColumnCount;
              _tmpColumnCount = _currentColumnCount;
              _currentColumnCount = _cc;
            }
          });
        }
      },
      onScaleEnd: (details) {
        setState(() {
          _interpolation = 1;
          _scaleRatio = 1;
          _prevColumnCount = _currentColumnCount;
        });
      },
      child: Transform(
        alignment: Alignment.topLeft,
        transform:
            Transform.scale(scale: _scaleRatio * _interpolation).transform,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _currentColumnCount),
            itemCount: widget.itemCount,
            //如果不需要动画的话 直接返回widget.builder就可以了
            itemBuilder: (context, index) {
              int column = index % _currentColumnCount;
              int row = index ~/ _currentColumnCount;
              int prevIndex = row * _tmpColumnCount + column;
              Widget _old =
                  column > _currentColumnCount || prevIndex >= widget.itemCount
                      ? Container()
                      : widget.builder(context, prevIndex);
              Widget _new = widget.builder(context, index);
              double _begin = prevIndex == index ? 1 : 0;
              return TweenAnimationBuilder<double>(
                  key: ValueKey(_modifyCount),
                  tween: Tween<double>(begin: _begin, end: 1),
                  duration: widget.duration,
                  builder: (context, value, _) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(opacity: value, child: _new),
                        Opacity(opacity: 1 - value, child: _old),
                      ],
                    );
                  });
            }),
      ),
    );
  }

  int _calcColumnCount(double scaleRatio) {
    return (_prevColumnCount / _scaleRatio + 0.99)
        .toInt()
        .clamp(widget.minColumnCount, widget.maxColumnCount);
  }
}
