import 'dart:io';
import 'dart:math';

// import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';
// import 'package:cicle_mobile_f3/service/doc_file_service.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:html/parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/board_list_item_model.dart';
import '../models/member_model.dart';
import '../screens/invitation_screen.dart';
import '../service/doc_file_service.dart';
import '../widgets/webview_cummon.dart';
import 'constant.dart';
import 'internal_link_adapter.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    if (colourNameToHex(hexColor) != null) {
      hexColor = colourNameToHex(hexColor).toUpperCase().replaceAll("#", "");

      hexColor = "FF" + hexColor;
      return int.parse(hexColor, radix: 16);
    }

    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String getInitials(String texts) => texts.isNotEmpty
    ? texts.trim().split(' ').map((l) => l[0]).take(2).join()
    : '';

showAlert(
    {String message = '',
    Widget? customActionWidget,
    int flashDuration = 4, // in s
    FlashPosition position = FlashPosition.top,
    messageColor = const Color(0xff1F3762)}) {
  EasyDebounce.debounce(
      'submit-add-check-in', // <-- An ID for this particular debouncer
      Duration(milliseconds: 400), // <-- The debounce duration
      () {
    showFlash(
      context: Get.context!,
      duration: Duration(seconds: flashDuration),
      builder: (context, controller) {
        return Flash(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
          margin: EdgeInsets.all(20),
          controller: controller,
          behavior: FlashBehavior.floating,
          boxShadows: kElevationToShadow[4],
          position: position,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            padding: EdgeInsets.zero,
            content: Row(
              children: [
                Container(
                  height: 52,
                  width: 6,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          message,
                          style: TextStyle(fontSize: 12, color: messageColor),
                        ))),
                customActionWidget != null ? customActionWidget : SizedBox(),
                IconButton(
                    onPressed: () {
                      controller.dismiss();
                    },
                    icon: Icon(Icons.close))
              ],
            ),
          ),
        );
      },
    );
  } // <-- The target method
      );
}

String removeHtmlTag(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body!.text).documentElement!.text;

  return parsedString;
}

String getPhotoUrl({String url = ''}) {
  if (url == "") {
    return 'https://api.cicle.app/public/images/logo-square%20center-black.png';
  }
  if (url.contains(Env.BASE_URL)) {
    var getPartUrl = url.split(Env.BASE_URL);
    return 'https://api.cicle.app' + Uri.encodeFull(getPartUrl[1]);
  }
  if (url[0] == '/') {
    return 'https://api.cicle.app' + Uri.encodeFull(url);
  } else {
    return url;
  }
}

List months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

hideKeyboard() {
  return FocusScope.of(Get.context!).unfocus();
}

Future<bool> checkPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}

validateEmail(String email) {
  bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
  return emailValid;
}

const cardHomeColorsList = [
  '#794C74',
  '#C56183',
  '#03C4A1',
  '#FF7171',
  '#0880AE',
  '#14A38B'
];

String getModuleNameByIndex(int index) {
  switch (index) {
    case 0:
      return 'overview';
    case 1:
      return 'blasts';
    case 2:
      return 'boards';
    case 3:
      return 'docs';
    case 4:
      return 'group-chat';
    case 5:
      return 'schedules';
    default:
      return 'check-ins';
  }
}

