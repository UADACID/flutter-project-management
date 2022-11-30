import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'mentioned_user.dart';

class InlineWidget extends WidgetFactory {
  final bool isSmall;

  InlineWidget({this.isSmall = false});
  @override
  void parse(BuildMetadata meta) {
    if (meta.element.id == "mentioned-user") {
      String? userId = meta.element.attributes["data-mentioned-user-id"] ?? '';
      String userName = meta.element.text;
      String? photoUrl = meta.element.children.first.attributes["src"] ??
          meta.element.children.first.children.first.children.first
              .attributes["src"] ??
          '';
      meta.register(BuildOp(
        onTree: (_, tree) {
          Widget widget = MentionedUser(
            isSmall: isSmall,
            photoUrl: photoUrl,
            userName: userName.trim(),
            userId: userId,
          );
          // WidgetBit.inline(tree, widget).insertBefore(tree);
          WidgetBit.inline(tree.parent!, widget).insertBefore(tree);
          tree.detach();
        },
      ));
    }
    super.parse(meta);
  }
}
