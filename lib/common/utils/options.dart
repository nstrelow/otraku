import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:otraku/modules/calendar/calendar_models.dart';
import 'package:otraku/modules/discover/discover_models.dart';
import 'package:otraku/modules/home/home_provider.dart';
import 'package:otraku/modules/media/media_constants.dart';
import 'package:otraku/common/utils/theming.dart';
import 'package:path_provider/path_provider.dart';

/// Current app version.
const versionCode = '1.2.6+1';

/// General options keys.
enum _OptionKey {
  themeMode,
  themeIndex,
  pureWhiteOrBlackTheme,
  defaultHomeTab,
  defaultDiscoverType,
  defaultAnimeSort,
  defaultMangaSort,
  defaultDiscoverSort,
  imageQuality,
  animeCollectionPreview,
  mangaCollectionPreview,
  airingSortForPreview,
  confirmExit,
  leftHanded,
  analogueClock,
  feedOnFollowing,
  viewerActivitiesInFeed,
  calendarSeason,
  calendarStatus,
  discoverItemView,
  collectionItemView,
  collectionPreviewItemView,
  feedActivityFilters,
  lastNotificationId,
  lastVersionCode,
  lastBackgroundWork,
}

/// User state keys.
enum _ProfileKey {
  account,
  id,
  expiration,
}

/// Available image qualities.
enum ImageQuality {
  VeryHigh('extraLarge'),
  High('large'),
  Medium('medium');

  const ImageQuality(this.value);
  final String value;
}

/// Hive box keys.
const _optionsBoxKey = 'options';
const _profileBoxKey = 'profiles';

/// Local settings.
/// [notifyListeners] is called when the theme configuration changes.
class Options extends ChangeNotifier {
  Options._(
    this._themeMode,
    this._theme,
    this._pureWhiteOrBlackTheme,
    this._defaultHomeTab,
    this._defaultDiscoverType,
    this._defaultAnimeSort,
    this._defaultMangaSort,
    this._defaultDiscoverSort,
    this._imageQuality,
    this._animeCollectionPreview,
    this._mangaCollectionPreview,
    this._airingSortForPreview,
    this._confirmExit,
    this._leftHanded,
    this._analogueClock,
    this._feedOnFollowing,
    this._viewerActivitiesInFeed,
    this._calendarSeason,
    this._calendarStatus,
    this._discoverItemView,
    this._collectionItemView,
    this._collectionPreviewItemView,
    this._feedActivityFilters,
    this._lastNotificationId,
    this._lastVersionCode,
    this._lastBackgroundWork,
    this._account,
    this._id0,
    this._id1,
    this._expiration0,
    this._expiration1,
  );

