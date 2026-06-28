import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _go(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.push(route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Akun'),
          _group([
            _tile(context, Icons.person_outline_rounded, 'Edit Profil', 'Ubah nama, foto, dan bio',
                onTap: () => _go(context, '/profile/edit')),
            _tile(context, Icons.lock_outline_rounded, 'Ubah Password', 'Perbarui kata sandi akun',
                onTap: () => _go(context, '/profile/password'), last: true),
          ]),
          const SizedBox(height: 20),
          _section('Langganan'),
          _group([
            _tile(context, Icons.workspace_premium_rounded, 'Premium', 'Kelola langganan kamu',
                color: Colors.amber.shade700, onTap: () => _go(context, '/billing/premium'), last: true),
          ]),
          const SizedBox(height: 20),
          _section('Tentang'),
          _group([
            _tile(context, Icons.info_outline_rounded, 'Tentang Aplikasi', 'Versi & informasi',
                onTap: () => _showAbout(context)),
            _tile(context, Icons.privacy_tip_outlined, 'Kebijakan Privasi', 'Bagaimana data kamu dikelola',
                onTap: () => _showInfo(context, 'Kebijakan Privasi',
                    'Ruang Tenang menjaga privasi & keamanan data kamu. Data hanya digunakan untuk meningkatkan pengalamanmu.')),
            _tile(context, Icons.help_outline_rounded, 'Bantuan', 'Pusat bantuan & dukungan',
                onTap: () => _showInfo(context, 'Bantuan',
                    'Butuh bantuan? Hubungi tim kami melalui menu dukungan di aplikasi atau email support.'),
                last: true),
          ]),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: TextButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, color: AppColors.destructive),
              label: const Text('Keluar', style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.bold, fontSize: 16)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.destructive.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 10),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mutedForeground, letterSpacing: 0.5)),
      );

  Widget _group(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(children: children),
      );

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle,
      {required VoidCallback onTap, Color color = AppColors.primary, bool last = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.mutedForeground.withOpacity(0.5)),
                ],
              ),
            ),
            if (!last) Divider(height: 1, thickness: 1, color: AppColors.border.withOpacity(0.3), indent: 56),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAboutDialog(
        context: context,
        applicationName: 'Ruang Tenang',
        applicationVersion: '1.0.0',
        applicationLegalese: '© 2025 Ruang Tenang',
        children: const [
          SizedBox(height: 12),
          Text('Ruang tenang untuk kesehatan mental & ketenangan pikiranmu.'),
        ],
      );
    });
  }

  void _showInfo(BuildContext context, String title, String body) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(body),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
        ),
      );
    });
  }

  void _confirmLogout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Keluar dari Akun'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.destructive),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
    });
  }
}
