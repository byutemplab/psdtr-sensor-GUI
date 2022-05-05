import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:admin/models/alignment_settings.dart';

import 'package:http/http.dart' as http;

class ProjectorBoxCard extends StatefulWidget {
  const ProjectorBoxCard({
    Key? key,
  }) : super(key: key);

  @override
  _ProjectorBoxCardState createState() => _ProjectorBoxCardState();
}

class _ProjectorBoxCardState extends State<ProjectorBoxCard> {
  ProjectorBox box = ProjectorBox();
  @override
  void initState() {
    super.initState();
    fetchProjectorBoxSettings().then((value) {
      setState(() => box = value);
    });
  }

  void setBox() async {
    final response =
        await http.post(Uri.parse('http://localhost/green-projector/set-box'));

    if (response.statusCode == 200) {
      print('Green box set');
    } else {
      throw Exception('Failed to set green box');
    }
  }

  Future<ProjectorBox> fetchProjectorBoxSettings() async {
    final response = await http.get(Uri.parse(
        'http://localhost/projector-box-setting/green-projector-box'));

    if (response.statusCode == 200) {
      ProjectorBox box =
          ProjectorBox.fromJson(json.decode(response.body)['data']);
      return box;
    } else {
      throw Exception('Failed to load projector box settings');
    }
  }

  void updateProjectorBoxSettings() async {
    final response = await http.post(Uri.parse(
        'http://localhost/projector-box-setting/green-projector-box?x_offset=${box.xOffset}&y_offset=${box.yOffset}&side_length=${box.sideLength}'));

    if (response.statusCode == 200) {
      print('Green box settings updated');
    } else {
      throw Exception(
          'Failed to update green box settings, message ${response.body}');
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
            "Projector Box",
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
                  min: -1,
                  max: 1,
                  value: box.xOffset,
                  decimals: 3,
                  step: 0.001,
                  decoration: InputDecoration(labelText: 'x offset'),
                  onChanged: (value) {
                    setState(() {
                      box.xOffset = value;
                    });
                    updateProjectorBoxSettings();
                  },
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                flex: 1,
                child: SpinBox(
                  min: -1,
                  max: 1,
                  value: box.yOffset,
                  decimals: 3,
                  step: 0.001,
                  decoration: InputDecoration(labelText: 'y offset'),
                  onChanged: (value) {
                    setState(() {
                      box.yOffset = value;
                    });
                    updateProjectorBoxSettings();
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
                  max: 1,
                  value: box.sideLength,
                  decimals: 3,
                  step: 0.001,
                  decoration: InputDecoration(labelText: 'Side length'),
                  onChanged: (value) {
                    setState(() {
                      box.sideLength = value;
                    });
                    updateProjectorBoxSettings();
                  },
                ),
              ),
              SizedBox(width: defaultPadding),
              Expanded(
                flex: 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: defaultPadding * 4,
                  ),
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(defaultColor),
                    ),
                    onPressed: setBox,
                    icon: Icon(Icons.send_rounded, color: Colors.white),
                    label: Text('Set Box'),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
