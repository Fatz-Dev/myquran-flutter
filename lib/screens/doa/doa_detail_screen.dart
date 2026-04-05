import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/doa_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../data/models/bookmark_model.dart';
import '../../widgets/common/error_state_widget.dart';

class DoaDetailScreen extends StatefulWidget {
  final int doaId;

  const DoaDetailScreen({super.key, required this.doaId});

  @override
  State<DoaDetailScreen> createState() => _DoaDetailScreenState();
}

class _DoaDetailScreenState extends State<DoaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaProvider>().loadDoaDetail(widget.doaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Doa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/doa'),
        ),
        actions: [
          // Bookmark button
          Consumer2<DoaProvider, BookmarkProvider>(
            builder: (context, doa, bm, _) {
              if (doa.currentDoa == null) return const SizedBox.shrink();
              final d = doa.currentDoa!;
              final isBookmarked = bm.isDoaBookmarked(widget.doaId);
              return IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isBookmarked ? const Color(0xFFF0C12C) : null,
                ),
                tooltip: isBookmarked ? 'Hapus Bookmark' : 'Bookmark Doa',
                onPressed: () {
                  bm.toggleDoaBookmark(DoaBookmark(
                    doaId: widget.doaId,
                    judul: d.judul,
                    arab: d.arab,
                    terjemahan: d.terjemahan,
                    timestamp: DateTime.now(),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        isBookmarked ? 'Bookmark dihapus' : 'Doa dibookmark'),
                    duration: const Duration(seconds: 1),
                  ));
                },
              );
            },
          ),
          // Share button
          Consumer<DoaProvider>(
            builder: (context, doa, _) {
              if (doa.currentDoa == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  final d = doa.currentDoa!;
                  Clipboard.setData(ClipboardData(
                    text:
                        '${d.judul}\n\n${d.arab}\n\n${d.latin}\n\n${d.terjemahan}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doa disalin')),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<DoaProvider>(
        builder: (context, doa, _) {
          if (doa.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }
          if (doa.errorDetail != null) {
            return ErrorStateWidget(
              message: doa.errorDetail!,
              onRetry: () => doa.loadDoaDetail(widget.doaId),
            );
          }
          if (doa.currentDoa == null) return const SizedBox.shrink();

          final d = doa.currentDoa!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  d.judul,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (d.grup != null && d.grup!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d.grup!,
                          style: TextStyle(
                              fontSize: 12,
                              color: primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                // Arabic text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1B1B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    d.arab,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 28,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.9,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Transliteration
                if (d.latin.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1B1B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latin',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: primary)),
                        const SizedBox(height: 8),
                        Text(
                          d.latin,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Translation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1B1B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terjemahan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: primary)),
                      const SizedBox(height: 8),
                      Text(
                        d.terjemahan,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
                // Reference
                if (d.referensi != null && d.referensi!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0C12C).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF0C12C).withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.book_outlined,
                            size: 16, color: Color(0xFFF0C12C)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Referensi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFFF0C12C))),
                              const SizedBox(height: 4),
                              Text(
                                d.referensi!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Copy button
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text:
                          '${d.judul}\n\n${d.arab}\n\n${d.latin}\n\n${d.terjemahan}',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Doa berhasil disalin'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Salin Doa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
