import 'package:cached_network_image/cached_network_image.dart';
import 'package:cicle_mobile_f3/controllers/blast_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_more_action.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BlastItem extends StatelessWidget {
  BlastItem({
    Key? key,
    required this.item,
    this.showMore = true,
    this.customTitle,
    this.customFooter,
    this.customMargin = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  }) : super(key: key);

  String? teamId = Get.parameters['teamId'];
  String? blastId = Get.parameters['blastId'];
  String companyId = Get.parameters['companyId'] ?? '';
  final PostItemModel item;
  final bool showMore;
  final Widget? customTitle;
  final Widget? customFooter;
  final EdgeInsets? customMargin;

  onDelete() async {
    BlastController _blastController = Get.find();
    try {
      _blastController.addListPostIdInProgress(item.sId);
      Get.back();
      await Future.delayed(Duration(milliseconds: 300));
      Get.back();
      await Future.delayed(Duration(milliseconds: 300));
      await _blastController.archivePost(item.sId);
      showAlert(message: 'Post has been archived');
    } catch (e) {
      _blastController.removeListPostIdInProgress(item.sId);
      if (e is DioError) {
        showAlert(message: 'Failed to archive, ${e.response!.statusCode}');
      }
    }
  }

  onEdit() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.toNamed(
        '${RouteName.blastFormScreen(teamId: teamId!, companyId: companyId)}?blastId=${item.sId}&type=edit');
  }

  onPressMore() async {
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: onDelete,
      onEdit: onEdit,
      titleAlert: 'Archive Post ?',
    ));
  }

  CustomRenderMatcher img1Matcher() => (ctx) {
        // print(ctx);
        if (ctx.tree.element != null) {
          if (ctx.tree.element!.attributes['style'] != null) {
            if (ctx.tree.element!.attributes['style']!
                    .contains('width: 20px') ||
                ctx.tree.element!.attributes['style']!.contains('width:20px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 10px') ||
                ctx.tree.element!.attributes['style']!.contains('width:10px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 12px') ||
                ctx.tree.element!.attributes['style']!.contains('width:12px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 15px') ||
                ctx.tree.element!.attributes['style']!.contains('width:15px')) {
              return true;
            }
          }

          return false;
        }

        return false;
        // // return ctx.tree.element!.attributes['style']!.contains('width: 20px') ||
        // //     ctx.tree.element!.attributes['style']!.contains('width:20px');
      };

  @override
  Widget build(BuildContext context) {
    String title = item.title;
    String creatorName = item.creator.fullName;
    String createdAt =
        DateFormat.Hm().format(DateTime.parse(item.createdAt).toLocal());
    String photoUrl = item.creator.photoUrl;

    String content = item.content;
    int commentCounter = item.commentsAsString.length;
    String textCompleteStatus =
        item.complete ? 'Completed' : 'Not complete yet';

    return InkWell(
      onTap: () {
        String path = RouteName.blastDetailScreen(companyId, teamId!, item.sId);
        TeamDetailController _teamDetailController = Get.find();
        Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
            moduleName: 'post',
            companyId: companyId,
            path: path,
            teamName: _teamDetailController.teamName,
            title: item.title,
            subtitle:
                'Home  >  ${_teamDetailController.teamName}  >  Blast  >  ${item.title}',
            uniqId: item.sId));
        Get.toNamed(path);
      },
      child: Container(
        margin: customMargin != null
            ? customMargin
            : EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 23, right: 15, top: 23),
              child: Row(
                children: [
                  AvatarCustom(
                      height: 40,
                      child: Image.network(
                        getPhotoUrl(url: photoUrl),
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      item.isPublic
                                          ? SizedBox()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: Icon(
                                                Icons.lock_rounded,
                                                size: 14,
                                              ),
                                            ),
                                      Flexible(
                                        child: customTitle != null
                                            ? customTitle!
                                            : Text(
                                                title,
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                      ),
                                    ],
                                  )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  showMore
                                      ? Obx(() {
                                          BlastController _blastController =
                                              Get.find();
                                          bool isInProgress = _blastController
                                              .listPostIdInProgress
                                              .contains(item.sId);
                                          if (isInProgress) {
                                            return SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            );
                                          }
                                          return InkWell(
                                            onTap: onPressMore,
                                            child: Icon(
                                              Icons.more_vert,
                                              color: Color(0xff979797),
                                            ),
                                          );
                                        })
                                      : SizedBox()
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  Text(creatorName,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Color(0xff708FC7),
                                          fontWeight: FontWeight.w600)),
                                  Container(
                                    width: 1,
                                    height: 12,
                                    color: Colors.grey,
                                    margin: EdgeInsets.symmetric(horizontal: 7),
                                  ),
                                  Text(createdAt,
                                      style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.black.withOpacity(0.5),
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    child: Text(textCompleteStatus,
                                        style: TextStyle(
                                            fontSize: 9.sp,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal)),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 13,
            ),
            Padding(
              padding: EdgeInsets.only(left: 23, right: 15),
              child: Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 150),
                        child: Html(
                          data: content,
                          // data: dummyContent,
                          customRenders: {
                            img1Matcher(): CustomRender.widget(
                                widget: (context, buildChildren) {
                              print(context);
                              String imageAvatarUrl = '';
                              if (context.tree.element!.attributes['src'] !=
                                  null) {
                                imageAvatarUrl =
                                    context.tree.element!.attributes['src']!;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: CircleAvatar(
                                  radius: 20, // Image radius
                                  backgroundImage: NetworkImage(
                                      getPhotoUrl(url: imageAvatarUrl)),
                                ),
                              );
                            }),
                          },
                          // customRender: {
                          //   "img": (ctx, child) {
                          //     if (ctx.tree.element!.attributes['style']!
                          //             .contains('width: 20px') ||
                          //         ctx.tree.element!.attributes['style']!
                          //             .contains('width:20px')) {
                          //       return ClipRRect(
                          //         borderRadius: BorderRadius.circular(20),
                          //         child: Image.network(
                          //           getPhotoUrl(
                          //               url: ctx.tree.element!.attributes["src"]
                          //                   .toString()),
                          //           width: 20,
                          //           height: 20,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       );
                          //     } else if (ctx.tree.element!.attributes['style']!
                          //             .contains('width: 10px') ||
                          //         ctx.tree.element!.attributes['style']!
                          //             .contains('width:10px')) {
                          //       return ClipRRect(
                          //         borderRadius: BorderRadius.circular(20),
                          //         child: Image.network(
                          //           getPhotoUrl(
                          //               url: ctx.tree.element!.attributes["src"]
                          //                   .toString()),
                          //           width: 20,
                          //           height: 20,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       );
                          //     } else if (ctx.tree.element!.attributes['style']!
                          //             .contains('width: 12px') ||
                          //         ctx.tree.element!.attributes['style']!
                          //             .contains('width:12px')) {
                          //       return ClipRRect(
                          //         borderRadius: BorderRadius.circular(20),
                          //         child: Image.network(
                          //           getPhotoUrl(
                          //               url: ctx.tree.element!.attributes["src"]
                          //                   .toString()),
                          //           width: 20,
                          //           height: 20,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       );
                          //     } else if (ctx.tree.element!.attributes['style']!
                          //             .contains('width: 15px') ||
                          //         ctx.tree.element!.attributes['style']!
                          //             .contains('width:15px')) {
                          //       return ClipRRect(
                          //         borderRadius: BorderRadius.circular(20),
                          //         child: Image.network(
                          //           getPhotoUrl(
                          //               url: ctx.tree.element!.attributes["src"]
                          //                   .toString()),
                          //           width: 20,
                          //           height: 20,
                          //           fit: BoxFit.cover,
                          //         ),
                          //       );
                          //     } else if (ctx.tree.element!.attributes["src"] !=
                          //         null) {
                          //       return Image.network(
                          //         ctx.tree.element!.attributes["src"].toString(),
                          //         width: 50,
                          //         height: 50,
                          //         fit: BoxFit.cover,
                          //       );
                          //     }
                          //     return child;
                          //   }
                          // },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  commentCounter > 0
                      ? Container(
                          margin: EdgeInsets.only(right: 7.5),
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            commentCounter.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
            customFooter != null
                ? customFooter!
                : SizedBox(
                    height: 20,
                  ),
          ],
        ),
      ),
    );
  }

  // CustomRenderMatcher img2Matcher() => (ctx) =>
  //     ctx.tree.element!.attributes['style']!.contains('width: 10px') ||
  //     ctx.tree.element!.attributes['style']!.contains('width:10px');

  // CustomRenderMatcher img3Matcher() => (ctx) =>
  //     ctx.tree.element!.attributes['style']!.contains('width: 12px') ||
  //     ctx.tree.element!.attributes['style']!.contains('width:12px');

  // CustomRenderMatcher img4Matcher() => (ctx) =>
  //     ctx.tree.element!.attributes['style']!.contains('width: 15px') ||
  //     ctx.tree.element!.attributes['style']!.contains('width:15px');

  // CustomRenderMatcher img5Matcher() =>
  //     (ctx) => ctx.tree.element!.attributes["src"] != null;
}

