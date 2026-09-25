import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../common/widgets/mascot_hero.dart';

class JournalInsightsScreen extends StatefulWidget {
  const JournalInsightsScreen({super.key});
  @override
  State<JournalInsightsScreen> createState() => _JournalInsightsScreenState();
}

class _JournalInsightsScreenState extends State<JournalInsightsScreen> {
  final JournalRepository _journals = sl<JournalRepository>();
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _context;
  Map<String, dynamic>? _weeklySummary;
  List<dynamic> _logs = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _journals.getAnalytics(),
        _journals.getSettings(),
        _journals.getAiContext(),
      ]);
      final logs = await _journals.getAiAccessLogs();
      Map<String, dynamic>? weeklySummary;
      try {
        weeklySummary = await _journals.getWeeklySummary();
      } catch (_) {
        // Weekly AI summary may be unavailable while other analytics are ready.
      }
      if (!mounted) return;
      setState(() {
        _analytics = results[0];
        _settings = results[1];
        _context = results[2];
        _weeklySummary = weeklySummary;
        _logs = logs;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Data jurnal belum berhasil dimuat.';
        });
      }
    }
  }

  Future<void> _update(String key, dynamic value) async {
    if (_settings == null) return;
    setState(() => _saving = true);
    try {
      final settings = await _journals.updateSettings(key, value);
      if (mounted) setState(() => _settings = settings);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan belum berhasil disimpan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export(String format) async {
    setState(() => _saving = true);
    try {
      final data = await _journals.exportJournals(format);
      final filename = (data['filename'] as String? ?? 'jurnal.$format')
          .replaceAll(RegExp(r'[/\\]'), '_');
      final file = File('${(await getTemporaryDirectory()).path}/$filename');
      if (format == 'pdf') {
        await file.writeAsBytes(base64Decode(data['content'] as String));
      } else {
        await file.writeAsString(data['content'] as String);
      }
      await Share.shareXFiles([
        XFile(
          file.path,
          mimeType: format == 'pdf' ? 'application/pdf' : 'text/plain',
        ),
      ], subject: 'Ekspor jurnal');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jurnal belum berhasil diekspor.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wawasan Jurnal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const TabBar(
          isScrollable: false,
          tabs: [
            Tab(text: 'Analitik'),
            Tab(text: 'Privasi'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: TextButton(
                onPressed: _load,
                child: Text('$_error Coba lagi'),
              ),
            )
          : TabBarView(children: [_analyticsTab(), _privacyTab()]),
    ),
  );

  Widget _analyticsTab() {
    final metrics = <(String, dynamic, IconData, Color, Color)>[
      (
        'Total jurnal',
        _analytics?['total_entries'],
        Icons.auto_stories_rounded,
        const Color(0xFFEF4444),
        const Color(0xFFFFF0F0),
      ),
      (
        'Bulan ini',
        _analytics?['entries_this_month'],
        Icons.calendar_month_rounded,
        const Color(0xFF3B82F6),
        const Color(0xFFEFF6FF),
      ),
      (
        'Jumlah kata',
        _analytics?['total_word_count'],
        Icons.notes_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFFF5F3FF),
      ),
      (
        'Rata-rata kata',
        _analytics?['avg_word_count'],
        Icons.short_text_rounded,
        const Color(0xFF0F766E),
        const Color(0xFFF0FDFA),
      ),
      (
        'Runtun menulis',
        _analytics?['writing_streak'],
        Icons.local_fire_department_rounded,
        const Color(0xFFF97316),
        const Color(0xFFFFF7ED),
      ),
      (
        'Runtun terpanjang',
        _analytics?['longest_streak'],
        Icons.emoji_events_rounded,
        const Color(0xFFCA8A04),
        const Color(0xFFFEFCE8),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        const MascotHero(
          title: 'Setiap catatan berarti',
          description: 'Lihat ritme menulis dan suasana hati yang terekam.',
          pose: 'journal',
          eyebrow: 'PERKEMBANGAN JURNAL',
        ),
        const SizedBox(height: 22),
        _sectionHeading(
          'Perjalanan menulismu',
          'Ringkasan kebiasaan jurnal yang sudah kamu bangun.',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _metricCard(
              metric.$1,
              metric.$2,
              metric.$3,
              metric.$4,
              metric.$5,
            );
          },
        ),
        const SizedBox(height: 24),
        _sectionHeading(
          'Suasana dan tema',
          'Pola yang paling sering muncul di catatanmu.',
        ),
        const SizedBox(height: 12),
        _moodDistributionCard(),
        const SizedBox(height: 12),
        _tagFrequencyCard(),
        const SizedBox(height: 24),
        _sectionHeading(
          'Ritme dari waktu ke waktu',
          'Jumlah jurnal yang kamu tulis setiap bulan.',
        ),
        const SizedBox(height: 12),
        _monthlyActivityCard(),
        const SizedBox(height: 24),
        _weeklyReflectionCard(),
        const SizedBox(height: 14),
        _exportCard(),
      ],
    );
  }

  Widget _privacyTab() {
    final allowAi = _settings?['allow_ai_access'] == true;
    final defaultShare = _settings?['default_share_with_ai'] == true;
    final days = _choiceValue(_settings?['ai_context_days'], const [
      7,
      14,
      30,
      90,
    ], 30);
    final maxEntries = _choiceValue(
      _settings?['ai_context_max_entries'],
      const [3, 5, 10, 20],
      5,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        const MascotHero(
          title: 'Privasi di tanganmu',
          description:
              'Kamu yang menentukan kapan jurnal boleh menjadi konteks AI.',
          pose: 'secure',
          eyebrow: 'KONTROL PRIVASI',
        ),
        const SizedBox(height: 22),
        _sectionHeading(
          'Penggunaan AI',
          'Kelola izin untuk jurnal dan percakapan AI.',
        ),
        const SizedBox(height: 12),
        _surface(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _privacySwitchRow(
                icon: Icons.auto_awesome_rounded,
                title: 'Izinkan akses AI',
                description:
                    'AI dapat memakai jurnal yang kamu pilih sebagai konteks.',
                value: allowAi,
                onChanged: _saving
                    ? null
                    : (value) => _update('allow_ai_access', value),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              _privacySwitchRow(
                icon: Icons.share_rounded,
                title: 'Bagikan jurnal baru otomatis',
                description: 'Jurnal baru ikut dibagikan sebagai konteks AI.',
                value: defaultShare,
                onChanged: _saving
                    ? null
                    : (value) => _update('default_share_with_ai', value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeading(
          'Batas konteks',
          'Atur seberapa banyak riwayat yang boleh digunakan.',
        ),
        const SizedBox(height: 12),
        _surface(
          padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
          child: Column(
            children: [
              _contextChoice(
                title: 'Jangkauan waktu',
                subtitle: 'Jurnal dari beberapa hari terakhir',
                value: days,
                options: const [7, 14, 30, 90],
                suffix: 'hari',
                onChanged: (value) => _update('ai_context_days', value),
              ),
              const Divider(height: 1),
              _contextChoice(
                title: 'Jumlah jurnal',
                subtitle: 'Batas catatan yang masuk ke konteks',
                value: maxEntries,
                options: const [3, 5, 10, 20],
                suffix: 'jurnal',
                onChanged: (value) => _update('ai_context_max_entries', value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeading(
          'Ringkasan penggunaan',
          'Jurnal yang sudah dibagikan dan digunakan AI.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'Dibagikan ke AI',
                _settings?['shared_with_ai_count'],
                Icons.ios_share_rounded,
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'Dalam konteks AI',
                _context?['entries_count'],
                Icons.psychology_alt_rounded,
                const Color(0xFF8B5CF6),
                const Color(0xFFF5F3FF),
              ),
            ),
          ],
        ),
        if (_context?['summary']?.toString().trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _surface(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconBadge(
                  Icons.summarize_rounded,
                  const Color(0xFF64748B),
                  const Color(0xFFF1F5F9),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan konteks AI',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _context!['summary'].toString(),
                        style: const TextStyle(
                          height: 1.45,
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        _accessLogsCard(),
      ],
    );
  }

  Widget _sectionHeading(String title, String description) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF182230),
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        description,
        style: const TextStyle(
          color: Color(0xFF7B8494),
          fontSize: 12,
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _metricCard(
    String label,
    dynamic value,
    IconData icon,
    Color tone,
    Color tint,
  ) => _surface(
    padding: const EdgeInsets.all(13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _iconBadge(icon, tone, tint, size: 32, iconSize: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF687386),
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2, top: 8),
          child: Text(
            _numberText(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF182230),
              fontSize: 23,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _moodDistributionCard() {
    final items =
        _mapValue(_analytics?['mood_distribution']).entries
            .map((entry) => (entry.key, _integer(entry.value)))
            .where((entry) => entry.$2 > 0)
            .toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));
    final maxCount = items.isEmpty ? 1 : items.first.$2;

    return _surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(
            Icons.mood_rounded,
            'Distribusi mood',
            'Suasana hati yang kamu catat',
            const Color(0xFFEC4899),
            const Color(0xFFFDF2F8),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _emptyHint('Tambahkan mood pada jurnal untuk melihat polanya.')
          else
            ...items.map((entry) {
              final tone = _moodTone(entry.$1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 31,
                      child: Text(
                        _moodEmoji(entry.$1),
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _moodLabel(entry.$1),
                                  style: const TextStyle(
                                    color: Color(0xFF30394A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.$2}',
                                style: const TextStyle(
                                  color: Color(0xFF687386),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: entry.$2 / maxCount,
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF1F3F6),
                              color: tone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _tagFrequencyCard() {
    final tags =
        _mapValue(
            _analytics?['tag_frequency'],
          ).entries.map((entry) => (entry.key, _integer(entry.value))).toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));

    return _surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(
            Icons.sell_rounded,
            'Tag yang sering ditulis',
            'Tema yang paling banyak kamu tandai',
            const Color(0xFF0F766E),
            const Color(0xFFF0FDFA),
          ),
          const SizedBox(height: 14),
          if (tags.isEmpty)
            _emptyHint('Tag jurnalmu akan muncul di sini.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.take(12).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9ECF1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#${tag.$1.replaceFirst(RegExp(r'^#'), '')}',
                        style: const TextStyle(
                          color: Color(0xFF455064),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${tag.$2}',
                        style: const TextStyle(
                          color: Color(0xFF9098A6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _monthlyActivityCard() {
    final raw = _analytics?['entries_by_month'];
    final entries = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (item) =>
                    (item['month']?.toString() ?? '', _integer(item['count'])),
              )
              .toList()
        : <(String, int)>[];
    final maxCount = entries.fold<int>(
      0,
      (maximum, item) => item.$2 > maximum ? item.$2 : maximum,
    );

    return _surface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(
            Icons.bar_chart_rounded,
            'Jurnal per bulan',
            'Konsistensi catatanmu dari waktu ke waktu',
            const Color(0xFF3B82F6),
            const Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            _emptyHint('Belum ada catatan bulanan untuk ditampilkan.')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.map((entry) {
                  final barHeight = maxCount == 0
                      ? 5.0
                      : (entry.$2 / maxCount * 56).clamp(5.0, 56.0).toDouble();
                  return SizedBox(
                    width: 48,
                    height: 104,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.$2}',
                            style: const TextStyle(
                              color: Color(0xFF7B8494),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 58,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 25,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF87171),
                                      Color(0xFFEF4444),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _monthLabel(entry.$1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF7B8494),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _weeklyReflectionCard() {
    final summary = _weeklySummary;
    final themes = summary?['key_themes'] is List
        ? (summary!['key_themes'] as List)
              .map((item) => item.toString())
              .toList()
        : <String>[];
    final suggestions = summary?['suggestions'] is List
        ? (summary!['suggestions'] as List)
              .map((item) => item.toString())
              .toList()
        : <String>[];

    return _surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(
            Icons.auto_awesome_rounded,
            'Refleksi pekan ini',
            'Sekilas tentang perjalananmu minggu ini',
            const Color(0xFFB45309),
            const Color(0xFFFFF7ED),
          ),
          const SizedBox(height: 14),
          if (summary == null)
            _emptyHint('Ringkasan mingguan belum tersedia.')
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_numberText(summary['entries_count'])} jurnal minggu ini',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary['summary']?.toString().trim().isNotEmpty == true
                        ? summary['summary'].toString()
                        : 'Terus luangkan waktu untuk memahami perasaanmu.',
                    style: const TextStyle(
                      color: Color(0xFF414B5B),
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (themes.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Tema minggu ini',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: themes
                    .map(
                      (theme) => _smallChip(
                        theme,
                        const Color(0xFFFFF7ED),
                        const Color(0xFF9A3412),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 15),
              ...suggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 17,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            color: Color(0xFF556071),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _exportCard() => _surface(
    padding: const EdgeInsets.all(16),
    color: const Color(0xFFFFF8F8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cardHeading(
          Icons.file_download_outlined,
          'Simpan salinan jurnal',
          'Ekspor catatanmu untuk disimpan secara pribadi.',
          const Color(0xFFEF4444),
          const Color(0xFFFFEEEE),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saving ? null : () => _export('txt'),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Ekspor TXT'),
                style: _exportButtonStyle(),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saving ? null : () => _export('pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Ekspor PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  ButtonStyle _exportButtonStyle() => OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF394456),
    side: const BorderSide(color: Color(0xFFE3E7ED)),
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  );

  Widget _privacySwitchRow({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _iconBadge(
        icon,
        value ? const Color(0xFFEF4444) : const Color(0xFF64748B),
        value ? const Color(0xFFFFEEEE) : const Color(0xFFF1F5F9),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF7B8494),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 7),
      Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFFEF4444),
      ),
    ],
  );

  Widget _contextChoice({
    required String title,
    required String subtitle,
    required int value,
    required List<int> options,
    required String suffix,
    required ValueChanged<int> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8992A0), fontSize: 11),
              ),
            ],
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isDense: true,
            borderRadius: BorderRadius.circular(14),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text('$option $suffix'),
                  ),
                )
                .toList(),
            onChanged: _saving
                ? null
                : (next) {
                    if (next != null) onChanged(next);
                  },
          ),
        ),
      ],
    ),
  );

  Widget _accessLogsCard() => _surface(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconBadge(
              Icons.history_rounded,
              const Color(0xFF8B5CF6),
              const Color(0xFFF5F3FF),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat akses AI',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Jurnal yang pernah digunakan sebagai konteks',
                    style: TextStyle(color: Color(0xFF8992A0), fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_logs.length} akses',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_logs.isEmpty)
          _emptyHint('Belum ada jurnal yang digunakan sebagai konteks.')
        else
          ..._logs
              .whereType<Map>()
              .take(12)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFC),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFEEF0F4)),
                    ),
                    child: Row(
                      children: [
                        _iconBadge(
                          Icons.menu_book_rounded,
                          const Color(0xFF8B5CF6),
                          Colors.white,
                          size: 34,
                          iconSize: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['journal_title']?.toString() ?? 'Jurnal',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF30394A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatAccessDate(
                                  item['accessed_at']?.toString() ?? '',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF8992A0),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    ),
  );

  Widget _cardHeading(
    IconData icon,
    String title,
    String subtitle,
    Color tone,
    Color tint,
  ) => Row(
    children: [
      _iconBadge(icon, tone, tint, size: 38, iconSize: 19),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF8992A0), fontSize: 11),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _iconBadge(
    IconData icon,
    Color tone,
    Color tint, {
    double size = 38,
    double iconSize = 19,
  }) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(size * 0.34),
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: iconSize, color: tone),
  );

  Widget _surface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color color = Colors.white,
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE6E9EF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );

  Widget _emptyHint(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FB),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: Color(0xFF8992A0),
        fontSize: 12,
        height: 1.4,
      ),
    ),
  );

  Widget _smallChip(String text, Color background, Color foreground) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Map<String, dynamic> _mapValue(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  int _integer(dynamic value) =>
      value is num ? value.round() : int.tryParse(value?.toString() ?? '') ?? 0;

  String _numberText(dynamic value) {
    final number = _integer(value);
    final grouped = number.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return number < 0 ? '-$grouped' : grouped;
  }

  int _choiceValue(dynamic value, List<int> options, int fallback) {
    final parsed = _integer(value);
    return options.contains(parsed) ? parsed : fallback;
  }

  String _moodLabel(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'bahagia':
      case 'senang':
        return 'Bahagia';
      case 'neutral':
      case 'netral':
        return 'Netral';
      case 'angry':
      case 'marah':
        return 'Marah';
      case 'disappointed':
      case 'kecewa':
        return 'Kecewa';
      case 'sad':
      case 'sedih':
        return 'Sedih';
      case 'crying':
      case 'menangis':
        return 'Sedih sekali';
      default:
        return mood.replaceAll('_', ' ');
    }
  }

  String _moodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'bahagia':
      case 'senang':
        return '😊';
      case 'neutral':
      case 'netral':
        return '😐';
      case 'angry':
      case 'marah':
        return '😠';
      case 'disappointed':
      case 'kecewa':
        return '😕';
      case 'sad':
      case 'sedih':
        return '😔';
      case 'crying':
      case 'menangis':
        return '😢';
      default:
        return '🙂';
    }
  }

  Color _moodTone(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'bahagia':
      case 'senang':
        return const Color(0xFF22C55E);
      case 'neutral':
      case 'netral':
        return const Color(0xFFEAB308);
      case 'angry':
      case 'marah':
        return const Color(0xFFEF4444);
      case 'disappointed':
      case 'kecewa':
        return const Color(0xFFF97316);
      case 'sad':
      case 'sedih':
        return const Color(0xFF3B82F6);
      case 'crying':
      case 'menangis':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _monthLabel(String month) {
    final parts = month.split(RegExp(r'[-/]'));
    final monthNumber = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (monthNumber != null && monthNumber >= 1 && monthNumber <= 12) {
      const names = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return names[monthNumber - 1];
    }
    return month.length > 3 ? month.substring(0, 3) : month;
  }

  String _formatAccessDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final date = parsed.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} • $hour:$minute';
  }
}
