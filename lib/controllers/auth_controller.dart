import 'dart:convert';
import 'dart:io';
import 'dart:math';
// import 'package:cicle_mobile_f3/service/auth_service.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
// import 'package:cicle_mobile_f3/utils/helpers.dart';
// import 'package:cicle_mobile_f3/widgets/apple_in_app_webview_screen.dart';
import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import '../models/companies_model.dart';
import '../models/member_model.dart';
import '../service/auth_service.dart';
import '../utils/constant.dart';
import '../utils/helpers.dart';
import '../widgets/apple_in_app_webview_screen.dart';

class AuthController extends GetxController {
  var uuid = Uuid();

  // service
  AuthService _authService = AuthService();
  final box = GetStorage();

  GoogleSignIn _googleSignIn = GoogleSignIn(clientId: Env.GOOGLE_WEB_CLIENT_ID);

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  var packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  ).obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _initPackageInfo();
  }

  checkPrivacyPolice(callback) async {
    var isTNCChecked = box.read('tncChecked');
    print(isTNCChecked);
    if (isTNCChecked == null) {
      // // Get.offNamed('/tnc');
      // Get.back();
      await Future.delayed(Duration(milliseconds: 300));
      var result = await Get.toNamed('/tnc');
      // print(result);
      if (result is bool && result == true) {
        // box.write('tncChecked', true);
        callback();
      }
    } else {
      callback();
    }
  }

  _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      packageInfo.value = info;
    } catch (e) {
      print(e);
    }
  }

  signInGoogle() async {
    if (Platform.isIOS) {
      googleSignInForIos();

      return;
    }

    _isLoading.value = true;
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await account.authentication;

        String? code = googleSignInAuthentication.serverAuthCode;
        final response = await _authService.googleService(code!);
        await DefaultCacheManager().emptyCache();
        await DefaultCacheManager().emptyCache();
        String token = response.data['token'];
        // String deviceId = uuid.v4();
        dynamic user = response.data['user'];

        // String token = body['token'];
        // String token = dummyToken;

        String deviceId = uuid.v4();
        // dynamic user = body['user'];
        // dynamic user = dummyUser;

        // if (response.data['user']['defaultCompany'] != null) {
        //   String companyId = user['defaultCompany'].runtimeType == String
        //       ? user['defaultCompany']
        //       : user['defaultCompany']?['_id'];
        //   box.write(KeyStorage.selectedCompanyId, companyId);
        //   final newSession =
        //       await _authService.renewSession(token, deviceId, companyId);

        //   if (newSession.statusCode == 200 || newSession.statusCode == 201) {
        //     box.write(KeyStorage.token, token);
        //     box.write(KeyStorage.deviceId, deviceId);
        //     box.write(KeyStorage.logedInUser, user);
        //     _isLoading.value = false;
        //     return redirect(companyId);
        //   }
        // } else {
        // case user dont have company
        box.write(KeyStorage.token, token);
        box.write(KeyStorage.deviceId, deviceId);
        box.write(KeyStorage.logedInUser, user);
        _isLoading.value = false;
        return redirect("");
        // }

        // _isLoading.value = false;
        // return showAlert(message: 'error create session');
      }
      _isLoading.value = false;
      return showAlert(message: 'you cancel the signin process');
    } catch (e) {
      // print(e);
      // if (e is DioError) {
      //   _isLoading.value = false;
      //   return showAlert(message: e.message);
      // }

      // _isLoading.value = false;
      // return showAlert(message: e.toString());
      _isLoading.value = false;
      errorMessageMiddleware(e, false, 'Failed to sign-in with Google,');
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  googleSignInForIos() async {
    try {
      _isLoading.value = true;
      final response = await _authService.getGoogleRedirectUrl();
      await DefaultCacheManager().emptyCache();

      String resultUrl = response.data['url'];

      var htmlContent = await Navigator.push(
          Get.context!,
          MaterialPageRoute(
              builder: (_) => AppleInAppWebViewScree(
                    initialUrl: resultUrl,
                    isApple: false,
                  )));

      if (htmlContent == null) {
        _isLoading.value = false;
        return;
      }
      var xx = removeHtmlTag(htmlContent);

      final body = json.decode(xx);

      String token = body['token'];
      // String token = dummyToken;

      String deviceId = uuid.v4();
      dynamic user = body['user'];
      // dynamic user = dummyUser;

      // if (user['defaultCompany'] != null) {
      //   String companyId = user['defaultCompany'].runtimeType == String
      //       ? user['defaultCompany']
      //       : user['defaultCompany']?['_id'];
      //   box.write(KeyStorage.selectedCompanyId, companyId);
      //   final newSession =
      //       await _authService.renewSession(token, deviceId, companyId);
      //   if (newSession.statusCode == 200 || newSession.statusCode == 201) {
      //     box.write(KeyStorage.token, token);
      //     box.write(KeyStorage.deviceId, deviceId);
      //     box.write(KeyStorage.logedInUser, user);
      //     _isLoading.value = false;
      //     return redirect(companyId);
      //   }
      // } else {
      box.write(KeyStorage.token, token);
      box.write(KeyStorage.deviceId, deviceId);
      box.write(KeyStorage.logedInUser, user);
      _isLoading.value = false;
      return redirect("");
      // }

      // _isLoading.value = false;
      // return showAlert(message: 'error create session');
    } catch (e) {
      print(e);
      _isLoading.value = false;
      errorMessageMiddleware(e, false, 'Failed to sign-in with Google,');
    }
  }

  testSignInApple() async {
    try {
      _isLoading.value = true;
      final response = await _authService.getAppleRedirectUrl();
      await DefaultCacheManager().emptyCache();
      String resultUrl = response.data['url'];

      var htmlContent = await Navigator.push(
          Get.context!,
          MaterialPageRoute(
              builder: (_) => AppleInAppWebViewScree(
                    initialUrl: resultUrl,
                    isApple: true,
                  )));

      if (htmlContent == null) {
        _isLoading.value = false;
        return;
      }
      var xx = removeHtmlTag(htmlContent);

      final body = json.decode(xx);

      String token = body['token'];
      String deviceId = uuid.v4();
      dynamic user = body['user'];
      // if (body['user']['defaultCompany'] != null) {
      //   String companyId = user['defaultCompany'].runtimeType == String
      //       ? user['defaultCompany']
      //       : user['defaultCompany']?['_id'];
      //   box.write(KeyStorage.selectedCompanyId, companyId);
      //   final newSession =
      //       await _authService.renewSession(token, deviceId, companyId);
      //   if (newSession.statusCode == 200 || newSession.statusCode == 201) {
      //     box.write(KeyStorage.token, token);
      //     box.write(KeyStorage.deviceId, deviceId);
      //     box.write(KeyStorage.logedInUser, user);
      //     _isLoading.value = false;
      //     return redirect(companyId);
      //   }
      // } else {
      box.write(KeyStorage.token, token);
      box.write(KeyStorage.deviceId, deviceId);
      box.write(KeyStorage.logedInUser, user);
      _isLoading.value = false;
      return redirect("");
      // }

      // _isLoading.value = false;
      // return showAlert(message: 'error create session');
    } catch (e) {
      print(e);
      errorMessageMiddleware(e, false, 'Failed to sign-in with Google,');
      _isLoading.value = false;
    }
  }

  signInApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    _isLoading.value = true;
    try {
      AuthorizationCredentialAppleID credential;
      if (Platform.isIOS) {
        credential = await SignInWithApple.getAppleIDCredential(scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ], nonce: nonce);
      } else {
        credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
                clientId: "app.cicle.staging",
                redirectUri:
                    Uri.parse("${Env.BASE_URL}/api/v1/auth/apple/signin")));
      }

      dynamic body = {
        "identityToken": credential.identityToken,
        "nonce": rawNonce
      };
      final response = await _authService.appleService(body);
      await DefaultCacheManager().emptyCache();
      String token = response.data['token'];
      // String token = dummyToken;
      String deviceId = uuid.v4();
      dynamic user = response.data['user'];

      // if (response.data['user']['defaultCompany'] != null) {
      //   String companyId = user['defaultCompany'].runtimeType == String
      //       ? user['defaultCompany']
      //       : user['defaultCompany']?['_id'];
      //   box.write(KeyStorage.selectedCompanyId, companyId);
      //   final newSession =
      //       await _authService.renewSession(token, deviceId, companyId);
      //   if (newSession.statusCode == 200 || newSession.statusCode == 201) {
      //     box.write(KeyStorage.token, token);
      //     box.write(KeyStorage.deviceId, deviceId);
      //     box.write(KeyStorage.logedInUser, user);
      //     _isLoading.value = false;
      //     return redirect(companyId);
      //   }
      // } else {
      box.write(KeyStorage.token, token);
      box.write(KeyStorage.deviceId, deviceId);
      box.write(KeyStorage.logedInUser, user);
      _isLoading.value = false;
      return redirect("");
      // }

      // _isLoading.value = false;
      // return showAlert(message: 'error create session');
    } catch (e) {
      // print(e);
      // if (e is DioError) {
      //   _isLoading.value = false;
      //   return showAlert(message: e.message);
      // }

      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          _isLoading.value = false;

          return;
        }
      }

      _isLoading.value = false;
      errorMessageMiddleware(e, false, 'Failed to sign-in with Apple ID,');
      // return showAlert(message: ErrorMessage.cummon);
    }
  }

  redirect(String companyId) async {
    // Get.toNamed('${RouteName.signInScreen}?redirect=true');
    // await Future.delayed(Duration(seconds: 3));
    if (companyId == '') {
      box.write(KeyStorage.selectedCompanyId, 'new-user');
      Get.offAllNamed(RouteName.dashboardScreen('new-user'));
    } else {
      Get.offAllNamed(RouteName.dashboardScreen(companyId));
    }
  }

  _removeAllLocalStorageTeams(String userLogedInId) {
    // _companyController.teams
    List<Teams> teams = Get.put(CompanyController()).teams;

    for (var team in teams) {
      String key = 'team-${team.sId}-user-$userLogedInId';

      var localCurrentTeam = box.read(key);
      print('key $key');

      if (localCurrentTeam != null) {
        print('team ${team.name}');
        box.remove(key);
      }
    }
  }

  handleSignOut() async {
    showLoadingOverlay();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);

    try {
      await _googleSignIn.disconnect();
      box.remove(KeyStorage.invitationToken);
      box.remove(KeyStorage.token);
      box.remove(KeyStorage.selectedCompanyId);
      box.remove(KeyStorage.logedInUser);
      box.remove('recentlyViewed');
      box.remove('companies-user-${logedInUser.sId}');
      _removeAllLocalStorageTeams(logedInUser.sId);
      await DefaultCacheManager().emptyCache();
      OneSignal.shared.removeExternalUserId();
      await Future.delayed(Duration(seconds: 1));
      Get.back();
      Get.offAllNamed(RouteName.splashScreen);

      OneSignal.shared.clearOneSignalNotifications();
    } catch (e) {
      print(e);
      box.remove(KeyStorage.invitationToken);
      box.remove(KeyStorage.token);
      box.remove(KeyStorage.selectedCompanyId);
      box.remove(KeyStorage.logedInUser);
      box.remove('recentlyViewed');
      _removeAllLocalStorageTeams(logedInUser.sId);
      await DefaultCacheManager().emptyCache();
      await Future.delayed(Duration(seconds: 1));
      OneSignal.shared.removeExternalUserId();
      Get.back();
      Get.offAllNamed(RouteName.splashScreen);
      await _googleSignIn.disconnect();
    }
  }
}