  factory Options._read() {
    int themeMode = _optionBox.get(_OptionKey.themeMode.name) ?? 0;
    if (themeMode < 0 || themeMode >= ThemeMode.values.length) themeMode = 0;

    int homeTab = _optionBox.get(_OptionKey.defaultHomeTab.name) ?? 0;
    if (homeTab < 0 || homeTab >= HomeTab.values.length) homeTab = 0;

    int discoverType = _optionBox.get(_OptionKey.defaultDiscoverType.name) ?? 0;
    if (discoverType < 0 || discoverType >= DiscoverType.values.length) {
      discoverType = 0;
    }

    int animeSort = _optionBox.get(_OptionKey.defaultAnimeSort.name) ?? 0;
    if (animeSort < 0 || animeSort >= EntrySort.values.length) animeSort = 0;

    int mangaSort = _optionBox.get(_OptionKey.defaultMangaSort.name) ?? 0;
    if (mangaSort < 0 || mangaSort >= EntrySort.values.length) mangaSort = 0;

    int discoverSort = _optionBox.get(_OptionKey.defaultDiscoverSort.name) ??
        MediaSort.TRENDING_DESC.index;
    if (discoverSort < 0 || discoverSort >= MediaSort.values.length) {
      discoverSort = MediaSort.TRENDING_DESC.index;
    }

    int imageQualityIndex = _optionBox.get(_OptionKey.imageQuality.name) ?? 1;
    if (imageQualityIndex < 0 ||
        imageQualityIndex >= ImageQuality.values.length) {
      imageQualityIndex = 1;
    }

    int calendarSeason = _optionBox.get(_OptionKey.calendarSeason.name) ?? 0;
    if (calendarSeason < 0 ||
        calendarSeason >= CalendarSeasonFilter.values.length) {
      calendarSeason = 0;
    }

    int calendarStatus = _optionBox.get(_OptionKey.calendarStatus.name) ?? 0;
    if (calendarStatus < 0 ||
        calendarStatus >= CalendarStatusFilter.values.length) {
      calendarStatus = 0;
    }

    int discoverItemView =
        _optionBox.get(_OptionKey.discoverItemView.name) ?? 0;
    if (discoverItemView < 0 || discoverItemView > 1) {
      discoverItemView = 0;
    }

    int collectionItemView =
        _optionBox.get(_OptionKey.collectionItemView.name) ?? 0;
    if (collectionItemView < 0 || collectionItemView > 1) {
      collectionItemView = 0;
    }

    int collectionPreviewItemView =
        _optionBox.get(_OptionKey.collectionPreviewItemView.name) ?? 0;
    if (collectionPreviewItemView < 0 || collectionPreviewItemView > 1) {
      collectionPreviewItemView = 0;
    }

    return Options._(
      ThemeMode.values[themeMode],
      _optionBox.get(_OptionKey.themeIndex.name),
      _optionBox.get(_OptionKey.pureWhiteOrBlackTheme.name) ?? false,
      HomeTab.values[homeTab],
      DiscoverType.values[discoverType],
      EntrySort.values[animeSort],
      EntrySort.values[mangaSort],
      MediaSort.values[discoverSort],
      ImageQuality.values.elementAt(imageQualityIndex),
      _optionBox.get(_OptionKey.animeCollectionPreview.name) ?? true,
      _optionBox.get(_OptionKey.mangaCollectionPreview.name) ?? true,
      _optionBox.get(_OptionKey.airingSortForPreview.name) ?? true,
      _optionBox.get(_OptionKey.confirmExit.name) ?? false,
      _optionBox.get(_OptionKey.leftHanded.name) ?? false,
      _optionBox.get(_OptionKey.analogueClock.name) ?? false,
      _optionBox.get(_OptionKey.feedOnFollowing.name) ?? false,
      _optionBox.get(_OptionKey.viewerActivitiesInFeed.name) ?? false,
      calendarSeason,
      calendarStatus,
      discoverItemView,
      collectionItemView,
      collectionPreviewItemView,
      _optionBox.get(_OptionKey.feedActivityFilters.name) ?? [0, 1, 2],
      _optionBox.get(_OptionKey.lastNotificationId.name) ?? -1,
      _optionBox.get(_OptionKey.lastVersionCode.name) ?? '',
      _optionBox.get(_OptionKey.lastBackgroundWork.name),
      _profileBox.get(_ProfileKey.account.name),
      _profileBox.get('${_ProfileKey.id.name}0'),
      _profileBox.get('${_ProfileKey.id.name}1'),
      _profileBox.get('${_ProfileKey.expiration.name}0'),
      _profileBox.get('${_ProfileKey.expiration.name}1'),
    );
  }

  factory Options() => _instance;

  static late Options _instance;

  static bool _didInit = false;

  /// Should be called before use.
  static Future<void> init() async {
    if (_didInit) return;
    _didInit = true;

    WidgetsFlutterBinding.ensureInitialized();

    /// Configure home directory if not in the browser.
    if (!kIsWeb) Hive.init((await getApplicationDocumentsDirectory()).path);

    /// Initialise boxes and instance.
    await Hive.openBox(_optionsBoxKey);
    await Hive.openBox(_profileBoxKey);
    _instance = Options._read();
  }

  /// Clears option data and resets instance.
  /// Doesn't affect local profile settings or online account settings.
  static void resetOptions() {
    Hive.box(_optionsBoxKey).clear();
    _instance = Options._read();
  }

  static Box get _optionBox => Hive.box(_optionsBoxKey);
  static Box get _profileBox => Hive.box(_profileBoxKey);

  /// Administrative data.
  int? _account;
  int? _id0;
  int? _id1;
  int? _expiration0;
  int? _expiration1;

