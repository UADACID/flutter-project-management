import 'package:flutter/material.dart';

class DefaultAlert extends StatelessWidget {
  DefaultAlert(
      {Key? key,
      required this.onSubmit,
      required this.onCancel,
      this.showDescription = false,
      required this.title,
      this.textCancel = 'Cancel',
      this.textSubmit = 'Ok',
      this.description = '',
      this.textSubmitColor = const Color(0xffFDC532),
      this.hideCancel = false})
      : super(key: key);

  final Function onSubmit;
  final Function onCancel;
  final bool showDescription;
  final String title;
  final String textCancel;
  final String textSubmit;
  final String description;
  final Color textSubmitColor;
  final bool hideCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(bottom: 12, left: 22, right: 22, top: 25),
          margin: MediaQuery.of(context).viewInsets,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          width: 258,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              showDescription
                  ? Padding(
                      padding: const EdgeInsets.only(top: 19.0),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xffFF7171), fontSize: 11),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: 19,
              ),
              Row(
                mainAxisAlignment: hideCancel ? MainAxisAlignment.center :  MainAxisAlignment.spaceEvenly,
                children: [
                  hideCancel
                      ? SizedBox()
                      : TextButton(
                          onPressed: () {
                            onCancel();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Text(
                              textCancel,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: hideCancel ? 0 : 16,
                  ),
                  TextButton(
                    onPressed: () {
                      onSubmit();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Text(
                        textSubmit,
                        style: TextStyle(color: textSubmitColor, fontSize: 11),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
