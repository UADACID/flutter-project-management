import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:cicle_mobile_f3/controllers/board_filter_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/label_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_color/random_color.dart';

class FilterBoard extends StatelessWidget {
  FilterBoard({
    Key? key,
  }) : super(key: key);

  BoardController _boardController = Get.find();
  BoardFilterController _boardFilterController = Get.find();

  showDialogFilter() {
    _boardFilterController.name = _boardController.filteredName;
    _boardFilterController.selectedLabels = [
      ..._boardController.selectedLabels
    ];
    _boardFilterController.selectedMembers = [
      ..._boardController.selectedMembers
    ];
    _boardFilterController.isDueToday = _boardController.isDueToday;
    _boardFilterController.isDueSoon = _boardController.isDueSoon;
    _boardFilterController.isOverDue = _boardController.isOverDue;
    Get.dialog(CardFilter(
      controller: _boardFilterController,
      onApply: (name, selectedLabels, selectedMembers, isDueSoon, isDueToday,
          isOverDue) {
        _boardController.filteredName = name;
        _boardController.updateSeletedlabels(selectedLabels);
        _boardController.updateSeletedMembers(selectedMembers);
        _boardController.isDueSoon = isDueSoon;
        _boardController.isDueToday = isDueToday;
        _boardController.isOverDue = isOverDue;
        Get.back();
      },
    ));
  }

  isFilterActive() {
    bool isNameEmpty = _boardController.filteredName == '' ? false : true;
    bool isDueSoonActive = _boardController.isDueSoon ? true : false;
    bool isDueTodayActive = _boardController.isDueToday ? true : false;
    bool isOverDueActive = _boardController.isOverDue ? true : false;
    bool isAnyMemberFilterSelected =
        _boardController.selectedMembers.length > 0 ? true : false;
    bool isAnyLabelFilterSelected =
        _boardController.selectedLabels.length > 0 ? true : false;

    if (isNameEmpty ||
        isDueSoonActive ||
        isDueTodayActive ||
        isOverDueActive ||
        isAnyMemberFilterSelected ||
        isAnyLabelFilterSelected) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: showDialogFilter,
        child: Padding(
          padding: const EdgeInsets.all(7.5),
          child: Obx(() => Icon(
                Icons.filter_alt_outlined,
                color: isFilterActive()
                    ? Theme.of(context).primaryColor
                    : Color(0xffB5B5B5),
              )),
        ),
      ),
    );
  }
}

class CardFilter extends StatefulWidget {
  CardFilter({
    Key? key,
    required this.onApply,
    required this.controller,
    this.leading,
    this.hideFilterName = false,
  }) : super(key: key);

  final Function onApply;
  final BoardFilterController controller;
  final Widget? leading;
  final bool hideFilterName;

  @override
  _CardFilterState createState() => _CardFilterState();
}

class _CardFilterState extends State<CardFilter> {
  late FocusNode _focusNodeInputCardName;

  bool _isFocusInputCardName = false;
  String _keywordInputCardName = '';
  TextEditingController _textEditingControllerInputCardName =
      TextEditingController(text: '');

  late FocusNode _focusNode;
  bool _isFocus = false;
  String _keyword = '';
  TextEditingController _textEditingController =
      TextEditingController(text: '');
  RandomColor _randomColor = RandomColor();
  BoardController _boardController = Get.find<BoardController>();

  TeamDetailController _teamDetailController = Get.find();

