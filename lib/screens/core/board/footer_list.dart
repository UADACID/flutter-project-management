import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FooterList extends StatefulWidget {
  FooterList({Key? key, required this.listItem}) : super(key: key);

  final BoardListItemModel listItem;

  @override
  State<FooterList> createState() => _FooterListState();
}

class _FooterListState extends State<FooterList> {
  BoardController _boardController = Get.find();

  bool showInput = false;

  bool _isPrivate = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('rebuild footer');
    return Obx(() => Padding(
          padding: const EdgeInsets.all(4.0),
          child: _boardController.selectedListIdForAddNewCard ==
                  widget.listItem.sId
              ? StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(left: 6.5, right: 6.5, bottom: 6),
                        decoration: BoxDecoration(
                          color: Color(0xffF0F1F6),
                          border: Border.all(color: Color(0xffE0E2EE)),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller,
                              autofocus: true,
                              minLines: 1,
                              maxLines: 2,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 8),
                                hintText: 'Your card name',
                                hintStyle: TextStyle(color: Color(0xffB5B5B5)),
                                border: InputBorder.none,
                                suffixIconConstraints: BoxConstraints(
                                    minHeight: 28, maxHeight: 28),
                                suffixIcon: GestureDetector(
                                    onTap: () async {
                                      if (_controller.text.length > 0) {
                                        FocusScope.of(context).unfocus();
                                        await Future.delayed(
                                            Duration(milliseconds: 200));
                                        _boardController.addNewCard(
                                            name: _controller.text,
                                            listId: widget.listItem.sId,
                                            isPrivate: _isPrivate);
                                        _controller.text = '';
                                      }
                                      setState(() {
                                        _isPrivate = false;
                                      });
                                      _boardController
                                          .selectedListIdForAddNewCard = '';
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Icon(Icons.check),
                                    )),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Switch(
                              value: _isPrivate,
                              onChanged: (value) {
                                setState(() {
                                  _isPrivate = value;
                                });
                              }),
                          Text(
                            'Private Card',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          )
                        ],
                      )
                    ],
                  );
                })
              : buildButton(),
        ));
  }

  Widget buildButton() {
    return Container(
      margin: EdgeInsets.only(left: 6, right: 6, bottom: 6),
      child: ElevatedButton(
        onPressed: () async {
          await Future.delayed(Duration(milliseconds: 200));
          _boardController.selectedListIdForAddNewCard = widget.listItem.sId;
        },
        style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(3),
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xffF0F1F6)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.add,
                color: Color(0xff393E46),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Text(
                  'Add new card',
                  style: TextStyle(
                      color: Color(0xff393E46), fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
