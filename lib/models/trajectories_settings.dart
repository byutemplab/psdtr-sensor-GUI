import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Trajectory {
  Offset start;
  Offset end;

  Trajectory({
    required this.start,
    required this.end,
  });

  factory Trajectory.fromJson(Map<String, dynamic> json) {
    return Trajectory(
      start: Offset(json['start'][0], json['start'][1]),
      end: Offset(json['end'][0], json['end'][1]),
    );
  }
}

class TrajectoriesSetting {
  final String name;
  final int numberOfMeasurements;
  final int measurementTime;
  final String measurementTimeUnit;
  final int greenPointDiameter;
  final int laserPointDiameter;
  final List<Trajectory> trajectories;

  const TrajectoriesSetting({
    this.name = '',
    this.numberOfMeasurements = 0,
    this.measurementTime = 1,
    this.measurementTimeUnit = 'ms',
    this.greenPointDiameter = 1,
    this.laserPointDiameter = 1,
    this.trajectories = const [],
  });

  factory TrajectoriesSetting.fromJson(Map<String, dynamic> json) {
    List<Trajectory> trajectories = [];
    for (var trajectory in json['trajectories']) {
      trajectories.add(Trajectory.fromJson(trajectory));
    }
    return TrajectoriesSetting(
      name: json['name'],
      numberOfMeasurements: int.parse(json['number-of-measurements']),
      measurementTime: int.parse(json['measurement-time']),
      measurementTimeUnit: json['measurement-time-unit'],
      greenPointDiameter: int.parse(json['green-point-diameter']),
      laserPointDiameter: int.parse(json['laser-point-diameter']),
      trajectories: trajectories,
    );
  }
}

// Only fetching the first trajectory for now

Future<TrajectoriesSetting> fetchTrajectoriesSetting() async {
  final response = await http.get(Uri.parse('http://localhost/trajectories'));

  if (response.statusCode == 200) {
    print(json.decode(response.body)['data'][0]);
    return TrajectoriesSetting.fromJson(json.decode(response.body)['data'][0]);
  } else {
    throw Exception('Failed to load trajectories setting');
  }
}

void updateTrajectory(name, trajectoryIndex, pattern) async {
  String startX = pattern.trajectories[trajectoryIndex].start.dx.toString();
  String startY = pattern.trajectories[trajectoryIndex].start.dy.toString();
  String endX = pattern.trajectories[trajectoryIndex].end.dx.toString();
  String endY = pattern.trajectories[trajectoryIndex].end.dy.toString();
  String path =
      'http://localhost/trajectories-setting/$name/$trajectoryIndex?start_x=$startX&start_y=$startY&end_x=$endX&end_y=$endY';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print(
        "Set trajectory #$trajectoryIndex of $name to start: ($startX, $startY), end: ($endX, $endY)");
  } else {
    throw Exception('Failed to set trajectory');
  }
}
