import 'dart:convert';
import 'package:admin/models/alignment_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

class AlignmentBoxCorners {
  final List<Offset> corners;

  const AlignmentBoxCorners({
    required this.corners,
  });

  factory AlignmentBoxCorners.fromJson(Map<String, dynamic> json) {
    List<Offset> corners = [];
    for (var corner in json['data']) {
      corners.add(Offset(corner[0], corner[1]));
    }
    return AlignmentBoxCorners(corners: corners);
  }
}

Future<List<Offset>> fetchAlignmentBoxCorners(streamUrl) async {
  final response = await http.get(Uri.parse('http://localhost/$streamUrl'));

  if (response.statusCode == 200) {
    List cornersArray = json.decode(response.body)["data"]['coordinates'];
    List<Offset> corners = [];
    for (var corner in cornersArray) {
      corners.add(Offset(corner[0].toDouble(), corner[1].toDouble()));
    }
    return corners;
  } else {
    throw Exception('Failed to load alignment setting from $streamUrl');
  }
}

void updateAlignmentBoxCorners(streamUrl, corners, selectedCorner) async {
  String x = corners[selectedCorner].dx.toString();
  String y = corners[selectedCorner].dy.toString();
  String path =
      'http://localhost/$streamUrl?point_idx=$selectedCorner&x=$x&y=$y';
  final response = await http.post(Uri.parse(path));

  if (response.statusCode == 201) {
    print(
        "Set point ${selectedCorner + 1} of $streamUrl to (${corners[selectedCorner].dx}, ${corners[selectedCorner].dy})");
  } else {
    throw Exception('Failed to set alignment setting from $streamUrl');
  }
}

class AlignmentBox extends StatefulHookWidget {
  final AlignmentSetting alignmentSetting;

  const AlignmentBox({
    Key? key,
    required this.alignmentSetting,
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
    fetchAlignmentBoxCorners(widget.alignmentSetting.streamUrl).then((value) {
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

    // Round corners to the nearest 0.0001
    newCorner = Offset((newCorner.dx * 10000).round() / 10000,
        (newCorner.dy * 10000).round() / 10000);

    setState(() {
      corners[selectedCorner] = newCorner;
    });
  }

  void updateCornerInServer() {
    if (selectedCorner == -1) return;
    // POST request to update server
    updateAlignmentBoxCorners(
        widget.alignmentSetting.streamUrl, corners, selectedCorner);
    // Release corner
    selectedCorner = -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double sideLength = constraints.maxWidth;
      if (widget.alignmentSetting.visible == false) {
        return Container();
      }
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
                selectedCorner: selectedCorner,
                color: widget.alignmentSetting.color ?? Colors.green),
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
  final Color color;

  BoxPainter({
    required this.corners,
    required this.sideLength,
    required this.selectedCorner,
    this.strokeWidth = 4,
    this.color = Colors.green,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = this.strokeWidth;
    final circlePaint = Paint()
      ..color = color
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
