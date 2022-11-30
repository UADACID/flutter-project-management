// import 'package:cicle_mobile_f3/controllers/search_controller.dart';
// import 'package:cicle_mobile_f3/screens/search/search_screen.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
// import 'package:cicle_mobile_f3/utils/helpers.dart';
// import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:get/get.dart';
// import 'package:substring_highlight/substring_highlight.dart';

// class SearchDocs extends StatelessWidget {
//   const SearchDocs({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 23),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SearchHeaderMenu(
//             title: 'Document',
//           ),
//           // Container(
//           //   width: 150,
//           //   height: 130,
//           //   child: Card(),
//           // ),
//           Container(
//             // padding: EdgeInsets.all(5),
//             // margin: EdgeInsets.only(top: 27),
//             width: double.infinity,
//             // height: 200,
//             // child: Text(list.length.toString()),
//             child: GridView.count(
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               // Create a grid with 2 columns. If you change the scrollDirection to
//               // horizontal, this produces 2 rows.
//               crossAxisCount: 2,
//               crossAxisSpacing: 4,
//               childAspectRatio: 146 / 172,
//               // Generate 100 widgets that display their index in the List.
//               children: List.generate(1, (index) {
//                 return SearchDocItem();
//               }),
//             ),
//           ),
//           SizedBox(
//             height: 25,
//           ),
//           ButtonShowAllRelatedItems(
//             onPress: () {
//               String companyId = Get.parameters['companyId'] ?? '';
//               String teamId = Get.parameters['teamId'] ?? '';
//               Get.toNamed(
//                   '${RouteName.searchResultAllRelatedScreen(companyId, teamId)}');
//             },
//             title: 'docs & files',
//           )
//         ],
//       ),
//     );
//   }
// }

// class SearchDocItem extends StatelessWidget {
//   SearchDocItem({
//     Key? key,
//   }) : super(key: key);

//   SearchController _searchController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(6),
//       color: Color(0xffF6F6F6),
//       child: Column(
//         children: [
//           Expanded(
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 width: double.infinity,
//                 child: Column(
//                   children: [
//                     Obx(() => SubstringHighlight(
//                           caseSensitive: false,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           terms: [_searchController.keyWords],
//                           text: 'Template Info Hiring',
//                           textAlign: TextAlign.right,
//                           textStyle: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xffB5B5B5),
//                               fontWeight: FontWeight.w600),
//                           textStyleHighlight: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xffFFBF42),
//                               fontWeight: FontWeight.w600),
//                         )),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Flexible(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: SingleChildScrollView(
//                           physics: NeverScrollableScrollPhysics(),
//                           child: HtmlWidget(dummyContent,
//                               customWidgetBuilder: (element) {
//                             if (element.localName == 'video') {
//                               // print(element);
//                               String url = element.attributes['src'].toString();
//                               // print(url);
//                               return Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: ConstrainedBox(
//                                   constraints: new BoxConstraints(
//                                     minHeight: 75.0,
//                                     minWidth: 150.0,
//                                     maxHeight: 200.0,
//                                     maxWidth: 300.0,
//                                   ),
//                                   child: Container(
//                                     color: Colors.black,
//                                     child: Center(
//                                       child: Icon(
//                                         Icons.play_circle_fill_rounded,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }

//                             return null;
//                           }),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 15,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Text(
//               'Div. Apps & Products > Docs & File',
//               maxLines: 2,
//               style: TextStyle(
//                   fontSize: 10,
//                   color: Color(0xffB5B5B5),
//                   fontWeight: FontWeight.w500),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
