import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/bookmark_provider.dart';
import '../../data/models/bookmark_model.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit & Bookmark'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor:
              isDark ? Colors.white54 : Colors.black54,
          indicatorColor: primary,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Ayat'),
            Tab(icon: Icon(Icons.volunteer_activism_rounded), text: 'Doa'),
          ],
        ),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bm, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAyahTab(context, bm, isDark, primary),
              _buildDoaTab(context, bm, isDark, primary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAyahTab(BuildContext context, BookmarkProvider bm, bool isDark,
      Color primary) {
    if (bm.ayahBookmarks.isEmpty) {
      return _buildEmpty(context, 'Belum ada ayat yang dibookmark',
          'Tekan ikon bookmark pada ayat Al-Quran untuk menyimpannya di sini.',
          Icons.bookmark_border_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bm.ayahBookmarks.length,
      itemBuilder: (context, i) {
        final b = bm.ayahBookmarks[i];
        return _buildAyahCard(context, b, bm, isDark, primary);
      },
    );
  }

  Widget _buildAyahCard(BuildContext context, AyahBookmark b,
      BookmarkProvider bm, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () =>
          context.go('/quran/detail/${b.surahNomor}?ayah=${b.ayahNomor}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${b.surahName} : ${b.ayahNomor}',
                        style: TextStyle(
                            fontSize: 11,
                            color: primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      b.surahNama,
                      style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 20),
                  onPressed: () =>
                      bm.removeAyahBookmark(b.surahNomor, b.ayahNomor),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              b.arabText,
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
            const SizedBox(height: 8),
            Text(
              b.terjemahan,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoaTab(BuildContext context, BookmarkProvider bm, bool isDark,
      Color primary) {
    if (bm.doaBookmarks.isEmpty) {
      return _buildEmpty(context, 'Belum ada doa yang dibookmark',
          'Tekan ikon bookmark pada detail doa untuk menyimpannya di sini.',
          Icons.bookmark_border_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bm.doaBookmarks.length,
      itemBuilder: (context, i) {
        final b = bm.doaBookmarks[i];
        return _buildDoaCard(context, b, bm, isDark, primary);
      },
    );
  }

  Widget _buildDoaCard(BuildContext context, DoaBookmark b, BookmarkProvider bm,
      bool isDark, Color primary) {
    final gold = const Color(0xFFF0C12C);
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/doa/${b.doaId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    b.judul,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 20),
                  onPressed: () => bm.removeDoaBookmark(b.doaId),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              b.arab,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                height: 1.8,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              b.terjemahan,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String title, String subtitle,
      IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
