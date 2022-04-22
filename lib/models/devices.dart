import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Device {
  final String name;
  final String description;
  final bool connected;
  final String deviceType;

  const Device({
    required this.name,
    required this.description,
    required this.connected,
    required this.deviceType,
  });

  factory Device.fromJson(Map<String, dynamic> device) {
    return Device(
      name: device['name'],
      description: device['description'],
      connected: device['connected'],
      deviceType: device['device_type'],
    );
  }
}

Future<List<Device>> fetchDevices() async {
  final response = await http.get(Uri.parse('http://localhost/devices'));

  if (response.statusCode == 200) {
    List<Device> devices = [];
    final _devices = json.decode(response.body)['data'];
    for (var device in _devices) {
      devices.add(Device.fromJson(device));
    }
    return devices;
  } else {
    throw Exception('Failed to load devices info');
  }
}

IconData getDeviceIcon(String device) {
  switch (device) {
    case "Green Projector":
      return Icons.control_camera;
    case "Laser Projector":
      return Icons.control_camera;
    case "Waveform Generator":
      return Icons.waves;
    case "Lock-In Camera":
      return Icons.camera_rear_sharp;
    case "CMOS Camera":
      return Icons.camera;
    default:
      return Icons.control_camera;
  }
}