// String dummyContent =
//     '<p>Kaget ga sih baca judulnya wkwkwk&nbsp;</p><p><br></p><p>Aku disini mau nyampein sesuatu yang menurut ku perlu di sampaikan yang amat sangat penting!&nbsp;</p><p>Bisa di baca yang aku screenshot yaaa... Ini tentang alumni yang kasih testimoni ke team SDC&nbsp;</p><p><img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/7c11d7b03489ea14f3e56d59d4c1fe55/DF776A10-94E4-4BFB-95F0-F0EA324D93B3.png" style="width: 300px;" class="fr-fic fr-dib"></p><p><br></p><p><img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/56f72fe7eddcbab9fcf02464929ad50b/7E975578-8342-459B-9007-EB765386CA4A.png" style="width: 300px;" class="fr-fic fr-dib"></p><p><img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/c0cf1d57a3eab4f6e01a65c6a7d99933/61BA0982-DD97-44EA-82C3-FBD9F37DE735.png" style="width: 300px;" class="fr-fic fr-dib"></p><p><img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/514314fa72b6c1a5e2700ea20395c4bc/5278A793-D9A0-4335-A660-A047D0FD50EB.png" style="width: 300px;" class="fr-fic fr-dib"></p><p>Dibaca sendiri yaaa tanggapan mereka rata rata ini testimoni untuk seluruh team SDC.&nbsp;</p><p>Aku ingin mengAPRESIASI Kerja keras untuk kalian semua khususnya team yang berhubungan langsung untuk membuat sistem yang baik di SDC berjalan.&nbsp;</p><p><b>Thanks berat gaes !&nbsp;</b></p><p>Ini baru sebagian testimoni yang kita dapat dari sebagian kecil alumni. Jadi semoga ini bisa jadi motivasi buat kita untuk membuat sistem yang lebih baik agar para client kita bisa merasa terbantu sesuai dengan goals utama kita.&nbsp;</p><p><br></p><p>Pastinya ada testimoni yang kurang mengenakan, artinya kita tetap harus mengevaluasi diri dengan tanggung jawab pekerjaan kita untuk terus lebih baik dan makin meningkat kualitas semua performance ataupun sistemnya.&nbsp;</p><p><br></p><p><b>Sekali lagi thanks berat ini hasil yang telah kalian kerjakan nikmati dan jangan lupa bersyukur!</b></p><p><br></p><p><b>Applause untuk team SDC ! 🤧👏👏👏👏👏🤝🤜🤛</b></p>';

