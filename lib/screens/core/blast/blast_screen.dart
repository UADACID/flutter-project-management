import 'package:cicle_mobile_f3/controllers/blast_controller.dart';

import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../team_detail.dart';
import 'blast_item.dart';

class BlastScreen extends StatelessWidget {
  BlastScreen({Key? key}) : super(key: key);

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  TeamDetailController _teamDetailController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh(BlastController controller) async {
    await controller.getPosts();
    refreshController.refreshCompleted();
  }

  void onLoadMore(BlastController controller) async {
    print('load more');
    await controller.getMorePosts();
    print('load more done');

    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() => Text(
              _teamDetailController.teamName,
              style: TextStyle(fontSize: 16),
            )),
        elevation: 0.0,
        actions: [
          SizedBox(
            width: 10,
          ),
          ActionsAppBarTeamDetail(
            showSetting: false,
          )
        ],
      ),
      body: GetX<BlastController>(
          init: BlastController(),
          initState: (state) {
            state.controller!.init();
          },
          builder: (_blastControlle) {
            if (_blastControlle.isLoading &&
                _blastControlle.posts.length == 0) {
              return _buildLoading();
            }
            if (!_blastControlle.isLoading &&
                _blastControlle.posts.length == 0) {
              return _buildEmpty(_blastControlle);
            }
            return _buildHasData(_blastControlle);
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'blast',
        onPressed: () {
          Get.toNamed(
              RouteName.blastFormScreen(companyId: companyId, teamId: teamId!));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Center _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  SmartRefresher _buildEmpty(BlastController _blastControlle) {
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 89,
        ),
        Image.asset(
          'assets/images/blast.png',
          height: 145.w,
          width: 247.w,
          fit: BoxFit.contain,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 34, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            width: 306.w,
            child: Column(
              children: [
                Text(
                  'No blasts here yet...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
                ),
              ],
            ))
      ],
    );
    return SmartRefresher(
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(_blastControlle),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }

  Widget _buildHasData(BlastController _blastControlle) {
    return SmartRefresher(
      enablePullUp: true,
      header: WaterDropMaterialHeader(),
      controller: refreshController,
      onRefresh: () => onRefresh(_blastControlle),
      onLoading: () => onLoadMore(_blastControlle),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = SizedBox();
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: _blastControlle.posts.length,
          itemBuilder: (ctx, index) {
            PostItemModel item = _blastControlle.posts[index];
            return BlastItem(
              item: item,
            );
          }),
    );
  }
}
