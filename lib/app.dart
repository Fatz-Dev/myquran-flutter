import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/quran/surah_list_screen.dart';
import 'screens/quran/surah_detail_screen.dart';
import 'screens/doa/doa_list_screen.dart';
import 'screens/doa/doa_detail_screen.dart';
import 'screens/prayer/prayer_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/bookmarks/bookmarks_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/quran/smart_search_screen.dart';
import 'screens/hadis/hadis_list_screen.dart';
import 'screens/hadis/hadis_detail_screen.dart';
import 'screens/hadis/perawi_list_screen.dart';
import 'screens/hadis/perawi_detail_screen.dart';

class MyQuranApp extends StatefulWidget {
  const MyQuranApp({super.key});

  @override
  State<MyQuranApp> createState() => _MyQuranAppState();
}

class _MyQuranAppState extends State<MyQuranApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        ShellRoute(
          builder: (context, state, child) =>
              MainShell(child: child, location: state.uri.path),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/quran',
              builder: (_, __) => const SurahListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:nomor',
                  builder: (_, state) {
                    final nomor = int.tryParse(
                            state.pathParameters['nomor'] ?? '1') ??
                        1;
                    final startAyah = int.tryParse(
                        state.uri.queryParameters['ayah'] ?? '1') ?? 1;
                    return SurahDetailScreen(
                        surahNomor: nomor, startAyah: startAyah);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/doa',
              builder: (_, __) => const DoaListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) {
                    final id =
                        int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                    return DoaDetailScreen(doaId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/prayer',
              builder: (_, __) => const PrayerScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/bookmarks',
              builder: (_, __) => const BookmarksScreen(),
            ),
            GoRoute(
              path: '/calendar',
              builder: (_, __) => const CalendarScreen(),
            ),
            GoRoute(
              path: '/smart-search',
              builder: (_, __) => const SmartSearchScreen(),
            ),
            GoRoute(
              path: '/hadis',
              builder: (_, __) => const HadisListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (_, state) {
                    final id =
                        int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                    return HadisDetailScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'perawi',
                  builder: (_, __) => const PerawiListScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (_, state) {
                        final id =
                            int.tryParse(state.pathParameters['id'] ?? '1') ??
                                1;
                        return PerawiDetailScreen(id: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'MyQuran',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  int _currentIndex() {
    if (location.startsWith('/quran')) return 1;
    if (location.startsWith('/doa')) return 2;
    if (location.startsWith('/prayer')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final currentIndex = _currentIndex();

    // Hide bottom nav on detail screens
    final isDetail = location.contains('/quran/detail') ||
        location.contains('/hadis/detail') ||
        location.contains('/hadis/perawi/') ||
        (location.startsWith('/doa/') && location.length > 5);

    return Scaffold(
      body: child,
      bottomNavigationBar: isDetail
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) {
                switch (i) {
                  case 0: context.go('/home'); break;
                  case 1: context.go('/quran'); break;
                  case 2: context.go('/doa'); break;
                  case 3: context.go('/prayer'); break;
                  case 4: context.go('/settings'); break;
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(currentIndex == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(currentIndex == 1
                      ? Icons.menu_book_rounded
                      : Icons.menu_book_outlined),
                  label: 'Al-Quran',
                ),
                BottomNavigationBarItem(
                  icon: Icon(currentIndex == 2
                      ? Icons.volunteer_activism_rounded
                      : Icons.volunteer_activism_outlined),
                  label: 'Doa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(currentIndex == 3
                      ? Icons.access_time_filled_rounded
                      : Icons.access_time_rounded),
                  label: 'Shalat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(currentIndex == 4
                      ? Icons.settings_rounded
                      : Icons.settings_outlined),
                  label: 'Pengaturan',
                ),
              ],
            ),
    );
  }
}
