import 'dart:io';

import 'package:cicle_mobile_f3/bidings/auth_binding.dart';
import 'package:cicle_mobile_f3/bidings/blast_binding.dart';
import 'package:cicle_mobile_f3/bidings/blast_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/board_binding.dart';
import 'package:cicle_mobile_f3/bidings/board_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/check_in_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/comment_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/doc_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/file_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/folder_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/group_chat_binding.dart';
import 'package:cicle_mobile_f3/bidings/initial_binding.dart';
import 'package:cicle_mobile_f3/bidings/my_task_binding.dart';
import 'package:cicle_mobile_f3/bidings/my_task_blast_more_binding.dart';
import 'package:cicle_mobile_f3/bidings/my_task_kanban_more_binding.dart';
import 'package:cicle_mobile_f3/bidings/private_chat_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/schedule_detail_binding.dart';
import 'package:cicle_mobile_f3/bidings/search_binding.dart';
import 'package:cicle_mobile_f3/bidings/tab_main_binding.dart';
import 'package:cicle_mobile_f3/bidings/team_detail_binding.dart';
import 'package:cicle_mobile_f3/screens/cheers/cheers_screen.dart';
import 'package:cicle_mobile_f3/screens/comment_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/blast/blast_form_screen.dart';
import 'package:cicle_mobile_f3/screens/core/blast_detail/blast_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/board_detail/board_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/check_in/check_in_form.dart';
import 'package:cicle_mobile_f3/screens/core/check_in_detail/check_in_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/doc_and_file/doc_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/doc_and_file/doc_form_screen.dart';
import 'package:cicle_mobile_f3/screens/core/doc_and_file/file_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/doc_and_file/folder_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/core/group_chat/group_chat_screen.dart';
import 'package:cicle_mobile_f3/screens/core/schedule/schedule_form_screen.dart';
import 'package:cicle_mobile_f3/screens/core/schedule_detail/event_occurence_detail.dart';
import 'package:cicle_mobile_f3/screens/core/schedule_detail/schedule_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/dashboard_screen.dart';
import 'package:cicle_mobile_f3/screens/dashboard_team.dart';
import 'package:cicle_mobile_f3/screens/intro_screen.dart';
import 'package:cicle_mobile_f3/screens/invitation_screen.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_blast_more_screen.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_kanban_more_screen.dart';
import 'package:cicle_mobile_f3/screens/my_task/my_task_screen.dart';
import 'package:cicle_mobile_f3/screens/private_chat_detail_screen.dart';
import 'package:cicle_mobile_f3/screens/private_chat/private_chat_screen.dart';
import 'package:cicle_mobile_f3/screens/profile_screen.dart';
import 'package:cicle_mobile_f3/screens/search/search_result_all_related_screen.dart';
import 'package:cicle_mobile_f3/screens/search/search_result_screen.dart';
import 'package:cicle_mobile_f3/screens/sign_in_screen.dart';
import 'package:cicle_mobile_f3/screens/splash_screen.dart';
import 'package:cicle_mobile_f3/screens/statistic_report/statistic_report_screen.dart';
import 'package:cicle_mobile_f3/screens/workload/workload_screen.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:get/get.dart';

import '../screens/tnc_screen.dart';

class RoutePages {
  static routes() {
    return [
      GetPage(
          name: RouteName.splashScreen,
          page: () => SplashScreen(),
          binding: InitialBinding()),
      GetPage(
          name: '/splash-end',
          page: () => SplashEndScreen(),
          transition: Platform.isAndroid ? Transition.fade : Transition.native,
          binding: InitialBinding()),
      GetPage(
          name: RouteName.introScreen,
          page: () => IntroScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: RouteName.signInScreen,
          page: () => SignInScreen(),
          binding: AuthBinding()),
      GetPage(
          name: '/dashboard/:companyId',
          page: () => DashboardScreen(),
          transition: Transition.fadeIn,
          binding: TabMainBinding()),
      GetPage(
          name: '/dashboard/:companyId/profile', page: () => ProfileScreen()),
      GetPage(
          name: '/dashboard/:companyId/private-chats',
          page: () => PrivateChatScreen()),
      GetPage(
          name: '/dashboard/:companyId/private-chats-detail/:chatId',
          page: () => PrivateChatDetailScreen(),
          binding: PrivateChatDetailBinding()),
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId',
          page: () => DashboardTeamScreen(),
          // transition: Transition.fadeIn,
          transitionDuration: Duration(milliseconds: 300),
          bindings: [
            TabMainBinding(),
            TeamDetailBinding(),
            BoardBinding(),
            BlastBinding()
          ]),

      // BLAST
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/blasts/:blastId',
          page: () => BlastDetailScreen(),
          binding: BlastDetailBinding()),
      GetPage(
        name: '/dashboard/:companyId/team-detail/:teamId/blast-form',
        page: () => BlastFormScreen(),
      ),

      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/schedules/:scheduleId',
          page: () => ScheduleDetailScreen(),
          binding: ScheduleDetailBinding()),
      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/schedules/:scheduleId/occurrences/:occurenceId',
          page: () => EventOccurenceDetail(),
          binding: ScheduleDetailBinding()),
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/schedules-form',
          page: () => ScheduleFormScreen()),

      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/boards/:boardsId',
          page: () => BoardDetailScreen(),
          binding: BoardDetailBinding()),

      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/check-ins/:checkInId',
          page: () => CheckInDetailScreen(),
          binding: CheckInDetailBinding()),
      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/check-in/:checkInId/form/:type',
          page: () => CheckInForm()),

      // DOCS & FILES
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/docs/:docId',
          page: () => DocDetailScreen(),
          binding: DocDetailBinding()),
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/files/:fileId',
          page: () => FileDetailScreen(),
          binding: FileDetailBinding()),
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/folder/:folderId',
          page: () => FolderDetailScreen(),
          binding: FolderDetailBinding()),
      GetPage(
          name: '/dashboard/:companyId/team-detail/:teamId/doc-form',
          page: () => DocFormScreen()),

      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/group-chats/:groupChatId',
          page: () => GroupChatScreen(),
          binding: GroupChatBinding()),

      GetPage(
          name:
              '/dashboard/:companyId/team-detail/:teamId/:moduleName/:moduleId/comments/:commentId',
          page: () => CommentDetailScreen(),
          binding: CommentDetailBinding()),

      GetPage(
          name: '/dashboard/:companyId/my-task',
          page: () => MyTaskScreen(),
          binding: MyTaskBinding()),
      GetPage(
          name: '/dashboard/:companyId/my-task-kanban-more',
          page: () => MyTaskKanbanMoreScreen(),
          binding: MyTaskkanbanMoreBinding()),

      GetPage(
          name: '/dashboard/:companyId/my-task-blast-more',
          page: () => MyTaskBlastMoreScreen(),
          binding: MyTaskBlastMoreBinding()),

      GetPage(
        name: '/dashboard/:companyId/workload',
        page: () => WorkloadScreen(),
      ),
      GetPage(
        name: '/dashboard/:companyId/static-report',
        page: () => StatisticReportScreen(),
      ),
      GetPage(
        name: '/dashboard/:companyId/cheers',
        page: () => CheersScreen(),
      ),
      GetPage(
          name: '/search-result',
          page: () => SearchResultScreen(),
          binding: SearchBinding(),
          transition: Transition.noTransition),
      GetPage(
        name: '/search-result-all',
        page: () => SearchResultAllRelatedScreen(),
      ),

      GetPage(
        name: '/invitation/:invitationToken',
        page: () => InvitationScreen(),
      ),

      GetPage(name: '/tnc', page: () => TncScreen())
    ];
  }
}