showLoadingOverlay() {
  return Get.dialog(
      Container(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
      name: 'loading-overlay');
}

colourNameToHex(name) {
  Map<String, String> colours = {
    "aliceblue": "#f0f8ff",
    "antiquewhite": "#faebd7",
    "aqua": "#00ffff",
    "aquamarine": "#7fffd4",
    "azure": "#f0ffff",
    "beige": "#f5f5dc",
    "bisque": "#ffe4c4",
    "black": "#000000",
    "blanchedalmond": "#ffebcd",
    "blue": "#0000ff",
    "blueviolet": "#8a2be2",
    "brown": "#a52a2a",
    "burlywood": "#deb887",
    "cadetblue": "#5f9ea0",
    "chartreuse": "#7fff00",
    "chocolate": "#d2691e",
    "coral": "#ff7f50",
    "cornflowerblue": "#6495ed",
    "cornsilk": "#fff8dc",
    "crimson": "#dc143c",
    "cyan": "#00ffff",
    "darkblue": "#00008b",
    "darkcyan": "#008b8b",
    "darkgoldenrod": "#b8860b",
    "darkgray": "#a9a9a9",
    "darkgreen": "#006400",
    "darkkhaki": "#bdb76b",
    "darkmagenta": "#8b008b",
    "darkolivegreen": "#556b2f",
    "darkorange": "#ff8c00",
    "darkorchid": "#9932cc",
    "darkred": "#8b0000",
    "darksalmon": "#e9967a",
    "darkseagreen": "#8fbc8f",
    "darkslateblue": "#483d8b",
    "darkslategray": "#2f4f4f",
    "darkturquoise": "#00ced1",
    "darkviolet": "#9400d3",
    "deeppink": "#ff1493",
    "deepskyblue": "#00bfff",
    "dimgray": "#696969",
    "dodgerblue": "#1e90ff",
    "firebrick": "#b22222",
    "floralwhite": "#fffaf0",
    "forestgreen": "#228b22",
    "fuchsia": "#ff00ff",
    "gainsboro": "#dcdcdc",
    "ghostwhite": "#f8f8ff",
    "gold": "#ffd700",
    "goldenrod": "#daa520",
    "grey": "#808080",
    "gray": "#808080",
    "green": "#008000",
    "greenyellow": "#adff2f",
    "honeydew": "#f0fff0",
    "hotpink": "#ff69b4",
    "indianred ": "#cd5c5c",
    "indigo": "#4b0082",
    "ivory": "#fffff0",
    "khaki": "#f0e68c",
    "lavender": "#e6e6fa",
    "lavenderblush": "#fff0f5",
    "lawngreen": "#7cfc00",
    "lemonchiffon": "#fffacd",
    "lightblue": "#add8e6",
    "lightcoral": "#f08080",
    "lightcyan": "#e0ffff",
    "lightgoldenrodyellow": "#fafad2",
    "lightgrey": "#d3d3d3",
    "lightgreen": "#90ee90",
    "lightpink": "#ffb6c1",
    "lightsalmon": "#ffa07a",
    "lightseagreen": "#20b2aa",
    "lightskyblue": "#87cefa",
    "lightslategray": "#778899",
    "lightsteelblue": "#b0c4de",
    "lightyellow": "#ffffe0",
    "lime": "#00ff00",
    "limegreen": "#32cd32",
    "linen": "#faf0e6",
    "magenta": "#ff00ff",
    "maroon": "#800000",
    "mediumaquamarine": "#66cdaa",
    "mediumblue": "#0000cd",
    "mediumorchid": "#ba55d3",
    "mediumpurple": "#9370d8",
    "mediumseagreen": "#3cb371",
    "mediumslateblue": "#7b68ee",
    "mediumspringgreen": "#00fa9a",
    "mediumturquoise": "#48d1cc",
    "mediumvioletred": "#c71585",
    "midnightblue": "#191970",
    "mintcream": "#f5fffa",
    "mistyrose": "#ffe4e1",
    "moccasin": "#ffe4b5",
    "navajowhite": "#ffdead",
    "navy": "#000080",
    "oldlace": "#fdf5e6",
    "olive": "#808000",
    "olivedrab": "#6b8e23",
    "orange": "#ffa500",
    "orangered": "#ff4500",
    "orchid": "#da70d6",
    "palegoldenrod": "#eee8aa",
    "palegreen": "#98fb98",
    "paleturquoise": "#afeeee",
    "palevioletred": "#d87093",
    "papayawhip": "#ffefd5",
    "peachpuff": "#ffdab9",
    "peru": "#cd853f",
    "pink": "#ffc0cb",
    "plum": "#dda0dd",
    "powderblue": "#b0e0e6",
    "purple": "#800080",
    "rebeccapurple": "#663399",
    "red": "#ff0000",
    "rosybrown": "#bc8f8f",
    "royalblue": "#4169e1",
    "saddlebrown": "#8b4513",
    "salmon": "#fa8072",
    "sandybrown": "#f4a460",
    "seagreen": "#2e8b57",
    "seashell": "#fff5ee",
    "sienna": "#a0522d",
    "silver": "#c0c0c0",
    "skyblue": "#87ceeb",
    "slateblue": "#6a5acd",
    "slategray": "#708090",
    "snow": "#fffafa",
    "springgreen": "#00ff7f",
    "steelblue": "#4682b4",
    "tan": "#d2b48c",
    "teal": "#008080",
    "thistle": "#d8bfd8",
    "tomato": "#ff6347",
    "turquoise": "#40e0d0",
    "violet": "#ee82ee",
    "wheat": "#f5deb3",
    "white": "#ffffff",
    "whitesmoke": "#f5f5f5",
    "yellow": "#ffff00",
    "yellowgreen": "#9acd32"
  };
  return colours[name];
}

getPathExtention({mimeType = ''}) {
  switch (mimeType) {
    case 'pdf':
      return 'assets/images/icon_pdf-min.png';
    case 'docx':
      return 'assets/images/icon_word-min.png';
    case 'xlsx':
      return 'assets/images/icon_xls-min.png';
    case 'ppt':
      return 'assets/images/icon_ppt-min.png';
    default:
      return 'assets/images/icon_question-min.png';
  }
}

List<String> getMentionedUsers(
    String contentAsParams, List<MemberModel> teamMembersAsParams) {
  final regPatern = r'data-mentioned-user-id\=\"([A-Za-z0-9 _]*)\"';
  final regEx = RegExp(regPatern, multiLine: true);
  final obtainedMemeberId =
      regEx.allMatches(contentAsParams).map((m) => m.group(0)).join(',');
  if (obtainedMemeberId == "") {
    return [];
  }

  var mentionedMemberId = obtainedMemeberId.split(',');
  List<String> listStringMemberId = mentionedMemberId.map((e) {
    var id = e.split("=")[1];
    return id;
  }).toList();

  List<String> uniqMentionedId = listStringMemberId.toSet().toList();

  var removeDoubleQuete = uniqMentionedId.map((e) {
    var x = e.replaceAll('"', '_');
    var g = x.replaceAll("_", '');
    return g;
  }).toList();
  return removeDoubleQuete;
}

Future<bool> parseLinkPressed(String url) async {
  var prefixUrl = url.split(":");
  if (!prefixUrl[0].contains('https') && !prefixUrl[0].contains('http')) {
    url = 'https://$url';
  }

  url = url.replaceAll('%7D', "").replaceAll('}', "");
  // if (prefixUrl[0] == 'https') {
  //   url = url;
  // } else if (prefixUrl[0] == 'http') {
  //   url = url;
  // }

  // if (prefixUrl[0] == 'https' || prefixUrl[0] == 'http') {
  //   url = url;
  // } else {

  // }

  // if (prefixUrl[0] != 'https' && prefixUrl[0] != 'http') {
  //   url = 'https://$url';
  // }
  // print('url $url');

  var isInternalUrl = url.split(Env.WEB_URL);
  // print('url isInternalUrl.length ${isInternalUrl.length}');
  // print(isInternalUrl);
  if (isInternalUrl.length > 1) {
    print('link adapter');
    internalLinkAdapter(isInternalUrl[1]);
    return true;
  }

  // print('url $url');
  // return;
  // await canLaunchUrl(Uri.parse(url))
  //     ? await launchUrl(Uri.parse(url))
  //     : showAlert(message: "can't open $url", messageColor: Colors.red);
  try {
    bool canLaunch = await canLaunchUrl(Uri.parse(url));
    print('url canLaunch $canLaunch');
    if (canLaunch) {
      bool isLaunched =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!isLaunched) {
        showAlert(message: "can't open $url", messageColor: Colors.red);
      }
    } else {
      Get.to(WebViewCummon(url: url));
      // showAlert(message: "can't launch zzzz $url", messageColor: Colors.red);
    }

    return true;
  } catch (e) {
    // print(e);
    showAlert(message: e.toString(), messageColor: Colors.red);
    return false;
  }
}

