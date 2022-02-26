class StreamingDevice {
  final String? name, streamUrl;

  StreamingDevice({
    this.name,
    this.streamUrl,
  });
}

List streamingDevices = [
  StreamingDevice(
    name: "SEM Images",
    streamUrl: 'sem-images/feed',
  ),
  StreamingDevice(
    name: "Lock-In Camera",
    streamUrl: 'lock-in-camera/feed',
  ),
  StreamingDevice(
    name: "CMOS Camera",
    streamUrl: 'cmos-camera/feed',
  ),
  StreamingDevice(
    name: "Alignment Check",
    streamUrl: 'alignment-check/feed',
  ),
];
