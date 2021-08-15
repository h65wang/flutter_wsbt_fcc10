/// Author: WSBT
/// https://www.bilibili.com/video/BV1Po4y1C7j2

import 'package:flutter/material.dart';

class WangShuDemo extends StatefulWidget {
  @override
  _WangShuDemoState createState() => _WangShuDemoState();
}

class _WangShuDemoState extends State<WangShuDemo> {
  ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FCC 010"),
      ),
      body: Scrollbar(
        controller: _controller,
        child: GalleryView.builder(
          controller: _controller,
          itemCount: 101,
          maxPerRow: 10,
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
  final int? itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final int initialPerRow;
  final int minPerRow;
  final int maxPerRow;

  final Duration duration;
  final ScrollController? controller;

  GalleryView.builder({
    Key? key,
    this.itemCount,
    required this.itemBuilder,
    this.initialPerRow = 3,
    this.minPerRow = 1,
    this.maxPerRow = 7,
    this.duration = const Duration(seconds: 1),
    this.controller,
  }) : super(key: key);

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late ScrollController _controller = widget.controller ?? ScrollController();

  double _maxWidth = 0.0;

  late double _size; // size of each grid item
  late double _prevSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth != _maxWidth) {
          _maxWidth = constraints.maxWidth;
          _size = _maxWidth / widget.initialPerRow;
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            _snapToGrid();
          });
        }
        return GestureDetector(
          child: _buildListView(),
          onScaleStart: (_) {
            _controller.jumpTo(0);
            _prevSize = _size;
          },
          onScaleUpdate: (details) {
            final maxSize = _maxWidth / widget.minPerRow;
            final minSize = _maxWidth / widget.maxPerRow;
            setState(() {
              _size = (_prevSize * details.scale).clamp(minSize, maxSize);
            });
          },
          onScaleEnd: (_) => _snapToGrid(),
        );
      },
    );
  }

  _snapToGrid() {
    final countPerRow = (_maxWidth / _size).round().clamp(
          widget.minPerRow,
          widget.maxPerRow,
        );
    setState(() => _size = _maxWidth / countPerRow);
  }

  ListView _buildListView() {
    final countPerRow = (_maxWidth / _size).ceil();

    return ListView.builder(
      controller: _controller,
      itemExtent: _size,
      itemCount: widget.itemCount != null
          ? (widget.itemCount! / countPerRow).ceil()
          : null,
      itemBuilder: (context, int i) {
        return OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              for (int j = 0; j < countPerRow; j++)
                if (widget.itemCount == null ||
                    i * countPerRow + j < widget.itemCount!)
                  _buildItem(context, i * countPerRow + j),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(context, int index) {
    return SizedBox(
      width: _size,
      height: _size,
      child: AnimatedSwitcher(
        duration: widget.duration,
        child: KeyedSubtree(
          key: ValueKey(index),
          child: widget.itemBuilder(context, index),
        ),
      ),
    );
  }
}
