import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/pages/pushable/character_page.dart';
import 'package:otraku/pages/pushable/edit_entry_page.dart';
import 'package:otraku/pages/pushable/media_page.dart';
import 'package:otraku/pages/pushable/staff_page.dart';
import 'package:otraku/pages/pushable/studio_page.dart';
import 'package:otraku/tools/page_transition.dart';

class MediaIndexer extends StatelessWidget {
  final Browsable itemType;
  final int id;
  final String tag;
  final Widget child;

  MediaIndexer({
    @required this.itemType,
    @required this.id,
    @required this.tag,
    @required this.child,
  });

  static void pushMedia({
    @required BuildContext context,
    @required Browsable type,
    @required int id,
    @required String tag,
  }) {
    Widget page;
    switch (type) {
      case Browsable.anime:
      case Browsable.manga:
        page = MediaPage(id, tag);
        break;
      case Browsable.characters:
        page = CharacterPage(id, tag);
        break;
      case Browsable.staff:
        page = StaffPage(id, tag);
        break;
      default:
        page = StudioPage(id, tag);
        break;
    }

    Navigator.push(context, PageTransition.route(builder: page));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => MediaIndexer.pushMedia(
        context: context,
        type: itemType,
        id: id,
        tag: tag,
      ),
      onLongPress: () {
        if (itemType == Browsable.anime || itemType == Browsable.manga)
          Navigator.push(
            context,
            PageTransition.route(builder: EditEntryPage(id, (_) {})),
          );
      },
      child: child,
    );
  }
}