// String dummyContent =
//     '<p>Dibaca sendiri yaaa tanggapan mereka rata rata ini testimoni untuk seluruh team SDC.&nbsp;</p><p>Aku ingin mengAPRESIASI Kerja keras untuk kalian semua khususnya team yang berhubungan langsung untuk membuat sistem yang baik di SDC berjalan.&nbsp;</p><p>';

// String dummyContent =
//     '''<p>Aku disini mau nyampein sesuatu yang menurut ku perlu di sampaikan yang amat sangat penting!&nbsp;</p>
// <p>Bisa di baca yang aku screenshot yaaa... Ini tentang alumni yang kasih testimoni ke team SDC&nbsp;</p>
// <p>
//   <img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/7c11d7b03489ea14f3e56d59d4c1fe55/DF776A10-94E4-4BFB-95F0-F0EA324D93B3.png" style="width:300px" class="fr-fic fr-dib">
// </p>
// <p>
//   <br>
// </p>
// <p>
//   <img src="https://storage.googleapis.com/production-cicle-app/5f8402fcf4cc864e3addac77/5f86dab13a36b417e2f0f39f/56f72fe7eddcbab9fcf02464929ad50b/7E975578-8342-459B-9007-EB765386CA4A.png" style="width:300px" class="fr-fic fr-dib">
// </p>''';

