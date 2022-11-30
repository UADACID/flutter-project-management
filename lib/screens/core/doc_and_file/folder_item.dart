import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

class FolderItem extends StatelessWidget {
  FolderItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final DocFileItemModel item;

  final faker = Faker(provider: FakerDataProvider());
  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    final String imageFolder = 'assets/images/folder.svg';
    String folderName = item.title ?? '';
    List<DocFileItemModel> list = [
      ...item.buckets,
      ...item.docs,
      ...item.files
    ];

    return GestureDetector(
      onTap: () {
        String path =
            RouteName.folderDetailScreen(companyId, teamId!, item.sId!);
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'folder',
            companyId: companyId,
            path: path,
            teamName: Get.put(TeamDetailController()).teamName,
            title: item.title!,
            subtitle:
                'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Docs & Files  >  ${item.title}',
            uniqId: item.sId!));
        Get.toNamed(path);
      },
      child: Container(
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: SvgPicture.asset(
                      imageFolder,
                      semanticsLabel: 'folder',
                      fit: BoxFit.fill,
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xffEEEEEE),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 27),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 4.w,
                      ),
                      itemBuilder: (_, index) => _buildItem(list[index]),
                      itemCount: list.length,
                    ),
                  ),
                  item.isPublic == true
                      ? SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
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
                  Expanded(
                    child: Text(
                      folderName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Container _buildItem(DocFileItemModel itemValue) {
    if (itemValue.type == 'doc') {
      return Container(child: _buildTypeDoc(itemValue));
    }
    if (itemValue.type == 'file') {
      return Container(child: _buildTypeFile(itemValue));
    }
    return Container(
      child: _buildTypeFolder(itemValue),
    );
  }

  Widget _buildTypeFolder(DocFileItemModel itemValue) {
    final String imageFolder = 'assets/images/folder.svg';
    String title = itemValue.title ?? '';
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xffEEEEEE),
          border: Border.all(color: Color(0xffD6D6D6), width: 0.25)),
      child: Stack(
        children: [
          SvgPicture.asset(
            imageFolder,
            semanticsLabel: 'folder',
            fit: BoxFit.fill,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(fontSize: 9.w, fontWeight: FontWeight.bold),
            ),
          ),
          itemValue.isPublic == true
              ? SizedBox()
              : Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7.0, top: 4),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 11,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildTypeDoc(DocFileItemModel itemValue) {
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            border: Border.all(color: Color(0xffD6D6D6), width: 0.75)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemValue.title!,
                style: TextStyle(fontSize: 8.w, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2,
              ),
              itemValue.isPublic == true
                  ? HtmlWidget(
                      itemValue.content!,
                      textStyle: TextStyle(fontSize: 8.w),
                    )
                  : Icon(
                      Icons.lock_rounded,
                      size: 11,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFile(DocFileItemModel itemValue) {
    String title = itemValue.title ?? '';
    String mimeType = lookupMimeType(itemValue.url ?? '') ?? '';
    bool isImage = mimeType.contains('image');
    String ext = mimeType == '' ? '' : extensionFromMime(mimeType);
    Widget child = Container();
    if (isImage) {
      child = Image.network(
        getPhotoUrl(url: itemValue.url!),
        fit: BoxFit.cover,
      );
    } else {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            getPathExtention(mimeType: ext),
            fit: BoxFit.cover,
            height: 25,
            width: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title.toLowerCase(),
              style: TextStyle(fontSize: 8),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              border: Border.all(color: Color(0xffD6D6D6))),
          child:
              ClipRRect(borderRadius: BorderRadius.circular(5.0), child: child),
        ),
        itemValue.isPublic == true
            ? SizedBox()
            : Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white.withOpacity(0.80),
                    border: Border.all(color: Color(0xffD6D6D6))),
                child: Icon(
                  Icons.lock_rounded,
                  size: 11,
                ),
              )
      ],
    );
  }
}
