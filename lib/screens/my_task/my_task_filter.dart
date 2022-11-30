import 'package:cicle_mobile_f3/controllers/my_task_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTaskFilter extends StatelessWidget {
  MyTaskFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: GetX<MyTaskFilterController>(
              init: MyTaskFilterController(),
              initState: (state) {
                // state.controller!.init();
              },
              builder: (_myTaskFilterController) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 14,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'filter',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: () => _myTaskFilterController.reset(),
                              child: Text(
                                'reset',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSearchInput(_myTaskFilterController),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Headquarters '),
                                    _myTaskFilterController
                                            .listHqSelected.isEmpty
                                        ? SizedBox()
                                        : Text(
                                            '(${_myTaskFilterController.listHqSelected.length} selected)'),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _myTaskFilterController.listHq.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('-',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      )
                                    : Column(
                                        children: [
                                          ..._myTaskFilterController.listHq
                                              .sublist(
                                                  0,
                                                  _myTaskFilterController
                                                      .limitDisplayHq.value)
                                              .asMap()
                                              .map((key, value) {
                                                bool _isSelectedItem =
                                                    _myTaskFilterController
                                                        .listHqSelected
                                                        .contains(value.sId);
                                                return MapEntry(
                                                    key,
                                                    InkWell(
                                                        onTap: () {
                                                          _myTaskFilterController
                                                              .onPressHqItem(
                                                                  value.sId);
                                                        },
                                                        child: Item(
                                                          isSelectedItem:
                                                              _isSelectedItem,
                                                          value: value.name,
                                                        )));
                                              })
                                              .values
                                              .toList(),
                                          _myTaskFilterController
                                                      .limitDisplayHq.value ==
                                                  _myTaskFilterController
                                                      .listHq.length
                                              ? _myTaskFilterController
                                                          .listHq.length <=
                                                      2
                                                  ? SizedBox()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _myTaskFilterController
                                                                .limitDisplayHq
                                                                .value = 2,
                                                        child: Text(
                                                          'Show less',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffB5B5B5)),
                                                        ),
                                                      ),
                                                    )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        _myTaskFilterController
                                                                .limitDisplayHq
                                                                .value =
                                                            _myTaskFilterController
                                                                .listHq.length,
                                                    child: Text(
                                                      'Show more (${_myTaskFilterController.listHq.length - _myTaskFilterController.listHq.sublist(0, _myTaskFilterController.limitDisplayHq.value).toList().length} more)',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xffB5B5B5)),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text('Team / Department '),
                                    _myTaskFilterController
                                            .listTeamSelected.isEmpty
                                        ? SizedBox()
                                        : Text(
                                            '(${_myTaskFilterController.listTeamSelected.length} selected)'),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _myTaskFilterController.listTeam.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('-',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      )
                                    : Column(
                                        children: [
                                          ..._myTaskFilterController.listTeam
                                              .sublist(
                                                  0,
                                                  _myTaskFilterController
                                                      .limitDisplayTeam.value)
                                              .toList()
                                              .asMap()
                                              .map((key, value) {
                                                bool _isSelectedItem =
                                                    _myTaskFilterController
                                                        .listTeamSelected
                                                        .contains(value.sId);
                                                return MapEntry(
                                                    key,
                                                    InkWell(
                                                        onTap: () {
                                                          _myTaskFilterController
                                                              .onPressTeamItem(
                                                                  value.sId);
                                                          // onPressItem(value);
                                                        },
                                                        child: Item(
                                                          isSelectedItem:
                                                              _isSelectedItem,
                                                          value: value.name,
                                                        )));
                                              })
                                              .values
                                              .toList(),
                                          _myTaskFilterController
                                                      .limitDisplayTeam.value ==
                                                  _myTaskFilterController
                                                      .listTeam.length
                                              ? _myTaskFilterController
                                                          .listTeam.length <=
                                                      2
                                                  ? SizedBox()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _myTaskFilterController
                                                                .limitDisplayTeam
                                                                .value = 2,
                                                        child: Text(
                                                          'Show less',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffB5B5B5)),
                                                        ),
                                                      ),
                                                    )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        _myTaskFilterController
                                                                .limitDisplayTeam
                                                                .value =
                                                            _myTaskFilterController
                                                                .listTeam
                                                                .length,
                                                    child: Text(
                                                      'Show more (${_myTaskFilterController.listTeam.length - _myTaskFilterController.listTeam.sublist(0, _myTaskFilterController.limitDisplayTeam.value).toList().length} more)',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xffB5B5B5)),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text('Projects'),
                                    _myTaskFilterController
                                            .listProjectSelected.isEmpty
                                        ? SizedBox()
                                        : Text(
                                            '(${_myTaskFilterController.listProjectSelected.length} selected)'),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                _myTaskFilterController.listProject.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('-',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      )
                                    : Column(
                                        children: [
                                          ..._myTaskFilterController.listProject
                                              .sublist(
                                                  0,
                                                  _myTaskFilterController
                                                      .limitDisplayProject
                                                      .value)
                                              .toList()
                                              .asMap()
                                              .map((key, value) {
                                                bool _isSelectedItem =
                                                    _myTaskFilterController
                                                        .listProjectSelected
                                                        .contains(value.sId);
                                                return MapEntry(
                                                    key,
                                                    InkWell(
                                                        onTap: () {
                                                          _myTaskFilterController
                                                              .onPressProjectItem(
                                                                  value.sId);
                                                          // onPressItem(value);
                                                        },
                                                        child: Item(
                                                          isSelectedItem:
                                                              _isSelectedItem,
                                                          value: value.name,
                                                        )));
                                              })
                                              .values
                                              .toList(),
                                          _myTaskFilterController
                                                      .limitDisplayProject
                                                      .value ==
                                                  _myTaskFilterController
                                                      .listProject.length
                                              ? _myTaskFilterController
                                                          .listProject.length <=
                                                      2
                                                  ? SizedBox()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _myTaskFilterController
                                                                .limitDisplayProject
                                                                .value = 2,
                                                        child: Text(
                                                          'Show less',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffB5B5B5)),
                                                        ),
                                                      ),
                                                    )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        _myTaskFilterController
                                                                .limitDisplayProject
                                                                .value =
                                                            _myTaskFilterController
                                                                .listProject
                                                                .length,
                                                    child: Text(
                                                      'Show more (${_myTaskFilterController.listProject.length - _myTaskFilterController.listProject.sublist(0, _myTaskFilterController.limitDisplayProject.value).toList().length} more)',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xffB5B5B5)),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        EdgeInsets.symmetric(vertical: 10)),
                                    overlayColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.grey.withOpacity(0.5)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xff708FC7)),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ))),
                                onPressed: () {
                                  _myTaskFilterController.onSubmit();
                                },
                                child: Text(
                                  'Done',
                                  style: TextStyle(color: Colors.white),
                                ))),
                      ),
                      SizedBox(
                        height: 14,
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  TextField _buildSearchInput(MyTaskFilterController controller) {
    return TextField(
      controller: controller.nameTextEditingController,
      style: TextStyle(fontSize: 12),
      onChanged: (value) {
        controller.searchKey = value;
      },
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(15, 12, 10, 12),

        hintText: "Search HQ / team / projects...",
        hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Color(0xffD6D6D6)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        suffixIcon: controller.searchKey != ""
            ? InkWell(
                onTap: () {
                  controller.searchKey = "";
                  controller.nameTextEditingController.text = "";
                },
                child: Icon(Icons.close, color: Color(0xffFFBF42)))
            : Icon(
                Icons.search,
                color: Color(0xffFFBF42),
              ),
        suffixIconConstraints: BoxConstraints(
            // maxHeight: 90,
            minWidth: 40),
        // prefixIcon: Icon(Icons.search)
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required bool isSelectedItem,
    required this.value,
  })  : _isSelectedItem = isSelectedItem,
        super(key: key);

  final bool _isSelectedItem;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 3),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 18),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Color(0xffD6D6D6))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(color: Color(0xff7A7A7A)),
            ),
            _isSelectedItem
                ? Icon(
                    Icons.check,
                    color: Color(0xff708FC7),
                  )
                : SizedBox()
          ],
        ));
  }
}
