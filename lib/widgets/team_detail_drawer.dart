import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'edit_menu.dart';
import 'edit_team.dart';

class TeamDetailDrawer extends StatefulWidget {
  const TeamDetailDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _TeamDetailDrawerState createState() => _TeamDetailDrawerState();
}

class _TeamDetailDrawerState extends State<TeamDetailDrawer> {
  TeamDetailController _teamDetailController = Get.find();

  bool _showEditTeam = false;
  bool _showEditMenu = false;

  onSaveEditTeam({name, description}) async {
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration(milliseconds: 300));
    _teamDetailController.updateTeam(name, description);
    setState(() {
      _showEditTeam = false;
    });
  }

  onSaveEditMenu() {
    setState(() {
      _showEditMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showEditTeam == true || _showEditMenu == true) {
          setState(() {
            _showEditTeam = false;
            _showEditMenu = false;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Drawer(
            child: Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Settings',
                      style:
                          TextStyle(color: Color(0xff7A7A7A), fontSize: 16.w),
                    ),
                    onTap: () {
                      Get.back();
                    },
                    trailing: Icon(Icons.settings_outlined),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Divider(),
                  ),
                  _showEditTeam
                      ? Column(
                          children: [
                            ListTile(
                              leading: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showEditTeam = false;
                                    });
                                  },
                                  icon: Icon(Icons.arrow_back_outlined)),
                              title: Text(
                                'Edit Team',
                                style: TextStyle(color: Color(0xffF0B418)),
                              ),
                              onTap: () {
                                setState(() {
                                  _showEditTeam = false;
                                });
                              },
                            ),
                            EditTeam(
                              onSave: onSaveEditTeam,
                            ),
                          ],
                        )
                      : _showEditMenu == false
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: ListTile(
                                leading: Icon(MyFlutterApp.icon_editteam,
                                    size: 32.w, color: Color(0xffF0B418)),
                                title: Text(
                                  'Edit Team',
                                  style: TextStyle(color: Color(0xffF0B418)),
                                ),
                                onTap: () {
                                  setState(() {
                                    _showEditTeam = true;
                                  });
                                },
                              ),
                            )
                          : Container(),
                  _showEditMenu
                      ? Column(
                          children: [
                            ListTile(
                              leading: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showEditMenu = false;
                                    });
                                  },
                                  icon: Icon(Icons.arrow_back_outlined)),
                              title: Text(
                                'Edit Menu',
                                style: TextStyle(color: Color(0xffF0B418)),
                              ),
                              onTap: () {
                                setState(() {
                                  _showEditMenu = false;
                                });
                              },
                            ),
                            EditMenu(onSave: onSaveEditMenu)
                          ],
                        )
                      : _showEditTeam == false
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: ListTile(
                                leading: Icon(
                                  MyFlutterApp.vector__2_,
                                  color: Color(0xffF0B418),
                                ),
                                title: Text(
                                  'Edit Menu',
                                  style: TextStyle(color: Color(0xffF0B418)),
                                ),
                                onTap: () {
                                  setState(() {
                                    _showEditMenu = true;
                                  });
                                },
                              ),
                            )
                          : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
