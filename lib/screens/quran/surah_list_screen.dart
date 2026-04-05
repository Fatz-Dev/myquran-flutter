import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/quran_provider.dart';
import '../../widgets/quran/surah_card.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/error_state_widget.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSuratList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuranProvider>(
        builder: (context, quran, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text('Al-Quran'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.psychology_alt_rounded),
                    tooltip: 'Tanya AI',
                    onPressed: () => context.go('/smart-search'),
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => quran.search(v),
                      decoration: InputDecoration(
                        hintText: 'Cari surat...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  quran.search('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              if (quran.isLoadingList)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerSurahCard(),
                      childCount: 10,
                    ),
                  ),
                )
              else if (quran.errorList != null)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: quran.errorList!,
                    onRetry: () {
                      context.read<QuranProvider>().loadSuratList();
                    },
                  ),
                )
              else if (quran.suratList.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'Tidak ada surat yang ditemukan',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final surah = quran.suratList[index];
                        return SurahCard(
                          surah: surah,
                          onTap: () {
                            context.go('/quran/detail/${surah.nomor}');
                          },
                        );
                      },
                      childCount: quran.suratList.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
