import 'package:admin/models/streaming_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'interactive_stream.dart';
import 'alignment_box.dart';

import '../../../constants.dart';

class ImageViewer extends StatefulHookWidget {
  final StreamingDevice info;
  final bool expanded;
  final Function() expandCard;
  final Function() changeScrollableSettings;

  const ImageViewer({
    Key? key,
    required this.info,
    required this.expanded,
    required this.expandCard,
    required this.changeScrollableSettings,
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.info.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mouseOver)
                  Column(
                    children: [
                      Text("x=${xCoord.toStringAsFixed(4)}",
                          style: TextStyle(fontSize: 10)),
                      Text("y=${yCoord.toStringAsFixed(4)}",
                          style: TextStyle(fontSize: 10)),
                    ],
                  ),
                Row(children: [
                  ToggleButtons(
                    children:
                        widget.info.alignmentSettings?.map((alignmentSetting) {
                              return IconButton(
                                padding: EdgeInsets.all(1),
                                icon: Icon(Icons.select_all,
                                    color: Colors.white54, size: 18),
                                tooltip: "Select ${alignmentSetting.name}",
                                constraints: BoxConstraints(
                                  minHeight: 18,
                                  minWidth: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    alignmentSetting.visible =
                                        !alignmentSetting.visible!;
                                  });
                                },
                              );
                            }).toList() ??
                            [],
                    isSelected:
                        widget.info.alignmentSettings?.map((alignmentSetting) {
                              return alignmentSetting.visible ?? false;
                            }).toList() ??
                            [],
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
                    onPressed: widget.expandCard,
                  ),
                ]),
              ],
            ),
            SizedBox(height: defaultPadding / 2),
            Expanded(
              child: Builder(builder: (context) {
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
                      yCoord = event.localPosition.dy / context.size!.height;
                    }),
                    cursor: SystemMouseCursors.precise,
                    child: Stack(
                      children: [
                        Mjpeg(
                          fit: BoxFit.cover,
                          isLive: isRunning.value,
                          error: (context, error, stack) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          stream: 'http://localhost/${widget.info.streamUrl!}',
                        ),
                        ...List.generate(
                          widget.info.alignmentSettings?.length ?? 0,
                          (index) {
                            final alignmentSetting =
                                widget.info.alignmentSettings![index];
                            return AlignmentBox(
                              alignmentSetting: alignmentSetting,
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
      ),
    );
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
