import 'package:cicle_mobile_f3/controllers/form_edit_team_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditTeam extends StatelessWidget {
  EditTeam({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  final Function({String name, String description}) onSave;

  @override
  Widget build(BuildContext context) {
    return GetX<EditTeamController>(
        init: EditTeamController(),
        builder: (_editTeamController) {
          return _editTeamController.teamName != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 23.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 35.w,
                      ),
                      Text(
                        'Team Name',
                        style: TextStyle(
                            fontSize: 12.w,
                            color: Color(0xff262727),
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20.w,
                      ),
                      _buildInputName(_editTeamController),
                      SizedBox(
                        height: 25.w,
                      ),
                      Text(
                        'Team Description',
                        style: TextStyle(
                            fontSize: 12.w,
                            color: Color(0xff262727),
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20.w,
                      ),
                      _buildInputDescription(_editTeamController),
                      SizedBox(
                        height: 27.w,
                      ),
                      _buildButtonSave(_editTeamController)
                    ],
                  ),
                )
              : SizedBox();
        });
  }

  Widget _buildButtonSave(EditTeamController _editTeamController) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.h),
              ))),
          onPressed: _editTeamController.teamName == '' ||
                  _editTeamController.teamDescription == ''
              ? null
              : () {
                  String name = _editTeamController.teamName;
                  String description = _editTeamController.teamDescription;
                  print(name);
                  print(description);

                  onSave(name: name, description: description);
                },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 0.w, horizontal: 30),
              child: Text(
                'Save',
                style: TextStyle(
                    fontSize: 12.w,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ))),
    );
  }

  Widget _buildInputName(_editTeamController) {
    return TextField(
      maxLines: 1,
      controller: _editTeamController.teamNameEditingController,
      onChanged: (String value) {
        _editTeamController.teamName = value;
      },
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        hintText: 'type name...',
        hintStyle: TextStyle(color: Color(0xffB5B5B5)),
        errorText: _editTeamController.teamName == ''
            ? 'field name is required'
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xffB5B5B5)),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
      ),
    );
  }

  TextField _buildInputDescription(_editTeamController) {
    return TextField(
      maxLines: 3,
      controller: _editTeamController.teamDescriptionEditingController,
      onChanged: (String value) {
        _editTeamController.teamDescription = value;
      },
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        hintText: "type description...",
        hintStyle: TextStyle(color: Color(0xffB5B5B5)),
        errorText: _editTeamController.teamDescription == ''
            ? 'field description is required'
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xffB5B5B5)),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