// String dummyContent =
//     '''<p>Hi gengs dan team baru kita <span contenteditable="false" data-mentioned-user-id="60091ad3280e28d610b75995" style="padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center;"><img style="width: 20px; height: 20px; object-fit: cover; border-radius: 100%;" src="https://lh3.googleusercontent.com/a-/AOh14GjZni4hWIFmHFK6NgbGokcGBzcfRSGSyRG_MK9Z=s96-c" class="fr-fil fr-dib"><a href="/profiles/60091ad3280e28d610b75995" target="_blank">Edy Susanto</a></span> ,<span contenteditable="false" data-mentioned-user-id="60090530280e28d610b758ab" style="padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center;"><img style="width: 20px; height: 20px; object-fit: cover; border-radius: 100%;" src="https://lh3.googleusercontent.com/a-/AOh14Gi4iB9oYOUXYW1mU47hI1j0iHMI2cZgol7u5y8F-A=s96-c" class="fr-fil fr-dib"><a href="/profiles/60090530280e28d610b758ab" target="_blank">haidar rifki</a></span> Dan <span contenteditable="false" data-mentioned-user-id="600903c4280e28d610b7587c" style="padding:1px; background-color:#e8ffff; border-radius:2px; display:inline-flex; align-items:center;"><img style="width: 20px; height: 20px; object-fit: cover; border-radius: 100%;" src="https://lh3.googleusercontent.com/a-/AOh14Gjc17WtSB-Lpuip7XwwXK_L2Et-LbepF__VlUVLYQ=s96-c" class="fr-fil fr-dib"><a href="/profiles/600903c4280e28d610b7587c" target="_blank">Audia Refanda&nbsp;</a></span>&nbsp;</p><p><br></p><p>Hari senin adalah rutinitas kita untuk meeting di zoom bahas terkait OKR (untuk yg baru akan aku jelaskan terpisah terkait OKR) inti dari OKR target kita mencapai sesuatu dalam 3 bulan kedepan, sampai 1 tahun kedepan. Dan Progressnya akan di infokan setiap hari senin. detail waktunya disini :&nbsp;</p><p><a href="https://my.cicle.app/docs/600a5eaf280e28d610b76274" rel="noopener noreferrer" target="_blank">https://my.cicle.app/docs/600a5eaf280e28d610b76274</a></p><p><br></p><p>Tapi khusus senin tgl 25 januari 2021 &nbsp;semua anggota team product akan ikut meeting divisi "product education dan support" di link zoom sekolah digital cilsy (sdc) &nbsp;disini:&nbsp;</p><p><a href="https://zoom.us/j/4594410493?pwd=OGVGOUVaYVZEaDQ5TFdJeU1JcHZBUT09" rel="noopener noreferrer" target="_blank">https://zoom.us/j/4594410493?pwd=OGVGOUVaYVZEaDQ5TFdJeU1JcHZBUT09</a></p><p><br></p><p>Yaitu jam <strong>09.30</strong> harus tepat waktu. Ada beberapa pembahasan pastinya dan sekaligus memperlihatkan sistem OKR ke team baru.&nbsp;</p><p><br></p><p>Jadwalnya seperti berikut :&nbsp;</p><p>- salam dan sapa ( Moderator : Nenden)</p><p>- good news or badnews ( setiap anggota memberikan info pribadi apa yang membuat dia happy ataupun membuat dia sedih )</p><p>- industry news ( setiap orang jika ada informasi terbaru terkait bisnis {startup ataupun yg lainnya}, perkembangan teknologi, dll)</p><p>- Menjelaskan tentang OKR ( Moderator "iseng" : Nenden)&nbsp;</p><p>- OKR setiap subdiv ( memimpin meeting : Tresna )</p><p>- Penutup&nbsp;</p><p><br></p><p>Jika ada pertanyaan silahkan ya gengs !&nbsp;</p><p>Dan jika <strong>sudah baca&nbsp;</strong>minimal kasih komentar. Biar gue tau harus followup ke siapa aja yang belum liat.</p>''';
