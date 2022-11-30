import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/dialog_selectable_webview.dart';
import 'package:cicle_mobile_f3/widgets/form_add_notes.dart';
import 'package:cicle_mobile_f3/widgets/inline_widget_html.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'board_detail_screen.dart';

class NotesWidget extends StatelessWidget {
  NotesWidget({
    Key? key,
    required this.boardDetailController,
  }) : super(key: key);

  final BoardDetailController boardDetailController;

  String dummy = '''
  You can view a complete example 
  ''';

  ontapNotes() {
    Get.to(
      Container(
        height: Get.height,
        width: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: FormAddNote(
          members: boardDetailController.teamMembers,
          initialData: boardDetailController.notes,
          onSubmit: (String? text) async {
            boardDetailController.updateDesc(text ?? '');
            await Future.delayed(Duration(seconds: 1));
            Get.back();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 18),
        child: Container(
            width: double.infinity,
            child: Obx(() {
              if (boardDetailController.isLoading) {
                return _buildLoading();
              }

              return _buildHasData();
            })),
      ),
    );
  }

  Column _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: label,
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          width: double.infinity,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerCustom(
                        height: 15,
                        borderRadius: 0,
                        width: 200.w,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      ShimmerCustom(
                        height: 15,
                        borderRadius: 0,
                        width: 170.w,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      ShimmerCustom(
                        height: 15,
                        borderRadius: 0,
                        width: 140.w,
                      ),
                    ],
                  ))),
        ),
      ],
    );
  }

  _onLongPressItem(String content) {
    Get.dialog(DialogSelectableWebView(
        content: content
            .replaceAll(">target='_blank'", "")
            .replaceAll("id='isPasted'>", "")
        // .replaceAll(
        //     RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)'), "")
        ));
    showAlert(message: 'to copy text you can select the content below');
  }

  Column _buildHasData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Description',
              style: label,
            ),
            GestureDetector(
              onTap: ontapNotes,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                child: Icon(
                  MyFlutterApp.edit,
                  size: 18,
                  color: Color(0xff7A7A7A),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Obx(() {
          if (boardDetailController.showFullNote) {
            return Column(
              children: [
                _buildHtmlWidget(),
                InkWell(
                    onTap: () {
                      boardDetailController.showFullNote = false;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'show less note',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.withOpacity(0.9)),
                      ),
                    ))
              ],
            );
          }

          if (boardDetailController.notes == '') {
            return Text('-',
                style: TextStyle(fontSize: 11, color: Colors.grey));
          }

          return Stack(
            children: [
              Container(
                  height: boardDetailController.maxHeightShowMore.toDouble(),
                  child: IgnorePointer(
                    child: SingleChildScrollView(
                        child: WidgetSize(
                            onChange: (Size mapSize) {
                              if (mapSize.height >= 120) {
                                boardDetailController.maxHeightShowMore = 120;
                              } else {
                                boardDetailController.maxHeightShowMore =
                                    mapSize.height.toInt() + 20;
                              }
                            },
                            child: _buildHtmlWidget())),
                  )),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.5),
                      Colors.white,
                      Colors.white,
                    ],
                  )),
                  height: 80,
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: InkWell(
                        onTap: () {
                          boardDetailController.showFullNote = true;
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'show more note',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.withOpacity(0.9)),
                          ),
                        )),
                  )),
                ),
              )
            ],
          );
        })
      ],
    );
  }

  Container _buildHtmlWidget() {
    return Container(
      width: double.infinity,
      child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() => GestureDetector(
                    onLongPress: () {
                      _onLongPressItem(boardDetailController.notes);
                    },
                    child: HtmlWidget(
                      boardDetailController.notes,
                      factoryBuilder: () => InlineWidget(),
                      onTapUrl: parseLinkPressed,
                      onTapImage: (ImageMetadata imageData) {
                        String url = imageData.sources.length > 0
                            ? imageData.sources.first.url
                            : 'default uri';
                        Get.dialog(PhotoViewSection(
                          url: url,
                        ));
                      },
                      customWidgetBuilder: (element) {
                        if (element.localName == 'video') {
                          print(element);
                          String url = element.attributes['src'].toString();
                          print(url);
                          return GestureDetector(
                            onTap: () async {
                              print('on tap');
                              parseLinkPressed(url);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ConstrainedBox(
                                constraints: new BoxConstraints(
                                  minHeight: 75.0,
                                  minWidth: 150.0,
                                  maxHeight: 200.0,
                                  maxWidth: 300.0,
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
                            ),
                          );
                        }

                        return null;
                      },
                    ),
                  )))),
    );
  }
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _WidgetSizeState createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
