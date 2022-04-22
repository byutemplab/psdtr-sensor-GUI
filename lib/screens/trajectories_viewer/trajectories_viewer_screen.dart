import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants.dart';
import 'components/header.dart';

// import 'components/recent_files.dart';

class TrajectoriesViewerScreen extends StatefulHookWidget {
  @override
  _TrajectoriesViewerScreenState createState() =>
      _TrajectoriesViewerScreenState();
}

class _TrajectoriesViewerScreenState extends State<TrajectoriesViewerScreen> {
  bool mouseOverCard = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: mouseOverCard
            ? NeverScrollableScrollPhysics()
            : AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding),
        child: Column(children: [
          Header(),
          SizedBox(height: defaultPadding),
        ]),
      ),
    );
  }
}
