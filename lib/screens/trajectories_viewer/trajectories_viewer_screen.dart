import 'package:flutter/material.dart';
import 'package:admin/responsive.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:admin/models/trajectories_settings.dart';

import '../../constants.dart';
import 'components/header.dart';
import 'components/trajectories_viewer_card.dart';
import 'components/trajectories_settings_card.dart';
import 'package:context_menus/context_menus.dart';

import 'package:admin/models/streaming_devices.dart';

class TrajectoriesViewerScreen extends StatefulHookWidget {
  @override
  _TrajectoriesViewerScreenState createState() =>
      _TrajectoriesViewerScreenState();
}

class _TrajectoriesViewerScreenState extends State<TrajectoriesViewerScreen> {
  bool mouseOverCard = false;
  TrajectoriesSetting pattern = TrajectoriesSetting();

  @override
  void initState() {
    super.initState();
    fetchTrajectoriesSetting().then((value) {
      setState(() => pattern = value);
    });
  }

  void _updateNumberOfMeasurements(double value) {
    setState(() {
      pattern.numberOfMeasurements = value;
    });
    updateNumberOfMeasurements("Trajectory Setting demo", value);
  }

  void _updateMeasurementTime(double value) {
    setState(() {
      pattern.measurementTime = value;
    });
    updateMeasurementTime("Trajectory Setting demo", value);
  }

  void _updateGreenPointDiameter(double value) {
    setState(() {
      pattern.greenPointDiameter = value;
    });
    updateGreenPointDiameter("Trajectory Setting demo", value);
  }

  void _updateLaserPointDiameter(double value) {
    setState(() {
      pattern.laserPointDiameter = value;
    });
    updateLaserPointDiameter("Trajectory Setting demo", value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ContextMenuOverlay(
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
                  if (!Responsive.isMobile(context))
                    Expanded(
                        child: TrajectoriesSettingsCard(
                          pattern: pattern,
                          updateNumberOfMeasurements:
                              _updateNumberOfMeasurements,
                          updateMeasurementTime: _updateMeasurementTime,
                          updateGreenPointDiameter: _updateGreenPointDiameter,
                          updateLaserPointDiameter: _updateLaserPointDiameter,
                        ),
                        flex: 2),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  Expanded(
                    flex: 3,
                    child: TrajectoriesViewer(
                      info: streamingDevices[0],
                      pattern: pattern,
                      expanded: true,
                      changeScrollableSettings: () {
                        setState(
                          () {
                            mouseOverCard = !mouseOverCard;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (Responsive.isMobile(context))
                SizedBox(height: defaultPadding),
              if (Responsive.isMobile(context))
                TrajectoriesSettingsCard(
                  pattern: pattern,
                  updateNumberOfMeasurements: _updateNumberOfMeasurements,
                  updateMeasurementTime: _updateMeasurementTime,
                  updateGreenPointDiameter: _updateGreenPointDiameter,
                  updateLaserPointDiameter: _updateLaserPointDiameter,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
