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
  String name;
  double numberOfMeasurements;
  double measurementTime;
  String measurementTimeUnit;
  double greenPointDiameter;
  double laserPointDiameter;
  List<Trajectory> trajectories;

  TrajectoriesSetting({
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
      numberOfMeasurements:
          double.parse(json['number-of-measurements'].toString()),
      measurementTime: double.parse(json['measurement-time'].toString()),
      measurementTimeUnit: json['measurement-time-unit'],
      greenPointDiameter: double.parse(json['green-point-diameter'].toString()),
      laserPointDiameter: double.parse(json['laser-point-diameter'].toString()),
      trajectories: trajectories,
    );
  }
}

// Only fetching the first trajectory for now

Future<TrajectoriesSetting> fetchTrajectoriesSetting() async {
  final response = await http.get(Uri.parse('http://localhost/trajectories'));

  if (response.statusCode == 200) {
    return TrajectoriesSetting.fromJson(json.decode(response.body)['data'][0]);
  } else {
    throw Exception('Failed to load trajectories setting');
  }
}

void updateTrajectory(name, trajectoryIndex, pattern) async {
  if (trajectoryIndex == -1) return;

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

void updateNumberOfMeasurements(name, numberOfMeasurements) async {
  String path =
      'http://localhost/trajectories-setting/$name/number-of-measurements?number_of_measurements=${numberOfMeasurements.toInt()}';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print("Set number of measurements of $name to $numberOfMeasurements");
  } else {
    throw Exception('Failed to set number of measurements');
  }
}

void updateMeasurementTime(name, measurementTime) async {
  String path =
      'http://localhost/trajectories-setting/$name/measurement-time?measurement_time=${measurementTime.toInt()}';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print("Set measurement time of $name to $measurementTime");
  } else {
    throw Exception('Failed to set measurement time');
  }
}

void updateGreenPointDiameter(name, greenPointDiameter) async {
  String path =
      'http://localhost/trajectories-setting/$name/green-point-diameter?green_point_diameter=${greenPointDiameter.toInt()}';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print("Set green point diameter of $name to $greenPointDiameter");
  } else {
    throw Exception('Failed to set green point diameter');
  }
}

void updateLaserPointDiameter(name, laserPointDiameter) async {
  String path =
      'http://localhost/trajectories-setting/$name/laser-point-diameter?laser_point_diameter=${laserPointDiameter.toInt()}';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print("Set laser point diameter of $name to $laserPointDiameter");
  } else {
    throw Exception('Failed to set laser point diameter');
  }
}

void addTrajectory(name, pattern) async {
  int idx = pattern.trajectories.length - 1;
  String startX = pattern.trajectories[idx].start.dx.toString();
  String startY = pattern.trajectories[idx].start.dy.toString();
  String endX = pattern.trajectories[idx].end.dx.toString();
  String endY = pattern.trajectories[idx].end.dy.toString();
  String path =
      'http://localhost/trajectories-setting/$name/$idx?start_x=$startX&start_y=$startY&end_x=$endX&end_y=$endY';
  final response = await http.put(Uri.parse(path));

  if (response.statusCode == 201) {
    print(
        "Added trajectory #$idx of $name to start: ($startX, $startY), end: ($endX, $endY)");
  } else {
    throw Exception('Failed to add trajectory');
  }
}

void removeTrajectory(name, trajectoryIndex) async {
  if (trajectoryIndex == -1) return;

  String path = 'http://localhost/trajectories-setting/$name/$trajectoryIndex';
  final response = await http.delete(Uri.parse(path));

  if (response.statusCode == 200) {
    print("Removed trajectory #$trajectoryIndex of $name");
  } else {
    throw Exception('Failed to remove trajectory');
  }
}