// String dummyToken =
//     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjYyNGU2ODFhZjczNmI1Njg4OThmN2FmYyIsImRlZmF1bHRDb21wYW55Ijp7Il9pZCI6IjYxZWJhNzRjNTA4MGY0ZDJhZmRkZDA3ZSJ9LCJjb21wYW5pZXMiOltdLCJnb29nbGVJZCI6IjEwMTk1NDA2OTkyMTE1NTUzMDU0MiIsImVtYWlsIjoiZmFqYXJjb29sMjM0QGdtYWlsLmNvbSIsImZ1bGxOYW1lIjoiRmFqYXIgTXVoYW1hZCIsInBob3RvVXJsIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2hOblRfQTZJb3VBQlBrX0h6TzR3MVo1MUlnNmJvYW9MX0hSU21kMEE9czk2LWMiLCJiaW8iOiIiLCJzdGF0dXMiOiIiLCJjcmVhdGVkQXQiOiIyMDIyLTA0LTA3VDA0OjI3OjA2LjAzOFoiLCJ1cGRhdGVkQXQiOiIyMDIyLTA4LTE4VDEzOjM1OjU3LjEyMloiLCJfX3YiOjB9LCJpYXQiOjE2NjQyNTExNTUsImV4cCI6MTY2Njg0MzE1NX0.J_BohAPQV2fHdFvCKbXo0MLxkkMhI-XO-M1piJydhrw";

// dynamic dummyUser = {
//   "_id": "624e681af736b568898f7afc",
//   "defaultCompany": "61eba74c5080f4d2afddd07e",
//   "companies": [],
//   "googleId": "101954069921155530542",
//   "email": "fajarcool234@gmail.com",
//   "fullName": "Djar Music",
//   "photoUrl":
//       "https://lh3.googleusercontent.com/a-/AOh14GhNnT_A6IouABPk_HzO4w1Z51Ig6boaoL_HRSmd0A=s96-c",
//   "bio": "",
//   "status": "",
//   "createdAt": "2022-04-07T04:27:06.038Z",
//   "updatedAt": "2022-05-11T22:01:17.340Z",
//   "__v": 0
// };
