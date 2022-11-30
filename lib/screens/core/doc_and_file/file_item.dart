import 'dart:io';

import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:mime/mime.dart';

class FileItem extends StatelessWidget {
  FileItem({Key? key, required this.item}) : super(key: key);
  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  final DocFileItemModel item;

  Widget _buildFileType() {
    String url = item.url!;
    // if (Platform.isAndroid) {
    String? mimeType = lookupMimeType(url);
    if (mimeType != null) {
      String? ext = extensionFromMime(mimeType);
      if (mimeType.contains('image')) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              getPhotoUrl(url: url),
              fit: BoxFit.cover,
            ));
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.asset(
          getPathExtention(mimeType: ext),
          width: 50.w,
          height: 50.w,
          fit: BoxFit.scaleDown,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.asset(
        getPathExtention(mimeType: ''),
        width: 50.w,
        height: 50.w,
        fit: BoxFit.scaleDown,
      ),
    );
    // }
    // return ClipRRect(
    //   borderRadius: BorderRadius.circular(15.0),
    //   child: IgnorePointer(
    //     child: InAppWebView(
    //         initialUrlRequest: URLRequest(url: Uri.parse(url)),
    //         androidOnPermissionRequest: (controller, origin, resources) async {
    //           return PermissionRequestResponse(
    //               resources: resources,
    //               action: PermissionRequestResponseAction.GRANT);
    //         },
    //         onLoadError: (ctrl, url, code, message) {
    //           print('messageerror $message');
    //         }),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    String url = item.url!;
    String title = item.title!;
    return GestureDetector(
      onTap: () {
        String path =
            '${RouteName.fileDetailScreen(companyId, teamId!, item.sId!)}?file-url=$url';
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'file',
            companyId: companyId,
            path: path,
            teamName: Get.put(TeamDetailController()).teamName,
            title: title,
            subtitle:
                'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Docs & Files  >  ${item.title}',
            uniqId: item.sId!));
        Get.toNamed(path);
      },
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffEEEEEE).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    child: url == '' ? SizedBox() : _buildFileType(),
                  ),
                  item.isPublic == true
                      ? SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock_rounded,
                              size: 18,
                            ),
                          ),
                        )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 8, bottom: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: Color(0xff979797),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
