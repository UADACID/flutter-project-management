// import 'package:cicle_mobile_f3/controllers/search_controller.dart';
// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/post_item_model.dart';
// import 'package:cicle_mobile_f3/screens/core/blast/blast_item.dart';
// import 'package:cicle_mobile_f3/screens/search/search_screen.dart';
// import 'package:cicle_mobile_f3/utils/helpers.dart';
// import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:substring_highlight/substring_highlight.dart';

// class SearchBlast extends StatelessWidget {
//   SearchBlast({
//     Key? key,
//   }) : super(key: key);
//   SearchController _searchController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 23),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SearchHeaderMenu(
//             title: 'Blast',
//           ),
//           // Container(
//           //   width: double.infinity,
//           //   height: 112,
//           //   child: Card(),
//           // ),
//           BlastItem(
//               showMore: false,
//               customTitle: Obx(() => SubstringHighlight(
//                     caseSensitive: false,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     terms: [_searchController.keyWords],
//                     text: 'Template Info Hiring',
//                     textAlign: TextAlign.right,
//                     textStyle: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xff393E46)),
//                     textStyleHighlight: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xffFFBF42),
//                         fontWeight: FontWeight.w600),
//                   )),
//               item: PostItemModel(
//                   archived: Archived(),
//                   content: dummyContent,
//                   creator: Creator(fullName: 'Pratama Setya Aji'),
//                   sId: '',
//                   commentsAsString: ['1'],
//                   createdAt: DateTime.now().toString(),
//                   title: 'Template untuk hiring partner')),
//           SizedBox(
//             height: 25,
//           ),
//           ButtonShowAllRelatedItems(
//             onPress: () {},
//             title: 'posts',
//           )
//         ],
//       ),
//     );
//   }
// }
