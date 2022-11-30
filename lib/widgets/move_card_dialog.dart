import 'package:cicle_mobile_f3/controllers/move_card_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'error_something_wrong.dart';

class MoveCardDialog extends StatefulWidget {
  MoveCardDialog({
    Key? key,
    required this.onMove,
    required this.cardId,
    required this.boardId,
    required this.listId,
  }) : super(key: key);

  final Function(String sourceId, String destintionId) onMove;
  final String cardId;
  final String boardId;
  final String listId;

  @override
  _MoveCardDialogState createState() => _MoveCardDialogState();
}

class _MoveCardDialogState extends State<MoveCardDialog> {
  @override
  Widget build(BuildContext context) {
    return GetX<MoveCardController>(
        init: MoveCardController(),
        initState: (_) {
          _.controller!.getList(widget.boardId, widget.cardId, widget.listId);
        },
        builder: (controller) {
          if (controller.isLoading) {
            return Container(
              child: Material(
                child: Column(
                  children: [
                    AppBar(
                      elevation: 0.5,
                      leading: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.close,
                          size: 25,
                        ),
                      ),
                      title: Text(
                        'Move card',
                      ),
                      titleSpacing: 0,
                    ),
                    Expanded(child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            );
          }

          if (!controller.isLoading && controller.errorMessage != '') {
            return Container(
              child: Material(
                child: Column(
                  children: [
                    AppBar(
                      elevation: 0.5,
                      leading: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.close,
                          size: 25,
                        ),
                      ),
                      title: Text(
                        'Move card',
                      ),
                      titleSpacing: 0,
                    ),
                    Expanded(
                      child: Center(
                          child: ErrorSomethingWrong(
                        refresh: () async {
                          return controller.getList(
                              widget.boardId, widget.cardId, widget.listId);
                        },
                        message: controller.errorMessage,
                      )),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  AppBar(
                    elevation: 0.5,
                    leading: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        size: 25,
                      ),
                    ),
                    title: Text(
                      'Move card',
                    ),
                    titleSpacing: 0,
                    actions: [
                      IconButton(
                          onPressed: () {
                            if (controller.currentList.sId ==
                                controller.currentSourceList.sId) {
                              Get.back();
                            } else {
                              widget.onMove(controller.currentSourceList.sId,
                                  controller.currentList.sId);
                              Get.back();
                            }
                          },
                          icon: Icon(
                            Icons.check,
                            size: 25,
                            color: Theme.of(context).primaryColor,
                          ))
                    ],
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24.0, top: 16),
                        child: Text('List'),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(21, 8, 21, 21),
                    child: Material(
                        color: Colors.white,
                        child: DropdownSearch<BoardListItemModel>(
                          dropdownBuilder: (ctx, BoardListItemModel? listItem) {
                            return Text(listItem!.name,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14));
                          },
                          popupProps: PopupProps.menu(
                            itemBuilder: (ctx, listItem, string) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(23, 12, 23, 12),
                                child: Text(
                                  listItem.name,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              );
                            },
                          ),
                          items: controller.boardList,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: Color(0xffD8D8D8)),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(8.0),
                                  ),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  size: 40,
                                )),
                          ),
                          onChanged: (value) {
                            controller.currentList = value!;
                          },
                          selectedItem: controller.currentList,
                        )

                        // child: DropdownSearch<BoardListItemModel>(
                        //   mode: Mode.MENU,
                        //   dropdownButtonBuilder: (ctx) {
                        //     return SizedBox();
                        //   },
                        //   dropdownBuilder: (ctx, BoardListItemModel? listItem,
                        //       String? string) {
                        //     return Text(listItem!.name,
                        //         style:
                        //             TextStyle(color: Colors.black, fontSize: 14));
                        //   },
                        //   popupItemBuilder: (ctx, listItem, string) {
                        //     return Padding(
                        //       padding: const EdgeInsets.fromLTRB(23, 12, 23, 12),
                        //       child: Text(
                        //         listItem.name,
                        //         style:
                        //             TextStyle(color: Colors.black, fontSize: 14),
                        //       ),
                        //     );
                        //   },
                        //   items: controller.boardList,
                        //   maxHeight: 400,
                        //   hint: "country in menu mode",
                        //   onChanged: (value) {
                        //     controller.currentList = value!;
                        //   },
                        //   popupBackgroundColor: Color(0xffFAFAFA),
                        //   selectedItem: controller.currentList,
                        //   dropdownSearchDecoration: InputDecoration(
                        //       floatingLabelBehavior: FloatingLabelBehavior.never,
                        //       isDense: true,
                        //       contentPadding: EdgeInsets.only(left: 16),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius: new BorderRadius.circular(8.0),
                        //         borderSide: BorderSide(color: Color(0xffD8D8D8)),
                        //       ),
                        //       border: OutlineInputBorder(
                        //         borderRadius: const BorderRadius.all(
                        //           const Radius.circular(8.0),
                        //         ),
                        //       ),
                        //       suffixIcon: Icon(
                        //         Icons.arrow_drop_down,
                        //         size: 40,
                        //       )),
                        // ),
                        ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
