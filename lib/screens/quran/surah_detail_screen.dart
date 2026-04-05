import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/bookmark_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/quran/audio_player_bar.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNomor;
  final int startAyah;

  const SurahDetailScreen(
      {super.key, required this.surahNomor, this.startAyah = 1});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool _showTafsir = false;
  final ScrollController _scrollController = ScrollController();
  bool _didScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahDetail(widget.surahNomor);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addToHistory(SurahDetailModel surah) {
    context.read<HistoryProvider>().addOrUpdate(
          nomor: surah.nomor,
          namaLatin: surah.namaLatin,
          nama: surah.nama,
          arti: surah.arti,
          lastAyah: widget.startAyah,
          jumlahAyat: surah.jumlahAyat,
        );
  }

  void _scrollToAyah() {
    if (_didScroll || widget.startAyah <= 1) return;
    _didScroll = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final estimatedOffset = (widget.startAyah - 1) * 220.0;
      _scrollController.animateTo(
        estimatedOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Consumer<QuranProvider>(
        builder: (context, quran, _) {
          if (quran.isLoadingDetail) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(title: Text('Memuat...')),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerDoaCard(),
                      childCount: 8,
                    ),
                  ),
                ),
              ],
            );
          }

          if (quran.errorDetail != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: ErrorStateWidget(
                message: quran.errorDetail!,
                onRetry: () => quran.loadSurahDetail(widget.surahNomor),
              ),
            );
          }

          final surah = quran.currentSurah;
          if (surah == null) return const SizedBox.shrink();

          // Add to history once data is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _addToHistory(surah);
            _scrollToAyah();
          });

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      _buildAppBar(context, surah, isDark, primary),
                      SliverToBoxAdapter(
                        child:
                            _buildSurahHeader(context, surah, isDark, primary),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final ayah = surah.ayat[index];
                              return _buildAyahCard(
                                  context, ayah, surah, isDark, primary);
                            },
                            childCount: surah.ayat.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: 24)),
                    ],
                  ),
                ),
                const AudioPlayerBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SurahDetailModel surah, bool isDark,
      Color primary) {
    return SliverAppBar(
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.go('/quran'),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(surah.namaLatin,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '${surah.jumlahAyat} Ayat',
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showTafsir
                ? Icons.format_list_bulleted_rounded
                : Icons.format_list_bulleted_rounded,
            color: _showTafsir ? primary : null,
          ),
          onPressed: () {
            setState(() => _showTafsir = !_showTafsir);
            if (_showTafsir) {
              context.read<QuranProvider>().loadTafsir(surah.nomor);
            }
          },
          tooltip: 'Tafsir',
        ),
        _buildAudioMenuButton(context, surah, primary),
      ],
    );
  }

  Widget _buildAudioMenuButton(
      BuildContext context, SurahDetailModel surah, Color primary) {
    if (surah.audioFull == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      icon: Icon(Icons.headphones_rounded, color: primary),
      tooltip: 'Putar Surat',
      onSelected: (qariId) {
        final url = surah.audioFull!.getUrlByQari(qariId);
        final qariName = ApiConstants.qariList
            .firstWhere((q) => q['id'] == qariId,
                orElse: () => {'name': 'Qari'})['name']!;
        context.read<AudioProvider>().playAudio(
              url: url,
              title: surah.namaLatin,
              subtitle: 'Qari: $qariName',
            );
      },
      itemBuilder: (_) => ApiConstants.qariList
          .map((q) => PopupMenuItem<String>(
                value: q['id'],
                child: Text(q['name']!),
              ))
          .toList(),
    );
  }

  Widget _buildSurahHeader(BuildContext context, SurahDetailModel surah,
      bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            surah.nama,
            style: GoogleFonts.amiri(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            surah.namaLatin,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          Text(
            surah.arti,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(
                  '${surah.jumlahAyat} Ayat', Icons.format_list_numbered),
              const SizedBox(width: 12),
              _infoChip(surah.tempatTurun, Icons.location_on_rounded),
            ],
          ),
          if (widget.surahNomor != 9 && widget.surahNomor != 1) ...[
            const SizedBox(height: 16),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: GoogleFonts.amiri(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAyahCard(BuildContext context, AyahModel ayah,
      SurahDetailModel surah, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return Consumer<BookmarkProvider>(
      builder: (context, bm, _) {
        final isBookmarked =
            bm.isAyahBookmarked(surah.nomor, ayah.nomorAyat);
        return Consumer<QuranProvider>(
          builder: (context, quran, _) {
            final tafsir = _showTafsir ? quran.getTafsir(ayah.nomorAyat) : null;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isBookmarked
                    ? Border.all(color: primary.withOpacity(0.5), width: 1.5)
                    : Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ayah number row
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${ayah.nomorAyat}',
                              style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Bookmark button
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color:
                                isBookmarked ? primary : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            bm.toggleAyahBookmark(AyahBookmark(
                              surahNomor: surah.nomor,
                              surahName: surah.namaLatin,
                              surahNama: surah.nama,
                              ayahNomor: ayah.nomorAyat,
                              arabText: ayah.teksArab,
                              terjemahan: ayah.teksIndonesia,
                              timestamp: DateTime.now(),
                            ));
                            // Update history position
                            context
                                .read<HistoryProvider>()
                                .updateLastAyah(surah.nomor, ayah.nomorAyat);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(isBookmarked
                                  ? 'Bookmark dihapus'
                                  : 'Ayat ${ayah.nomorAyat} dibookmark'),
                              duration: const Duration(seconds: 1),
                            ));
                          },
                          visualDensity: VisualDensity.compact,
                          tooltip: isBookmarked
                              ? 'Hapus Bookmark'
                              : 'Bookmark',
                        ),
                        // Copy button
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              size: 18, color: Colors.grey),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text:
                                    '${ayah.teksArab}\n\n${ayah.teksIndonesia}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Ayat disalin'),
                                    duration: Duration(seconds: 1)));
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                        // Audio per-ayah
                        if (ayah.audio.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.play_circle_rounded,
                                color: primary, size: 22),
                            onPressed: () {
                              final audioProvider =
                                  context.read<AudioProvider>();
                              final qariId = audioProvider.selectedQariId;
                              final url = ayah.getAudioUrl(qariId);
                              audioProvider.playAudio(
                                    url: url,
                                    title:
                                        '${surah.namaLatin} : ${ayah.nomorAyat}',
                                    subtitle: surah.nama,
                                  );
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  // Arabic text
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      ayah.teksArab,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        height: 1.9,
                      ),
                    ),
                  ),
                  // Translation
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      '${ayah.nomorAyat}. ${ayah.teksIndonesia}',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                    ),
                  ),
                  // Tafsir (if expanded)
                  if (_showTafsir && tafsir != null) ...[
                    Divider(
                        height: 1,
                        color: primary.withOpacity(0.1)),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tafsir',
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tafsir,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
