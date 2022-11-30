// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cicle_mobile_f3/env/env.dart';

class RouteName {
  static String splashScreen = '/';
  static String introScreen = '/intro';
  static String signInScreen = '/sign-in';

  static String myTaskKanbanMoreScreen(String companyId) =>
      '/dashboard/$companyId/my-task-kanban-more';
  static String myTaskBlastMoreScreen(String companyId) =>
      '/dashboard/$companyId/my-task-blast-more';

  static String dashboardScreen(String companyId) => '/dashboard/$companyId';
  static String profileScreen(String companyId) =>
      '/dashboard/$companyId/profile';
  static String privateChatScreen(String companyId) =>
      '/dashboard/$companyId/private-chats';
  static String privateChatDetailScreen(String companyId, String chatId) =>
      '/dashboard/$companyId/private-chats-detail/$chatId';
  static String teamDetailScreen(String companyId) =>
      '/dashboard/$companyId/team-detail';

  static String myTaskScreen(String companyId) =>
      '/dashboard/$companyId/my-task';
  static String workloadScreen(String companyId) =>
      '/dashboard/$companyId/workload';
  static String staticReportScreen(String companyId) =>
      '/dashboard/$companyId/static-report';
  static String cheersScreen(String companyId) =>
      '/dashboard/$companyId/cheers';

  // BLAST
  static String blastDetailScreen(
          String companyId, String teamId, String blastId) =>
      '/dashboard/$companyId/team-detail/$teamId/blasts/$blastId';
  static String blastFormScreen(
      {required String teamId, required String companyId}) {
    return '/dashboard/$companyId/team-detail/$teamId/blast-form';
  }

  // SCHEDULE
  static String scheduleDetailScreen(
          String companyId, String teamId, String scheduleId) =>
      '/dashboard/$companyId/team-detail/$teamId/schedules/$scheduleId';
  static String scheduleFormScreen(
      {required String teamId, required String companyId}) {
    return '/dashboard/$companyId/team-detail/$teamId/schedules-form';
  }

  static String occurenceDetailScreen(String companyId, String teamId,
          String scheduleId, String occurrencesId) =>
      '/dashboard/$companyId/team-detail/$teamId/schedules/$scheduleId/occurrences/$occurrencesId';

  // BOARD
  static String boardDetailScreen(
          String companyId, String teamId, String boardsId) =>
      '/dashboard/$companyId/team-detail/$teamId/boards/$boardsId';

  // CHECKIN
  static String checkInDetailScreen(
          String companyId, String teamId, String checkInId) =>
      '/dashboard/$companyId/team-detail/$teamId/check-ins/$checkInId';

  static String checkInForm(
          String companyId, String teamId, String checkInId, String type) =>
      '/dashboard/$companyId/team-detail/$teamId/check-in/$checkInId/form/$type';

  // DOC & FILES
  static String docDetailScreen(
          String companyId, String teamId, String docId) =>
      '/dashboard/$companyId/team-detail/$teamId/docs/$docId';

  static String fileDetailScreen(
          String companyId, String teamId, String fileId) =>
      '/dashboard/$companyId/team-detail/$teamId/files/$fileId';

  static String folderDetailScreen(
          String companyId, String teamId, String folderId) =>
      '/dashboard/$companyId/team-detail/$teamId/folder/$folderId';

  static String docFormScreen(
      {required String teamId, required String companyId}) {
    return '/dashboard/$companyId/team-detail/$teamId/doc-form';
  }
  //

  static String groupChatScreen(
          String companyId, String teamId, String groupChatId) =>
      '/dashboard/$companyId/team-detail/$teamId/group-chats/$groupChatId';

  static String commentDetailScreen(String companyId, String teamId,
          String moduleName, String moduleId, String commentId) =>
      '/dashboard/$companyId/team-detail/$teamId/$moduleName/$moduleId/comments/$commentId';

  // Search
  static String searchResultScreen(
    String companyId,
    String teamId,
  ) =>
      '/search-result?companyId=$companyId&teamId=$teamId';
  static String searchResultAllRelatedScreen(
    String companyId,
    String teamId,
  ) =>
      '/search-result-all?companyId=$companyId&teamId=$teamId';

  // invitation
  static String invitationScreen(String invitationToken) {
    return '/invitation/$invitationToken';
  }
}

class ErrorMessage {
  static String cummon = 'Internal Network Error';
  static String noInternet = 'No internet Connection';
  static String somethingWentWrong = 'Something went wrong please try again :(';
  static String errorLoadingDocument =
      'an Error occurend while loading your file';
  static String errorTimeout =
      'it seems the page you want to open\nis taking too long to load';
}

class KeyStorage {
  static String token = 'token';
  static String selectedCompanyId = 'selectedCompanyId';
  static String deviceId = 'device_id';
  static String logedInUser = 'loged_in_user';
  static String invitationToken = 'invitationToken';
}

class Constants {
  static String companyActive = 'Company is active.';
}

// class Env {
//   // ignore: non_constant_identifier_names
//   static String BASE_API = dotenv.env['BASE_API'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String BASE_URL = dotenv.env['BASE_URL'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String BASE_URL_SOCKET = dotenv.env['BASE_URL_SOCKET'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String WEB_URL = dotenv.env['WEB_URL'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String GOOGLE_WEB_CLIENT_ID = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String GOOGLE_IOS_CLIENT_ID = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';
//   // ignore: non_constant_identifier_names
//   static String ONE_SIGNAL_APP_ID = dotenv.env['ONE_SIGNAL_APP_ID'] ?? '';
// }
class Env {
  // ignore: non_constant_identifier_names
  static String BASE_API = EnvLib.BASE_API;
  // ignore: non_constant_identifier_names
  static String BASE_URL = EnvLib.BASE_URL;
  // ignore: non_constant_identifier_names
  static String BASE_URL_SOCKET = EnvLib.BASE_URL_SOCKET;
  // ignore: non_constant_identifier_names
  static String WEB_URL = EnvLib.WEB_URL;
  // ignore: non_constant_identifier_names
  static String GOOGLE_WEB_CLIENT_ID = EnvLib.GOOGLE_WEB_CLIENT_ID;
  // ignore: non_constant_identifier_names
  static String GOOGLE_IOS_CLIENT_ID = EnvLib.GOOGLE_IOS_CLIENT_ID;
  // ignore: non_constant_identifier_names
  static String ONE_SIGNAL_APP_ID = EnvLib.ONE_SIGNAL_APP_ID;
}
