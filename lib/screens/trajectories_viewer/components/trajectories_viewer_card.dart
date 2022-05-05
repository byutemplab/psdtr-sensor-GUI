import 'package:admin/models/streaming_devices.dart';
import 'package:admin/models/trajectories_settings.dart';
import 'package:admin/screens/trajectories_viewer/components/trajectories_pattern_previewer.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'interactive_stream.dart';
import 'trajectories_pattern_editor.dart';

import '../../../constants.dart';

class TrajectoriesViewer extends StatefulHookWidget {
  final StreamingDevice info;
  final bool expanded;
  final Function() changeScrollableSettings;
  final TrajectoriesSetting pattern;

  const TrajectoriesViewer({
    Key? key,
    required this.info,
    required this.expanded,
    required this.changeScrollableSettings,
    required this.pattern,
  }) : super(key: key);

  @override
  _TrajectoriesViewerState createState() => _TrajectoriesViewerState();
}

class _TrajectoriesViewerState extends State<TrajectoriesViewer> {
  double xCoord = 0;
  double yCoord = 0;
  bool mouseOver = false;
  bool alignmentBoxVisible = false;
  bool preview = false;

  @override
  Widget build(BuildContext context) {
    final isRunning = useState(true);
    return LayoutBuilder(builder: (context, size) {
      return SizedBox(
          height: min(size.maxHeight, size.maxWidth) + 40,
          child: Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pattern",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (mouseOver)
                      Text(
                          "x=${xCoord.toStringAsFixed(4)}, y=${yCoord.toStringAsFixed(4)}",
                          style: TextStyle(fontSize: 10)),
                    IconButton(
                      padding: EdgeInsets.all(3),
                      icon: Icon(preview ? Icons.pause : Icons.play_arrow,
                          color: Colors.white54, size: 18),
                      constraints: BoxConstraints(
                        minHeight: 18,
                        minWidth: 18,
                      ),
                      tooltip: preview ? 'Pause preview' : 'Play preview',
                      onPressed: () => setState(() {
                        preview = !preview;
                      }),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding / 2),
                Expanded(
                  child: LayoutBuilder(builder: (context, size) {
                    return InteractiveViewer(
                      maxScale: 100,
                      child: MouseRegion(
                        onEnter: (event) {
                          setState(() => mouseOver = true);
                          widget.changeScrollableSettings();
                        },
                        onExit: (event) {
                          setState(() => mouseOver = false);
                          widget.changeScrollableSettings();
                        },
                        onHover: (event) => setState(() {
                          xCoord = event.localPosition.dx / context.size!.width;
                          yCoord =
                              event.localPosition.dy / context.size!.height;
                        }),
                        cursor: SystemMouseCursors.precise,
                        child: Stack(
                          children: [
                            Mjpeg(
                              fit: BoxFit.cover,
                              height: size.maxHeight,
                              width: size.maxHeight,
                              isLive: isRunning.value,
                              error: (context, error, stack) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              stream:
                                  'http://localhost/${widget.info.streamUrl!}',
                            ),
                            ...List.generate(
                              widget.info.alignmentSettings?.length ?? 0,
                              (index) {
                                if (!preview)
                                  return TrajectoriesPatternEditor(
                                      pattern: widget.pattern);
                                else
                                  return TrajectoriesPatternPreviewer(
                                    pattern: widget.pattern,
                                  );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ));
    });
  }
}

// class ProgressLine extends StatelessWidget {
//   const ProgressLine({
//     Key? key,
//     this.color = primaryColor,
//     required this.percentage,
//   }) : super(key: key);

//   final Color? color;
//   final int? percentage;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           width: double.infinity,
//           height: 5,
//           decoration: BoxDecoration(
//             color: color!.withOpacity(0.1),
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//         ),
//         LayoutBuilder(
//           builder: (context, constraints) => Container(
//             width: constraints.maxWidth * (percentage! / 100),
//             height: 5,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
