import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  const VideoThumbnailWidget({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String _coverUrl = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    getThumbnailAsCover();
  }

  getThumbnailAsCover() async {
    try {
      var url = Uri.parse(widget.url);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        String? fileName = await VideoThumbnail.thumbnailFile(
          video: widget.url,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          maxHeight:
              64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
          quality: 75,
        );
        setState(() {
          _coverUrl = fileName!;
        });
      } else {
        setState(() {
          _isError = true;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_coverUrl != '') {
      return Stack(
        children: [
          Image.file(File(_coverUrl),
              fit: BoxFit.cover, width: double.infinity),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 40,
                color: Colors.white,
              ))
        ],
      );
    } else if (_isError) {
      return Text('error laod thumbnail video');
    }
    return Container();
  }
}
