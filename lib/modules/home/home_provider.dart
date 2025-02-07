import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:otraku/common/utils/options.dart';

final homeProvider =
    ChangeNotifierProvider.autoDispose((ref) => HomeNotifier());

class HomeNotifier extends ChangeNotifier {
  HomeTab _homeTab = Options().defaultHomeTab;

  HomeTab get homeTab => _homeTab;

  set homeTab(HomeTab val) {
    if (_homeTab == val) return;
    _homeTab = val;
    notifyListeners();
  }

  /// The system schemes acquired asynchronously
  /// from [DynamicColorBuilder] are cached.
  ColorScheme? _systemLightScheme;
  ColorScheme? _systemDarkScheme;

  ColorScheme? getSystemScheme(bool isDark) =>
      isDark ? _systemDarkScheme : _systemLightScheme;

  void setSystemSchemes(ColorScheme? l, ColorScheme? d) {
    _systemLightScheme = l;
    _systemDarkScheme = d;
  }

  /// The discover and feed tab are loaded lazily, when first opened.
  var _didOpenFeed = false;
  var _didOpenDiscover = false;

  bool get didOpenFeed => _didOpenFeed;
  bool get didOpenDiscover => _didOpenDiscover;

  void checkLazyTabs() {
    if (_homeTab == HomeTab.feed) {
      _didOpenFeed = true;
    } else if (_homeTab == HomeTab.discover) {
      _didOpenDiscover = true;
    }
  }

  /// In preview mode, user's collections first load only current media.
  /// The rest is loaded by a manual request from the user
  /// and thus the collection "expands".
  /// If preview mode is off, collections are auto-expanded
  /// and immediately load everything.
  var _didExpandAnimeCollection = !Options().animeCollectionPreview;
  var _didExpandMangaCollection = !Options().mangaCollectionPreview;

  bool didExpandCollection(bool ofAnime) =>
      ofAnime ? _didExpandAnimeCollection : _didExpandMangaCollection;

  void expandCollection(bool ofAnime) {
    if (ofAnime) {
      if (_didExpandAnimeCollection) return;
      _didExpandAnimeCollection = true;
      notifyListeners();
    } else {
      if (_didExpandMangaCollection) return;
      _didExpandMangaCollection = true;
      notifyListeners();
    }
  }
}

enum HomeTab {
  feed,
  anime,
  manga,
  discover,
  profile;

  String get title => switch (this) {
        feed => 'Feed',
        anime => 'Anime',
        manga => 'Manga',
        discover => 'Discover',
        profile => 'Profile',
      };

  IconData get iconData => switch (this) {
        feed => Ionicons.file_tray_outline,
        anime => Ionicons.film_outline,
        manga => Ionicons.bookmark_outline,
        discover => Ionicons.compass_outline,
        profile => Ionicons.person_outline,
      };
}
