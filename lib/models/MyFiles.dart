import 'package:admin/constants.dart';
import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? svgSrc, title, totalStorage, streamUrl;
  final int? numOfFiles, percentage;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.percentage,
    this.color,
    this.streamUrl,
  });
}

List demoMyFiles = [
  CloudStorageInfo(
    title: "SEM Images",
    numOfFiles: 1328,
    svgSrc: "assets/icons/Documents.svg",
    totalStorage: "1.9GB",
    color: primaryColor,
    percentage: 35,
    streamUrl: 'sem-images/feed',
  ),
  CloudStorageInfo(
    title: "Lock-In Camera",
    numOfFiles: 1328,
    svgSrc: "assets/icons/google_drive.svg",
    totalStorage: "2.9GB",
    color: Color(0xFFFFA113),
    percentage: 35,
    streamUrl: 'lock-in-camera/feed',
  ),
  CloudStorageInfo(
    title: "CMOS Camera",
    numOfFiles: 1328,
    svgSrc: "assets/icons/one_drive.svg",
    totalStorage: "1GB",
    color: Color(0xFFA4CDFF),
    percentage: 10,
    streamUrl: 'cmos-camera/feed',
  ),
  CloudStorageInfo(
    title: "Alignment Check",
    numOfFiles: 5328,
    svgSrc: "assets/icons/drop_box.svg",
    totalStorage: "7.3GB",
    color: Color(0xFF007EE5),
    percentage: 78,
    streamUrl: 'alignment-check/feed',
  ),
];
