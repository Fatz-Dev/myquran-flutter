import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/audio_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Pengaturan'),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionLabel(context, 'Tampilan'),
                _buildThemeSection(context, isDark, primary),
                const SizedBox(height: 20),
                _sectionLabel(context, 'Audio'),
                _buildQariSection(context, isDark, primary),
                const SizedBox(height: 20),
                _sectionLabel(context, 'Tentang'),
                _buildAboutSection(context, isDark),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThemeSection(
      BuildContext context, bool isDark, Color primary) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildRadioTile<ThemeMode>(
                context: context,
                title: 'Mode Gelap',
                subtitle: 'Tema gelap (default)',
                icon: Icons.dark_mode_rounded,
                value: ThemeMode.dark,
                groupValue: theme.themeMode,
                onChanged: (v) => theme.setThemeMode(v!),
                primary: primary,
              ),
              Divider(height: 1, indent: 56),
              _buildRadioTile<ThemeMode>(
                context: context,
                title: 'Mode Terang',
                subtitle: 'Tema terang',
                icon: Icons.light_mode_rounded,
                value: ThemeMode.light,
                groupValue: theme.themeMode,
                onChanged: (v) => theme.setThemeMode(v!),
                primary: primary,
              ),
              Divider(height: 1, indent: 56),
              _buildRadioTile<ThemeMode>(
                context: context,
                title: 'Mengikuti Sistem',
                subtitle: 'Sesuai pengaturan perangkat',
                icon: Icons.settings_brightness_rounded,
                value: ThemeMode.system,
                groupValue: theme.themeMode,
                onChanged: (v) => theme.setThemeMode(v!),
                primary: primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQariSection(
      BuildContext context, bool isDark, Color primary) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: ApiConstants.qariList.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              return Column(
                children: [
                  _buildRadioTile<String>(
                    context: context,
                    title: q['name']!,
                    subtitle: 'Qari ${q['id']}',
                    icon: Icons.mic_rounded,
                    value: q['id']!,
                    groupValue: audio.selectedQariId,
                    onChanged: (v) => audio.setQari(v!),
                    primary: primary,
                  ),
                  if (i < ApiConstants.qariList.length - 1)
                    Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Versi Aplikasi',
            subtitle: '1.0.0',
          ),
          Divider(height: 1, indent: 56),
          _buildInfoTile(
            context,
            icon: Icons.api_rounded,
            title: 'Sumber Data',
            subtitle: 'equran.id, myquran.com, hadeethenc.com',
          ),
          Divider(height: 1, indent: 56),
          _buildInfoTile(
            context,
            icon: Icons.person_rounded,
            title: 'Dibuat Oleh',
            subtitle: 'Fatz-Dev',
            onTap: () async {
              final url = Uri.parse('https://github.com/Fatz-Dev');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    required Color primary,
  }) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: primary,
      secondary: Icon(icon, color: primary, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildInfoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      VoidCallback? onTap}) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Icon(icon, color: primary, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}
