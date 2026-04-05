import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hadis_provider.dart';

class PerawiDetailScreen extends StatefulWidget {
  final int id;
  const PerawiDetailScreen({super.key, required this.id});

  @override
  State<PerawiDetailScreen> createState() => _PerawiDetailScreenState();
}

class _PerawiDetailScreenState extends State<PerawiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadisProvider>().loadPerawiDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perawi'),
        centerTitle: true,
      ),
      body: Consumer<HadisProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailPerawi == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final p = provider.detailPerawi!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(p, primary, isDark),
                const SizedBox(height: 20),
                _buildInfoCard('Profil & Kelahiran', [
                  _buildInfoRow('Tanggal/Tempat Lahir', p.birthDatePlace),
                  _buildInfoRow('Wafat', p.deathDatePlace),
                  _buildInfoRow('Tempat Tinggal', p.placesOfStay),
                ], primary),
                const SizedBox(height: 16),
                _buildInfoCard('Keluarga', [
                  _buildInfoRow('Orang Tua', p.parents),
                  _buildInfoRow('Pasangan', p.spouse),
                  _buildInfoRow('Saudara', p.siblings),
                  _buildInfoRow('Anak', p.children),
                ], primary),
                const SizedBox(height: 16),
                _buildInfoCard('Pendidikan & Karya', [
                  _buildInfoRow('Guru', p.teachers),
                  _buildInfoRow('Murid', p.students),
                  _buildInfoRow('Fokus Bidang', p.areaOfInterest),
                  _buildInfoRow('Karya Buku', p.books),
                ], primary),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(dynamic p, Color primary, bool isDark) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: primary.withOpacity(0.1),
              child: Text(
                p.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p.grade,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
            if (p.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: p.tags.split(',').map<Widget>((t) => Chip(
                  label: Text(t.trim(), style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> items, Color primary) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
