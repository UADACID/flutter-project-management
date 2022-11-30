import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class DocItem extends StatelessWidget {
  DocItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final DocFileItemModel item;

  final faker = Faker(provider: FakerDataProvider());
  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  @override
  Widget build(BuildContext context) {
    String docName = item.title ?? '';
    String content = item.content ?? '';
    return GestureDetector(
      onTap: () {
        String path = RouteName.docDetailScreen(companyId, teamId!, item.sId!);
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'doc',
            companyId: companyId,
            path: path,
            teamName: Get.put(TeamDetailController()).teamName,
            title: docName,
            subtitle:
                'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Docs & Files  >  ${item.title}',
            uniqId: item.sId!));
        Get.toNamed(path);
      },
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child:
                          HtmlWidget(content, customWidgetBuilder: (element) {
                        if (element.localName == 'video') {
                          print(element);
                          String url = element.attributes['src'].toString();
                          print(url);
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ConstrainedBox(
                              constraints: new BoxConstraints(
                                minHeight: 75.0,
                                minWidth: 150.0,
                                maxHeight: 200.0,
                                maxWidth: 300.0,
                              ),
                              child: Container(
                                color: Colors.black,
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return null;
                      }),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  item.isPublic == true
                      ? SizedBox()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.99),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock_rounded,
                              size: 18,
                            ),
                          ),
                        )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            docName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: Icon(
                      Icons.more_vert_outlined,
                      color: Color(0xff979797),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
