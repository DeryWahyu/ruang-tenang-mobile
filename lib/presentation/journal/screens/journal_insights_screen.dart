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
        title: const Text('Wawasan Jurnal'),
        bottom: const TabBar(
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
          : TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const MascotHero(
                      title: 'Setiap catatan berarti',
                      description:
                          'Lihat ritme menulis dan suasana hati yang terekam.',
                      pose: 'journal',
                    ),
                    const SizedBox(height: 16),
                    _metric('Total jurnal', _analytics?['total_entries']),
                    _metric('Bulan ini', _analytics?['entries_this_month']),
                    _metric('Jumlah kata', _analytics?['total_word_count']),
                    _metric('Rata-rata kata', _analytics?['avg_word_count']),
                    _metric('Runtun menulis', _analytics?['writing_streak']),
                    _metric('Runtun terpanjang', _analytics?['longest_streak']),
                    const SizedBox(height: 16),
                    Text(
                      'Distribusi mood',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...(_analytics?['mood_distribution'] as Map? ?? {}).entries
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.key.toString()),
                            trailing: Text(entry.value.toString()),
                          ),
                        ),
                    Text(
                      'Tag yang sering ditulis',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...(_analytics?['tag_frequency'] as Map? ?? {}).entries.map(
                      (entry) => ListTile(
                        title: Text(entry.key.toString()),
                        trailing: Text(entry.value.toString()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jurnal per bulan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...(_analytics?['entries_by_month'] as List<dynamic>? ?? [])
                        .whereType<Map>()
                        .map(
                          (item) => ListTile(
                            title: Text(item['month']?.toString() ?? ''),
                            trailing: Text(item['count']?.toString() ?? '0'),
                          ),
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'Refleksi pekan ini',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_weeklySummary == null)
                      const ListTile(
                        title: Text('Ringkasan mingguan belum tersedia'),
                      )
                    else ...[
                      _metric(
                        'Jurnal pekan ini',
                        _weeklySummary?['entries_count'],
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _weeklySummary?['summary']?.toString() ?? '',
                          ),
                        ),
                      ),
                      ...(_weeklySummary?['key_themes'] as List<dynamic>? ?? [])
                          .map((theme) => Chip(label: Text(theme.toString()))),
                      ...(_weeklySummary?['suggestions'] as List<dynamic>? ??
                              [])
                          .map(
                            (suggestion) => ListTile(
                              leading: const Icon(
                                Icons.lightbulb_outline_rounded,
                              ),
                              title: Text(suggestion.toString()),
                            ),
                          ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => _export('txt'),
                            child: const Text('Ekspor TXT'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => _export('pdf'),
                            child: const Text('Ekspor PDF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const MascotHero(
                      title: 'Privasi di tanganmu',
                      description:
                          'Atur akses AI dan tinjau riwayat penggunaan jurnal.',
                      pose: 'secure',
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Izinkan akses AI'),
                      subtitle: const Text(
                        'AI dapat memakai jurnal yang kamu pilih sebagai konteks.',
                      ),
                      value: _settings?['allow_ai_access'] == true,
                      onChanged: _saving
                          ? null
                          : (value) => _update('allow_ai_access', value),
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Bagikan jurnal baru ke AI secara default',
                      ),
                      value: _settings?['default_share_with_ai'] == true,
                      onChanged: _saving
                          ? null
                          : (value) => _update('default_share_with_ai', value),
                    ),
                    ListTile(
                      title: const Text('Jangkauan konteks'),
                      subtitle: Text(
                        '${_settings?['ai_context_days'] ?? 0} hari',
                      ),
                      trailing: DropdownButton<int>(
                        value:
                            [
                              7,
                              14,
                              30,
                              90,
                            ].contains(_settings?['ai_context_days'])
                            ? _settings!['ai_context_days'] as int
                            : 30,
                        items: [7, 14, 30, 90]
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text('$day hari'),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  _update('ai_context_days', value);
                                }
                              },
                      ),
                    ),
                    ListTile(
                      title: const Text('Maksimum jurnal untuk konteks'),
                      trailing: DropdownButton<int>(
                        value:
                            [
                              3,
                              5,
                              10,
                              20,
                            ].contains(_settings?['ai_context_max_entries'])
                            ? _settings!['ai_context_max_entries'] as int
                            : 5,
                        items: [3, 5, 10, 20]
                            .map(
                              (count) => DropdownMenuItem(
                                value: count,
                                child: Text('$count jurnal'),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  _update('ai_context_max_entries', value);
                                }
                              },
                      ),
                    ),
                    _metric(
                      'Jurnal dibagikan ke AI',
                      _settings?['shared_with_ai_count'],
                    ),
                    _metric(
                      'Jurnal dalam konteks AI',
                      _context?['entries_count'],
                    ),
                    if (_context?['summary']?.toString().isNotEmpty == true)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_context!['summary'].toString()),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Riwayat akses AI',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_logs.isEmpty)
                      const ListTile(title: Text('Belum ada riwayat akses')),
                    ..._logs.whereType<Map>().map(
                      (item) => ListTile(
                        title: Text(
                          item['journal_title']?.toString() ?? 'Jurnal',
                        ),
                        subtitle: Text(item['accessed_at']?.toString() ?? ''),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    ),
  );

  Widget _metric(String label, dynamic value) => Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        '${value ?? 0}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
