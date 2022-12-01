import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/edit/edit_providers.dart';
import 'package:otraku/utils/consts.dart';
import 'package:otraku/discover/discover_models.dart';
import 'package:otraku/edit/edit_view.dart';
import 'package:otraku/filter/filter_providers.dart';
import 'package:otraku/home/home_provider.dart';
import 'package:otraku/home/home_view.dart';
import 'package:otraku/media/media_models.dart';
import 'package:otraku/media/media_providers.dart';
import 'package:otraku/widgets/link_tile.dart';
import 'package:otraku/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/floating_bar.dart';
import 'package:otraku/widgets/layouts/page_layout.dart';
import 'package:otraku/widgets/loaders.dart/loaders.dart';
import 'package:otraku/widgets/overlays/dialogs.dart';
import 'package:otraku/widgets/overlays/sheets.dart';
import 'package:otraku/widgets/overlays/toast.dart';

class MediaInfoView extends StatelessWidget {
  const MediaInfoView(this.media);

  final Media media;

  @override
  Widget build(BuildContext context) {
    final info = media.info;

    final infoTitles = [
      'Status',
      'Episodes',
      'Duration',
      'Chapters',
      'Volumes',
      'Start Date',
      'End Date',
      'Season',
      'Average Score',
      'Mean Score',
      'Popularity',
      'Favourites',
      'Source',
      'Origin',
    ];

    final infoData = [
      info.status,
      info.episodes,
      info.duration,
      info.chapters,
      info.volumes,
      info.startDate,
      info.endDate,
      info.season,
      info.averageScore,
      info.meanScore,
      info.popularity,
      info.favourites,
      info.source,
      info.countryOfOrigin,
    ];

    for (int i = infoData.length - 1; i >= 0; i--) {
      if (infoData[i] == null) {
        infoData.removeAt(i);
        infoTitles.removeAt(i);
      }
    }

    final scrollCtrl = context
        .findAncestorStateOfType<NestedScrollViewState>()!
        .innerController;

    return Consumer(
      builder: (context, ref, _) => PageLayout(
        floatingBar: FloatingBar(
          scrollCtrl: scrollCtrl,
          children: [_EditButton(media), _FavoriteButton(info)],
        ),
        child: CustomScrollView(
          controller: scrollCtrl,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            if (info.description.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: Consts.padding,
                  child: GestureDetector(
                    child: Card(
                      child: Padding(
                        padding: Consts.padding,
                        child: Text(
                          info.description,
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    onTap: () => showPopUp(
                      context,
                      TextDialog(title: 'Description', text: info.description),
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverPadding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithMinWidthAndFixedHeight(
                  height: Consts.tapTargetSize,
                  minWidth: 130,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            infoTitles[i],
                            maxLines: 1,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(infoData[i].toString(), maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                  childCount: infoData.length,
                ),
              ),
            ),
            if (info.genres.isNotEmpty)
              _ScrollCards(
                title: 'Genres',
                items: info.genres,
                onTap: (i) {
                  ref.read(searchProvider(null).notifier).state = null;
                  final notifier = ref.read(discoverFilterProvider);
                  notifier.type = info.type;

                  final filter = notifier.filter.clear();
                  filter.genreIn.add(info.genres[i]);
                  notifier.filter = filter;

                  ref.read(homeProvider).homeTab = HomeView.DISCOVER;
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
              ),
            if (info.tags.isNotEmpty) _Tags(info, ref),
            if (info.studios.isNotEmpty)
              _ScrollCards(
                title: 'Studios',
                items: info.studios.keys.toList(),
                onTap: (index) => LinkTile.openView(
                  context: context,
                  id: info.studios[info.studios.keys.elementAt(index)]!,
                  imageUrl: info.studios.keys.elementAt(index),
                  discoverType: DiscoverType.studio,
                ),
              ),
            if (info.producers.isNotEmpty)
              _ScrollCards(
                title: 'Producers',
                items: info.producers.keys.toList(),
                onTap: (i) => LinkTile.openView(
                  context: context,
                  id: info.producers[info.producers.keys.elementAt(i)]!,
                  imageUrl: info.producers.keys.elementAt(i),
                  discoverType: DiscoverType.studio,
                ),
              ),
            if (info.hashtag != null) _Title('Hashtag', info.hashtag!),
            if (info.romajiTitle != null) _Title('Romaji', info.romajiTitle!),
            if (info.englishTitle != null)
              _Title('English', info.englishTitle!),
            if (info.nativeTitle != null) _Title('Native', info.nativeTitle!),
            if (info.synonyms.isNotEmpty)
              _Title('Synonyms', info.synonyms.join(', ')),
            const SliverFooter(),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  const _EditButton(this.media);

  final Media media;

  @override
  State<_EditButton> createState() => __EditButtonState();
}

class __EditButtonState extends State<_EditButton> {
  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    return ActionButton(
      icon: media.edit.status == null ? Icons.add : Icons.edit_outlined,
      tooltip: media.edit.status == null ? 'Add' : 'Edit',
      onTap: () => showSheet(
        context,
        EditView(
          EditTag(media.info.id),
          callback: (edit) => setState(() => media.edit = edit),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton(this.info);

  final MediaInfo info;

  @override
  State<_FavoriteButton> createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: widget.info.isFavorite ? Icons.favorite : Icons.favorite_border,
      tooltip: widget.info.isFavorite ? 'Unfavourite' : 'Favourite',
      onTap: () {
        setState(() => widget.info.isFavorite = !widget.info.isFavorite);
        toggleFavoriteMedia(
          widget.info.id,
          widget.info.type == DiscoverType.anime,
        ).then((ok) {
          if (!ok) {
            setState(() => widget.info.isFavorite = !widget.info.isFavorite);
          }
        });
      },
    );
  }
}

class _ScrollCards extends StatelessWidget {
  const _ScrollCards({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<String> items;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Text(title, style: Theme.of(context).textTheme.subtitle1),
            ),
            SizedBox(
              height: 42,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 10, bottom: 2),
                physics: Consts.physics,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => onTap(index),
                  onLongPress: () => Toast.copy(context, items[index]),
                  child: Card(
                    margin: const EdgeInsets.only(right: 10),
                    child: Padding(
                      padding: Consts.padding,
                      child: Text(items[index]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.label, this.title);

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 90,
              child: Text(label, style: Theme.of(context).textTheme.subtitle1),
            ),
            Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Toast.copy(context, title),
                child: Text(
                  title,
                  maxLines: null,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tags extends StatefulWidget {
  const _Tags(this.info, this.ref);

  final MediaInfo info;
  final WidgetRef ref;

  @override
  State<_Tags> createState() => __TagsState();
}

class __TagsState extends State<_Tags> {
  bool? _showSpoilers;

  @override
  void initState() {
    super.initState();
    for (final t in widget.info.tags) {
      if (t.isSpoiler) {
        _showSpoilers = false;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = _showSpoilers == null || _showSpoilers!
        ? widget.info.tags
        : widget.info.tags.where((t) => !t.isSpoiler).toList();

    final spoilerTextStyle = Theme.of(context)
        .textTheme
        .bodyText1
        ?.copyWith(color: Theme.of(context).colorScheme.error);

    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text('Tags', style: Theme.of(context).textTheme.subtitle1),
                const Spacer(),
                if (_showSpoilers != null)
                  TopBarIcon(
                    icon: _showSpoilers!
                        ? Ionicons.eye_off_outline
                        : Ionicons.eye_outline,
                    tooltip: _showSpoilers! ? 'Hide Spoilers' : 'Show Spoilers',
                    onTap: () =>
                        setState(() => _showSpoilers = !_showSpoilers!),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 10, bottom: 2),
              itemCount: tags.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  final ref = widget.ref;
                  ref.read(searchProvider(null).notifier).state = null;
                  final notifier = ref.read(discoverFilterProvider);
                  notifier.type = widget.info.type;

                  final filter = notifier.filter.clear();
                  filter.tagIn.add(tags[i].name);
                  notifier.filter = filter;

                  ref.read(homeProvider).homeTab = HomeView.DISCOVER;
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                onLongPress: () => showPopUp(
                  context,
                  TextDialog(title: tags[i].name, text: tags[i].desciption),
                ),
                child: Card(
                  margin: const EdgeInsets.only(right: 10),
                  child: Padding(
                    padding: Consts.padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tags[i].name,
                          style: tags[i].isSpoiler ? spoilerTextStyle : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${tags[i].rank}%',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
