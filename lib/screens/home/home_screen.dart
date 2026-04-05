import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/hadis_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../data/models/history_model.dart';
import '../../data/models/bookmark_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _countdown = '00:00:00';
  String _nextPrayerName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prayer = context.read<PrayerProvider>();
      if (prayer.monthlySchedule.isEmpty) prayer.loadSchedule();
      final quran = context.read<QuranProvider>();
      if (quran.suratList.isEmpty) quran.loadSuratList();
      context.read<HadisProvider>().loadRandomHadis();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final prayer = context.read<PrayerProvider>();
      final today = prayer.todaySchedule;
      if (today != null && mounted) {
        final nextPrayer = today.getNextPrayer();
        final nextTime = today.getNextPrayerTime();
        setState(() {
          _nextPrayerName = nextPrayer ?? '';
          _countdown = nextTime != null
              ? DateHelper.getCountdown(nextTime)
              : '00:00:00';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark, primary),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildHeader(context, isDark),
                const SizedBox(height: 20),
                _buildTopCards(context, isDark, primary),
                const SizedBox(height: 20),
                _buildContinueReading(context, isDark, primary),
                _buildReadingHistory(context, isDark, primary),
                _buildFavoriteSection(context, isDark, primary),
                _buildAyatHariIni(context, isDark, primary),
                _buildHadisHariIni(context, isDark, primary),
                const SizedBox(height: 20),
                _buildShortcuts(context, primary, isDark),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, Color primary) {
    return SliverAppBar(
      pinned: true,
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      title: Row(
        children: [
          Image.asset('icon-quran.png', width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            'MyQuran',
            style: GoogleFonts.poppins(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.bookmark_rounded, color: primary),
          tooltip: 'Favorit',
          onPressed: () => context.go('/bookmarks'),
        ),
        IconButton(
          icon: Icon(Icons.search_rounded, color: primary),
          onPressed: () => context.go('/quran'),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Assalamu'alaikum",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => context.go('/calendar'),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 6),
                  Text(
                    '${DateHelper.getDayName()}, ${DateHelper.todayFormatted()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                DateHelper.getHijriDate(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopCards(BuildContext context, bool isDark, Color primary) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPrayerCard(context, isDark),
          const SizedBox(width: 12),
          _buildDoaHarianCard(context, isDark, primary),
          const SizedBox(width: 12),
          _buildQuranCard(context, isDark, primary),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/prayer'),
      child: Consumer<PrayerProvider>(
        builder: (context, prayer, _) {
          return Container(
            width: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF0C12C).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0C12C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          color: Color(0xFFF0C12C), size: 16),
                    ),
                    Text(
                      prayer.selectedCityName.isNotEmpty
                          ? prayer.selectedCityName
                          : 'Batam',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFF0C12C),
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const Spacer(),
                Text('Shalat Berikutnya',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(
                  _nextPrayerName.isNotEmpty ? _nextPrayerName : 'Memuat...',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _countdown,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF0C12C),
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoaHarianCard(BuildContext context, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/doa'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.volunteer_activism_rounded, color: primary, size: 22),
            const Spacer(),
            Text('Doa & Dzikir',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('228 Doa tersedia',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranCard(BuildContext context, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/quran'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.menu_book_rounded, color: primary, size: 22),
            const Spacer(),
            Text('Al-Quran',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('114 Surat', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  // ─── Lanjutkan Membaca ────────────────────────────────
  Widget _buildContinueReading(
      BuildContext context, bool isDark, Color primary) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (!history.hasHistory) return const SizedBox.shrink();
        final last = history.lastRead!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Lanjutkan Membaca',
                icon: Icons.play_circle_rounded, color: primary),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.go(
                  '/quran/detail/${last.nomor}?ayah=${last.lastAyah}'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${last.nomor}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            last.namaLatin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            last.progressText,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: last.progress,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ─── Riwayat Bacaan ───────────────────────────────────
  Widget _buildReadingHistory(
      BuildContext context, bool isDark, Color primary) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        if (!history.hasHistory) return const SizedBox.shrink();
        final list = history.history;
        final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Riwayat Bacaan',
                icon: Icons.history_rounded, color: primary),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final item = list[i];
                  return GestureDetector(
                    onTap: () => context.go(
                        '/quran/detail/${item.nomor}?ayah=${item.lastAyah}'),
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.nomor}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.nama,
                                style: GoogleFonts.amiri(
                                    fontSize: 14, color: primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.namaLatin,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: item.progress,
                              backgroundColor:
                                  primary.withOpacity(0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primary),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ayat ${item.lastAyah}',
                            style: TextStyle(
                                fontSize: 10,
                                color: primary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ─── Favorit ─────────────────────────────────────────
  Widget _buildFavoriteSection(
      BuildContext context, bool isDark, Color primary) {
    return Consumer<BookmarkProvider>(
      builder: (context, bm, _) {
        if (!bm.hasBookmarks) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(context, 'Favorit',
                    icon: Icons.bookmark_rounded, color: const Color(0xFFF0C12C)),
                TextButton(
                  onPressed: () => context.go('/bookmarks'),
                  child: Text('Lihat Semua',
                      style: TextStyle(color: primary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (bm.ayahBookmarks.isNotEmpty) ...[
              _buildFavoriteAyahPreview(context, bm.ayahBookmarks.first, isDark, primary),
              const SizedBox(height: 10),
            ],
            if (bm.doaBookmarks.isNotEmpty) ...[
              _buildFavoriteDoaPreview(context, bm.doaBookmarks.first, isDark),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteAyahPreview(BuildContext context, AyahBookmark b,
      bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () =>
          context.go('/quran/detail/${b.surahNomor}?ayah=${b.ayahNomor}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.bookmark_rounded, color: primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${b.surahName} : ${b.ayahNomor}',
                    style: TextStyle(
                        fontSize: 11,
                        color: primary,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.arabText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(fontSize: 16, height: 1.7),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteDoaPreview(
      BuildContext context, DoaBookmark b, bool isDark) {
    final gold = const Color(0xFFF0C12C);
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/doa/${b.doaId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.bookmark_rounded, color: gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.judul,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.arab,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(fontSize: 16, height: 1.7),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyatHariIni(BuildContext context, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Ayat Hari Ini',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 26,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sesungguhnya bersama kesulitan ada kemudahan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'QS. Al-Insyirah: 6',
            style: TextStyle(
                fontSize: 12, color: primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHadisHariIni(BuildContext context, bool isDark, Color primary) {
    final gold = const Color(0xFFF0C12C);
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return Consumer<HadisProvider>(
      builder: (context, hadis, _) {
        if (hadis.isLoading) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withOpacity(0.2)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (hadis.randomHadis == null) return const SizedBox.shrink();

        final h = hadis.randomHadis!;

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Hadis Hari Ini',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      h.grade,
                      style: TextStyle(
                          fontSize: 10,
                          color: gold,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                h.textAr,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                h.textId,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      h.takhrij,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: gold, size: 20),
                    onPressed: () => hadis.loadRandomHadis(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (h.hikmah.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: gold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        h.hikmah,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildShortcuts(BuildContext context, Color primary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionTitle(context, 'Menu Utama',
            icon: Icons.grid_view_rounded, color: primary),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildShortcutItem(context,
                icon: Icons.menu_book_rounded,
                label: 'Al-Quran',
                onTap: () => context.go('/quran'),
                color: primary,
                isDark: isDark),
            _buildShortcutItem(context,
                icon: Icons.volunteer_activism_rounded,
                label: 'Doa & Dzikir',
                onTap: () => context.go('/doa'),
                color: const Color(0xFFF0C12C),
                isDark: isDark),
            _buildShortcutItem(context,
                icon: Icons.access_time_rounded,
                label: 'Jadwal Shalat',
                onTap: () => context.go('/prayer'),
                color: Colors.blue.shade400,
                isDark: isDark),
            _buildShortcutItem(context,
                icon: Icons.psychology_alt_rounded,
                label: 'Tanya AI',
                onTap: () => context.go('/smart-search'),
                color: Colors.teal.shade400,
                isDark: isDark),
            _buildShortcutItem(context,
                icon: Icons.bookmark_rounded,
                label: 'Favorit',
                onTap: () => context.go('/bookmarks'),
                color: Colors.orange.shade400,
                isDark: isDark),
            _buildShortcutItem(context,
                icon: Icons.auto_stories_rounded,
                label: 'Hadis',
                onTap: () => context.go('/hadis'),
                color: Colors.indigo.shade400,
                isDark: isDark),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title,
      {required IconData icon, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
