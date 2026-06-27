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
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.red100,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(user.email, style: const TextStyle(color: AppColors.mutedForeground)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('🌟 Member Biasa', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Gamification Hub
              _buildSectionTitle('Gamifikasi'),
              _buildMenuCard(
                context,
                icon: Icons.sports_esports,
                title: 'Game Hub',
                subtitle: 'Level, EXP, dan aktivitas harian',
                onTap: () => context.push('/gamification'),
                color: AppColors.primary,
              ),
              _buildMenuCard(
                context,
                icon: Icons.workspace_premium,
                title: 'Koleksi Badge',
                subtitle: 'Pencapaian yang telah kamu raih',
                onTap: () => context.push('/gamification/badges'),
                color: AppColors.warning,
              ),

              const SizedBox(height: 24),

              // Premium / Billing
              _buildSectionTitle('Berlangganan'),
              _buildMenuCard(
                context,
                icon: Icons.star,
                title: 'Upgrade Premium',
                subtitle: 'Akses tanpa batas ke semua fitur',
                onTap: () => context.push('/billing/premium'),
                color: Colors.amber.shade700,
              ),
              
              const SizedBox(height: 24),
              
              // Account Settings
              _buildSectionTitle('Akun'),
              _buildMenuCard(
                context,
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: () {},
              ),
              _buildMenuCard(
                context,
                icon: Icons.lock_outline,
                title: 'Ubah Password',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar'),
                      content: const Text('Apakah kamu yakin ingin keluar?'),
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
                },
                icon: const Icon(Icons.logout, color: AppColors.destructive),
                label: const Text('Keluar', style: TextStyle(color: AppColors.destructive)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.destructive)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color color = AppColors.mutedForeground}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
      ),
    );
  }
}