import 'dart:async';

import 'package:admin/models/devices.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'device_info_card.dart';

class DevicesStatus extends StatefulWidget {
  const DevicesStatus({
    Key? key,
  }) : super(key: key);

  @override
  _DevicesStatusState createState() => _DevicesStatusState();
}

class _DevicesStatusState extends State<DevicesStatus> {
  late Future<List<Device>> futureDevices = fetchDevices();

  setUpTimedFetch() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.mounted) {
        setState(() {
          futureDevices = fetchDevices();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setUpTimedFetch();
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
          FutureBuilder<List<Device>>(
            future: futureDevices,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data?.map((device) {
                        return DeviceInfoCard(
                          icon: getDeviceIcon(device.description),
                          name: device.description,
                          connected: device.connected,
                        );
                      }).toList() ??
                      [],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
