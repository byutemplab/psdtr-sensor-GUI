import 'package:flutter/material.dart';

import '../../../constants.dart';

class DeviceInfoCard extends StatelessWidget {
  const DeviceInfoCard({
    Key? key,
    required this.name,
    required this.icon,
    required this.connected,
  }) : super(key: key);

  final String name;
  final bool connected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding * 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20,
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
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    connected ? 'CONNECTED' : 'DISCONNECTED',
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.circle,
              size: 20, color: connected ? Colors.green : Colors.grey),
        ],
      ),
    );
  }
}
