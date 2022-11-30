import 'package:cicle_mobile_f3/screens/search/search_screen.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/search_header_menu.dart';
import 'package:flutter/material.dart';

class SearchComments extends StatelessWidget {
  const SearchComments({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchHeaderMenu(
            title: 'Comment',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: AvatarCustom(height: 48, child: Container()),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                width: 292,
                // height: 95,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Pratama Setya Aji',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff393E46)),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'loremipsum dolor sit amet wkwkwk hmmmm ahai',
                                style: TextStyle(color: Color(0xff393E46)),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Color(0xffB5B5B5),
                                    size: 14,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    '3h',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffB5B5B5)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 14,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Icon(
                              Icons.more_horiz_outlined,
                              color: Color(0xff979797),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          ButtonShowAllRelatedItems(
            onPress: () {},
            title: 'comments',
          )
        ],
      ),
    );
  }
}
