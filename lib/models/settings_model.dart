import 'package:otraku/utils/convert.dart';
import 'package:otraku/enums/list_sort.dart';
import 'package:otraku/enums/score_format.dart';

class SettingsModel {
  final ScoreFormat scoreFormat;
  final ListSort defaultSort;
  final String? titleLanguage;
  final Map<String?, bool?> notificationOptions;
  final bool splitCompletedAnime;
  final bool splitCompletedManga;
  final bool displayAdultContent;
  final bool airingNotifications;
  final bool advancedScoringEnabled;

  SettingsModel._({
    required this.scoreFormat,
    required this.defaultSort,
    required this.titleLanguage,
    required this.notificationOptions,
    required this.splitCompletedAnime,
    required this.splitCompletedManga,
    required this.airingNotifications,
    required this.displayAdultContent,
    required this.advancedScoringEnabled,
  });

  factory SettingsModel(Map<String, dynamic> map) => SettingsModel._(
        scoreFormat: Convert.stringToEnum(
              map['mediaListOptions']['scoreFormat'],
              ScoreFormat.values,
            ) ??
            ScoreFormat.POINT_10,
        defaultSort:
            ListSortHelper.getEnum(map['mediaListOptions']['rowOrder']),
        titleLanguage: map['options']['titleLanguage'],
        notificationOptions: Map.fromIterable(
          map['options']['notificationOptions'],
          key: (n) => n['type'],
          value: (n) => n['enabled'],
        ),
        splitCompletedAnime: map['mediaListOptions']['animeList']
                ['splitCompletedSectionByFormat'] ??
            false,
        splitCompletedManga: map['mediaListOptions']['mangaList']
                ['splitCompletedSectionByFormat'] ??
            false,
        displayAdultContent: map['options']['displayAdultContent'] ?? false,
        airingNotifications: map['options']['airingNotifications'] ?? false,
        advancedScoringEnabled: map['mediaListOptions']['animeList']
                ['advancedScoringEnabled'] ??
            false,
      );
}
