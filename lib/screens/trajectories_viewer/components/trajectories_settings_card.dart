import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:admin/models/trajectories_settings.dart';

import 'package:http/http.dart' as http;

class TrajectoriesSettingsCard extends StatefulWidget {
  final TrajectoriesSetting pattern;
  final Function(double) updateNumberOfMeasurements;
  final Function(double) updateMeasurementTime;
  final Function(double) updateGreenPointDiameter;
  final Function(double) updateLaserPointDiameter;

  const TrajectoriesSettingsCard({
    required this.pattern,
    required this.updateNumberOfMeasurements,
    required this.updateMeasurementTime,
    required this.updateGreenPointDiameter,
    required this.updateLaserPointDiameter,
    Key? key,
  }) : super(key: key);

  @override
  _TrajectoriesSettingsCardState createState() =>
      _TrajectoriesSettingsCardState();
}

class _TrajectoriesSettingsCardState extends State<TrajectoriesSettingsCard> {
  @override
  void initState() {
    super.initState();
  }

  void setPattern() async {
    final response = await http.post(Uri.parse(
        'http://localhost/green-projector/set-pattern/${widget.pattern.name}'));

    if (response.statusCode == 200) {
      print('Pattern set');
    } else {
      throw Exception('Failed to set pattern');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultPadding * 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: 2,
                  max: 50,
                  value: widget.pattern.numberOfMeasurements,
                  decoration: InputDecoration(labelText: '# of measurements'),
                  onChanged: (value) =>
                      widget.updateNumberOfMeasurements(value),
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: 1,
                  max: 10000,
                  value: widget.pattern.measurementTime,
                  decoration:
                      InputDecoration(labelText: 'Measurement time (ms)'),
                  onChanged: (value) => widget.updateMeasurementTime(value),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: 1,
                  max: 100,
                  value: widget.pattern.greenPointDiameter,
                  decoration:
                      InputDecoration(labelText: 'Green point diameter'),
                  onChanged: (value) => widget.updateGreenPointDiameter(value),
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: 1,
                  max: 100,
                  value: widget.pattern.laserPointDiameter,
                  decoration:
                      InputDecoration(labelText: 'Laser point diameter'),
                  onChanged: (value) => widget.updateLaserPointDiameter(value),
                ),
              ),
            ],
          ),
          SizedBox(height: defaultPadding * 2),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: defaultPadding * 3,
              minWidth: double.infinity,
            ),
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(defaultColor),
              ),
              onPressed: setPattern,
              icon: Icon(Icons.send_rounded, color: Colors.white),
              label: Text('Set Pattern'),
            ),
          )
        ],
      ),
    );
  }
}
