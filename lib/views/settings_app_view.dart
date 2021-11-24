import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otraku/constants/entry_sort.dart';
import 'package:otraku/constants/explorable.dart';
import 'package:otraku/constants/media_sort.dart';
import 'package:otraku/constants/config.dart';
import 'package:otraku/utils/convert.dart';
import 'package:otraku/utils/local_settings.dart';
import 'package:otraku/utils/theming.dart';
import 'package:otraku/views/home_view.dart';
import 'package:otraku/widgets/fields/checkbox_field.dart';
import 'package:otraku/widgets/fields/drop_down_field.dart';
import 'package:otraku/widgets/layouts/sliver_grid_delegates.dart';
import 'package:otraku/widgets/layouts/nav_layout.dart';

class SettingsAppView extends StatelessWidget {
  const SettingsAppView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        physics: Config.PHYSICS,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 160,
              height: 75,
            ),
            delegate: SliverChildListDelegate.fixed([
              DropDownField<int>(
                title: 'Light Theme',
                value: LocalSettings().lightTheme,
                items: Theming.themes,
                onChanged: (val) => LocalSettings().lightTheme = val,
              ),
              DropDownField<int>(
                title: 'Dark Theme',
                value: LocalSettings().darkTheme,
                items: Theming.themes,
                onChanged: (val) => LocalSettings().darkTheme = val,
              ),
              DropDownField<ThemeMode>(
                title: 'Theme Mode',
                value: LocalSettings().themeMode,
                items: const {
                  'Auto': ThemeMode.system,
                  'Light': ThemeMode.light,
                  'Dark': ThemeMode.dark,
                },
                onChanged: (val) => LocalSettings().themeMode = val,
              ),
              DropDownField<int>(
                title: 'Startup Page',
                value: LocalSettings().defaultHomeTab,
                items: {
                  'Feed': HomeView.FEED,
                  'Anime List': HomeView.ANIME_LIST,
                  'Manga List': HomeView.MANGA_LIST,
                  'Explore': HomeView.EXPLORE,
                  'Profile': HomeView.PROFILE,
                },
                onChanged: (val) => LocalSettings().defaultHomeTab = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Anime Sort',
                value: LocalSettings().defaultAnimeSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => LocalSettings().defaultAnimeSort = val,
              ),
              DropDownField<EntrySort>(
                title: 'Default Manga Sort',
                value: LocalSettings().defaultMangaSort,
                items: Map.fromIterable(
                  EntrySort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => LocalSettings().defaultMangaSort = val,
              ),
              DropDownField<MediaSort>(
                title: 'Default Explore Sort',
                value: LocalSettings().defaultExploreSort,
                items: Map.fromIterable(
                  MediaSort.values,
                  key: (v) => Convert.clarifyEnum(describeEnum(v))!,
                ),
                onChanged: (val) => LocalSettings().defaultExploreSort = val,
              ),
              DropDownField<Explorable>(
                title: 'Default Explorable',
                value: LocalSettings().defaultExplorable,
                items: Map.fromIterable(
                  Explorable.values,
                  key: (e) => Convert.clarifyEnum(describeEnum(e))!,
                ),
                onChanged: (val) => LocalSettings().defaultExplorable = val,
              ),
            ]),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinWidthAndFixedHeight(
              minWidth: 200,
              mainAxisSpacing: 0,
              crossAxisSpacing: 20,
              height: Config.MATERIAL_TAP_TARGET_SIZE,
            ),
            delegate: SliverChildListDelegate.fixed([
              CheckBoxField(
                title: 'Left-Handed Mode',
                initial: LocalSettings().leftHanded,
                onChanged: (val) => LocalSettings().leftHanded = val,
              ),
              CheckBoxField(
                title: '12 Hour Clock',
                initial: LocalSettings().analogueClock,
                onChanged: (val) => LocalSettings().analogueClock = val,
              ),
              CheckBoxField(
                title: 'Confirm Exit',
                initial: LocalSettings().confirmExit,
                onChanged: (val) => LocalSettings().confirmExit = val,
              ),
            ]),
          ),
          SliverToBoxAdapter(
              child: SizedBox(height: NavLayout.offset(context))),
        ],
      ),
    );
  }
}
