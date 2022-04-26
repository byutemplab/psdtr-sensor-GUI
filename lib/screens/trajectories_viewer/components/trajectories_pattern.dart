import 'dart:convert';
import 'dart:math';
import 'package:admin/models/trajectories_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TrajectoriesPattern extends StatefulHookWidget {
  const TrajectoriesPattern({
    Key? key,
  }) : super(key: key);

  @override
  _TrajectoriesPatternState createState() => _TrajectoriesPatternState();
}

class _TrajectoriesPatternState extends State<TrajectoriesPattern> {
  TrajectoriesSetting pattern = TrajectoriesSetting();
  int selectedTrajectory = -1;
  int hoveredTrajectory = -1;

  @override
  void initState() {
    super.initState();
    fetchTrajectoriesSetting().then((value) {
      setState(() => pattern = value);
    });
  }

  void checkIfHoveringTrajectory(Offset pos) {
    for (int i = 0; i < pattern.trajectories.length; i++) {
      final start = pattern.trajectories[i].start;
      final end = pattern.trajectories[i].end;
      final offset = 0.05;
      // get bounding box
      final minX = min(start.dx, end.dx) - offset;
      final maxX = max(start.dx, end.dx) + offset;
      final minY = min(start.dy, end.dy) - offset;
      final maxY = max(start.dy, end.dy) + offset;
      // get line equation
      final slope = (end.dy - start.dy) / (end.dx - start.dx);
      final intercept = start.dy - slope * start.dx;
      final yOffset = sqrt(pow(slope * offset, 2) + pow(offset, 2));
      // check if hovering inside bounding box and close to line
      if (pos.dx > minX &&
          pos.dx < maxX &&
          pos.dy > minY &&
          pos.dy < maxY &&
          ((pos.dy > pos.dx * slope + intercept - yOffset &&
                  pos.dy < pos.dx * slope + intercept + yOffset) ||
              (start.dx == end.dx))) {
        setState(() => hoveredTrajectory = i);
        return;
      }
    }
    setState(() => hoveredTrajectory = -1);
  }

  void selectTrajectory(Offset click) {
    // Only grab trajectory if mouse is over it
    if (hoveredTrajectory != -1) {
      setState(() => selectedTrajectory = hoveredTrajectory);
    }
  }

  void updateTrajectoryCenter(Offset newCenter) {
    if (selectedTrajectory == -1) return;
    // Compute new start and end points for selected trajectory
    final start = pattern.trajectories[selectedTrajectory].start;
    final end = pattern.trajectories[selectedTrajectory].end;
    Offset center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    Offset newStart = Offset(
      start.dx + newCenter.dx - center.dx,
      start.dy + newCenter.dy - center.dy,
    );
    Offset newEnd = Offset(
      end.dx + newCenter.dx - center.dx,
      end.dy + newCenter.dy - center.dy,
    );
    // Don't allow trajectory to go off screen
    if (newStart.dx < 0 ||
        newStart.dx > 1 ||
        newStart.dy < 0 ||
        newStart.dy > 1 ||
        newEnd.dx < 0 ||
        newEnd.dx > 1 ||
        newEnd.dy < 0 ||
        newEnd.dy > 1) {
      return;
    }

    // Round coordinates to the nearest 0.0001
    newStart = Offset(
      (newStart.dx * 10000).round() / 10000,
      (newStart.dy * 10000).round() / 10000,
    );
    newEnd = Offset(
      (newEnd.dx * 10000).round() / 10000,
      (newEnd.dy * 10000).round() / 10000,
    );

    setState(() {
      pattern.trajectories[selectedTrajectory].start = newStart;
      pattern.trajectories[selectedTrajectory].end = newEnd;
    });
  }

