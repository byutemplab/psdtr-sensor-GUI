import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../constants.dart';
import 'device_info_card.dart';
import 'package:http/http.dart' as http;

class Device {
  final int id;
  final String name;
  final bool connected;
  final String deviceType;

  const Device({
    required this.id,
    required this.name,
    required this.connected,
    required this.deviceType,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['data']['laser-projector']['id'],
      name: json['data']['laser-projector']['name'],
      connected: json['data']['cmos-camera']['connected'],
      deviceType: json['data']['laser-projector']['device_type'],
    );
  }
}

Future<Device> fetchDevice() async {
  final response = await http.get(Uri.parse('http://localhost/devices'));

  if (response.statusCode == 200) {
    return Device.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load device');
  }
}

class DevicesStatus extends StatefulWidget {
  const DevicesStatus({
    Key? key,
  }) : super(key: key);

  @override
  _DevicesStatusState createState() => _DevicesStatusState();
}

class _DevicesStatusState extends State<DevicesStatus> {
  late Future<Device> futureDevice;

  @override
  void initState() {
    super.initState();
    futureDevice = fetchDevice();
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
            "Devices",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          // SizedBox(height: defaultPadding),
          // Chart(),
          FutureBuilder<Device>(
            future: futureDevice,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DeviceInfoCard(
                  icon: Icons.control_camera,
                  name: snapshot.data!.name,
                  connected: snapshot.data!.connected,
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          DeviceInfoCard(
            icon: Icons.control_camera,
            name: "Green Projector",
            connected: true,
          ),
          DeviceInfoCard(
            icon: Icons.camera_rear_sharp,
            name: "Lock-In Camera",
            connected: true,
          ),
          DeviceInfoCard(
            icon: Icons.camera,
            name: "CMOS Camera",
            connected: true,
          ),
          DeviceInfoCard(
            icon: Icons.waves,
            name: "Waveform Generator",
            connected: false,
          ),
          IconButton(
              icon: Icon(Icons.replay_outlined),
              onPressed: () {
                setState(() {
                  futureDevice = fetchDevice();
                });
              }),
        ],
      ),
    );
  }
}
