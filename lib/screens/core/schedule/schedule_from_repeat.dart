import 'package:cicle_mobile_f3/controllers/schedule_form_controller.dart';
import 'package:cicle_mobile_f3/models/repeat_model.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleFormRepeat extends StatelessWidget {
  ScheduleFormRepeat({
    Key? key,
  }) : super(key: key);

  ScheduleFormController _scheduleFormController =
      Get.put(ScheduleFormController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 23),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 11),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffECECEC), width: 1),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeat',
            style: TextStyle(fontSize: 11.sp),
          ),
          SizedBox(
            height: 5,
          ),
          Obx(() => DropdownSearch<RepeatModel>(
                dropdownBuilder: (
                  ctx,
                  RepeatModel? listItem,
                ) {
                  return Text(listItem!.name,
                      style: TextStyle(color: Colors.black, fontSize: 14));
                },
                popupProps: PopupProps.menu(
                  itemBuilder: (ctx, listItem, string) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(23, 12, 23, 12),
                      child: Text(
                        listItem.name,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    );
                  },
                ),
                items: _scheduleFormController.repeats,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      isDense: true,
                      contentPadding: EdgeInsets.only(left: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Color(0xffD8D8D8)),
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
                onChanged: (RepeatModel? value) {
                  print(value);
                  _scheduleFormController.selectedRepeat = value!;
                },
                selectedItem: _scheduleFormController.selectedRepeat,
              )),
          // Obx(() => DropdownSearch<RepeatModel>(
          //       searchBoxController:
          //           _scheduleFormController.repeatTextEditingController,
          //       mode: Mode.MENU,
          //       dropdownButtonBuilder: (ctx) {
          //         return SizedBox();
          //       },
          //       dropdownBuilder: (ctx, RepeatModel? listItem, String? string) {
          //         return Text(listItem!.name,
          //             style: TextStyle(color: Colors.black, fontSize: 14));
          //       },
          //       popupItemBuilder: (ctx, listItem, string) {
          //         return Padding(
          //           padding: const EdgeInsets.fromLTRB(23, 12, 23, 12),
          //           child: Text(
          //             listItem.name,
          //             style: TextStyle(color: Colors.black, fontSize: 14),
          //           ),
          //         );
          //       },
          //       items: _scheduleFormController.repeats,
          //       maxHeight: 300,
          //       hint: "country in menu mode",
          //       onChanged: (RepeatModel? value) {
          //         print(value);
          //         _scheduleFormController.selectedRepeat = value!;
          //       },
          //       popupBackgroundColor: Color(0xffFAFAFA),
          //       selectedItem: _scheduleFormController.selectedRepeat,
          //       dropdownSearchDecoration: InputDecoration(
          //           floatingLabelBehavior: FloatingLabelBehavior.never,
          //           isDense: true,
          //           contentPadding: EdgeInsets.only(left: 16),
          //           enabledBorder: OutlineInputBorder(
          //             borderRadius: new BorderRadius.circular(8.0),
          //             borderSide: BorderSide(color: Color(0xffD8D8D8)),
          //           ),
          //           border: OutlineInputBorder(
          //             borderRadius: const BorderRadius.all(
          //               const Radius.circular(8.0),
          //             ),
          //           ),
          //           suffixIcon: Icon(
          //             Icons.arrow_drop_down,
          //             size: 40,
          //           )),
          //     )),
          SizedBox(
            height: 10,
          ),
          Obx(() => _scheduleFormController.selectedRepeat.name ==
                  "Don't repeat"
              ? SizedBox()
              : Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListTile(
                        onTap: () {
                          _scheduleFormController.selectedAdditionalRepeat =
                              RepeatType.forever;
                        },
                        title: const Text('Forever'),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 16.0),
                        dense: true,
                        leading: Radio<RepeatType>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: RepeatType.forever,
                          groupValue:
                              _scheduleFormController.selectedAdditionalRepeat,
                          onChanged: (RepeatType? value) {
                            _scheduleFormController.selectedAdditionalRepeat =
                                value!;
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 120,
                          child: Container(
                            child: ListTile(
                              title: const Text('Until'),
                              onTap: () {
                                _scheduleFormController
                                        .selectedAdditionalRepeat =
                                    RepeatType.Until;
                              },
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 16.0),
                              dense: true,
                              leading: Container(
                                child: Radio<RepeatType>(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  value: RepeatType.Until,
                                  groupValue: _scheduleFormController
                                      .selectedAdditionalRepeat,
                                  onChanged: (RepeatType? value) async {
                                    _scheduleFormController
                                        .selectedAdditionalRepeat = value!;

                                    if (value == RepeatType.forever) {
                                      await Future.delayed(
                                          Duration(milliseconds: 600));
                                      _scheduleFormController
                                          .repeatUntilTextEditingController
                                          .text = '';
                                    } else {
                                      final String formattedInitDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now());
                                      await Future.delayed(
                                          Duration(milliseconds: 600));
                                      _scheduleFormController
                                          .repeatUntilTextEditingController
                                          .text = formattedInitDate;
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        _scheduleFormController.selectedAdditionalRepeat ==
                                RepeatType.Until
                            ? Flexible(
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Obx(() {
                                    DateTime initStartDate =
                                        _scheduleFormController.startDate == ''
                                            ? DateTime.now()
                                            : DateTime(
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .startDate)
                                                    .year,
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .startDate)
                                                    .month,
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .startDate)
                                                    .day);
                                    DateTime initDate =
                                        _scheduleFormController.endDate ==
                                                ''
                                            ? DateTime.now()
                                            : DateTime(
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .endDate)
                                                    .year,
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .endDate)
                                                    .month,
                                                DateTime.parse(
                                                        _scheduleFormController
                                                            .endDate)
                                                    .day);
                                    String initValue = initDate.toString();
                                    return DateTimePicker(
                                        type: DateTimePickerType.date,
                                        decoration: InputDecoration(
                                          hintText: 'date',
                                          contentPadding: EdgeInsets.only(
                                              left: 5,
                                              bottom: 3.w,
                                              top: 11.w,
                                              right: 15),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                        initialValue: initValue,
                                        firstDate: initStartDate,
                                        lastDate: DateTime(
                                            DateTime.now().year + 1,
                                            DateTime.now().month,
                                            DateTime.now().day),
                                        dateLabelText: '',
                                        onChanged: (val) {
                                          String result =
                                              DateFormat("yyyy-MM-dd HH:mm:ss")
                                                  .format(DateTime.parse(val));
                                          _scheduleFormController
                                              .repeatUntilTextEditingController
                                              .text = result;
                                        });
                                  }),
                                ),
                              )
                            : SizedBox()
                      ],
                    )
                  ],
                ))
        ],
      ),
    );
  }
}
