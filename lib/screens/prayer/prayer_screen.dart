import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_helper.dart';
import '../../providers/prayer_provider.dart';
import '../../data/models/prayer_model.dart';
import '../../widgets/common/error_state_widget.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prayer = context.read<PrayerProvider>();
      prayer.loadSchedule();
    });
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
      body: Consumer<PrayerProvider>(
        builder: (context, prayer, _) {
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                title: const Text('Jadwal Shalat'),
                actions: [
                  TextButton.icon(
                    onPressed: () => _showLocationPicker(context, prayer),
                    icon: Icon(Icons.location_on_rounded,
                        size: 16, color: primary),
                    label: Text(
                      prayer.selectedCityName.isNotEmpty
                          ? prayer.selectedCityName
                          : 'Pilih Kota',
                      style: TextStyle(color: primary, fontSize: 12),
                    ),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: primary,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.bodySmall?.color,
                  indicatorColor: primary,
                  tabs: const [
                    Tab(text: 'Hari Ini'),
                    Tab(text: 'Bulanan'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(context, prayer, isDark, primary),
                _buildMonthlyTab(context, prayer, isDark, primary),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyTab(BuildContext context, PrayerProvider prayer, bool isDark,
      Color primary) {
    if (prayer.isLoadingSchedule) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prayer.error != null) {
      return ErrorStateWidget(
        message: prayer.error!,
        onRetry: () => prayer.loadSchedule(),
      );
    }
    if (prayer.todaySchedule == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded,
                size: 64, color: primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Pilih kota terlebih dahulu'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showLocationPicker(context, prayer),
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Pilih Lokasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final today = prayer.todaySchedule!;
    final nextPrayer = today.getNextPrayer();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateCard(context, isDark, primary, prayer),
          const SizedBox(height: 16),
          if (nextPrayer != null) _buildNextPrayerCard(context, today, nextPrayer, isDark),
          const SizedBox(height: 16),
          _buildPrayerTimesGrid(context, today, nextPrayer, isDark, primary),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, bool isDark, Color primary,
      PrayerProvider prayer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateHelper.getDayName(),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13),
              ),
              Text(
                DateHelper.todayFormatted(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                DateHelper.getHijriDate(),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white70, size: 16),
              Text(
                prayer.selectedCityName.isNotEmpty
                    ? prayer.selectedCityName
                    : 'Batam',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                prayer.selectedProvinceName.isNotEmpty
                    ? prayer.selectedProvinceName
                    : 'Kepulauan Riau',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(BuildContext context, PrayerTimeModel today,
      String nextPrayer, bool isDark) {
    final times = today.toTimeMap();
    final nextTime = times[nextPrayer] ?? '';
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i).asBroadcastStream(),
      builder: (context, _) {
        final countdown = DateHelper.getCountdown(nextTime);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0C12C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFFF0C12C).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Color(0xFFF0C12C), size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shalat Berikutnya',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFF0C12C)),
                    ),
                    Text(
                      nextPrayer,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateHelper.formatTime(nextTime),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                countdown,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF0C12C),
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimesGrid(BuildContext context, PrayerTimeModel today,
      String? nextPrayer, bool isDark, Color primary) {
    final times = [
      {'name': 'Imsak', 'time': today.imsak, 'icon': Icons.bedtime_rounded},
      {'name': 'Subuh', 'time': today.subuh, 'icon': Icons.wb_twilight_rounded},
      {'name': 'Terbit', 'time': today.terbit, 'icon': Icons.wb_sunny_rounded},
      {'name': 'Dhuha', 'time': today.dhuha, 'icon': Icons.light_mode_rounded},
      {'name': 'Dzuhur', 'time': today.dzuhur, 'icon': Icons.sunny},
      {'name': 'Ashar', 'time': today.ashar, 'icon': Icons.wb_cloudy_rounded},
      {'name': 'Maghrib', 'time': today.maghrib, 'icon': Icons.nights_stay_rounded},
      {'name': 'Isya', 'time': today.isya, 'icon': Icons.dark_mode_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: times.length,
      itemBuilder: (context, i) {
        final item = times[i];
        final isNext = item['name'] == nextPrayer;
        final cardColor = isNext
            ? const Color(0xFFF0C12C).withOpacity(0.12)
            : (isDark ? const Color(0xFF1C1B1B) : Colors.white);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: isNext
                ? Border.all(
                    color: const Color(0xFFF0C12C).withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                color: isNext ? const Color(0xFFF0C12C) : primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                        color: isNext ? const Color(0xFFF0C12C) : null,
                      ),
                    ),
                    Text(
                      DateHelper.formatTime(item['time'] as String),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNext ? const Color(0xFFF0C12C) : null,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyTab(BuildContext context, PrayerProvider prayer, bool isDark,
      Color primary) {
    if (prayer.isLoadingSchedule) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prayer.monthlySchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 64, color: primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Pilih kota untuk melihat jadwal'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showLocationPicker(context, prayer),
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Pilih Lokasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final today = DateTime.now().day;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prayer.monthlySchedule.length,
      itemBuilder: (context, index) {
        final p = prayer.monthlySchedule[index];
        int dayNum = 0;
        if (p.tanggal.contains('/')) {
          final datePart = p.tanggal.split(' ').last;
          dayNum = int.tryParse(datePart.split('/').first) ?? 0;
        } else if (p.tanggal.contains('-')) {
          final parts = p.tanggal.split('-');
          dayNum = parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0;
        }
        final isToday = dayNum == today;
        final cardColor = isToday
            ? primary.withOpacity(0.1)
            : (isDark ? const Color(0xFF1C1B1B) : Colors.white);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: primary.withOpacity(0.4))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? primary : primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayNum.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isToday ? Colors.white : primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _timeChip('Subuh', p.subuh, isDark),
                    _timeChip('Dzuhur', p.dzuhur, isDark),
                    _timeChip('Ashar', p.ashar, isDark),
                    _timeChip('Maghrib', p.maghrib, isDark),
                    _timeChip('Isya', p.isya, isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeChip(String label, String time, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey[400] : Colors.grey[600])),
        Text(
          DateHelper.formatTime(time),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showLocationPicker(BuildContext context, PrayerProvider prayer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationPickerSheet(prayer: prayer),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final PrayerProvider prayer;
  const _LocationPickerSheet({required this.prayer});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  bool _step2 = false;

  @override
  void initState() {
    super.initState();
    widget.prayer.loadProvinces();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1B1B) : Colors.white;
    final primary = Theme.of(context).colorScheme.primary;

    return Consumer<PrayerProvider>(
      builder: (context, prayer, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    if (_step2)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => setState(() => _step2 = false),
                      ),
                    Expanded(
                      child: Text(
                        _step2 ? 'Cari Kota' : 'Pilih Provinsi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_step2)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(Icons.my_location_rounded, color: primary),
                  ),
                  title: const Text('Otomatis dari GPS'),
                  subtitle: const Text('Gunakan lokasi saat ini'),
                  onTap: () async {
                    await prayer.updateLocationFromGPS();
                    if (mounted) Navigator.pop(context);
                  },
                ),
              if (!_step2) const Divider(),
              if (_step2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    onChanged: (v) => prayer.searchCity(v),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kota...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _step2
                    ? _buildCityList(prayer, primary)
                    : _buildProvinceList(prayer, primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProvinceList(PrayerProvider prayer, Color primary) {
    if (prayer.isLoadingProvinces) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: prayer.provinces.length,
      itemBuilder: (context, i) {
        final p = prayer.provinces[i];
        return ListTile(
          title: Text(p.name),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            await prayer.selectProvince(p);
            setState(() => _step2 = true);
          },
        );
      },
    );
  }

  Widget _buildCityList(PrayerProvider prayer, Color primary) {
    if (prayer.isLoadingCities) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: prayer.cities.length,
      itemBuilder: (context, i) {
        final c = prayer.cities[i];
        return ListTile(
          title: Text(c.name),
          onTap: () async {
            await prayer.selectCity(c);
            if (mounted) Navigator.pop(context);
          },
        );
      },
    );
  }
}
