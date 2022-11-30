import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/controllers/label_colors_controller.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'board_detail_screen.dart';

class LabelsWidget extends StatelessWidget {
  const LabelsWidget({Key? key, required this.boardDetailController})
      : super(key: key);

  final BoardDetailController boardDetailController;

  onTapNew() {
    if (boardDetailController.allLabels.length > 0) {
      Get.dialog(FormAddLabel(boardDetailController: boardDetailController));
    } else {
      Get.dialog(FormAddLabel(boardDetailController: boardDetailController));
      Get.dialog(FormAddNewLabel(
        onSubmit: (String labelName, ColorModel color) {
          print(color);
          // boardDetailController.addNewLabel(LabelModel(
          //     color: ColorModel(sId: color.sId, name: color.name),
          //     createdAt: DateTime.now().toString(),
          //     name: labelName,
          //     sId: getRandomString(20),
          //     updatedAt: DateTime.now().toString()));

          boardDetailController.addAllLabel(LabelModel(
              color: ColorModel(sId: color.sId, name: color.name),
              createdAt: DateTime.now().toString(),
              name: labelName,
              sId: getRandomString(20),
              updatedAt: DateTime.now().toString()));
          Get.back();
        },
      ));
    }
  }

  onDeleteCardLabel(value) async {
    try {
      String message = await boardDetailController.removeLabel(value);
      if (message != '') {
        showAlert(message: message);
      }
    } catch (e) {
      errorMessageMiddleware(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Obx(() {
            if (boardDetailController.isLoading) {
              return _buildLoading();
            }

            return _buildHasData();
          }),
        ),
      ),
    );
  }

  Column _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labels',
          style: label,
        ),
        SizedBox(
          height: 4,
        ),
        ShimmerCustom(
          height: 36,
          borderRadius: 17,
          width: double.infinity,
        )
      ],
    );
  }

  Obx _buildHasData() {
    return Obx(() {
      List<LabelModel> _list = boardDetailController.labels;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Labels',
            style: label,
          ),
          SizedBox(
            height: 2,
          ),
          Wrap(
            children: [
              InkWell(
                onTap: onTapNew,
                child: Container(
                  height: 22,
                  width: 40,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 1,
                          offset: Offset(1, 1),
                        ),
                      ],
                      color: Color(0xff708FC7),
                      borderRadius: BorderRadius.circular(3)),
                  child: Center(
                      child: Icon(Icons.add, color: Colors.white, size: 18)),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              ..._list
                  .asMap()
                  .map((key, value) => MapEntry(
                      key,
                      LabelItem(
                        item: value,
                        onDelete: () {
                          onDeleteCardLabel(value);
                        },
                      )))
                  .values
                  .toList()
            ],
          ),
        ],
      );
    });
  }
}

