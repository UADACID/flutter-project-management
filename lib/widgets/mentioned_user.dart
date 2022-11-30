import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MentionedUser extends StatelessWidget {
  MentionedUser({
    Key? key,
    this.photoUrl =
        'https://api.cicle.app/public/images/logo-square%20center-black.png',
    required this.userName,
    required this.userId,
    this.isSmall = false,
  }) : super(key: key);

  final String? photoUrl;
  final String userName;
  final String userId;
  final bool isSmall;

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    onPress() {
      String teamId = Get.parameters['teamId']!;
      String companyId = Get.parameters['companyId'] ?? '';
      String path =
          '${RouteName.profileScreen(companyId)}?id=$userId&name=$userName&photo=$photoUrl&teamId=$teamId';
      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);
      if (userId != logedInUser.sId) {
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'other-profile',
            companyId: companyId,
            path: path,
            teamName: ' ',
            title: userName,
            subtitle: 'Other user profile',
            uniqId: userId));
        Get.toNamed(path);
      } else {
        // handle for history viewed
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'profile',
            companyId: companyId,
            path: path,
            teamName: ' ',
            title: userName,
            subtitle: 'Home  >  Menu  >  Profile  >  $userName',
            uniqId: userId));
        Get.toNamed(path);
      }
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 1.5 : 3, vertical: isSmall ? 2 : 1),
        margin: EdgeInsets.only(bottom: isSmall ? 1 : 2),
        decoration: BoxDecoration(
            color: Color(0xffE8FFFF),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  padding: EdgeInsets.all(1),
                  color: Colors.black,
                  child: CachedNetworkImage(
                    imageUrl: getPhotoUrl(url: photoUrl!),
                    width: isSmall ? 5 : 10,
                    height: isSmall ? 5 : 10,
                    fit: BoxFit.cover,
                    errorWidget: (ctx, uri, _) {
                      return Container(
                        width: isSmall ? 5 : 10,
                        height: isSmall ? 5 : 10,
                        color: Colors.green,
                      );
                    },
                  ),
                )),
            SizedBox(
              width: isSmall ? 2 : 4,
            ),
            Text(
              userName,
              style: TextStyle(
                  color: Color(0xff287BFF),
                  fontWeight: FontWeight.w400,
                  fontSize: isSmall ? 6 : 11),
            ),
            SizedBox(
              width: isSmall ? 2 : 4,
            ),
          ],
        ),
      ),
    );
  }
}
