import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ListHeader extends StatelessWidget {
  ListHeader({
    Key? key,
    required this.listItem,
  }) : super(key: key);

  final BoardListItemModel listItem;

  BoardController _boardController = Get.find<BoardController>();
  TextEditingController _controller = TextEditingController();

  onTapMore() {
    Get.bottomSheet(BottomSheetBoardListMore(
      listItem: listItem,
    ));
  }

  getIconCompleteStatus() {
    if (listItem.complete.status) {
      if (listItem.complete.type == 'done') {
        return Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 0),
          child: _buildButtonSetStatusType(Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          )),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 0),
          child: _buildButtonSetStatusType(Icon(
            Icons.block,
            color: Colors.red,
            size: 16,
          )),
        );
      }
    } else {
      return SizedBox();
    }
  }

  _buildButtonSetStatusType(Icon icon) {
    onToggleDone() {
      _boardController.toggleListAsComplete(listItem.sId, 'done');
    }

    onToggleBlock() {
      _boardController.toggleListAsComplete(listItem.sId, 'blocked');
    }

    return Container(
      child: SizedBox(
        width: 35,
        height: 30,
        child: PopupMenuButton(
          offset: Offset(14, 20),
          padding: EdgeInsets.all(0),
          iconSize: 16,
          icon: icon,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              height: 35,
              child: Text(
                "Change icon type",
                style: TextStyle(fontSize: 14, color: Color(0xff979797)),
              ),
              value: 0,
            ),
            PopupMenuItem(
              height: 35,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      width: 1.0,
                      color: listItem.complete.type == 'done'
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.5)),
                ),
                onPressed: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Done",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    )
                  ],
                ),
              ),
              value: 1,
            ),
            PopupMenuItem(
              height: 35,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      width: 1.0,
                      color: listItem.complete.type != 'done'
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.5)),
                ),
                onPressed: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Blocked",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Icons.block,
                      size: 16,
                      color: Colors.red,
                    )
                  ],
                ),
              ),
              value: 2,
            ),
          ],
          onSelected: (int value) {
            switch (value) {
              case 1:
                return onToggleDone();
              case 2:
                return onToggleBlock();

              default:
                return;
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Obx(() => Row(
              children: [
                getIconCompleteStatus(),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10),
                  child: _boardController.selectedListIdForChangeName ==
                          listItem.sId
                      ? TextField(
                          controller: _controller,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 20,
                          maxLength: 50,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                            counterStyle: TextStyle(
                              height: double.minPositive,
                            ),
                            counterText: "",
                            hintText: "Type your title board list...",
                            hintStyle: TextStyle(
                                color: Color(0xffB5B5B5), fontSize: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _controller.text = listItem.name;
                            _boardController.selectedListIdForChangeName =
                                listItem.sId;
                          },
                          child: Text(
                            listItem.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                )),
                Obx(() =>
                    _boardController.selectedListIdForChangeName == listItem.sId
                        ? InkWell(
                            onTap: () {
                              if (_controller.text.length > 0) {
                                _boardController.changeListTitle(
                                    _controller.text, listItem.sId);
                              }
                              _boardController.selectedListIdForChangeName = '';
                              FocusScope.of(context).unfocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: onTapMore,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.more_horiz),
                            ),
                          ))
              ],
            )));
  }
}

class BottomSheetBoardListMore extends StatelessWidget {
  BottomSheetBoardListMore({
    Key? key,
    required this.listItem,
  }) : super(key: key);
  final BoardListItemModel listItem;
  BoardController _boardController = Get.find();

  @override
  Widget build(BuildContext context) {
    String titleSetListStatus = listItem.complete.status
        ? 'Unset Complete List'
        : 'Set as a Complete List';
    return Container(
      height: 185,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          ListTile(
            onTap: () async {
              showAlert(message: 'All cards has been moved to archive');
              List<String> _list = [];

              listItem.cards.forEach((element) {
                _list.add(element.sId);
              });

              _boardController.archiveAllCardOnList(
                  listId: listItem.sId, cards: _list);
              await Future.delayed(Duration(milliseconds: 600));
              Get.back();
            },
            title: Text(
              'Archive all cards in this list',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff708FC7),
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
                constraints: BoxConstraints(maxHeight: 2), child: Divider()),
          ),
          ListTile(
            onTap: () async {
              showAlert(message: 'List has been moved to archive');
              _boardController.archiveList(listId: listItem.sId);

              await Future.delayed(Duration(milliseconds: 600));
              Get.back();
            },
            title: Text('Archive this list',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff708FC7),
                    fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
                constraints: BoxConstraints(maxHeight: 2), child: Divider()),
          ),
          ListTile(
            onTap: () async {
              if (listItem.complete.status) {
                _boardController.unSetListAsComplete(listItem.sId);

                await Future.delayed(Duration(milliseconds: 600));
                Get.back();
              } else {
                _boardController.setListAsComplete(listItem.sId);

                await Future.delayed(Duration(milliseconds: 600));
                Get.back();
              }
            },
            title: Text(
              titleSetListStatus,
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff708FC7),
                  fontWeight: FontWeight.w600),
            ),
            trailing: Icon(Icons.check_circle,
                color: listItem.complete.status ? Colors.grey : Colors.green),
          )
        ],
      ),
    );
  }
}
