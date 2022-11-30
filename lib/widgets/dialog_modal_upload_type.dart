import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogModalUploadType extends StatefulWidget {
  const DialogModalUploadType({
    Key? key,
    required this.title,
    required this.onTapByUpload,
    required this.onTapByUrl,
  }) : super(key: key);

  final Function onTapByUpload;
  final Function(String) onTapByUrl;

  final String title;

  @override
  State<DialogModalUploadType> createState() => _DialogModalUploadTypeState();
}

class _DialogModalUploadTypeState extends State<DialogModalUploadType> {
  int _selectedIndex = 0;

  _onTapByUpload() {
    // setState(() {
    //   _selectedIndex = 0;
    // });
    widget.onTapByUpload();
  }

  _onTapByUrl() {
    // setState(() {
    //   _selectedIndex = 1;
    // });
    widget.onTapByUrl('url');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            // height: 150,
            width: 250,
            // margin: EdgeInsets.all(50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Add ${widget.title}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: _onTapByUpload,
                  leading: Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xff708FC7),
                  ),
                  title: Text(
                    'by upload',
                    style: TextStyle(color: Color(0xff708FC7)),
                  ),
                ),
                ListTile(
                  onTap: _onTapByUrl,
                  leading: Icon(
                    Icons.link,
                    color: Color(0xff708FC7),
                  ),
                  title: Text(
                    'by url',
                    style: TextStyle(color: Color(0xff708FC7)),
                  ),
                ),
                // _selectedIndex == 1 ? Container(
                //   height: 60,
                //   width: double.infinity,
                //   color: Colors.red,
                //   child: TextField(
                //     autofocus: true,
                //   )) : SizedBox(),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          )),
    );
  }
}

class FormInsertLink extends StatelessWidget {
  FormInsertLink({
    Key? key,
  }) : super(key: key);

  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                      hintText: "insert link here...",
                      hintStyle:
                          TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide:
                            BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    )),
                SizedBox(
                  height: 16,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () {
                        String result = _textEditingController.text;
                        if (result.trim() != '') {
                          Get.back(result: result);
                        }
                      },
                      child: Text('Insert')),
                )
              ],
            )),
      ),
    );
  }
}
