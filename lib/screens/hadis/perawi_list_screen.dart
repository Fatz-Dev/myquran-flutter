import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hadis_provider.dart';
import 'package:go_router/go_router.dart';

class PerawiListScreen extends StatefulWidget {
  const PerawiListScreen({super.key});

  @override
  State<PerawiListScreen> createState() => _PerawiListScreenState();
}

class _PerawiListScreenState extends State<PerawiListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HadisProvider>().loadPerawiBrowse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Perawi'),
        centerTitle: true,
      ),
      body: Consumer<HadisProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.perawiList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.perawiList.isEmpty) {
            return const Center(child: Text('Data perawi tidak tersedia'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.perawiList.length,
            itemBuilder: (context, index) {
              final p = provider.perawiList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      p.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    p.grade,
                    style: TextStyle(fontSize: 12, color: primary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => context.push('/hadis/perawi/${p.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
