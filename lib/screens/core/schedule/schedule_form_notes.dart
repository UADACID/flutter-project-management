import 'package:cicle_mobile_f3/controllers/schedule_form_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/form_add_notes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class ScheduleFormNotes extends StatelessWidget {
  ScheduleFormNotes({
    Key? key,
  }) : super(key: key);

  ScheduleFormController scheduleFormController =
      Get.put(ScheduleFormController());

  ontapNotes() {
    Get.to(
      Container(
        height: Get.height,
        width: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: FormAddNote(
          initialData: scheduleFormController.notes,
          onSubmit: (String? text) async {
            scheduleFormController.notes = text ?? '';
            await Future.delayed(Duration(seconds: 1));
            Get.back();
          },
          members: scheduleFormController.teamMembers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 1, color: Color(0xffECECEC)),
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.only(left: 13, top: 11, bottom: 11, right: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: TextStyle(fontSize: 11),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: ontapNotes,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xffECECEC)),
                    borderRadius: BorderRadius.circular(20)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Obx(() => Stack(
                              children: [
                                HtmlWidget(
                                  scheduleFormController.notes,
                                  onTapUrl: parseLinkPressed,
                                ),
                                removeHtmlTag(scheduleFormController.notes) ==
                                        ''
                                    ? Text(
                                        'Add a detailed notes here...',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xffB5B5B5)),
                                      )
                                    : Container()
                              ],
                            )))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