class LabelItem extends StatelessWidget {
  const LabelItem({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  final LabelModel item;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      margin: EdgeInsets.only(right: 5, bottom: 5),
      decoration: BoxDecoration(
          color: Color(0xffB5B5B5), borderRadius: BorderRadius.circular(3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 22,
              decoration: BoxDecoration(
                  color: HexColor(item.color.name),
                  borderRadius: BorderRadius.circular(3)),
              child: Center(
                  child: Text(
                item.name,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ))),
          InkWell(
            onTap: () {
              onDelete();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PopUpDeleteLabel extends StatelessWidget {
  PopUpDeleteLabel(
      {Key? key,
      required this.boardDetailController,
      required this.onDelete,
      required this.onCancel,
      this.showDescription = false})
      : super(key: key);

  final BoardDetailController boardDetailController;
  final Function onDelete;
  final Function onCancel;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(bottom: 12, left: 22, right: 22, top: 25),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          width: 258,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete label?',
                style: TextStyle(fontSize: 11),
              ),
              showDescription
                  ? Padding(
                      padding: const EdgeInsets.only(top: 19.0),
                      child: Text(
                        'Deleting label cause all related cards lose this label you’re about to delete',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xffFF7171), fontSize: 11),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 19,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      onCancel();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black, fontSize: 11),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  TextButton(
                    onPressed: () {
                      onDelete();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        'Delete',
                        style:
                            TextStyle(color: Color(0xffCF0F0F), fontSize: 11),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FormAddNewLabel extends StatefulWidget {
  FormAddNewLabel({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  final Function onSubmit;

  @override
  _FormAddNewLabelState createState() => _FormAddNewLabelState();
}

class _FormAddNewLabelState extends State<FormAddNewLabel> {
  final _listColor = [
    '#B9DD53',
    '#FF9898',
    '#EECC6F',
    '#C6ED95',
    '#C6ED95',
    '#FFB6F3',
    '#D38BF4',
    '#7299FF'
  ];

  int _selectedIndexColor = 0;

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _fullWidht = MediaQuery.of(context).size.width;
    double _fullWidhtContainer = _fullWidht - 40 - 20;
    double _fullWidthLabel = (_fullWidhtContainer - 61) / 4;
    return GetX<LabelsController>(
        init: LabelsController(),
        builder: (labelColorsController) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                width: 310,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 14,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Add new label',
                        style: TextStyle(
                            color: Color(0xff7A7A7A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 21,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 35,
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 15),
                            hintText: "Name your label...",
                            hintStyle: TextStyle(
                                color: Color(0xffB5B5B5), fontSize: 11),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5)),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Label color',
                        style:
                            TextStyle(color: Color(0xff7A7A7A), fontSize: 11),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    labelColorsController.colors.length == 0 &&
                            labelColorsController.isLoading
                        ? Container(
                            height: 100,
                            width: double.infinity,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Wrap(
                                children: labelColorsController.colors
                                    .asMap()
                                    .map((key, value) => MapEntry(
                                        key,
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedIndexColor = key;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                right: 3.5,
                                                left: 3.5,
                                                bottom: 9),
                                            width: _fullWidthLabel,
                                            height: 31,
                                            decoration: BoxDecoration(
                                                border:
                                                    key == _selectedIndexColor
                                                        ? Border.all(
                                                            color: Colors.grey,
                                                            width: 2)
                                                        : Border.all(
                                                            color: Colors.white,
                                                            width: 0),
                                                color: HexColor(value.name),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                        )))
                                    .values
                                    .toList(),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    !labelColorsController.isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xff708FC7)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ))),
                              onPressed: () {
                                if (_textEditingController.text == '' ||
                                    _textEditingController.text.length == 0) {
                                  return;
                                }
                                // Get.back();

                                widget.onSubmit(
                                    _textEditingController.text,
                                    labelColorsController
                                        .colors[_selectedIndexColor]);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.add,
                                  //   color: Colors.white,
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: Text(
                                      'submit',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class FormAddLabel extends StatefulWidget {
  FormAddLabel({Key? key, required this.boardDetailController})
      : super(key: key);
  final BoardDetailController boardDetailController;

  @override
  _FormAddLabelState createState() => _FormAddLabelState();
}

class _FormAddLabelState extends State<FormAddLabel> {
  final _listColor = [
    '#B9DD53',
    '#FF9898',
    '#EECC6F',
    '#C6ED95',
    '#C6ED95',
    '#FFB6F3',
    '#D38BF4',
    '#7299FF'
  ];

  int _selectedIndexColor = 0;

  TextEditingController _textEditingController = TextEditingController();
  String _keyWords = '';

  onDeleteLabel(value) {
    Get.dialog(PopUpDeleteLabel(
      boardDetailController: widget.boardDetailController,
      onCancel: () {
        Get.back();
      },
      onDelete: () {
        widget.boardDetailController.removeLabelOnAllLabel(value);
        Get.back();
      },
      showDescription: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          height: 389,
          width: 310,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 14,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Add label',
                  style: TextStyle(
                      color: Color(0xff7A7A7A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 21,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 35,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _keyWords = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 15),
                      hintText: "Search label...",
                      hintStyle:
                          TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                        borderSide:
                            BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Toggle Labels ${_textEditingController.text}',
                  style: TextStyle(color: Color(0xff7A7A7A), fontSize: 11),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Obx(() {
                  List<LabelModel> labels =
                      widget.boardDetailController.allLabels;
                  labels.sort((a, b) => a.name.compareTo(b.name));
                  return Container(
                    height: 190,
                    child: ListView(
                      children: labels
                          .where((element) => element.name
                              .toLowerCase()
                              .contains(_keyWords.toLowerCase()))
                          .toList()
                          .asMap()
                          .map((key, value) {
                            int isLabelIncludeOnLabels = widget
                                .boardDetailController.labels
                                .where((element) => element.sId == value.sId)
                                .length;

                            int isLabelInProgress = widget
                                .boardDetailController.labelsIdInProgress
                                .where((element) => element == value.sId)
                                .length;
                            return MapEntry(
                                key,
                                GestureDetector(
                                  onTap: () {
                                    if (isLabelInProgress > 0) {
                                      return;
                                    }
                                    if (isLabelIncludeOnLabels == 0) {
                                      widget.boardDetailController
                                          .addNewLabel(value);
                                    } else {
                                      widget.boardDetailController
                                          .removeLabel(value);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 4, left: 16, right: 16),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: HexColor(value.color.name)),
                                    padding: EdgeInsets.only(
                                        left: 15, top: 9, bottom: 9),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.2)),
                                          child: Text(
                                            value.name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                        isLabelInProgress > 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Center(
                                                  child: SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  isLabelIncludeOnLabels > 0
                                                      ? Container(
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.2),
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 16,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      onDeleteLabel(value);
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    12.0,
                                                                vertical: 0),
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                      ],
                                    ),
                                  ),
                                ));
                          })
                          .values
                          .toList(),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xff708FC7)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ))),
                  onPressed: () {
                    Get.dialog(FormAddNewLabel(
                      onSubmit: (String labelName, ColorModel color) {
                        widget.boardDetailController.addAllLabel(LabelModel(
                            color: ColorModel(sId: color.sId, name: color.name),
                            createdAt: DateTime.now().toString(),
                            name: labelName,
                            sId: getRandomString(20),
                            updatedAt: DateTime.now().toString()));
                        Get.back();
                      },
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          'Create new label',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
