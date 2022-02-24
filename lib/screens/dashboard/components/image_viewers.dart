import 'package:admin/models/MyFiles.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../constants.dart';
import 'image_viewer_card.dart';

class ImageViewers extends StatelessWidget {
  final Function() ChangeScrollableSettigs;

  const ImageViewers({
    Key? key,
    required this.ChangeScrollableSettigs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Responsive(
      mobile: ImageViewersGridView(
        crossAxisCount: _size.width < 650 ? 1 : 2,
        ChangeScrollableSettings: ChangeScrollableSettigs,
      ),
      tablet: ImageViewersGridView(
          ChangeScrollableSettings: ChangeScrollableSettigs),
      desktop: ImageViewersGridView(
          ChangeScrollableSettings: ChangeScrollableSettigs),
    );
  }
}

class ImageViewersGridView extends StatefulHookWidget {
  final Function() ChangeScrollableSettings;
  final int crossAxisCount;

  const ImageViewersGridView({
    Key? key,
    required this.ChangeScrollableSettings,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  _ImageViewersGridViewState createState() => _ImageViewersGridViewState();
}

class _ImageViewersGridViewState extends State<ImageViewersGridView> {
  List imageSources = demoMyFiles;
  bool expanded = false;
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Row(
        children: [
          Expanded(
            child: ImageViewer(
              info: imageSources[expandedIndex],
              expanded: true,
              ExpandCard: () {
                setState(() {
                  this.expanded = false;
                  this.expandedIndex = -1;
                });
              },
              ChangeScrollableSettings: widget.ChangeScrollableSettings,
            ),
          ),
        ],
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
          ExpandCard: () {
            setState(() {
              this.expanded = true;
              this.expandedIndex = index;
            });
          },
          ChangeScrollableSettings: widget.ChangeScrollableSettings,
        ),
      );
    }
  }
}
