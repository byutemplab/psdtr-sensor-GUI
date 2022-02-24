// import 'dart:html';

import 'package:admin/models/MyFiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'interactive_stream.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:image/image.dart';

import '../../../constants.dart';

class ImageViewer extends StatefulHookWidget {
  final CloudStorageInfo info;
  final bool expanded;
  final Function() ExpandCard;
  final Function() ChangeScrollableSettings;

  const ImageViewer({
    Key? key,
    required this.info,
    required this.expanded,
    required this.ExpandCard,
    required this.ChangeScrollableSettings,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  double xCoord = 0;
  double yCoord = 0;
  bool mouseOver = false;
  bool alignmentBoxVisible = false;

  @override
  Widget build(BuildContext context) {
    final isRunning = useState(true);
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.info.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mouseOver && widget.expanded)
                  Text(
                      "x=${xCoord.toStringAsFixed(4)}, y=${yCoord.toStringAsFixed(4)}",
                      style: TextStyle(fontSize: 10)),
                Row(children: [
                  ToggleButtons(
                    children: [
                      IconButton(
                        padding: EdgeInsets.all(1),
                        icon: Icon(Icons.select_all,
                            color: Colors.white54, size: 18),
                        tooltip: "Select dot pattern corners",
                        constraints: BoxConstraints(
                          minHeight: 18,
                          minWidth: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            alignmentBoxVisible = !alignmentBoxVisible;
                          });
                        },
                      ),
                    ],
                    isSelected: [false],
                    constraints: BoxConstraints(
                      minHeight: 12,
                      minWidth: 12,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(3),
                    icon: Icon(
                        widget.expanded
                            ? Icons.close_fullscreen_rounded
                            : Icons.open_in_full_rounded,
                        color: Colors.white54,
                        size: 18),
                    constraints: BoxConstraints(
                      minHeight: 18,
                      minWidth: 18,
                    ),
                    onPressed: widget.ExpandCard,
                  ),
                ]),
              ],
            ),
            SizedBox(height: defaultPadding / 2),
            Builder(builder: (context) {
              return InteractiveViewer(
                maxScale: 100,
                child: MouseRegion(
                  onEnter: (event) {
                    setState(() => mouseOver = true);
                    widget.ChangeScrollableSettings();
                  },
                  onExit: (event) {
                    setState(() => mouseOver = false);
                    widget.ChangeScrollableSettings();
                  },
                  onHover: (event) => setState(() {
                    xCoord = event.localPosition.dx / context.size!.width;
                    yCoord = event.localPosition.dy / context.size!.height;
                  }),
                  cursor: SystemMouseCursors.precise,
                  child: Stack(
                    children: [
                      Mjpeg(
                        isLive: isRunning.value,
                        error: (context, error, stack) {
                          print(error);
                          print(stack);
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        stream: 'http://localhost/${widget.info.streamUrl!}',
                      ),
                      if (alignmentBoxVisible)
                        AlignmentBox(alignmentSettingPath: "cmos-camera-marks"),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AlignmentSetting {
  final List<Offset> corners;

  const AlignmentSetting({
    required this.corners,
  });

  factory AlignmentSetting.fromJson(Map<String, dynamic> json) {
    List<Offset> corners = [];
    for (var corner in json['data']) {
      corners.add(Offset(corner[0], corner[1]));
    }
    return AlignmentSetting(corners: corners);
  }
}

Future<List<Offset>> fetchAlignmentSetting(name) async {
  final response =
      await http.get(Uri.parse('http://localhost/alignment-setting/$name'));

  if (response.statusCode == 200) {
    List cornersArray = json.decode(response.body)["data"];
    List<Offset> corners = [];
    for (var corner in cornersArray) {
      corners.add(Offset(corner[0].toDouble(), corner[1].toDouble()));
    }
    return corners;
  } else {
    throw Exception('Failed to load alignment setting for $name');
  }
}

void setAlignmentSetting(name, corners, selectedCorner) async {
  String x = corners[selectedCorner].dx.toString();
  String y = corners[selectedCorner].dy.toString();
  String path =
      'http://localhost/alignment-setting/$name?point_idx=$selectedCorner&x=$x&y=$y';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 200) {
    print(
        "Set point $selectedCorner of $name to (${corners[selectedCorner].dx}, ${corners[selectedCorner].dy})");
  } else {
    throw Exception('Failed to set alignment setting for $name');
  }
}

class AlignmentBox extends StatefulHookWidget {
  final String alignmentSettingPath;
  final String color;

  const AlignmentBox({
    Key? key,
    required this.alignmentSettingPath,
    this.color = "green",
  }) : super(key: key);

  @override
  _AlignmentBoxState createState() => _AlignmentBoxState();
}

class _AlignmentBoxState extends State<AlignmentBox> {
  List<Offset> corners = [];
  int selectedCorner = -1;

  @override
  void initState() {
    super.initState();
    fetchAlignmentSetting(widget.alignmentSettingPath).then((value) {
      setState(() => corners = value);
    });
  }

  void selectCorner(Offset click) {
    // Only grab corner if it the click was close enough
    for (int i = 0; i < corners.length; i++) {
      if (corners[i].dx - 0.05 <= click.dx &&
          click.dx <= corners[i].dx + 0.05 &&
          corners[i].dy - 0.05 <= click.dy &&
          click.dy <= corners[i].dy + 0.05) {
        setState(() {
          selectedCorner = i;
        });
        break;
      }
    }
  }

  void updateCorner(Offset newCorner) {
    if (selectedCorner == -1) return;
    // Don't allow corners to be moved outside of the image
    if (newCorner.dx < 0) newCorner = Offset(0, newCorner.dy);
    if (newCorner.dx > 1) newCorner = Offset(1, newCorner.dy);
    if (newCorner.dy < 0) newCorner = Offset(newCorner.dx, 0);
    if (newCorner.dy > 1) newCorner = Offset(newCorner.dx, 1);

    setState(() {
      corners[selectedCorner] = newCorner;
    });
  }

  void updateCornerInServer() {
    if (selectedCorner == -1) return;
    // POST request to update server
    setAlignmentSetting(widget.alignmentSettingPath, corners, selectedCorner);
    // Release corner
    selectedCorner = -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double sideLength = constraints.maxWidth;
      return GestureDetector(
        // Start dragging on corner
        onTapDown: (event) {
          Offset pos = event.localPosition / sideLength;
          selectCorner(pos);
        },
        onPanStart: (event) {
          Offset pos = event.localPosition / sideLength;
          selectCorner(pos);
        },
        // Update corner
        onPanUpdate: (event) {
          Offset pos = event.localPosition / sideLength;
          updateCorner(pos);
        },
        onLongPressMoveUpdate: (event) {
          Offset pos = event.localPosition / sideLength;
          updateCorner(pos);
        },
        // Release corner
        onPanEnd: (event) {
          updateCornerInServer();
        },
        onLongPressUp: () {
          updateCornerInServer();
        },
        child: Container(
          width: sideLength,
          height: sideLength,
          child: CustomPaint(
            painter: BoxPainter(
                corners: corners,
                sideLength: sideLength,
                selectedCorner: selectedCorner),
          ),
        ),
      );
    });
  }
}

class BoxPainter extends CustomPainter {
  final List<Offset> corners;
  final double sideLength;
  final int selectedCorner;
  final double strokeWidth;

  BoxPainter({
    required this.corners,
    required this.sideLength,
    required this.selectedCorner,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = this.strokeWidth;
    final circlePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (var i = 0; i < corners.length; i++) {
      final corner = corners[i] * this.sideLength;
      final nextCorner = corners[(i + 1) % corners.length] * this.sideLength;
      canvas.drawCircle(corner, this.strokeWidth / 2, circlePaint);
      canvas.drawLine(corner, nextCorner, linePaint);
    }

    // Show corner number if not selected
    for (var i = 0; i < corners.length; i++) {
      final corner = corners[i] * this.sideLength;
      if (i != selectedCorner) {
        final textStyle = TextStyle(
          color: Colors.white,
          fontSize: this.strokeWidth * 5,
          fontWeight: FontWeight.bold,
        );
        final textSpan = TextSpan(
          text: "${i + 1}",
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          corner - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
