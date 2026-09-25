import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ChatConsentGate extends StatefulWidget {
  final Widget child;
  const ChatConsentGate({super.key, required this.child});

  @override
  State<ChatConsentGate> createState() => _ChatConsentGateState();
}

class _ChatConsentGateState extends State<ChatConsentGate> {
  bool _acceptedHere = false;
  bool _dialogScheduled = false;
  bool _saving = false;
  String? _error;

  Future<void> _accept(
    BuildContext dialogContext,
    StateSetter updateDialog,
  ) async {
    updateDialog(() {
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
      if (!mounted || !dialogContext.mounted) return;
      context.read<AuthBloc>().add(const AuthProfileRefreshRequested());
      setState(() => _acceptedHere = true);
      Navigator.of(dialogContext, rootNavigator: true).pop(true);
    } catch (_) {
      if (mounted && dialogContext.mounted) {
        updateDialog(
          () => _error = 'Persetujuan belum berhasil disimpan. Coba lagi.',
        );
      }
    } finally {
      if (mounted && dialogContext.mounted) {
        updateDialog(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accepted =
        _acceptedHere ||
        context.select(
          (AuthBloc bloc) => bloc.state.user?.hasAcceptedAiDisclaimer ?? false,
        );
    if (!accepted && !_dialogScheduled) {
      _dialogScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showConsentDialog();
      });
    }
    return widget.child;
  }

  Future<void> _showConsentDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 22,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 440,
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.foreground.withValues(alpha: 0.14),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: StatefulBuilder(
                builder: (dialogContext, updateDialog) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _consentHero(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ConsentSectionTitle(),
                            const SizedBox(height: 11),
                            const _ConsentInfoCard(
                              icon: Icons.favorite_rounded,
                              title: 'Dukungan emosional awal',
                              description:
                                  'Teman Cerita AI membantumu mengekspresikan perasaan dan melihat sudut pandang baru.',
                              color: Color(0xFFE45158),
                              tint: Color(0xFFFFF1F2),
                            ),
                            const SizedBox(height: 9),
                            const _ConsentInfoCard(
                              icon: Icons.health_and_safety_rounded,
                              title: 'Bukan pengganti profesional',
                              description:
                                  'AI tidak memberi diagnosis atau pengobatan. Hubungi tenaga kesehatan bila membutuhkan bantuan klinis.',
                              color: Color(0xFF2563A6),
                              tint: Color(0xFFEFF6FF),
                            ),
                            const SizedBox(height: 9),
                            const _CrisisSupportCard(),
                            if (_error != null) ...[
                              const SizedBox(height: 11),
                              _ErrorNotice(message: _error!),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _saving
                                  ? null
                                  : () => _accept(dialogContext, updateDialog),
                              icon: _saving
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 19,
                                    ),
                              label: Text(
                                _saving
                                    ? 'Menyimpan persetujuan…'
                                    : 'Saya mengerti dan setuju',
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () {
                                    Navigator.of(
                                      dialogContext,
                                      rootNavigator: true,
                                    ).pop(false);
                                    context.go('/chat');
                                  },
                            child: const Text('Kembali ke daftar obrolan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _consentHero() => SizedBox(
    height: 156,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 19, 125, 17),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE7E7), Color(0xFFFFF3E8)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RUANG AMAN UNTUK BERCERITA',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.45,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Kenali Teman Cerita AI',
                style: TextStyle(
                  color: AppColors.foreground,
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Dukungan awal untuk memahami perasaanmu.',
                style: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -4,
          bottom: -10,
          width: 142,
          height: 170,
          child: Image.asset(
            'assets/images/mascot/chat-listen.webp',
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
        ),
      ],
    ),
  );
}

class _ConsentSectionTitle extends StatelessWidget {
  const _ConsentSectionTitle();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Sebelum kita mulai',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
      SizedBox(height: 3),
      Text(
        'Tiga hal penting untuk kamu ketahui.',
        style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
      ),
    ],
  );
}

class _ConsentInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color tint;

  const _ConsentInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.84)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CrisisSupportCard extends StatelessWidget {
  const _CrisisSupportCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xFFFED7AA)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDD5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Color(0xFFC2410C),
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saat kamu merasa tidak aman',
                style: TextStyle(
                  color: Color(0xFF7C2D12),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Segera cari bantuan langsung dari layanan darurat atau orang yang kamu percaya.',
                style: TextStyle(
                  color: Color(0xFF9A3412),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 9),
              Row(
                children: [
                  Icon(Icons.call_rounded, color: Color(0xFFC2410C), size: 15),
                  SizedBox(width: 5),
                  Text(
                    'Layanan darurat 119',
                    style: TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ErrorNotice extends StatelessWidget {
  final String message;
  const _ErrorNotice({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.destructive,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.red700,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}
