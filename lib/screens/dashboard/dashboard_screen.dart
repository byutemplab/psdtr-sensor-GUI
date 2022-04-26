import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants.dart';
import 'components/header.dart';

// import 'components/recent_files.dart';
import 'components/devices_status.dart';
import 'components/image_viewers.dart';

class DashboardScreen extends StatefulHookWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool mouseOverCard = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: mouseOverCard
            ? NeverScrollableScrollPhysics()
            : AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      ImageViewers(changeScrollableSettings: () {
                        setState(() {
                          mouseOverCard = !mouseOverCard;
                        });
                      }),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) DevicesStatus(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: DevicesStatus(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