  /// General options.
  ThemeMode _themeMode;
  int? _theme;
  bool _pureWhiteOrBlackTheme;
  HomeTab _defaultHomeTab;
  DiscoverType _defaultDiscoverType;
  EntrySort _defaultAnimeSort;
  EntrySort _defaultMangaSort;
  MediaSort _defaultDiscoverSort;
  ImageQuality _imageQuality;
  bool _animeCollectionPreview;
  bool _mangaCollectionPreview;
  bool _airingSortForPreview;
  bool _confirmExit;
  bool _leftHanded;
  bool _analogueClock;
  bool _feedOnFollowing;
  bool _viewerActivitiesInFeed;
  int _calendarSeason;
  int _calendarStatus;
  int _discoverItemView;
  int _collectionItemView;
  int _collectionPreviewItemView;
  List<int> _feedActivityFilters;
  int _lastNotificationId;
  String _lastVersionCode;
  DateTime? _lastBackgroundWork;

  /// Getters.

  ThemeMode get themeMode => _themeMode;
  int? get theme => _theme;
  bool get pureWhiteOrBlackTheme => _pureWhiteOrBlackTheme;
  HomeTab get defaultHomeTab => _defaultHomeTab;
  DiscoverType get defaultDiscoverType => _defaultDiscoverType;
  EntrySort get defaultAnimeSort => _defaultAnimeSort;
  EntrySort get defaultMangaSort => _defaultMangaSort;
  MediaSort get defaultDiscoverSort => _defaultDiscoverSort;
  ImageQuality get imageQuality => _imageQuality;
  bool get animeCollectionPreview => _animeCollectionPreview;
  bool get mangaCollectionPreview => _mangaCollectionPreview;
  bool get airingSortForPreview => _airingSortForPreview;
  bool get confirmExit => _confirmExit;
  bool get leftHanded => _leftHanded;
  bool get analogueClock => _analogueClock;
  bool get feedOnFollowing => _feedOnFollowing;
  bool get viewerActivitiesInFeed => _viewerActivitiesInFeed;
  int get calendarSeason => _calendarSeason;
  int get calendarStatus => _calendarStatus;
  int get discoverItemView => _discoverItemView;
  int get collectionItemView => _collectionItemView;
  int get collectionPreviewItemView => _collectionPreviewItemView;
  List<int> get feedActivityFilters => _feedActivityFilters;
  int get lastNotificationId => _lastNotificationId;
  String get lastVersionCode => _lastVersionCode;
  DateTime? get lastBackgroundWork => _lastBackgroundWork;

  int? get account => _account;

  bool isAvailableAccount(int i) {
    if (i < 0 || i > 1) return false;
    return _profileBox.get('${_ProfileKey.id.name}$i') != null;
  }

  int? get id {
    if (_account == null) return null;
    return _account == 0 ? _id0 : _id1;
  }

  int? idOf(int v) {
    if (v == 0) return _id0;
    if (v == 1) return _id1;
    return null;
  }

  int? expirationOf(int v) {
    if (v == 0) return _expiration0;
    if (v == 1) return _expiration1;
    return null;
  }

  /// Setters.

  set selectedAccount(int? v) {
    if (v == null && _account != null) {
      _account = null;
      _profileBox.delete(_ProfileKey.account.name);
      _instance.lastNotificationId = -1;
    } else if (v == 0 && _account != 0) {
      _account = 0;
      _profileBox.put(_ProfileKey.account.name, 0);
    } else if (v == 1 && _account != 1) {
      _account = 1;
      _profileBox.put(_ProfileKey.account.name, 1);
    }
  }

  set themeMode(ThemeMode v) {
    if (v == _themeMode) return;
    _themeMode = v;
    _optionBox.put(_OptionKey.themeMode.name, v.index);
    notifyListeners();
  }

  set theme(int? v) {
    if (v == _theme) return;

    if (v == null) {
      _theme = null;
      _optionBox.delete(_OptionKey.themeIndex.name);
      notifyListeners();
      return;
    }

    if (v < 0 || v >= colorSeeds.length) return;
    _theme = v;
    _optionBox.put(_OptionKey.themeIndex.name, v);
    notifyListeners();
  }

  set pureWhiteOrBlackTheme(bool v) {
    if (_pureWhiteOrBlackTheme == v) return;
    _pureWhiteOrBlackTheme = v;
    _optionBox.put(_OptionKey.pureWhiteOrBlackTheme.name, v);
    notifyListeners();
  }

  set defaultHomeTab(HomeTab v) {
    _defaultHomeTab = v;
    _optionBox.put(_OptionKey.defaultHomeTab.name, v.index);
  }

