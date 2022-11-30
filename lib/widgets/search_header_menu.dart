import 'package:flutter/material.dart';

class SearchHeaderMenu extends StatelessWidget {
  const SearchHeaderMenu({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xff7A7A7A)),
            ),
            SizedBox(
              height: 3.5,
            ),
            SizedBox(
                height: 1,
                child: Divider(
                  color: Color(0xff7A7A7A),
                )),
            SizedBox(
              height: 12.5,
            ),
          ],
        ));
  }
}
