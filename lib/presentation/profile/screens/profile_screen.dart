import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/media_url.dart';
import '../../common/widgets/app_avatar.dart';
import '../../common/widgets/app_alert_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            children: [
              _buildIdentityCard(
                avatar: user.avatar,
                name: user.name,
                email: user.email,
              ),
              const SizedBox(height: 26),
              _buildSectionTitle('Berlangganan'),
              _buildPremiumCard(context),
              const SizedBox(height: 26),
              _buildSectionTitle('Pengaturan Akun'),
              _menuGroup(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    subtitle: 'Perbarui foto dan informasi dirimu',
                    onTap: () => context.push('/profile/edit'),
                    color: const Color(0xFF0F766E),
                    showDivider: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    subtitle: 'Jaga keamanan akunmu',
                    onTap: () => context.push('/profile/password'),
                    color: const Color(0xFF6366F1),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              _buildSectionTitle('Bantuan & Informasi'),
              _menuGroup(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi dan informasi Ruang Tenang',
                    onTap: () => _showAbout(context),
                    color: const Color(0xFF0F766E),
                    showDivider: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Informasi tentang pengelolaan data',
                    onTap: () => _showPrivacy(context),
                    color: const Color(0xFF6366F1),
                    showDivider: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan',
                    subtitle: 'Pusat bantuan dan dukungan',
                    onTap: () => _showHelp(context),
                    color: AppColors.primary,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Keluar dari akun',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.destructive,
                    backgroundColor: AppColors.red50,
                    side: BorderSide(
                      color: AppColors.destructive.withValues(alpha: 0.16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIdentityCard({
    required String? avatar,
    required String name,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: resolveMediaUrl(avatar),
            name: name,
            size: 64,
            backgroundColor: AppColors.red50,
            showBorder: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    const premiumInk = Color(0xFF9A5B08);

    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFDF7), Color(0xFFFFF5D9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF4D67A)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.09),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push('/billing/premium'),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 112, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8A3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: premiumInk,
                                size: 13,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'PAKET PREMIUM',
                                style: TextStyle(
                                  color: premiumInk,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Jelajahi Paket Premium',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.foreground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 23,
                              height: 23,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE8A3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: premiumInk,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Dukungan ekstra untuk perjalananmu',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 8,
            width: 74,
            height: 74,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFBBF24).withValues(alpha: 0.28),
                      const Color(0xFFFBBF24).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -13,
            width: 112,
            height: 140,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/mascot/celebrate.webp',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGroup({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      boxShadow: [
        BoxShadow(
          color: AppColors.foreground.withValues(alpha: 0.025),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ProfileInfoDialog(
        eyebrow: 'TENTANG APLIKASI',
        title: 'Ruang Tenang',
        description:
            'Ruang aman untuk merawat kesehatan mental dan ketenangan pikiranmu.',
        mascot: 'celebrate',
        icon: Icons.spa_rounded,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFDE7D1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/logo.webp'),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ruang Tenang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Teman untuk langkah kecilmu.',
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '© 2026 Ruang Tenang',
              style: TextStyle(color: AppColors.gray600, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                showLicensePage(
                  context: context,
                  applicationName: 'Ruang Tenang',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 Ruang Tenang',
                  applicationIcon: Image.asset(
                    'assets/images/logo.webp',
                    width: 48,
                    height: 48,
                  ),
                );
              });
            },
            icon: const Icon(Icons.description_outlined, size: 17),
            label: const Text('Lihat lisensi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: _dialogPrimaryButtonStyle,
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ProfileInfoDialog(
        eyebrow: 'KEAMANAN DATA',
        title: 'Privasi kamu adalah prioritas',
        description:
            'Kami menjelaskan data apa yang digunakan dan bagaimana kamu tetap punya kendali.',
        mascot: 'secure',
        icon: Icons.shield_rounded,
        content: Column(
          children: const [
            _ProfileInfoPoint(
              icon: Icons.storage_rounded,
              title: 'Data yang diperlukan',
              description:
                  'Informasi akun, aktivitas fitur, serta konten yang kamu kirim diproses untuk menyediakan layanan.',
              tone: Color(0xFF2563A6),
              tint: Color(0xFFEFF6FF),
            ),
            SizedBox(height: 9),
            _ProfileInfoPoint(
              icon: Icons.lock_rounded,
              title: 'Penggunaan dan perlindungan',
              description:
                  'Data digunakan untuk menjalankan dan meningkatkan layanan, dengan akses yang dibatasi. Data pribadi tidak dijual.',
              tone: Color(0xFF059669),
              tint: Color(0xFFECFDF5),
            ),
            SizedBox(height: 9),
            _ProfileInfoPoint(
              icon: Icons.manage_accounts_rounded,
              title: 'Kendali tetap di tanganmu',
              description:
                  'Kamu dapat meminta akses, pembaruan, atau penghapusan data sesuai ketentuan yang berlaku.',
              tone: Color(0xFF7C3AED),
              tint: Color(0xFFF5F3FF),
            ),
            SizedBox(height: 12),
            _PolicyUpdatedDate(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () => _openSupportEmail(
              context,
              subject: 'Pertanyaan tentang privasi Ruang Tenang',
            ),
            style: _dialogPrimaryButtonStyle,
            icon: const Icon(Icons.mail_outline_rounded, size: 17),
            label: const Text('Tanya tentang privasi'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _ProfileInfoDialog(
        eyebrow: 'KAMI SIAP MEMBANTU',
        title: 'Ada yang bisa kami bantu?',
        description:
            'Tim Ruang Tenang siap membantu kendala akun, tagihan, konten, dan penggunaan aplikasi.',
        mascot: 'tour-support',
        icon: Icons.support_agent_rounded,
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFBE1DF)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.mail_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dukungan Pengguna',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'halo@ruangtenang.id',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                color: AppColors.gray400,
                size: 17,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () => _openSupportEmail(
              context,
              subject: 'Bantuan pengguna Ruang Tenang',
            ),
            style: _dialogPrimaryButtonStyle,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Kirim email'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSupportEmail(
    BuildContext context, {
    required String subject,
  }) async {
    final email = Uri(
      scheme: 'mailto',
      path: 'halo@ruangtenang.id',
      queryParameters: {'subject': subject},
    );
    final opened = await launchUrl(email);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Aplikasi email tidak tersedia.')),
        );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk mengakses data dan catatanmu.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 3, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.foreground,
      ),
    ),
  );

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color color = AppColors.mutedForeground,
    required bool showDivider,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.foreground,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
                ],
              ),
            ),
            if (showDivider)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
                indent: 73,
              ),
          ],
        ),
      ),
    );
  }
}

final _dialogPrimaryButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(0, 42),
  padding: const EdgeInsets.symmetric(horizontal: 14),
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  elevation: 1,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
);

class _ProfileInfoDialog extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final String mascot;
  final IconData icon;
  final Widget content;
  final List<Widget> actions;

  const _ProfileInfoDialog({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.mascot,
    required this.icon,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white,
            elevation: 22,
            shadowColor: const Color(0x33111827),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(21, 20, 98, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF1F2), Color(0xFFFFF8F0)],
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF4E3E3)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 13, color: AppColors.primary),
                              const SizedBox(width: 5),
                              Text(
                                eyebrow,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.65,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.foreground,
                            fontSize: 19,
                            height: 1.13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        content,
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.end,
                          runAlignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: actions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: -9,
            width: 112,
            height: 146,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/mascot/$mascot.webp',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileInfoPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color tone;
  final Color tint;

  const _ProfileInfoPoint({
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: tone, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 9,
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

class _PolicyUpdatedDate extends StatelessWidget {
  const _PolicyUpdatedDate();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_outlined, size: 14, color: AppColors.gray500),
        SizedBox(width: 6),
        Text(
          'Diperbarui 20 Februari 2026',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
