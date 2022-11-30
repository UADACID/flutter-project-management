import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class FormInputCheers extends StatelessWidget {
  FormInputCheers({
    Key? key,
    required this.onClose,
    required this.onSubmit,
  }) : super(key: key);

  final Function onClose;
  final Function(String? text) onSubmit;

  TextEditingController _controller = TextEditingController();
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);
    return Container(
      width: 254,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          AvatarCustom(
            height: 28,
            child: Image.network(
              getPhotoUrl(url: logedInUser.photoUrl),
              height: 28,
              width: 28,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
              child: TextField(
            controller: _controller,
            maxLength: 15,
            autofocus: true,
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Give’em cheers!',
              hintStyle: TextStyle(
                  fontSize: 11, color: Color(0xff7A7A7A).withOpacity(0.5)),
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(0, 0, 6, 0),
              counterStyle: TextStyle(
                height: double.minPositive,
              ),
              counterText: "",
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          )),
          GestureDetector(
            onTap: () {
              onSubmit(_controller.text);
              FocusScope.of(context).unfocus();
            },
            child: Container(
              height: 28,
              width: 28,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Color(0xff42E591)),
                  shape: BoxShape.circle),
              child: Icon(Icons.check, color: Color(0xff42E591)),
            ),
          ),
          GestureDetector(
            onTap: () {
              onClose();
            },
            child: Container(
              height: 28,
              width: 28,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Color(0xffFF7171)),
                  shape: BoxShape.circle),
              child: Icon(Icons.close, color: Color(0xffFF7171)),
            ),
          ),
        ],
      ),
    );
  }
}
