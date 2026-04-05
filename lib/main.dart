import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';
import 'data/services/api_service.dart';
import 'data/services/quran_service.dart';
import 'data/services/doa_service.dart';
import 'data/services/prayer_service.dart';
import 'data/services/notification_service.dart';
import 'data/local/preferences_service.dart';
import 'providers/theme_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/doa_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/history_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/hadis_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground init error: $e');
  }
  await initializeDateFormatting('id_ID', null);
  await NotificationService.initialize();

  final prefs = await PreferencesService.create();
  final apiService = ApiService();
  final quranService = QuranService(apiService);
  final doaService = DoaService(apiService);
  final prayerService = PrayerService(apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: prefs),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => QuranProvider(quranService)),
        ChangeNotifierProvider(create: (_) => DoaProvider(doaService)),
        ChangeNotifierProvider(
            create: (_) => PrayerProvider(prayerService, prefs)),
        ChangeNotifierProvider(create: (_) => AudioProvider(prefs)),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(prefs)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(prefs)),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => HadisProvider()),
      ],
      child: const MyQuranApp(),
    ),
  );
}
