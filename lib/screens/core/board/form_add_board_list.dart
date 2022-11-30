import 'package:cicle_mobile_f3/controllers/board_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormAddBoardList extends StatelessWidget {
  FormAddBoardList({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);
  final Function onSubmit;

  TextEditingController _controller = TextEditingController();
  BoardController _boardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: Colors.white),
          width: 310,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Add Board List'),
                  )),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                  hintText: "Add new list...",
                  hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(() => ElevatedButton(
                  onPressed: _boardController.loadingCreateList
                      ? null
                      : () async {
                          if (_controller.text.length != 0) {
                            onSubmit(_controller.text);
                            _controller.text = '';
                            FocusScope.of(context).unfocus();
                          }
                        },
                  child: Container(
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      )))))
            ],
          ),
        ),
      ),
    );
  }
}
