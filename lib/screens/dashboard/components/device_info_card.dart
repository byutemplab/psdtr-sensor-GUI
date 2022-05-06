import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants.dart';

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({
    Key? key,
    required this.name,
    required this.description,
    required this.icon,
    required this.connected,
    required this.connectionType,
  }) : super(key: key);

  final String name;
  final String description;
  final bool connected;
  final IconData icon;
  final String connectionType;

  void connect() async {
    final response =
        await http.post(Uri.parse('http://localhost/$name/connect'));

    if (response.statusCode == 200) {
      print('Device connected');
    } else {
      throw Exception('Failed to connect device, message ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding * 0.7),
      decoration: BoxDecoration(
        // border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding * 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 25,
            width: 20,
            child: Icon(icon),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Text(
          //   connected ? 'CONNECTED' : 'DISCONNECTED',
          //   style: Theme.of(context)
          //       .textTheme
          //       .caption!
          //       .copyWith(color: Colors.white70),
          // ),
          SizedBox(width: defaultPadding),
          // If connection type is not auto, show reconnect button
          connectionType == "auto"
              ? Icon(Icons.circle,
                  size: 20, color: connected ? Colors.green : Colors.grey)
              : connected
                  ? Icon(Icons.circle, size: 20, color: Colors.green)
                  : IconButton(
                      icon: Icon(Icons.refresh, size: 22, color: Colors.grey),
                      onPressed: connect,
                      padding: EdgeInsets.all(0),
                      constraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      tooltip: "Reconnect",
                    ),
          (connectionType == "auto" || connected)
              ? SizedBox(width: 2)
              : SizedBox(),
        ],
      ),
    );
  }
}
