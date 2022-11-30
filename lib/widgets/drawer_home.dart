import 'package:cicle_mobile_f3/controllers/auth_controller.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'form_add_team.dart';
import 'logo_complete.dart';

class DrawerHome extends StatelessWidget {
  DrawerHome({
    Key? key,
    required this.box,
  }) : super(key: key);

  final GetStorage box;

  CompanyController _companyController = Get.find();
  AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(),
                    child: LogoComplete(
                      size: 30.w,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    minLeadingWidth: 0,
                    title: Text('Create Company'),
                    onTap: () async {
                      Get.dialog(FormAddTeam(
                        type: 'Company',
                        onSave: (name, description) async {
                          _companyController.createCompany(
                              name: name, desc: description);
                        },
                      ));
                    },
                  ),
                  _buildItemSelected(context),
                  _buildListItem(context),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              minLeadingWidth: 0,
              title: Text('Sign Out'),
              onTap: () {
                _authController.handleSignOut();
              },
            ),
            ListTile(
              title: Text(
                'Cicle V.2 Dev',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    return Obx(() {
      List<Companies> _list = _companyController.companies;

      return Column(
        children: _list.length == 0
            ? []
            : [
                ..._list
                    .where((element) =>
                        element.sId != _companyController.selectedCompanyId)
                    .toList()
                    .asMap()
                    .map((key, value) {
                      Companies company = value;
                      return MapEntry(
                          key,
                          Container(
                            color: _companyController.selectedCompanyId ==
                                    company.sId
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            child: ListTile(
                              minLeadingWidth: 0,
                              leading: AvatarCustom(
                                  color: Colors.transparent,
                                  child: Image.network(
                                      getPhotoUrl(url: company.logo!))),
                              title: Text(
                                company.name,
                                style: TextStyle(
                                    color:
                                        _companyController.selectedCompanyId ==
                                                company.sId
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              onTap: () async {
                                _companyController.setCompanyId(company.sId);
                                Get.dialog(
                                    Container(
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                    name: 'check_subscription_dialog',
                                    barrierColor:
                                        Colors.black.withOpacity(0.5));
                              },
                            ),
                          ));
                    })
                    .values
                    .toList()
              ],
      );
    });
  }

  Obx _buildItemSelected(BuildContext context) {
    return Obx(() => Column(
          children: _companyController.companies.length == 0
              ? []
              : [
                  ..._companyController.companies
                      .where((element) =>
                          element.sId == _companyController.selectedCompanyId)
                      .toList()
                      .asMap()
                      .map((key, value) {
                        Companies company = value;
                        return MapEntry(
                            key,
                            Container(
                              color: _companyController.selectedCompanyId ==
                                      company.sId
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                              child: ListTile(
                                minLeadingWidth: 0,
                                leading: AvatarCustom(
                                    color: Colors.transparent,
                                    child: Image.network(
                                        getPhotoUrl(url: company.logo!))),
                                title: Text(
                                  company.name,
                                  style: TextStyle(
                                      color: _companyController
                                                  .selectedCompanyId ==
                                              company.sId
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                onTap: () {
                                  _companyController.setCompanyId(company.sId);
                                },
                              ),
                            ));
                      })
                      .values
                      .toList()
                ],
        ));
  }
}
