import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewSection extends StatelessWidget {
  PhotoViewSection({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;
  DownloadController _downloadController = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    var cachedNetworkImageProvider = CachedNetworkImageProvider(url);
    var localImage = FileImage(File(url));
    bool isLocal = url.length > 0 && url[0] == '/' ? true : false;
    return Material(
      color: Colors.black,
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      FlutterClipboard.copy(url).then((value) => showAlert(
                          message: 'image url already saved in clipboard'));
                    },
                    icon: Icon(
                      Icons.copy_outlined,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () async {
                      var grant = await checkPermission();
                      if (grant == true) {
                        _downloadController
                            .requestDownload(TaskInfo(name: 'url', link: url));
                      }
                    },
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    )),
              ],
            ),
            Expanded(
              child: isLocal
                  ? PhotoView(
                      tightMode: true,
                      imageProvider: localImage,
                    )
                  : PhotoView(
                      tightMode: true,
                      imageProvider: cachedNetworkImageProvider,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