String checkIsUrlHaveInvitationToken(String fullUrl, bool needSaveToLocal) {
  if (fullUrl.contains('/invitation/')) {
    List<String> splitUrl = fullUrl.split("/");
    if (splitUrl.length > 2) {
      if (splitUrl[1] == 'invitation') {
        String invitationTokenValue = splitUrl[2].replaceAll('.', '');
        final box = GetStorage();
        if (needSaveToLocal) {
          box.write(KeyStorage.invitationToken, invitationTokenValue);
        }

        Get.toNamed(RouteName.invitationScreen(invitationTokenValue));

        return invitationTokenValue;
      }

      return '';
    }

    return '';
  }

  return '';
}

bool isSameDayHelper(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

List<String> toggleMembersAdapter(
    List<MemberModel> membersFromListDialog, List<MemberModel> members) {
  List<MemberModel> _currentModuleMembers = [...members];
  List<String> listIdMembersFromListDialog =
      membersFromListDialog.map((e) => e.sId).toList();
  List<String> listIdCurrentTeamMembers =
      _currentModuleMembers.map((e) => e.sId).toList();
  List<String> result = [];
  listIdMembersFromListDialog.map((e) {
    if (listIdCurrentTeamMembers.contains(e)) {
    } else {
      result.add(e);
    }
  }).toList();
  listIdCurrentTeamMembers.map((e) {
    if (listIdMembersFromListDialog.contains(e)) {
    } else {
      result.add(e);
    }
  }).toList();
  return result.toSet().toList();
}

Future<String> uploadImage(PlatformFile file, Function onSuccess) async {
  try {
    DocFileService _docFileService = DocFileService();
    dynamic body = {"uri": file.path, "name": file.name};
    final response = await _docFileService.uploadImageEditor(body);

    onSuccess(response.data['link']);
    return Future.value(response.data['link']);
  } catch (e) {
    print(e);

    return Future.value('');
  }
}

Future<String> uploadVideo(PlatformFile file, Function onSuccess) async {
  try {
    DocFileService _docFileService = DocFileService();
    dynamic body = {"uri": file.path, "name": file.name};
    final response = await _docFileService.uploadVideoEditor(body);

    onSuccess(response.data['link']);
    return Future.value(response.data['link']);
  } catch (e) {
    print(e);

    return Future.value('');
  }
}

Future<String> uploadFile(PlatformFile file, Function onSuccess) async {
  try {
    DocFileService _docFileService = DocFileService();
    dynamic body = {"uri": file.path, "name": file.name};
    final response = await _docFileService.uploadFileEditor(body);

    onSuccess(response.data['link']);
    return Future.value(response.data['link']);
  } catch (e) {
    print(e);

    return Future.value('');
  }
}

String errorMessageMiddleware(payload,
    [hideAlert = false, String actionName = '']) {
  String errorMessage = '';

  if (payload is DioError) {
    int code = payload.response!.statusCode!;
    String message =
        payload.response?.data?['message'] ?? payload.response!.statusMessage!;
    errorMessage = '$message, status code: $code';
  } else if (payload == StateError) {
    errorMessage = payload.message;
  } else {
    errorMessage = 'Internal Server Error';
  }

  String finalMessage = '$actionName $errorMessage';
  if (payload is DioError && hideAlert == false) {
    finalMessage = '$finalMessage, ${payload.response?.data?['message']}';
    showAlert(
        message: '$finalMessage, ${payload.error}', messageColor: Colors.red);
  } else if (hideAlert == false) {
    showAlert(message: finalMessage, messageColor: Colors.red);
  }

  return finalMessage;
}

List<String> subcriberAdapter(List<MemberModel> value) {
  List<String> result = value.map((e) => e.sId).toList();
  return result;
}

int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
}

