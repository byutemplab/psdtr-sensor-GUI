import 'package:admin/models/streaming_devices.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../constants.dart';
import 'image_viewer_card.dart';

class ImageViewers extends StatelessWidget {
  final Function() changeScrollableSettings;

  const ImageViewers({
    Key? key,
    required this.changeScrollableSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Responsive(
      mobile: ImageViewersGridView(
        crossAxisCount: _size.width < 650 ? 1 : 2,
        changeScrollableSettings: changeScrollableSettings,
      ),
      tablet: ImageViewersGridView(
          changeScrollableSettings: changeScrollableSettings),
      desktop: ImageViewersGridView(
          changeScrollableSettings: changeScrollableSettings),
    );
  }
}

class ImageViewersGridView extends StatefulHookWidget {
  final Function() changeScrollableSettings;
  final int crossAxisCount;

  const ImageViewersGridView({
    Key? key,
    required this.changeScrollableSettings,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  _ImageViewersGridViewState createState() => _ImageViewersGridViewState();
}

class _ImageViewersGridViewState extends State<ImageViewersGridView> {
  List imageSources = streamingDevices;
  bool expanded = false;
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxWidth / 0.88,
            width: constraints.maxWidth,
            child: ImageViewer(
              info: imageSources[expandedIndex],
              expanded: true,
              expandCard: () {
                setState(() {
                  this.expanded = false;
                  this.expandedIndex = -1;
                });
              },
              changeScrollableSettings: widget.changeScrollableSettings,
            ),
          );
        },
      );
    } else {
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: imageSources.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: defaultPadding,
          mainAxisSpacing: defaultPadding,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) => ImageViewer(
          info: imageSources[index],
          expanded: false,
          expandCard: () {
            setState(() {
              this.expanded = true;
              this.expandedIndex = index;
            });
          },
          changeScrollableSettings: widget.changeScrollableSettings,
        ),
      );
    }
  }
}
