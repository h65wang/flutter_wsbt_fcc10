/// Author: 彼洛洛洛
/// https://github.com/a479304861/FlutterDemo/blob/main/GalleryViewDemo.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BiLuoDemo extends StatefulWidget {
  @override
  _BiLuoDemoState createState() => _BiLuoDemoState();
}

class _BiLuoDemoState extends State<BiLuoDemo> {
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("彼洛洛洛 Demo"),
      ),
      body: Scrollbar(
        controller: _controller,
        child: GalleryView.builder(
          controller: _controller,
          itemCount: 101,
          minPerRow: 1,
          maxPerRow: 10,
          duration: Duration(milliseconds: 500),
          itemBuilder: (_, index) => Container(
            color: Colors.primaries[index % Colors.primaries.length],
            alignment: Alignment.center,
            child: Text("$index"),
          ),
        ),
      ),
    );
  }
}

class GalleryView extends StatefulWidget {
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final int itemCount;
  final int minPerRow;
  final int maxPerRow;
  final Duration? duration;

  GalleryView.builder({
    required this.itemBuilder,
    this.controller,
    required this.itemCount,
    this.minPerRow = 1,
    this.maxPerRow = 7,
    this.duration,
  });

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  double _scale = 1;
  double _lateScale = 1;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var maxWidth = screenWidth / this.widget.maxPerRow;
    var minWidth = screenWidth / this.widget.minPerRow;
    var nowWidth = maxWidth * (_scale);
    var count = screenWidth / nowWidth; //每行多少个
    var countCeil = count.ceil(); //取整
    nowWidth = screenWidth / countCeil;
    if (nowWidth > minWidth) {
      _scale = minWidth / maxWidth;
      nowWidth = minWidth;
    }
    // print('$_tempScale    $nowWidth     $_scale');
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
        setState(() {
          if (scaleUpdateDetails.scale == 1) {
            _lateScale = 1;
          }
          _scale = _scale * (1 + scaleUpdateDetails.scale - _lateScale);
          _lateScale = scaleUpdateDetails.scale;
        });
        if (_scale <= 1) _scale = 1;
      },
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: nowWidth),
          itemCount: this.widget.itemCount,
          itemBuilder: (ctx, index) {
            return OpacityContainer(
              widget: this.widget.itemBuilder(ctx, index),
              duration: this.widget.duration == null
                  ? Duration(seconds: 1)
                  : this.widget.duration!,
            );
          }),
    );
  }
}

class OpacityContainer extends StatefulWidget {
  final Widget widget;
  final Duration duration;

  OpacityContainer({required this.widget, required this.duration});

  @override
  _OpacityContainerState createState() => _OpacityContainerState();
}

class _OpacityContainerState extends State<OpacityContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: this.widget.duration);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _controller.value,
      child: this.widget.widget,
    );
  }
}
