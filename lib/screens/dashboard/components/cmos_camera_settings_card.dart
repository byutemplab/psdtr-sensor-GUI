import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:admin/models/devices.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:http/http.dart' as http;

class CMOSCameraSettingsCard extends StatefulWidget {
  const CMOSCameraSettingsCard({
    Key? key,
  }) : super(key: key);

  @override
  _CMOSCameraSettingsCardState createState() => _CMOSCameraSettingsCardState();
}

class _CMOSCameraSettingsCardState extends State<CMOSCameraSettingsCard> {
  CMOSCameraSettings settings = CMOSCameraSettings();
  @override
  void initState() {
    super.initState();
    fetchCMOSCameraSettings().then((value) {
      setState(() => settings = value);
    });
  }

  Future<CMOSCameraSettings> fetchCMOSCameraSettings() async {
    final response =
        await http.get(Uri.parse('http://localhost/cmos-camera/settings'));

    if (response.statusCode == 200) {
      CMOSCameraSettings settings =
          CMOSCameraSettings.fromJson(json.decode(response.body)['data']);
      return settings;
    } else {
      throw Exception('Failed to load CMOS camera settings');
    }
  }

  void updateCMOSCameraSettings() async {
    final response = await http.post(Uri.parse(
        'http://localhost/cmos-camera/settings?exposure=${settings.exposure.toInt()}&gain=${settings.gain.toInt()}&brightness=${settings.brightness.toInt()}'));

    if (response.statusCode == 200) {
      print('CMOS camera settings updated');
    } else {
      throw Exception(
          'Failed to update CMOS camera settings, message ${response.body}');
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
            "CMOS Camera Settings",
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
                  min: 10,
                  max: 500000,
                  value: settings.exposure,
                  decoration: InputDecoration(labelText: 'Exposure'),
                  onChanged: (value) {
                    setState(() {
                      settings.exposure = value;
                    });
                    updateCMOSCameraSettings();
                  },
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
                  min: 0,
                  max: 100,
                  value: settings.gain,
                  decoration: InputDecoration(labelText: 'Gain'),
                  onChanged: (value) {
                    setState(() {
                      settings.gain = value;
                    });
                    updateCMOSCameraSettings();
                  },
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: 0,
                  max: 100,
                  value: settings.brightness,
                  decoration: InputDecoration(labelText: 'Brightness'),
                  onChanged: (value) {
                    setState(() {
                      settings.brightness = value;
                    });
                    updateCMOSCameraSettings();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