String autoLinkAdapter(String content) {
  RegExp exp = new RegExp(
      r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);
  String _tempContent = content;
  var replaceNbsp = _tempContent.replaceAll('"', "'");
  var splitBySpace = replaceNbsp.split(" ");

  String _finalContent = '';
  for (var i = 0; i < splitBySpace.length; i++) {
    String _text = splitBySpace[i];

    if (_text.contains("src") || _text.contains("href")) {
      _finalContent += "$_text ";
    } else {
      // check text is url or not
      if (exp.hasMatch(_text)) {
        String _link = _text;
        var replaceNbspWithSpace = _link.replaceAll('&nbsp;', " ");
        var splitLink = replaceNbspWithSpace.split(" ");
        String _tempLink = '';
        for (var j = 0; j < splitLink.length; j++) {
          String _text2 = splitLink[j];
          if (exp.hasMatch(_text2)) {
            if (_text2.contains("src") || _text2.contains("href")) {
              _tempLink += "$_text2 ";
            } else {
              _tempLink +=
                  '<a href="$_text2" rel=\"noopener noreferrer\" target=\"_blank\">$_text2</a> ';
            }
          } else {
            _tempLink += "$_text2 ";
          }
        }

        _finalContent += "$_tempLink ";
      } else {
        String _tempText = _text;
        RegExp extrackUrl = new RegExp(
            r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
            caseSensitive: false);
        Iterable<RegExpMatch> matches = extrackUrl.allMatches(_tempText);

        String _tempText2 = _tempText;
        matches.forEach((match) {
          String _extractedUrl = _tempText.substring(match.start, match.end);

          if (!_checkIsBadUrl(_extractedUrl)) {
            _tempText2 = _tempText2.replaceAll(_extractedUrl,
                '<a href="$_extractedUrl" rel=\"noopener noreferrer\" target=\"_blank\">$_extractedUrl</a> ');
          }
        });

        _finalContent += "$_tempText2 ";
      }
    }
  }

  return _finalContent;
}

bool _checkIsBadUrl(String url) {
  var a = url.split(".");
  if (a.length <= 2) {
    return true;
  }

  return false;
}

