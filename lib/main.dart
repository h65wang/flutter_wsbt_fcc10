import 'package:flutter/material.dart';

import 'wang_shu.dart';

import 'answers/alex_grid.dart';
import 'answers/alex_list.dart';
import 'answers/bi_luo.dart';
import 'answers/geng_yu.dart';
import 'answers/meng_ning.dart';
import 'answers/ming_zi.dart';
import 'answers/qmr777.dart';
import 'answers/shirne.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final demos = {
      "shirne": Shirne(),
      "彼洛洛洛": BiLuoDemo(),
      "更与何人说": GengYuDemo(),
      "qmr777": Qmr777App(),
      "名字难想好": MingZiDemo(),
      "AlexV525 - Grid思路": AlexGrid(),
      "檬柠木子": MengNingDemo(),
      "AlexV525 - List思路": AlexList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("FCD 010"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("UP主："),
            ElevatedButton(
              child: Text("王叔的Demo"),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WangShuDemo()),
              ),
            ),
            const SizedBox(height: 24),
            const Text("以下是大家的回复，按时间排序："),
            ...demos.keys.map(
              (key) => ElevatedButton(
                child: Text(key),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => demos[key]!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
