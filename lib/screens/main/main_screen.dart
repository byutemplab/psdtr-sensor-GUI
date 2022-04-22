import 'package:admin/controllers/MenuController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/trajectories_viewer/trajectories_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedPage = "Dashboard";

  void changePage(String selectedPage) {
    setState(() {
      _selectedPage = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldKey,
      drawer: SideMenu(changePage: changePage),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(changePage: changePage),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: _selectedPage == "Dashboard"
                  ? DashboardScreen()
                  : TrajectoriesViewerScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
