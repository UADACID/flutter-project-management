import 'dart:io';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AppleInAppWebViewScree extends StatefulWidget {
  AppleInAppWebViewScree(
      {Key? key, required this.initialUrl, required this.isApple})
      : super(key: key);

  final String initialUrl;
  final bool isApple;

  @override
  _InAppWebViewScreeState createState() => _InAppWebViewScreeState();
}

class _InAppWebViewScreeState extends State<AppleInAppWebViewScree> {
  final GlobalKey webViewKey = GlobalKey();
  String _platformVersion = 'Unknown';
  InAppWebViewController? webViewController;

  late PullToRefreshController pullToRefreshController;

  String url = "";

  double progress = 0;

  final urlController = TextEditingController();

  bool _showLoadingOverlay = false;

  @override
  void initState() {
    super.initState();
    FkUserAgent.init();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = FkUserAgent.userAgent!;
      print(platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String _redirectUrl = widget.isApple
        ? '${Env.BASE_URL}/api/v1/auth/apple/signin'
        : "'${Env.BASE_URL}/v2/auth/google/signin'";

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
            child: Text('apple'),
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: Uri.parse(widget.initialUrl)),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          userAgent: _platformVersion),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      )),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    String origin = url!.origin;
                    String path = url.path;
                    String fullUrl = origin + path;

                    if (path == "/signin/oauth/legacy/approval") {
                      setState(() {
                        _showLoadingOverlay = true;
                      });
                    }
                    if (fullUrl == _redirectUrl) {
                      var htmlContent = controller.getHtml();
                      showAlert(message: 'Sign-in success');
                      Get.back(result: htmlContent);
                    }
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunch(url)) {
                        await launch(
                          url,
                        );

                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, Uri? url) async {
                    pullToRefreshController.endRefreshing();
                    if (_redirectUrl.contains(url!.path)) {
                      var htmlContent = controller.getHtml();
                      showAlert(message: 'Sign-in success');
                      Get.back(result: htmlContent);
                    }
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      print(controller);
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
                _showLoadingOverlay
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
