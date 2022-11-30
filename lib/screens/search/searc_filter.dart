import 'package:cicle_mobile_f3/controllers/search_filter_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFilter extends StatelessWidget {
  const SearchFilter({
    Key? key,
  }) : super(key: key);

  BorderRadius getBorderRadius(int length, int index) {
    if (length > 1) {
      // check apakah index pertama
      // check apakah index terakhir
      // check apakah index diantara pertama & terakhir
      if (index == 0) {
        return BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10));
      } else if (index == length - 1) {
        return BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10));
      } else {
        return BorderRadius.circular(3);
      }
    } else {
      return BorderRadius.circular(10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height - 200,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: GetX<SearchFilterController>(
          init: SearchFilterController(),
          initState: (state) {
            state.controller!.getPreviousData();
          },
          builder: (controller) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 11),
                  height: 6,
                  width: 79,
                  decoration: BoxDecoration(
                      color: Color(0xffD6D6D6),
                      borderRadius: BorderRadius.circular(5)),
                ),
                SizedBox(
                  height: 32,
                ),
                _buildHeader(controller),
                SizedBox(
                  height: 20,
                ),
                _buildBody(controller),
                _buildButton(controller)
              ],
            );
          }),
    );
  }

  Container _buildButton(SearchFilterController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      child: SizedBox(
          width: Get.width,
          child: ElevatedButton(
              onPressed: () async {
                controller.submit();
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 0)),
                  overlayColor: MaterialStateProperty.all<Color>(
                      Theme.of(Get.context!).primaryColor.withOpacity(0.5)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xffF0B418)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ))),
              child: Text(
                'Show 1 result',
                style: TextStyle(color: Colors.white),
              ))),
    );
  }

  Expanded _buildBody(SearchFilterController controller) {
    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderTitle(
              'Headquarter',
              Icon(
                Icons.maps_home_work_outlined,
                color: Color(0xff262727),
              )),
          ...dummyHQ
              .asMap()
              .map((key, value) {
                bool isSelected = controller.listSelectedHq.contains(value);

                return MapEntry(
                    key,
                    InkWell(
                      onTap: () {
                        controller.onSelectHq(value);
                      },
                      child: Container(
                          margin:
                              EdgeInsets.only(left: 17, right: 17, bottom: 4),
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color:
                                  isSelected ? Color(0xffFFEEC3) : Colors.white,
                              borderRadius:
                                  getBorderRadius(dummyHQ.length, key),
                              border: Border.all(
                                  color: isSelected
                                      ? Color(0xffF0B418)
                                      : Color(0xffDADADA))),
                          child: Text(
                            value,
                            style: TextStyle(
                                color: isSelected
                                    ? Color(0xffF0B418)
                                    : Color(0xff7A7A7A)),
                          )),
                    ));
              })
              .values
              .toList(),
          _buildHeaderTitle(
              'Teams',
              Icon(
                Icons.groups_outlined,
                color: Color(0xff262727),
              )),
          ...dummyTeam
              .asMap()
              .map((key, value) {
                bool isSelected = controller.listSelectedTeam.contains(value);
                return MapEntry(
                    key,
                    InkWell(
                      onTap: () {
                        controller.onSelectTeam(value);
                      },
                      child: Container(
                          margin:
                              EdgeInsets.only(left: 17, right: 17, bottom: 4),
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color:
                                  isSelected ? Color(0xffFFEEC3) : Colors.white,
                              borderRadius:
                                  getBorderRadius(dummyTeam.length, key),
                              border: Border.all(
                                  color: isSelected
                                      ? Color(0xffF0B418)
                                      : Color(0xffDADADA))),
                          child: Text(
                            value,
                            style: TextStyle(
                                color: isSelected
                                    ? Color(0xffF0B418)
                                    : Color(0xff7A7A7A)),
                          )),
                    ));
              })
              .values
              .toList(),
          _buildHeaderTitle(
              'Project',
              Icon(
                Icons.assignment_outlined,
                color: Color(0xff262727),
              )),
          ...dummyProject
              .asMap()
              .map((key, value) {
                bool isSelected =
                    controller.listSelectedProject.contains(value);
                return MapEntry(
                    key,
                    InkWell(
                      onTap: () {
                        controller.onSelectProject(value);
                      },
                      child: Container(
                          margin:
                              EdgeInsets.only(left: 17, right: 17, bottom: 4),
                          padding: EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color:
                                  isSelected ? Color(0xffFFEEC3) : Colors.white,
                              borderRadius:
                                  getBorderRadius(dummyProject.length, key),
                              border: Border.all(
                                  color: isSelected
                                      ? Color(0xffF0B418)
                                      : Color(0xffDADADA))),
                          child: Text(
                            value,
                            style: TextStyle(
                                color: isSelected
                                    ? Color(0xffF0B418)
                                    : Color(0xff7A7A7A)),
                          )),
                    ));
                ;
              })
              .values
              .toList(),
        ],
      ),
    ));
  }

  Padding _buildHeader(SearchFilterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 0)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xffFF7171)),
              ),
              onPressed: () {
                controller.reset();
              },
              child: Text(
                'Reset',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ))
        ],
      ),
    );
  }

  Padding _buildHeaderTitle(String title, Icon icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 27, top: 16, bottom: 13),
      child: Row(
        children: [
          icon,
          SizedBox(
            width: 8,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                color: Color(0xff262727),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

List<String> dummyHQ = ['Cilsy HQ cabang bandung', 'Cilsy HQ cabang jakarta'];

List<String> dummyTeam = [
  'Dept. kreatif',
  'Dept. Produk',
  'Dept. Marketing',
  'Dept. HRD'
];

List<String> dummyProject = ['Sekolah devops', 'project cicle mobile'];