getDueCardColor(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final aDate = DateTime(date.year, date.month, date.day);

  if (aDate == today) {
    // due today
    return Color(0xffFFF86B);
  }

  final duration = date.difference(now).inMinutes;

  if (duration > 0 && duration <= 1440) {
    // due soon
    return Color(0xffFFF86B);
  } else if (duration < 0) {
    // over due
    return Colors.red;
  }

  return Color(0xffD6D6D6);
}

getDueTextColor(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final aDate = DateTime(date.year, date.month, date.day);

  if (aDate == today) {
    // due today
    return Colors.black;
  }

  final duration = date.difference(now).inMinutes;

  if (duration > 0 && duration <= 1440) {
    // due soon
    return Colors.black;
  } else if (duration < 0) {
    // over due
    return Colors.white;
  }

  return Colors.black;
}

getIconDueDate(BoardListItemModel list) {
  if (!list.complete.status) {
    return Icons.notifications_active;
  } else {
    if (list.complete.type == "done") {
      return Icons.check_circle;
    } else {
      return Icons.block;
    }
  }
}

moduleNameAdapter(String name) {
  switch (name) {
    case 'blast':
      return 'posts';
    case 'blasts':
      return 'posts';
    case 'card':
      return 'cards';
    case 'boards':
      return 'cards';
    case 'question':
      return 'questions';
    case 'check-ins':
      return 'questions';
    case 'file':
      return 'files';
    case 'doc':
      return 'docs';
    case 'occurrence':
      return 'occurrences';
    case 'event':
      return 'events';
    case 'schedules':
      return 'events';
    default:
      return name;
  }
}

String dummyContent = '''
<p>Karena sekarang untuk di backend logging error nya udah terpusat di sentry.io, jadi aku buat dokumentasi ini untuk yg pengen ngecek log error dari local development, live server staging atau production. jadi ntar bisa segera di fix klo ada error sebelum ketahuan wkwkw</p><p><br></p><ol><li>Login ke <a href="https://sentry.io/" rel="noopener noreferrer" target="_blank">https://sentry.io/</a> menggunakan email developer cicle (<span style='color: rgb(43, 29, 56); font-family: Rubik, "Avenir Next", "Helvetica Neue", sans-serif; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;'><strong>dev.cicle@gmail.com</strong></span>)</li><li>Masuk ke menu <strong>Issues&nbsp;</strong>pilih project yg ada (cicle-local / cicle-staging / cicle-prod)<br><img src="https://api.cicle.app/public/uploads/f5b994791f0fdab3-1627972064267.png" style="width: 300px;" class="fr-fic fr-dib"></li><li>Cek detail error, klik <strong>ReferenceError&nbsp;</strong>pada kotak gambar diatas<br><img src="https://api.cicle.app/public/uploads/a3d00ca0b437a8e2-1627972214241.png" style="width: 300px;" class="fr-fic fr-dib"></li><li>Klik <strong>Resolve&nbsp;</strong>jika bug sudah di fix.</li><li>Selesai. untuk menu2 lain bisa di explore sendiri yaa~</li></ol><p><br></p><p>Untuk project di sentry.io ada 3, yaitu:</p><ul><li><strong>cicle-local&nbsp;</strong>untuk logging error saat development di local</li><li><strong>cicle-staging&nbsp;</strong>untuk logging error di live server staging</li><li><strong>cicle-production&nbsp;</strong>untuk logging error di live server production</li></ul><p><br></p><p>Masing-masing memiliki client key DSN sebagai berikut:</p><ul><li><strong>cicle-local&nbsp;</strong><br><a href="https://205541381ee2443dbc13c18e057288a7@o941422.ingest.sentry.io/5890256" rel="noopener noreferrer" target="_blank">https://205541381ee2443dbc13c18e057288a7@o941422.ingest.sentry.io/5890256</a></li><li><strong>cicle-staging</strong><br><a href="https://d7ba405a467847e5ba8b38c6dab66784@o941422.ingest.sentry.io/5890248" rel="noopener noreferrer noopener noreferrer" target="_blank">https://d7ba405a467847e5ba8b38c6dab66784@o941422.ingest.sentry.io/5890248</a></li><li><strong>cicle-production</strong><br><a href="https://c181434b5a374d259933a32e409f1f6a@o941422.ingest.sentry.io/5890241" rel="noopener noreferrer noopener noreferrer noopener noreferrer" target="_blank">https://c181434b5a374d259933a32e409f1f6a@o941422.ingest.sentry.io/5890241</a></li></ul><p><br></p><p>Dokumen ini akan selalu di update jika ada perubahan atau ada yg perlu ditambahkan.</p>
''';
