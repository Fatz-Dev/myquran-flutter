import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/quran_provider.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanya AI Al-Quran'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1B1B) : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Cari ayat (misal: tentang sabar)...',
                  prefixIcon: Icon(Icons.psychology_alt_rounded, color: primary),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send_rounded, color: primary),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        context.read<QuranProvider>().searchSemantic(_controller.text);
                      }
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<QuranProvider>().searchSemantic(value);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Consumer<QuranProvider>(
              builder: (context, quran, _) {
                if (quran.isSemanticLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (quran.semanticResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Coba jelaskan apa yang ingin Anda cari\ndalam bahasa natural.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quran.semanticResults.length,
                  itemBuilder: (context, index) {
                    final result = quran.semanticResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${result.surahName} : Ayat ${result.ayah}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Score: ${(result.score * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(fontSize: 10, color: primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              result.text,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Scheherazade',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.translation,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.push(
                                      '/quran/detail/${result.surah}?ayah=${result.ayah}');
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Baca Selengkapnya'),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
