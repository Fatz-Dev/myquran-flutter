import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hadis_provider.dart';
import 'package:go_router/go_router.dart';

class HadisListScreen extends StatefulWidget {
  const HadisListScreen({super.key});

  @override
  State<HadisListScreen> createState() => _HadisListScreenState();
}

class _HadisListScreenState extends State<HadisListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadisProvider>().loadExplore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensiklopedia Hadis'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/hadis/perawi'),
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: 'Daftar Perawi',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari hadis (misal: niat, shalat)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HadisProvider>().loadExplore();
                  },
                ),
                filled: true,
                fillColor: isDark ? Colors.black26 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  context.read<HadisProvider>().searchKeyword(val);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<HadisProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isSearchActive = _searchController.text.isNotEmpty;
                final list = isSearchActive
                    ? provider.searchList
                    : provider.exploreList;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(isSearchActive 
                          ? 'Tidak ada hadis ditemukan' 
                          : 'Memuat hadis menarik...'),
                        if (!isSearchActive && !provider.isLoading)
                          TextButton(
                            onPressed: () => provider.loadExplore(),
                            child: const Text('Coba Lagi'),
                          ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        isSearchActive ? 'Hasil Pencarian' : 'Hadis Menarik Untukmu',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final h = list[index];
                          final title = h.takhrij.isNotEmpty ? h.takhrij : 'Hadis #${h.id}';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black12,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    h.textId,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, height: 1.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Baca Selengkapnya →',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => context.push('/hadis/detail/${h.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
