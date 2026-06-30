import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_network_image.dart';
import '../../../core/utils/media_url.dart';
import '../../common/widgets/app_avatar.dart';
import '../../../domain/entities/secondary_gamification.dart';
import '../cubit/secondary_cubits.dart';
import '../cubit/view_state.dart';

class GuildScreen extends StatelessWidget {
  const GuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuildCubit>()..load(),
      child: const _GuildView(),
    );
  }
}

class _GuildView extends StatelessWidget {
  const _GuildView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Guild', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      body: BlocConsumer<GuildCubit, ViewState<GuildHubData>>(
        listenWhen: (p, c) => p.actionMessage != c.actionMessage || p.error != c.error,
        listener: (context, state) {
          if (state.actionMessage.isNotEmpty) {
            _snack(context, state.actionMessage, AppColors.success);
          } else if (state.error.isNotEmpty && state.status == ViewStatus.failure) {
            _snack(context, state.error, AppColors.destructive);
          }
        },
        builder: (context, state) {
          if (state.data == null && state.status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.data == null) {
            return _retry(context, state.error);
          }
          final data = state.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<GuildCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: data.myGuild.isMember
                  ? _memberView(context, data, state)
                  : _discoverView(context, data, state),
            ),
          );
        },
      ),
    );
  }

  // ===== Member view =====
  List<Widget> _memberView(BuildContext context, GuildHubData data, ViewState<GuildHubData> state) {
    final detail = data.detail;
    final guild = detail?.guild ?? data.myGuild.guild;
    if (guild == null) return [const SizedBox.shrink()];
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Center(child: _guildIcon(guild.icon, 44)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guild.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Level ${guild.level} • ${guild.memberCount}/${guild.maxMembers} anggota',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${guild.totalXp}', 'Total XP'),
                _stat('${data.myGuild.xpContributed}', 'Kontribusimu'),
                _stat(data.myGuild.memberRole, 'Peranmu'),
              ],
            ),
          ],
        ),
      ),
      if (guild.inviteCode.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accentOrangeLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.key_rounded, color: AppColors.accentOrange, size: 18),
              const SizedBox(width: 8),
              const Text('Kode Undangan: ', style: TextStyle(fontSize: 13)),
              Text(guild.inviteCode,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrangeText)),
            ],
          ),
        ),
      ],
      if (detail != null && detail.activeChallenges.isNotEmpty) ...[
        const SizedBox(height: 24),
        _sectionTitle('Tantangan Guild'),
        const SizedBox(height: 12),
        ...detail.activeChallenges.map(_challengeCard),
      ],
      if (detail != null && detail.members.isNotEmpty) ...[
        const SizedBox(height: 24),
        _sectionTitle('Anggota (${detail.members.length})'),
        const SizedBox(height: 12),
        ...detail.members.map(_memberTile),
      ],
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: state.submitting
            ? null
            : () => _confirmLeave(context, guild.id),
        icon: const Icon(Icons.logout_rounded, color: AppColors.destructive),
        label: const Text('Keluar dari Guild', style: TextStyle(color: AppColors.destructive)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.destructive),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ];
  }

  Widget _challengeCard(GuildChallenge c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              if (c.isCompleted)
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.description, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (c.progressPercent / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.muted,
              color: c.isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text('${c.currentValue}/${c.targetValue} • +${c.xpReward} XP • +${c.coinReward} koin',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _memberTile(GuildMember m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: resolveMediaUrl(m.avatar),
            name: m.name.isNotEmpty ? m.name : m.username,
            size: 36,
            backgroundColor: AppColors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name.isNotEmpty ? m.name : m.username,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Lv ${m.userLevel} • ${m.role}',
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          Text('${m.xpContributed} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange, fontSize: 12)),
        ],
      ),
    );
  }

  // ===== Discover view (not a member) =====
  List<Widget> _discoverView(BuildContext context, GuildHubData data, ViewState<GuildHubData> state) {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.purple.shade400]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bergabunglah dengan Guild',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Tumbuh bersama komunitas, selesaikan tantangan, dan naik peringkat.',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.submitting ? null : () => _createDialog(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo),
                    child: const Text('Buat Guild'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.submitting ? null : () => _joinCodeDialog(context),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
                    child: const Text('Pakai Kode'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (data.publicGuilds.isNotEmpty) ...[
        const SizedBox(height: 24),
        _sectionTitle('Guild Publik'),
        const SizedBox(height: 12),
        ...data.publicGuilds.map((g) => _publicGuildTile(context, g, state)),
      ],
      if (data.leaderboard.isNotEmpty) ...[
        const SizedBox(height: 24),
        _sectionTitle('Peringkat Guild'),
        const SizedBox(height: 12),
        ...data.leaderboard.map(_leaderboardTile),
      ],
    ];
  }

  Widget _publicGuildTile(BuildContext context, Guild g, ViewState<GuildHubData> state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
            child: Center(child: _guildIcon(g.icon, 34)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Lv ${g.level} • ${g.memberCount}/${g.maxMembers} anggota',
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: state.submitting ? null : () => context.read<GuildCubit>().joinGuild(g.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Gabung'),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardTile(GuildLeaderboardEntry e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#${e.rank}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          ),
          _guildIcon(e.icon, 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Text('${e.totalXp} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange, fontSize: 12)),
        ],
      ),
    );
  }

  // ===== Helpers =====
  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground));

  Widget _retry(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 48, color: AppColors.mutedForeground),
          const SizedBox(height: 16),
          Text(error.isEmpty ? 'Gagal memuat guild' : error, style: const TextStyle(color: AppColors.mutedForeground)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => context.read<GuildCubit>().load(), child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _guildIcon(String icon, double size) {
    final isImage = icon.startsWith('http') ||
        icon.startsWith('/') ||
        icon.contains('/uploads') ||
        icon.endsWith('.png') ||
        icon.endsWith('.jpg') ||
        icon.endsWith('.jpeg') ||
        icon.endsWith('.webp');
    if (isImage) {
      final url = resolveMediaUrl(icon);
      if (url != null) {
        return AppNetworkImage(
          url: url,
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(size / 2),
          fallbackIcon: Icons.shield_rounded,
          fallbackColor: AppColors.primary,
        );
      }
    }
    if (icon.isNotEmpty) {
      // Konsisten dengan web: ikon guild non-image dirender sebagai emoji/teks.
      return Text(icon, style: TextStyle(fontSize: size * 0.6));
    }
    return Icon(Icons.shield_rounded, size: size * 0.75, color: AppColors.primary);
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _confirmLeave(BuildContext context, String guildId) {
    final cubit = context.read<GuildCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Guild'),
        content: const Text('Yakin ingin meninggalkan guild ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.leaveGuild(guildId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _createDialog(BuildContext context) {
    final cubit = context.read<GuildCubit>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isPublic = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Buat Guild'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Guild', hintText: 'min. 3 karakter'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Guild Publik'),
                value: isPublic,
                onChanged: (v) => setState(() => isPublic = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().length < 3) return;
                Navigator.pop(ctx);
                cubit.createGuild(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  icon: 'shield',
                  isPublic: isPublic,
                );
              },
              child: const Text('Buat'),
            ),
          ],
        ),
      ),
    );
  }

  void _joinCodeDialog(BuildContext context) {
    final cubit = context.read<GuildCubit>();
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Gabung dengan Kode'),
        content: TextField(
          controller: codeCtrl,
          decoration: const InputDecoration(labelText: 'Kode Undangan'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              cubit.joinByCode(codeCtrl.text.trim());
            },
            child: const Text('Gabung'),
          ),
        ],
      ),
    );
  }
}