  set defaultDiscoverType(DiscoverType v) {
    _defaultDiscoverType = v;
    _optionBox.put(_OptionKey.defaultDiscoverType.name, v.index);
  }

  set defaultAnimeSort(EntrySort v) {
    _defaultAnimeSort = v;
    _optionBox.put(_OptionKey.defaultAnimeSort.name, v.index);
  }

  set defaultMangaSort(EntrySort v) {
    _defaultMangaSort = v;
    _optionBox.put(_OptionKey.defaultMangaSort.name, v.index);
  }

  set defaultDiscoverSort(MediaSort v) {
    _defaultDiscoverSort = v;
    _optionBox.put(_OptionKey.defaultDiscoverSort.name, v.index);
  }

  set imageQuality(ImageQuality v) {
    _imageQuality = v;
    _optionBox.put(_OptionKey.imageQuality.name, v.index);
  }

  set animeCollectionPreview(bool v) {
    _animeCollectionPreview = v;
    _optionBox.put(_OptionKey.animeCollectionPreview.name, v);
  }

  set mangaCollectionPreview(bool v) {
    _mangaCollectionPreview = v;
    _optionBox.put(_OptionKey.mangaCollectionPreview.name, v);
  }

  set airingSortForPreview(bool v) {
    _airingSortForPreview = v;
    _optionBox.put(_OptionKey.airingSortForPreview.name, v);
  }

  set confirmExit(bool v) {
    _confirmExit = v;
    _optionBox.put(_OptionKey.confirmExit.name, v);
  }

  set leftHanded(bool v) {
    _leftHanded = v;
    _optionBox.put(_OptionKey.leftHanded.name, v);
  }

  set analogueClock(bool v) {
    _analogueClock = v;
    _optionBox.put(_OptionKey.analogueClock.name, v);
  }

  set feedOnFollowing(bool v) {
    _feedOnFollowing = v;
    _optionBox.put(_OptionKey.feedOnFollowing.name, v);
  }

  set viewerActivitiesInFeed(bool v) {
    _viewerActivitiesInFeed = v;
    _optionBox.put(_OptionKey.viewerActivitiesInFeed.name, v);
  }

  set calendarSeason(int v) {
    _calendarSeason = v;
    _optionBox.put(_OptionKey.calendarSeason.name, v);
  }

  set calendarStatus(int v) {
    _calendarStatus = v;
    _optionBox.put(_OptionKey.calendarStatus.name, v);
  }

  set discoverItemView(int v) {
    _discoverItemView = v;
    _optionBox.put(_OptionKey.discoverItemView.name, v);
  }

  set collectionItemView(int v) {
    _collectionItemView = v;
    _optionBox.put(_OptionKey.collectionItemView.name, v);
  }

  set collectionPreviewItemView(int v) {
    _collectionPreviewItemView = v;
    _optionBox.put(_OptionKey.collectionPreviewItemView.name, v);
  }

  set feedActivityFilters(List<int> v) {
    _feedActivityFilters = v;
    _optionBox.put(_OptionKey.feedActivityFilters.name, v);
  }

  set lastNotificationId(int v) {
    _lastNotificationId = v;
    _optionBox.put(_OptionKey.lastNotificationId.name, v);
  }

  /// Updates the version code to the newest one.
  void updateVersionCode() {
    _lastVersionCode = versionCode;
    _optionBox.put(_OptionKey.lastVersionCode.name, versionCode);
  }

  set lastBackgroundWork(DateTime? v) {
    _lastBackgroundWork = v;
    _optionBox.put(_OptionKey.lastBackgroundWork.name, v);
  }

  void setIdOf(int a, int? v) {
    if (a < 0 || a > 1) return;
    a == 0 ? _id0 = v : _id1 = v;
    v != null
        ? _profileBox.put('${_ProfileKey.id.name}$a', v)
        : _profileBox.delete('${_ProfileKey.id.name}$a');
  }

  void setExpirationOf(int a, int? v) {
    if (a < 0 || a > 1) return;
    a == 0 ? _expiration0 = v : _expiration1 = v;
    v != null
        ? _profileBox.put('${_ProfileKey.expiration.name}$a', v)
        : _profileBox.delete('${_ProfileKey.expiration.name}$a');
  }
}
