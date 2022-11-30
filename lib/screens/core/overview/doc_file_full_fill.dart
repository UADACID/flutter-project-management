import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mime/mime.dart';

class DocFileFullFill extends StatelessWidget {
  const DocFileFullFill({Key? key, this.list = const []}) : super(key: key);

  final List<DocFileItemModel> list;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Color(0xfff4f4f4)),
      padding: EdgeInsets.all(5),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 58 / 60,
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        children: [
          ...list
              .asMap()
              .map((key, value) {
                DocFileItemModel item = value;
                return MapEntry(key, _buildItem(item));
              })
              .values
              .toList(),
        ],
      ),
    );
  }

  Container _buildItem(DocFileItemModel item) {
    if (item.type == 'doc') {
      return Container(child: _buildTypeDoc(item));
    }
    if (item.type == 'file') {
      return Container(child: _buildTypeFile(item));
    }
    return Container(
      child: _buildTypeFolder(item),
    );
  }

  Widget _buildTypeFolder(DocFileItemModel item) {
    final String imageFolder = 'assets/images/folder.svg';
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
            child: Row(
              children: [
                SizedBox(
                  width: 8,
                ),
                item.isPublic == false
                    ? Padding(
                        padding: const EdgeInsets.only(right: 6.0, top: 2),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 9,
                        ),
                      )
                    : SizedBox(),
                Expanded(
                  child: Text(
                    item.title!,
                    maxLines: 1,
                    style:
                        TextStyle(fontSize: 9.w, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDoc(DocFileItemModel item) {
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
              Row(
                children: [
                  item.isPublic == false
                      ? Padding(
                          padding: const EdgeInsets.only(right: 2.0, top: 2.5),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 9,
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    child: Text(
                      item.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 8.w, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              HtmlWidget(item.content!, textStyle: TextStyle(fontSize: 8.w),
                  customWidgetBuilder: (element) {
                if (element.localName == 'video') {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: 50.0,
                        minWidth: 100.0,
                        maxHeight: 60.0,
                        maxWidth: 120.0,
                      ),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return null;
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFile(DocFileItemModel item) {
    String title = item.title ?? '';
    String mimeType = lookupMimeType(item.url ?? '') ?? '';
    bool isImage = mimeType.contains('image');
    String ext = mimeType == '' ? '' : extensionFromMime(mimeType);
    Widget child = Container();
    if (isImage) {
      child = Image.network(
        item.url!,
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

    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          border: Border.all(color: Color(0xffD6D6D6))),
      child: ClipRRect(borderRadius: BorderRadius.circular(5.0), child: child),
    );
  }
}
