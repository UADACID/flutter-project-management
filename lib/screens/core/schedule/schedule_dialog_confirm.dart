import 'package:flutter/material.dart';

class ScheduleDialogConfirm extends StatelessWidget {
  const ScheduleDialogConfirm(
      {Key? key, required this.onNo, required this.onYes})
      : super(key: key);

  final Function onNo;
  final Function onYes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            width: 275,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'This event repeats',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Do you want to change all of the future event too?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        onNo();
                      },
                      child: Text(
                        'No, change this event only',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            width: 1.0, color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        onYes();
                      },
                      child: Text('Yes, change this and future event')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
