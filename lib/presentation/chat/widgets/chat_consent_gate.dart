import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../common/widgets/mascot_hero.dart';

class ChatConsentGate extends StatefulWidget {
  final Widget child;
  const ChatConsentGate({super.key, required this.child});
  @override
  State<ChatConsentGate> createState() => _ChatConsentGateState();
}

class _ChatConsentGateState extends State<ChatConsentGate> {
  bool _acceptedHere = false;
  bool _saving = false;
  String? _error;

  Future<void> _accept() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final response = await sl<ApiClient>().post<dynamic>(
        '/user/accept-ai-disclaimer',
        data: {},
      );
      if (!response.success) {
        throw Exception(response.error ?? 'Persetujuan belum tersimpan');
      }
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
      setState(() => _acceptedHere = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Persetujuan belum berhasil disimpan. Coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accepted =
        _acceptedHere ||
        context.select(
          (AuthBloc bloc) => bloc.state.user?.hasAcceptedAiDisclaimer ?? false,
        );
    if (accepted) return widget.child;
    return Scaffold(
      appBar: AppBar(title: const Text('Sebelum mengobrol')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const MascotHero(
              title: 'Kenali Teman Cerita AI',
              description: 'Baca penjelasan ini sebelum memulai percakapan.',
              pose: 'chat-listen',
            ),
            const SizedBox(height: 20),
            const ListTile(
              leading: Icon(Icons.favorite_outline),
              title: Text('Dukungan emosional awal'),
              subtitle: Text(
                'Teman Cerita AI membantu kamu mengekspresikan perasaan dan melihat sudut pandang baru.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.health_and_safety_outlined),
              title: Text('Bukan pengganti profesional'),
              subtitle: Text(
                'AI tidak memberikan diagnosis atau pengobatan. Hubungi psikolog atau tenaga kesehatan bila membutuhkan bantuan klinis.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.emergency_outlined),
              title: Text('Saat krisis'),
              subtitle: Text(
                'Jika kamu merasa tidak aman, segera hubungi layanan darurat 119 atau orang yang kamu percaya.',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _accept,
              child: Text(
                _saving ? 'Menyimpan...' : 'Saya mengerti dan setuju',
              ),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Kembali ke beranda'),
            ),
          ],
        ),
      ),
    );
  }
}
