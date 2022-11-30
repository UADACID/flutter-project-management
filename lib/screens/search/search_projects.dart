// import 'package:cicle_mobile_f3/controllers/search_controller.dart';
// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/companies_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';
// import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:random_color/random_color.dart';
// import 'package:substring_highlight/substring_highlight.dart';

// import '../home_screen.dart';
// import 'search_screen.dart';

// class SearchProjects extends StatelessWidget {
//   SearchProjects({
//     Key? key,
//   }) : super(key: key);
//   RandomColor _randomColor = RandomColor();
//   SearchController _searchController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 23),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SearchHeaderMenu(
//             title: 'Project',
//           ),
//           GridView.count(
//             physics: NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             crossAxisCount: 2,
//             crossAxisSpacing: 10,
//             children: List.generate(1, (index) {
//               return TeamItem(
//                 disableOnPress: true,
//                 customTitle: Obx(() => SubstringHighlight(
//                       caseSensitive: false,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       terms: [_searchController.keyWords],
//                       text: 'Project $index',
//                       textAlign: TextAlign.right,
//                       textStyle: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                       textStyleHighlight: TextStyle(
//                           // fontSize: 12,
//                           backgroundColor: Color(0xffFFBF42),
//                           fontWeight: FontWeight.bold),
//                     )),
//                 color: _randomColor.randomColor(
//                     colorBrightness: ColorBrightness.light),
//                 team: Teams(
//                     archived: Archived(),
//                     sId: '23232$index',
//                     name: 'Team Name',
//                     desc: 'Loremipsum dolor sit',
//                     members: [
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/1.jpg'),
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/2.jpg'),
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/3.jpg'),
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/4.jpg'),
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/5.jpg'),
//                       MemberModel(
//                           fullName: 'Pratama Setya',
//                           photoUrl:
//                               'https://randomuser.me/api/portraits/women/6.jpg'),
//                     ]),
//               );
//             }),
//           ),
//           SizedBox(
//             height: 25,
//           ),
//           ButtonShowAllRelatedItems(
//             onPress: () {},
//             title: 'projects',
//           )
//         ],
//       ),
//     );
//   }
// }
