import 'dart:async';
import 'dart:io';

// import 'package:cicle_v2/utils/helpers.dart';
// import 'package:cicle_v2/utils/route_pages.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uni_links/uni_links.dart';

import 'utils/internal_link_adapter.dart';
import 'utils/route_pages.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  if (Platform.isAndroid) {
    await FirebaseAppCheck.instance.activate(// If you're building a web app.
        );
  }

  await FlutterDownloader.initialize(
      debug: false // optional: set false to disable printing logs to console
      );
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 619),
        builder: () {
          return GetMaterialApp(
            title: 'Cicle v2',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US')],
            theme: ThemeData(
                primarySwatch: createMaterialColor(Color(0xffFDC532)),
                textTheme:
                    GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
                appBarTheme: const AppBarTheme(
                    elevation: 0,
                    brightness: Brightness.light,
                    backgroundColor: Colors.white),
                scaffoldBackgroundColor: Color(0xffFAFAFA)),
            initialRoute: '/',
            getPages: RoutePages.routes(),
            builder: (context, _) {
              var child = _!;
              final navigatorKey = child.key as GlobalKey<NavigatorState>;

              final theme = Theme.of(context);
              final isThemeDark = theme.brightness == Brightness.dark;

              child = Toast(navigatorKey: navigatorKey, child: child);
              // Wrap with flash theme
              child = FlashTheme(
                flashBarTheme: isThemeDark
                    ? const FlashBarThemeData.dark()
                    : const FlashBarThemeData.light(),
                flashDialogTheme: const FlashDialogThemeData(),
                child: child,
              );
              return ScrollConfiguration(
                  behavior: const ScrollBehaviorModified(),
                  child: DeepLinkAdapter(child: child));
            },
          );
        });
  }
}

class DeepLinkAdapter extends StatefulWidget {
  const DeepLinkAdapter({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<DeepLinkAdapter> createState() => _DeepLinkAdapterState();
}

class _DeepLinkAdapterState extends State<DeepLinkAdapter> {
  StreamSubscription? _sub;
  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');

        String fullUrl = uri!.path;

        // check is login

        var token = box.read('token');
        if (token == null || token == '') {
          return;
        }

        print('fullUrl main $fullUrl');
        checkIsUrlHaveInvitationToken(fullUrl, false);

        internalLinkAdapter(fullUrl);
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
