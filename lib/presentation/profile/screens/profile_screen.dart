import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.foreground),
              onPressed: () {},
              tooltip: 'Pengaturan',
            ),
          ),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name, 
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email, 
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Member Biasa', 
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Gamification Hub Section
              _buildSectionTitle('Gamifikasi & Pencapaian'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.sports_esports_rounded,
                      title: 'Game Hub',
                      subtitle: 'Level, EXP, dan aktivitas harian',
                      onTap: () => context.push('/gamification'),
                      color: AppColors.primary,
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.workspace_premium_rounded,
                      title: 'Koleksi Badge',
                      subtitle: 'Pencapaian yang telah diraih',
                      onTap: () => context.push('/gamification/badges'),
                      color: Colors.orange,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Premium Section
              _buildSectionTitle('Berlangganan'),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade50,
                      Colors.amber.shade100.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: _buildMenuItem(
                  context,
                  icon: Icons.workspace_premium_rounded,
                  title: 'Upgrade ke Premium',
                  subtitle: 'Akses tanpa batas ke semua fitur Ruang Tenang',
                  onTap: () => context.push('/billing/premium'),
                  color: Colors.amber.shade700,
                  showDivider: false,
                  isPremium: true,
                ),
              ),
              const SizedBox(height: 24),
              
              // Account Settings Section
              _buildSectionTitle('Pengaturan Akun'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profil',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Password',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Keluar dari Akun'),
                        content: const Text('Apakah Anda yakin ingin keluar? Anda harus masuk kembali untuk mengakses data Anda.'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx), 
                            child: const Text('Batal', style: TextStyle(color: AppColors.mutedForeground)),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(const AuthLogoutRequested());
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.destructive,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.destructive),
                  label: const Text(
                    'Keluar', 
                    style: TextStyle(
                      color: AppColors.destructive,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.destructive.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title, 
        style: const TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: AppColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required VoidCallback onTap, 
    Color color = AppColors.mutedForeground,
    required bool showDivider,
    bool isPremium = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.amber.shade100 : color.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                            fontWeight: FontWeight.w600, 
                            fontSize: 16,
                            color: isPremium ? Colors.amber.shade900 : AppColors.foreground,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle, 
                            style: TextStyle(
                              fontSize: 13,
                              color: isPremium ? Colors.amber.shade800 : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded, 
                    color: isPremium ? Colors.amber.shade700 : AppColors.mutedForeground.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1, 
                thickness: 1, 
                color: AppColors.border.withValues(alpha: 0.3),
                indent: 68, // Aligns divider with text
              ),
          ],
        ),
      ),
    );
  }
}
