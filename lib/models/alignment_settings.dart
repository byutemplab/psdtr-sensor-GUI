import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlignmentSetting {
  final String? name, streamUrl;
  final Color? color;
  bool? visible;

  AlignmentSetting({
    this.name,
    this.streamUrl,
    this.color,
    this.visible,
  });
}

class ProjectorBox {
  String name;
  double xOffset, yOffset, sideLength;

  ProjectorBox({
    this.name = '',
    this.xOffset = 0.0,
    this.yOffset = 0.0,
    this.sideLength = 0.0,
  });

  factory ProjectorBox.fromJson(Map<String, dynamic> projector) {
    return ProjectorBox(
      name: projector['name'],
      xOffset: projector['x-offset'],
      yOffset: projector['y-offset'],
      sideLength: projector['side-length'],
    );
  }
}
