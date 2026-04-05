import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/doa_provider.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/error_state_widget.dart';

class DoaListScreen extends StatefulWidget {
  const DoaListScreen({super.key});

  @override
  State<DoaListScreen> createState() => _DoaListScreenState();
}

class _DoaListScreenState extends State<DoaListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaProvider>().loadDoaList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Consumer<DoaProvider>(
        builder: (context, doa, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                title: const Text('Doa & Dzikir'),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => doa.search(v),
                      decoration: InputDecoration(
                        hintText: 'Cari doa...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  doa.search('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              // Filter categories
              if (!doa.isLoadingList && doa.errorList == null)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: doa.categories.length,
                      itemBuilder: (context, index) {
                        final cat = doa.categories[index];
                        final selected = cat == doa.selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) => doa.setFilter(cat),
                            selectedColor: primary.withOpacity(0.2),
                            checkmarkColor: primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: selected ? primary : null,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // Content
              if (doa.isLoadingList)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerDoaCard(),
                      childCount: 8,
                    ),
                  ),
                )
              else if (doa.errorList != null)
                SliverFillRemaining(
                  child: ErrorStateWidget(
                    message: doa.errorList!,
                    onRetry: () => context.read<DoaProvider>().loadDoaList(),
                  ),
                )
              else if (doa.doaList.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    message: 'Tidak ada doa yang ditemukan',
                    icon: Icons.volunteer_activism_rounded,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final d = doa.doaList[index];
                        return _buildDoaCard(context, d, isDark, primary);
                      },
                      childCount: doa.doaList.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoaCard(BuildContext context, dynamic d, bool isDark, Color primary) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return GestureDetector(
      onTap: () => context.go('/doa/${d.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    d.judul,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (d.grup != null && d.grup!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      d.grup!,
                      style: TextStyle(
                          fontSize: 10,
                          color: primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (d.arab.isNotEmpty)
              Text(
                d.arab.length > 80 ? '${d.arab.substring(0, 80)}...' : d.arab,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              d.terjemahan.length > 100
                  ? '${d.terjemahan.substring(0, 100)}...'
                  : d.terjemahan,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
