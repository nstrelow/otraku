import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/controllers/activity.dart';
import 'package:otraku/controllers/feed.dart';
import 'package:otraku/utils/config.dart';
import 'package:otraku/enums/activity_type.dart';
import 'package:otraku/enums/browsable.dart';
import 'package:otraku/enums/themes.dart';
import 'package:otraku/models/activity_model.dart';
import 'package:otraku/pages/activity_page.dart';
import 'package:otraku/widgets/browse_indexer.dart';
import 'package:otraku/widgets/fade_image.dart';
import 'package:otraku/widgets/html_content.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/triangle_clip.dart';

class UserActivity extends StatelessWidget {
  final Feed feed;
  final ActivityModel model;

  UserActivity({required this.feed, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: BrowseIndexer(
                id: model.agentId!,
                imageUrl: model.agentImage,
                browsable: Browsable.user,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: Config.BORDER_RADIUS,
                      child: FadeImage(model.agentImage, height: 50, width: 50),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        model.agentName!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (model.recieverId != null) ...[
              if (model.isPrivate)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Ionicons.eye_off_outline),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_right_alt),
              ),
              BrowseIndexer(
                id: model.recieverId!,
                imageUrl: model.recieverImage,
                browsable: Browsable.user,
                child: ClipRRect(
                  borderRadius: Config.BORDER_RADIUS,
                  child: FadeImage(model.recieverImage, height: 50, width: 50),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        ClipPath(
          clipper: TriangleClip(),
          child: Container(
            width: 50,
            height: 10,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: Config.PADDING,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: Config.BORDER_RADIUS,
          ),
          child: Column(
            children: [
              if (model.type == ActivityType.ANIME_LIST ||
                  model.type == ActivityType.MANGA_LIST)
                MediaBox(model)
              else
                UnconstrainedBox(
                  constrainedAxis: Axis.horizontal,
                  alignment: Alignment.topLeft,
                  child: HtmlContent(model.text),
                ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    model.createdAt,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  _InteractionButtons(feed, model),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InteractionButtons extends StatefulWidget {
  final Feed feed;
  final ActivityModel model;

  _InteractionButtons(this.feed, this.model);

  @override
  __InteractionButtonsState createState() => __InteractionButtonsState();
}

class __InteractionButtonsState extends State<_InteractionButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.model.deletable)
          Tooltip(
            message: 'Delete',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: const Icon(Ionicons.trash, size: Style.ICON_SMALL),
              onTap: () => showPopUp(
                context,
                AlertDialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: Config.BORDER_RADIUS,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  title: Text('Delete?'),
                  actions: [
                    TextButton(
                      child: Text(
                        'No',
                        style: TextStyle(color: Theme.of(context).dividerColor),
                      ),
                      onPressed: Navigator.of(context).pop,
                    ),
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        widget.feed.deleteActivity(widget.model.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Tooltip(
          message: !widget.model.isSubscribed ? 'Subscribe' : 'Unsubscribe',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => widget.model.toggleSubscription());
              Activity.toggleSubscription(widget.model).then(
                (ok) => ok
                    ? widget.feed.updateActivity(widget.model)
                    : setState(() => widget.model.toggleSubscription()),
              );
            },
            child: Icon(
              Ionicons.notifications,
              size: Style.ICON_SMALL,
              color: !widget.model.isSubscribed
                  ? null
                  : Theme.of(context).accentColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Replies',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.toNamed(
              ActivityPage.ROUTE,
              arguments: [
                widget.model.id,
                widget.feed.id?.toString() ?? Feed.HOME_FEED_TAG,
              ],
              parameters: {'id': widget.model.id.toString()},
            ),
            child: Row(
              children: [
                Text(
                  widget.model.replyCount.toString(),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(width: 5),
                const Icon(Ionicons.chatbox, size: Style.ICON_SMALL),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: !widget.model.isLiked ? 'Like' : 'Unlike',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => widget.model.toggleLike());
              Activity.toggleLike(widget.model).then(
                (ok) => ok
                    ? widget.feed.updateActivity(widget.model)
                    : setState(() => widget.model.toggleLike()),
              );
            },
            child: Row(
              children: [
                Text(
                  widget.model.likeCount.toString(),
                  style: !widget.model.isLiked
                      ? Theme.of(context).textTheme.subtitle2
                      : Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).errorColor),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.favorite,
                  size: Style.ICON_SMALL,
                  color: widget.model.isLiked
                      ? Theme.of(context).errorColor
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MediaBox extends StatelessWidget {
  final ActivityModel activity;
  MediaBox(this.activity);

  @override
  Widget build(BuildContext context) {
    return BrowseIndexer(
      id: activity.mediaId!,
      imageUrl: activity.mediaImage,
      browsable: activity.mediaType!,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: Config.BORDER_RADIUS,
              child: FadeImage(activity.mediaImage, width: 70),
            ),
            Expanded(
              child: Padding(
                padding: Config.PADDING,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: activity.text,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            TextSpan(
                              text: activity.mediaTitle,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activity.mediaFormat != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(activity.mediaFormat!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
