import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otraku/modules/character/character_providers.dart';
import 'package:otraku/common/utils/consts.dart';
import 'package:otraku/common/widgets/cached_image.dart';
import 'package:otraku/common/widgets/grids/sliver_grid_delegates.dart';
import 'package:otraku/common/widgets/html_content.dart';
import 'package:otraku/common/widgets/layouts/constrained_view.dart';
import 'package:otraku/common/widgets/loaders/loaders.dart';
import 'package:otraku/common/widgets/overlays/dialogs.dart';
import 'package:otraku/common/widgets/overlays/toast.dart';

class CharacterInfoTab extends StatelessWidget {
  const CharacterInfoTab(this.id, this.imageUrl, this.scrollCtrl);

  final int id;
  final String? imageUrl;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width < 430.0
        ? MediaQuery.of(context).size.width * 0.30
        : 100.0;
    final imageHeight = imageWidth * Consts.coverHtoWRatio;

    return Consumer(
      builder: (context, ref, _) {
        final character = ref.watch(characterProvider(id));
        final imageUrl = character.valueOrNull?.imageUrl ?? this.imageUrl;

        final header = SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Hero(
                        tag: id,
                        child: ClipRRect(
                          borderRadius: Consts.borderRadiusMin,
                          child: Container(
                            width: imageWidth,
                            height: imageHeight,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: GestureDetector(
                              child: CachedImage(imageUrl),
                              onTap: () =>
                                  showPopUp(context, ImageDialog(imageUrl)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  character.maybeWhen(
                    orElse: () => const SizedBox(),
                    data: (data) => Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () => Toast.copy(context, data.name),
                            child: Text(
                              data.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (data.altNames.isNotEmpty)
                            Text(data.altNames.join(', ')),
                          if (data.altNamesSpoilers.isNotEmpty)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'Spoiler names',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              onTap: () => showPopUp(
                                context,
                                TextDialog(
                                  title: 'Spoiler names',
                                  text: data.altNamesSpoilers.join(', '),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final refreshControl = SliverRefreshControl(
          onRefresh: () => ref.invalidate(characterProvider(id)),
        );

        return ConstrainedView(
          child: character.when(
            loading: () => CustomScrollView(
              physics: Consts.physics,
              controller: scrollCtrl,
              slivers: [
                refreshControl,
                header,
                const SliverFillRemaining(child: Center(child: Loader())),
                const SliverFooter(),
              ],
            ),
            error: (_, __) => CustomScrollView(
              physics: Consts.physics,
              controller: scrollCtrl,
              slivers: [
                refreshControl,
                header,
                const SliverFillRemaining(
                  child: Center(child: Text('No data')),
                ),
                const SliverFooter(),
              ],
            ),
            data: (data) => CustomScrollView(
              physics: Consts.physics,
              controller: scrollCtrl,
              slivers: [
                refreshControl,
                header,
                SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMinWidthAndFixedHeight(
                    height: Consts.tapTargetSize,
                    minWidth: 150,
                  ),
                  delegate: SliverChildListDelegate([
                    _InfoTile('Favourites', data.favorites.toString()),
                    if (data.gender != null) _InfoTile('Gender', data.gender!),
                    if (data.age != null) _InfoTile('Age', data.age!),
                    if (data.dateOfBirth != null)
                      _InfoTile('Date of Birth', data.dateOfBirth!),
                    if (data.bloodType != null)
                      _InfoTile('Blood Type', data.bloodType!),
                  ]),
                ),
                if (data.description.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Card(
                        child: Padding(
                          padding: Consts.padding,
                          child: HtmlContent(data.description),
                        ),
                      ),
                    ),
                  ),
                const SliverFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              title,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(subtitle, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
