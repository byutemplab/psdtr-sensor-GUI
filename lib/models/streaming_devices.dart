import 'package:flutter/material.dart';
import 'alignment_settings.dart';

class StreamingDevice {
  final String? name, streamUrl;
  List<AlignmentSetting>? alignmentSettings;

  StreamingDevice({
    this.name,
    this.streamUrl,
    this.alignmentSettings,
  });
}

List streamingDevices = [
  StreamingDevice(
    name: "SEM Images",
    streamUrl: 'sem-images/feed',
    alignmentSettings: [
      AlignmentSetting(
        name: "SEM Image Marks",
        streamUrl: 'alignment-setting/sem-image-marks',
        color: Colors.grey,
        visible: true,
      ),
    ],
  ),
  StreamingDevice(
      name: "Lock-In Camera",
      streamUrl: 'lock-in-camera/feed',
      alignmentSettings: [
        AlignmentSetting(
          name: "Lock In Camera Green Dots",
          streamUrl: 'alignment-setting/lock-in-camera-green-dots',
          color: Colors.green,
          visible: true,
        ),
      ]),
  StreamingDevice(
      name: "CMOS Camera",
      streamUrl: 'cmos-camera/feed',
      alignmentSettings: [
        AlignmentSetting(
          name: "CMOS Camera Marks",
          streamUrl: 'alignment-setting/cmos-camera-marks',
          color: Colors.grey,
          visible: true,
        ),
        AlignmentSetting(
          name: "CMOS Camera Green Dots",
          streamUrl: 'alignment-setting/cmos-camera-green-dots',
          color: Colors.green,
          visible: true,
        ),
      ]),
  StreamingDevice(
    name: "Alignment Check",
    streamUrl: 'alignment-check/feed',
  ),
];