  void updateTrajectoryInServer() {
    if (selectedTrajectory == -1) return;
    // POST request to update server
    updateTrajectory("Trajectory Setting demo", selectedTrajectory, pattern);
    // Release trajectory
    selectedTrajectory = -1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double sideLength = constraints.maxHeight;
      return GestureDetector(
        // Start dragging on corner
        onTapDown: (event) {
          Offset pos = event.localPosition / sideLength;
          selectTrajectory(pos);
        },
        onPanStart: (event) {
          Offset pos = event.localPosition / sideLength;
          selectTrajectory(pos);
        },
        // Update corner
        onPanUpdate: (event) {
          Offset pos = event.localPosition / sideLength;
          updateTrajectoryCenter(pos);
        },
        onLongPressMoveUpdate: (event) {
          Offset pos = event.localPosition / sideLength;
          updateTrajectoryCenter(pos);
        },
        // Release corner
        onPanEnd: (event) {
          updateTrajectoryInServer();
        },
        onLongPressUp: () {
          updateTrajectoryInServer();
        },
        child: MouseRegion(
          // When the mouse enters the region, set the hoveredTrajectory
          onHover: (event) {
            Offset pos = event.localPosition / sideLength;
            checkIfHoveringTrajectory(pos);
          },
          child: Container(
            width: sideLength,
            height: sideLength,
            child: CustomPaint(
              painter: PatternPainter(
                pattern: pattern,
                sideLength: sideLength,
                selectedTrajectory: selectedTrajectory,
                hoveredTrajectory: hoveredTrajectory,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class PatternPainter extends CustomPainter {
  final TrajectoriesSetting pattern;
  final double sideLength;
  final int selectedTrajectory;
  final int hoveredTrajectory;
  final double pixelRatio;

  PatternPainter({
    required this.pattern,
    required this.sideLength,
    required this.selectedTrajectory,
    required this.hoveredTrajectory,
    this.pixelRatio = 0.5, // 1 sem image pixel = 1 projector pixel
  });

  List<Offset> interpolatePoints(Offset start, Offset end, int numPoints) {
    List<Offset> points = [];
    double dx = (end.dx - start.dx) / (numPoints - 1);
    double dy = (end.dy - start.dy) / (numPoints - 1);
    for (int i = 0; i < numPoints; i++) {
      points.add(Offset(start.dx + dx * i, start.dy + dy * i));
    }
    return points;
  }

  Offset getCenter(Offset start, Offset end) {
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final greenPointPaint = Paint()
      ..color = Color.fromRGBO(0, 255, 0, 0.5)
      ..style = PaintingStyle.fill;
    final greenPointSelectedPaint = Paint()
      ..color = Color.fromRGBO(0, 255, 0, 1)
      ..style = PaintingStyle.fill;
    final laserPointPaint = Paint()
      ..color = Color.fromRGBO(255, 0, 0, 0.5)
      ..style = PaintingStyle.fill;
    final laserPointSelectedPaint = Paint()
      ..color = Color.fromRGBO(255, 0, 0, 1)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < pattern.trajectories.length; i++) {
      final start = pattern.trajectories[i].start * this.sideLength;
      final end = pattern.trajectories[i].end * this.sideLength;
      List<Offset> greenPoints =
          interpolatePoints(start, end, pattern.numberOfMeasurements);
      for (var j = 0; j < greenPoints.length; j++) {
        if (i == hoveredTrajectory) {
          canvas.drawCircle(greenPoints[j],
              pattern.greenPointDiameter * pixelRatio, greenPointSelectedPaint);
        } else {
          canvas.drawCircle(greenPoints[j],
              pattern.greenPointDiameter * pixelRatio, greenPointPaint);
        }
      }
      Offset laserPoint = getCenter(start, end);
      if (i == hoveredTrajectory) {
        canvas.drawCircle(laserPoint, pattern.laserPointDiameter * pixelRatio,
            laserPointSelectedPaint);
      } else {
        canvas.drawCircle(laserPoint, pattern.laserPointDiameter * pixelRatio,
            laserPointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
