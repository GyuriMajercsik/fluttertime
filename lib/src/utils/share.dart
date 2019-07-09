import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

void shareProduct(BuildContext context, String url) async {
  final RenderBox box = context.findRenderObject();
  Share.share('View product $url',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}
