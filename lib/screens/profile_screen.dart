import 'dart:io';
import 'package:cicle_mobile_f3/controllers/profile_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/animation_fade_and_slide.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController _profileController = Get.put(ProfileController());

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final box = GetStorage();

  final fakerFa = Faker(provider: FakerDataProvider());

  String? paramId = Get.parameters['id'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileController.setInitialValue();
  }

  void _handleImagePicker() => _profileController.openImagePicker();

  void onRefresh() async {
    String id = '';
    if (paramId != null) {
      id = paramId!;
    } else {
      final userString = box.read(KeyStorage.logedInUser);

      MemberModel logedInUser = MemberModel.fromJson(userString);
      id = logedInUser.sId;
    }
    await _profileController.getData(id);
    refreshController.refreshCompleted();
  }

  Future<bool> onWillPop() async {
    if (_profileController.isEdit) {
      _profileController.isEdit = false;
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Obx(() {
              String _title =
                  _profileController.isEdit ? 'Edit Profile' : 'Profile';
              return Text(_title);
            }),
            actions: [
              Obx(() => _profileController.canEdit
                  ? IconButton(
                      onPressed: () {
                        if (_profileController.isEdit) {
                          _profileController.isEdit = false;
                          _profileController.updateProfile();
                        } else {
                          _profileController.isEdit =
                              !_profileController.isEdit;
                        }
                      },
                      icon: Icon(
                        _profileController.isEdit
                            ? MyFlutterApp.save_black_24dp_1
                            : MyFlutterApp.mdi_square_edit_outline,
                        color: _profileController.isEdit
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ))
                  : SizedBox())
            ],
          ),
          body: Obx(() {
            if (_profileController.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (!_profileController.isLoading &&
                _profileController.errorMessage != '') {
              return Center(
                  child: ErrorSomethingWrong(
                refresh: onRefresh,
                message: _profileController.errorMessage,
              ));
            }
            return SmartRefresher(
              physics: BouncingScrollPhysics(),
              header: WaterDropMaterialHeader(),
              controller: refreshController,
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      _buildPhoto(),
                      SizedBox(
                        height: 50,
                      ),
                      _buildBio(),
                      SizedBox(
                        height: 25,
                      ),
                      _buildAbout()
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Column _buildAbout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Text('About me'),
        ),
        SizedBox(
          height: 5,
        ),
        Obx(
          () => _profileController.isEdit == false
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: ListTile(
                            title: Text(
                              _profileController.about,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  height: 1.5,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        )
                      ],
                    ),
                  ),
                )
              : AnimationFadeAndSlide(
                  delay: Duration(milliseconds: 500),
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 5),
                    child: TextField(
                      maxLines: 6,
                      controller: _profileController.aboutInputController,
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                            left: 20, right: 20, top: 19, bottom: 19),
                        hintText: "",
                        hintStyle: TextStyle(color: Color(0xffB5B5B5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBio() {
    return Column(
      children: [
        AnimationFadeAndSlide(
          delay: Duration(milliseconds: 250),
          duration: Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text('Bio'),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Obx(
          () => _profileController.isEdit == false
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        _profileController.name,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              : AnimationFadeAndSlide(
                  delay: Duration(milliseconds: 300),
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: _profileController.nameInputController,
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                            left: 20, right: 20, top: 19, bottom: 19),
                        hintText: "Full name..",
                        hintStyle: TextStyle(color: Color(0xffB5B5B5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Obx(
          () => _profileController.isEdit == false
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(
                        _profileController.title,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              : AnimationFadeAndSlide(
                  delay: Duration(milliseconds: 400),
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 5),
                    child: TextField(
                      controller: _profileController.titleInputController,
                      decoration: InputDecoration(
                        isDense: true,
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                            left: 20, right: 20, top: 19, bottom: 19),
                        hintText: "Title..",
                        hintStyle: TextStyle(color: Color(0xffB5B5B5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Container _buildPhoto() {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(149.0),
              child: Container(
                height: 149,
                width: 149,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    shape: BoxShape.circle),
                child: Container(
                  color: Colors.white,
                  child: Obx(() {
                    bool _isLocalImage = _profileController.photoUrl[0] == '/';
                    if (_profileController.photoUrl.split('/')[1] == 'public') {
                      return Image.network(
                        getPhotoUrl(url: _profileController.photoUrl),
                        fit: BoxFit.cover,
                      );
                    }
                    if (_isLocalImage) {
                      return Image.file(
                        File(_profileController.photoUrl),
                        fit: BoxFit.cover,
                      );
                    }
                    return Image.network(
                      getPhotoUrl(url: _profileController.photoUrl),
                      fit: BoxFit.cover,
                    );
                  }),
                ),
              ),
            ),
          ),
          Obx(() => _profileController.isEdit
              ? Align(
                  alignment: Alignment.center,
                  child: AnimationFadeAndSlide(
                    delay: Duration(milliseconds: 200),
                    duration: Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: _handleImagePicker,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(149.0),
                        child: Container(
                          height: 149,
                          width: 149,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox()),
        ],
      ),
    );
  }
}
