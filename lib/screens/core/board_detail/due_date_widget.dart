import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'board_detail_screen.dart';

class DueDateWidget extends StatelessWidget {
  const DueDateWidget({
    Key? key,
    required this.boardDetailController,
  }) : super(key: key);
  final BoardDetailController boardDetailController;

  onPressDueDate() {
    print('object');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 2, bottom: 15),
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
          'Due Date',
          style: label,
        ),
        SizedBox(
          height: 6,
        ),
        ShimmerCustom(
          height: 36,
          borderRadius: 17,
          width: double.infinity,
        )
      ],
    );
  }

  Column _buildHasData() {
    getContainerColor() {
      if (boardDetailController.listItem.complete.status) {
        if (boardDetailController.listItem.complete.type == "done") {
          return Colors.green;
        } else {
          return Colors.grey.withOpacity(0.25);
        }
      } else {
        return getDueCardColor(
            DateTime.parse(boardDetailController.dueDate).toLocal());
      }
    }

    getLocalTextColor() {
      if (boardDetailController.listItem.complete.status) {
        if (boardDetailController.listItem.complete.type == "done") {
          return Colors.white;
        } else {
          return Colors.red;
        }
      } else {
        return getDueTextColor(
            DateTime.parse(boardDetailController.dueDate).toLocal());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due dates',
          style: label,
        ),
        SizedBox(
          height: 4,
        ),
        Obx(() => boardDetailController.dueDate == ''
            ? Stack(
                children: [
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                        color: Color(0xff708FC7),
                        borderRadius: BorderRadius.circular(17)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timelapse,
                            color: Colors.white,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 16),
                            child: Text(
                              'Set due date',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Obx(() => DateTimePicker(
                        controller:
                            boardDetailController.textEditingControllerDueDate,
                        locale: Locale('en', 'US'),
                        use24HourFormat: false,
                        textAlign: TextAlign.center,
                        type: DateTimePickerType.dateTime,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 17, top: 12, right: 15),
                        ),
                        style: TextStyle(
                            color: boardDetailController.dueDate == ''
                                ? Colors.transparent
                                : getLocalTextColor(),
                            fontWeight: FontWeight.normal,
                            fontSize: 11),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        dateLabelText: '',
                        onChanged: (val) =>
                            boardDetailController.updateDueDate(val),
                      )),
                ],
              )
            : _buildFullFillDueDate(getContainerColor, getLocalTextColor))
      ],
    );
  }

  Stack _buildFullFillDueDate(getContainerColor(), getLocalTextColor()) {
    return Stack(
      children: [
        Row(
          children: [
            Obx(() => boardDetailController.dueDate == ''
                ? Text(
                    '-',
                    style: TextStyle(color: Colors.grey),
                  )
                : Stack(
                    children: [
                      Container(
                          height: 26,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                              color: boardDetailController.dueDate == ''
                                  ? Color(0xff708FC7)
                                  : getContainerColor(),
                              borderRadius: BorderRadius.circular(3)),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                          child: Row(
                            children: [
                              boardDetailController.listItem.complete.status &&
                                      boardDetailController.dueDate != ''
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 0.0),
                                        child: Icon(
                                            getIconDueDate(
                                                boardDetailController.listItem),
                                            color: getLocalTextColor(),
                                            size: 16),
                                      ))
                                  : SizedBox(),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                boardDetailController.dueDate,
                                style: TextStyle(
                                    fontSize: 12, color: getLocalTextColor()),
                              ),
                            ],
                          )),
                    ],
                  )),
            SizedBox(
              width: 3,
            ),
            Obx(() => boardDetailController.dueDate != ''
                ? InkWell(
                    onTap: () {
                      boardDetailController
                          .removeDueDate(boardDetailController.dueDate);
                    },
                    child: Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ],
                          color: Color(0xffD45757),
                          borderRadius: BorderRadius.circular(3)),
                      child: Center(
                          child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      )),
                    ),
                  )
                : SizedBox()),
            Expanded(child: SizedBox()),
          ],
        ),
        Container(
          color: Colors.blue.withOpacity(0.0),
          width: 120,
          height: 27,
          child: DateTimePicker(
            controller: boardDetailController.textEditingControllerDueDate,
            locale: Locale('en', 'US'),
            use24HourFormat: false,
            textAlign: TextAlign.center,
            type: DateTimePickerType.dateTime,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 15, bottom: 17, top: 12, right: 15),
            ),
            style: TextStyle(
                color: Colors.transparent,
                fontWeight: FontWeight.normal,
                fontSize: 11),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            dateLabelText: '',
            onChanged: (val) => boardDetailController.updateDueDate(val),
          ),
        )
      ],
    );
  }
}