  @override
  void initState() {
    _textEditingControllerInputCardName.text = widget.controller.name;
    setState(() {
      _keywordInputCardName = widget.controller.name;
    });
    _focusNodeInputCardName = FocusNode();
    _focusNodeInputCardName.addListener(() {
      if (_focusNodeInputCardName.hasFocus) {
        setState(() {
          _isFocusInputCardName = true;
        });
      } else {
        setState(() {
          _isFocusInputCardName = false;
        });
      }
    });
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isFocus = true;
        });
      } else {
        setState(() {
          _isFocus = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment:
            _isFocus ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          SizedBox(
            height: _isFocus ? 20 : 30,
          ),
          Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.only(top: 2, bottom: 10),
              width: 310,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.leading != null
                          ? widget.leading!
                          : Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('Card Filters',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xff7A7A7A),
                                      fontWeight: FontWeight.w600)),
                            ),
                      TextButton(
                          onPressed: () {
                            widget.controller.reset();
                            _textEditingControllerInputCardName.text = '';
                            setState(() {
                              _keywordInputCardName = '';
                            });
                          },
                          child: Text('reset',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xffFF7171))))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      widget.hideFilterName
                          ? SizedBox()
                          : _buildCardTitleFilter(),
                      SizedBox(
                        height: 10,
                      ),
                      _buildLabelsFilter(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildMembersFilter(),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 20),
                        child: _buildDueDate(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildButtonApply(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildCardTitleFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Name Filter',
                  style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A)))),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _textEditingControllerInputCardName,
            focusNode: _focusNodeInputCardName,
            onChanged: (value) {
              setState(() {
                _keywordInputCardName = value;
              });
            },
            style: TextStyle(fontSize: 11),
            decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                hintText: "Search card name...",
                hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: _keywordInputCardName.length > 0
                    ? GestureDetector(
                        onTap: () {
                          _textEditingControllerInputCardName.text = '';
                          setState(() {
                            _keywordInputCardName = '';
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                suffixIconConstraints:
                    BoxConstraints(minHeight: 28, maxHeight: 28)),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Container _buildLabelsFilter() {
    return Container(
      height: 170,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Labels Filter',
                    style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A)))),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(child: Obx(() {
            List<LabelModel> labels = _boardController.allLabels;
            labels.sort((a, b) => a.name.compareTo(b.name));
            return ListView.builder(
                itemCount: labels.length,
                itemBuilder: (ctx, index) {
                  LabelModel label = labels[index];
                  return Obx(() {
                    int isLabelOnSelectedList = widget.controller.selectedLabels
                        .where((element) => element.sId == label.sId)
                        .length;
                    return GestureDetector(
                      onTap: () {
                        if (isLabelOnSelectedList > 0) {
                          widget.controller.removeLabel(label);
                        } else {
                          widget.controller.addSelectedLabel(label);
                        }
                      },
                      child: Container(
                        height: 35,
                        margin: EdgeInsets.only(bottom: 4, right: 16, left: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: HexColor(label.color.name),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2.5)),
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  label.name,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                            isLabelOnSelectedList > 0
                                ? Container(
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.check,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    );
                  });
                });
          })),
        ],
      ),
    );
  }

  Container _buildMembersFilter() {
    return Container(
      height: _isFocus ? 230 : 180,
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Company Members Filter',
                  style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A)))),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _textEditingController,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                _keyword = value;
              });
            },
            style: TextStyle(fontSize: 11),
            decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                hintText: "Search name...",
                hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                enabledBorder: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(5.0),
                  ),
                ),
                suffixIcon: _keyword.length > 0
                    ? GestureDetector(
                        onTap: () {
                          _textEditingController.text = '';
                          setState(() {
                            _keyword = '';
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(Get.context!).primaryColor,
                        ),
                      ),
                suffixIconConstraints:
                    BoxConstraints(minHeight: 28, maxHeight: 28)),
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: Obx(() {
              List<MemberModel> _allTeamMember = _teamDetailController
                  .teamMembers
                  .where((element) => element.fullName
                      .toLowerCase()
                      .contains(_keyword.toLowerCase()))
                  .toList();
              _allTeamMember.sort((a, b) =>
                  a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
              return ListView.builder(
                  itemCount: _allTeamMember.length,
                  itemBuilder: (ctx, index) {
                    MemberModel member = _allTeamMember[index];

                    Color _color = _randomColor.randomColor(
                        colorBrightness: ColorBrightness.light);

                    return Obx(() {
                      int isMemberOnSelectedList = widget
                          .controller.selectedMembers
                          .where((element) => element.sId == member.sId)
                          .length;
                      return InkWell(
                        onTap: () {
                          if (isMemberOnSelectedList > 0) {
                            widget.controller.removeMember(member);
                          } else {
                            widget.controller.addSelectedMember(member);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 2),
                          padding: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffD6D6D6)),
                              borderRadius: BorderRadius.circular(5)),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.only(left: 18),
                                  child: AvatarCustom(
                                      height: 25,
                                      child: Image.network(
                                        getPhotoUrl(url: member.photoUrl),
                                        height: 25,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                              ),
                              Center(
                                  child: Text(
                                member.fullName,
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xff7A7A7A)),
                              )),
                              isMemberOnSelectedList > 0
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Icon(
                                            Icons.check,
                                            size: 20,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )))
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    });
                  });
            }),
          )
        ],
      ),
    );
  }

  Widget _buildDueDate() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due Today',
                  style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A))),
              Obx(() => Checkbox(
                    value: widget.controller.isDueToday,
                    onChanged: (value) {
                      widget.controller.isDueToday = value!;
                      widget.controller.isDueSoon = false;
                      widget.controller.isOverDue = false;
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due Soon',
                  style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A))),
              Obx(() => Checkbox(
                    value: widget.controller.isDueSoon,
                    onChanged: (value) {
                      widget.controller.isDueSoon = value!;
                      widget.controller.isDueToday = false;
                      widget.controller.isOverDue = false;
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Over Due',
                  style: TextStyle(fontSize: 12, color: Color(0xff7A7A7A))),
              Obx(() => Checkbox(
                    value: widget.controller.isOverDue,
                    onChanged: (value) {
                      widget.controller.isOverDue = value!;
                      widget.controller.isDueSoon = false;
                      widget.controller.isDueToday = false;
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ))
            ],
          )
        ],
      ),
    );
  }

  ElevatedButton _buildButtonApply() {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Color(0xff708FC7)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ))),
      onPressed: () {
        widget.onApply(
            _textEditingControllerInputCardName.text,
            widget.controller.selectedLabels,
            widget.controller.selectedMembers,
            widget.controller.isDueSoon,
            widget.controller.isDueToday,
            widget.controller.isOverDue);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Apply',
            style: TextStyle(color: Colors.white, fontSize: 11),
          )
        ],
      ),
    );
  }
}
