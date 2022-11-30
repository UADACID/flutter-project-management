import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cheer_item.dart';
import 'comment_item.dart';
import 'form_input_cheer.dart';

class ListCheers extends StatelessWidget {
  const ListCheers({
    Key? key,
    required this.logedInUserId,
    required this.submitDelete,
    required this.cheers,
    required this.showFormCheers,
    required this.setShowFormCheers,
    required this.submitAdd,
  }) : super(key: key);
  final String logedInUserId;
  final Function(CheerItemModel) submitDelete;
  final Function(String) submitAdd;
  final List<CheerItemModel> cheers;
  final bool showFormCheers;
  final Function(bool) setShowFormCheers;

  showOptionCheers(CheerItemModel item) {
    if (logedInUserId != item.creator.sId) {
      return;
    }
    Get.bottomSheet(BottomSheetOptionCheers(
      item: item,
      onPressDelete: () {
        submitDelete(item);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Wrap(
        children: [
          ...cheers
              .asMap()
              .map((key, value) => MapEntry(
                  key,
                  InkWell(
                    onTap: () {
                      showOptionCheers(value);
                    },
                    child: CheerItem(
                      item: value,
                    ),
                  )))
              .values
              .toList(),
          showFormCheers
              ? FormInputCheers(
                  onClose: () async {
                    setShowFormCheers(false);
                  },
                  onSubmit: (String? text) {
                    if (text == null || text.trim() == '') {
                      return setShowFormCheers(false);
                    }
                    setShowFormCheers(false);
                    submitAdd(text);
                  },
                )
              : InkWell(
                  onTap: () {
                    setShowFormCheers(true);
                  },
                  child: Container(
                      margin: EdgeInsets.only(top: 2),
                      padding: EdgeInsets.all(2),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(Get.context!).primaryColor),
                          borderRadius: BorderRadius.circular(30)),
                      child: Image.asset(
                        'assets/images/cheers.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      )),
                )
        ],
      ),
    );
  }
}
