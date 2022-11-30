// import 'package:cicle_mobile_f3/controllers/search_controller.dart';
// import 'package:cicle_mobile_f3/screens/search/search_screen.dart';
// import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
// import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:substring_highlight/substring_highlight.dart';

// class SearchMembers extends StatelessWidget {
//   const SearchMembers({
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
//             title: 'Member',
//           ),
//           MemberItem(),
//           SizedBox(
//             height: 25,
//           ),
//           ButtonShowAllRelatedItems(
//             onPress: () {},
//             title: 'members',
//           )
//         ],
//       ),
//     );
//   }
// }

// class MemberItem extends StatelessWidget {
//   MemberItem({
//     Key? key,
//   }) : super(key: key);
//   SearchController _searchController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       // height: 95,
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   AvatarCustom(height: 42, child: Container()),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Text(
//                       //   'Pratama Setya Aji',
//                       //   style: TextStyle(
//                       //       fontSize: 14, fontWeight: FontWeight.bold),
//                       // ),
//                       Obx(() => SubstringHighlight(
//                             caseSensitive: false,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             terms: [_searchController.keyWords],
//                             text: 'Pratama Setya Aji',
//                             textAlign: TextAlign.right,
//                             textStyle: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xff393E46)),
//                             textStyleHighlight: TextStyle(
//                                 fontSize: 14,
//                                 color: Color(0xffFFBF42),
//                                 fontWeight: FontWeight.bold),
//                           )),
//                       Text(
//                         'Mobile Developer',
//                         style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xff708FC7)),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: 8,
//               ),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                     '08.30-16.30 | Busy Creating Alternate Reality Inside My Head',
//                     style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff393E46))),
//               ),
//               SizedBox(
//                 height: 4,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
