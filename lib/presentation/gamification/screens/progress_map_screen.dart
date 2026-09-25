import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/gamification.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

const _tierImages = <String>[
  'assets/images/journey/tier-01-foundation.webp',
  'assets/images/journey/tier-02-stability.webp',
  'assets/images/journey/tier-03-exploration.webp',
  'assets/images/journey/tier-04-reflection.webp',
  'assets/images/journey/tier-05-resilience.webp',
  'assets/images/journey/tier-06-maturity.webp',
  'assets/images/journey/tier-07-guidance.webp',
  'assets/images/journey/tier-08-mastery.webp',
  'assets/images/journey/tier-09-deep-calm.webp',
  'assets/images/journey/tier-10-completion.webp',
];

final _tierImagesByKey = <String, String>{
  'gerbang_awal': _tierImages[0],
  'taman_ketenangan': _tierImages[1],
  'perpustakaan_bijak': _tierImages[2],
  'lembah_refleksi': _tierImages[3],
  'alun_komunitas': _tierImages[4],
  'puncak_harmoni': _tierImages[5],
  'hutan_kebijaksanaan': _tierImages[6],
  'danau_kedamaian': _tierImages[7],
  'menara_guardian': _tierImages[8],
  'nirwana': _tierImages[9],
};

const _regionColors = <Color>[
  Color(0xFF10B981),
  Color(0xFF0EA5E9),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
];

String _tierImage(MapRegion region, int index) =>
    _tierImagesByKey[region.regionKey] ??
    _tierImages[index % _tierImages.length];

class ProgressMapScreen extends StatelessWidget {
  final bool showAppBar;
  const ProgressMapScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        sl<GamificationBloc>()..add(const GamificationProgressMapRequested()),
    child: _ProgressMapView(showAppBar: showAppBar),
  );
}

class _ProgressMapView extends StatelessWidget {
  final bool showAppBar;
  const _ProgressMapView({required this.showAppBar});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    appBar: showAppBar
        ? AppBar(
            title: const Text(
              'Peta Perjalananmu',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          )
        : null,
    body: BlocConsumer<GamificationBloc, GamificationState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.successMessage.isNotEmpty
            ? state.successMessage
            : state.status == GamificationStatus.failure
            ? state.errorMessage
            : '';
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: state.successMessage.isNotEmpty
                    ? AppColors.success
                    : AppColors.destructive,
              ),
            );
        }
      },
      builder: (context, state) {
        final map = state.progressMap;
        if (map == null && state.status == GamificationStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (map == null) return _MapError(message: state.errorMessage);

        final activeIndex = _activeRegionIndex(map.regions);
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => context.read<GamificationBloc>().add(
            const GamificationProgressMapRequested(),
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _MapHero(map: map),
              const SizedBox(height: 14),
              _MapStats(map: map),
              const SizedBox(height: 24),
              const _CheckpointHeading(),
              const SizedBox(height: 12),
              if (map.regions.isEmpty)
                const _EmptyMap()
              else
                ...map.regions.asMap().entries.map((entry) {
                  final index = entry.key;
                  return _RegionCheckpoint(
                    region: entry.value,
                    index: index,
                    isCurrent: index == activeIndex,
                    isLast: index == map.regions.length - 1,
                    isSubmitting: state.status == GamificationStatus.submitting,
                    onClaim: (id) => context.read<GamificationBloc>().add(
                      GamificationLandmarkClaimed(id),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    ),
  );
}

int _activeRegionIndex(List<MapRegion> regions) {
  final current = regions.indexWhere(
    (region) =>
        region.isUnlocked &&
        (region.totalLandmarks == 0 ||
            region.unlockedLandmarks < region.totalLandmarks),
  );
  if (current >= 0) return current;
  for (var i = regions.length - 1; i >= 0; i--) {
    if (regions[i].isUnlocked) return i;
  }
  return 0;
}

class _MapHero extends StatelessWidget {
  final ProgressMap map;
  const _MapHero({required this.map});

  @override
  Widget build(BuildContext context) {
    final progress = (map.overallProgress / 100).clamp(0.0, 1.0);
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1F2), Color(0xFFFFF8F0), Colors.white],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF4D8D9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            bottom: -5,
            width: 156,
            height: 194,
            child: Image.asset(
              'assets/images/mascot/checkpoint-explore.webp',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 112, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.explore_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'JALUR PERJALANANMU',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Setiap langkah berarti',
                  style: TextStyle(
                    color: AppColors.foreground,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Jelajahi checkpoint dan rayakan progres kecilmu.',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFF3D8D9),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${map.overallProgress.round()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
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
}

class _MapStats extends StatelessWidget {
  final ProgressMap map;
  const _MapStats({required this.map});

  @override
  Widget build(BuildContext context) {
    final values = [
      (
        Icons.public_rounded,
        '${map.unlockedRegions}/${map.totalRegions}',
        'Area terbuka',
        const Color(0xFF059669),
        const Color(0xFFECFDF5),
      ),
      (
        Icons.flag_rounded,
        '${map.unlockedLandmarks}/${map.totalLandmarks}',
        'Landmark',
        const Color(0xFF0284C7),
        const Color(0xFFF0F9FF),
      ),
      (
        Icons.explore_rounded,
        '${map.overallProgress.round()}%',
        'Peta selesai',
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _StatCard(data: values[i])),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final (IconData, String, String, Color, Color) data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 86),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(color: data.$5, shape: BoxShape.circle),
          child: Icon(data.$1, color: data.$4, size: 16),
        ),
        const SizedBox(height: 5),
        Text(
          data.$2,
          maxLines: 1,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        Text(
          data.$3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 9),
        ),
      ],
    ),
  );
}

class _CheckpointHeading extends StatelessWidget {
  const _CheckpointHeading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Pilih checkpoint untuk menjelajah',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 5),
      const Text(
        'Buka area baru, selesaikan landmark, lalu klaim hadiahnya.',
        style: TextStyle(
          color: AppColors.mutedForeground,
          fontSize: 12,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 7,
        children: const [
          _StatusLegend(
            Icons.check_rounded,
            'Selesai',
            Color(0xFF059669),
            Color(0xFFECFDF5),
          ),
          _StatusLegend(
            Icons.place_rounded,
            'Aktif',
            AppColors.primary,
            Color(0xFFFFF1F2),
          ),
          _StatusLegend(
            Icons.lock_rounded,
            'Terkunci',
            AppColors.gray500,
            AppColors.gray100,
          ),
        ],
      ),
    ],
  );
}

class _StatusLegend extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  const _StatusLegend(this.icon, this.label, this.color, this.background);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _RegionCheckpoint extends StatelessWidget {
  final MapRegion region;
  final int index;
  final bool isCurrent;
  final bool isLast;
  final bool isSubmitting;
  final ValueChanged<String> onClaim;

  const _RegionCheckpoint({
    required this.region,
    required this.index,
    required this.isCurrent,
    required this.isLast,
    required this.isSubmitting,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final complete =
        region.isUnlocked &&
        region.totalLandmarks > 0 &&
        region.unlockedLandmarks >= region.totalLandmarks;
    final locked = !region.isUnlocked;
    final state = complete
        ? _CheckpointState.complete
        : isCurrent
        ? _CheckpointState.current
        : locked
        ? _CheckpointState.locked
        : _CheckpointState.open;
    final color = switch (state) {
      _CheckpointState.complete => const Color(0xFF059669),
      _CheckpointState.current => AppColors.primary,
      _CheckpointState.open => _regionColors[index % _regionColors.length],
      _CheckpointState.locked => AppColors.gray400,
    };

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!isLast)
                  Positioned(
                    left: 20,
                    top: 40,
                    bottom: -14,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: complete
                            ? const Color(0xFFA7F3D0)
                            : AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: _CheckpointMarker(
                    index: index,
                    state: state,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _RegionTile(
              region: region,
              index: index,
              state: state,
              color: color,
              isSubmitting: isSubmitting,
              onClaim: onClaim,
            ),
          ),
        ],
      ),
    );
  }
}

enum _CheckpointState { complete, current, open, locked }

class _CheckpointMarker extends StatelessWidget {
  final int index;
  final _CheckpointState state;
  final Color color;
  const _CheckpointMarker({
    required this.index,
    required this.state,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      _CheckpointState.complete => Icons.check_rounded,
      _CheckpointState.current => Icons.place_rounded,
      _CheckpointState.open => Icons.explore_rounded,
      _CheckpointState.locked => Icons.lock_rounded,
    };
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: state == _CheckpointState.current
                  ? Colors.white
                  : color,
              child: Icon(
                icon,
                size: 10,
                color: state == _CheckpointState.current ? color : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final MapRegion region;
  final int index;
  final _CheckpointState state;
  final Color color;
  final bool isSubmitting;
  final ValueChanged<String> onClaim;

  const _RegionTile({
    required this.region,
    required this.index,
    required this.state,
    required this.color,
    required this.isSubmitting,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final locked = state == _CheckpointState.locked;
    final complete = state == _CheckpointState.complete;
    final progress = region.totalLandmarks > 0
        ? (region.unlockedLandmarks / region.totalLandmarks).clamp(0.0, 1.0)
        : region.isUnlocked
        ? 1.0
        : 0.0;
    final status = switch (state) {
      _CheckpointState.complete => 'Selesai',
      _CheckpointState.current => 'Aktif',
      _CheckpointState.open => 'Terbuka',
      _CheckpointState.locked => 'Terkunci',
    };
    final image = _tierImage(region, index);

    return Container(
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: complete
              ? const Color(0xFFBBF7D0)
              : state == _CheckpointState.current
              ? AppColors.red200
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(region.id),
          tilePadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHECKPOINT ${(index + 1).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      region.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: locked
                            ? AppColors.gray600
                            : AppColors.foreground,
                        fontSize: 14,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: status, state: state, color: color),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TierArtwork(path: image, locked: locked),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locked
                      ? 'Area ini akan terbuka di langkah berikutnya.'
                      : region.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: AppColors.gray200,
                          color: locked
                              ? AppColors.gray300
                              : complete
                              ? const Color(0xFF10B981)
                              : color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${region.unlockedLandmarks}/${region.totalLandmarks}',
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            const Divider(height: 1, color: AppColors.border),
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Landmark area',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (region.landmarks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Belum ada landmark di area ini.',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              )
            else
              ...region.landmarks.map(
                (landmark) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LandmarkTile(
                    landmark: landmark,
                    regionImage: image,
                    regionUnlocked: region.isUnlocked,
                    isSubmitting: isSubmitting,
                    onClaim: () => onClaim(landmark.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final _CheckpointState state;
  final Color color;
  const _StatusChip({
    required this.status,
    required this.state,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final background = switch (state) {
      _CheckpointState.complete => const Color(0xFFECFDF5),
      _CheckpointState.current => const Color(0xFFFFF1F2),
      _CheckpointState.open || _CheckpointState.locked => AppColors.gray100,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TierArtwork extends StatelessWidget {
  final String path;
  final bool locked;
  const _TierArtwork({required this.path, required this.locked});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (locked)
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                .2126,
                .7152,
                .0722,
                0,
                0,
                .2126,
                .7152,
                .0722,
                0,
                0,
                .2126,
                .7152,
                .0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image.asset(path, fit: BoxFit.cover),
            )
          else
            Image.asset(path, fit: BoxFit.cover),
          if (locked)
            Container(
              color: Colors.white.withValues(alpha: 0.28),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
        ],
      ),
    ),
  );
}

class _LandmarkTile extends StatelessWidget {
  final MapLandmark landmark;
  final String regionImage;
  final bool regionUnlocked;
  final bool isSubmitting;
  final VoidCallback onClaim;
  const _LandmarkTile({
    required this.landmark,
    required this.regionImage,
    required this.regionUnlocked,
    required this.isSubmitting,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !landmark.isUnlocked;
    final claimable = regionUnlocked && landmark.canClaim;
    final complete = landmark.rewardClaimed;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: complete
            ? const Color(0xFFF0FDF4)
            : locked
            ? AppColors.gray50
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: complete ? const Color(0xFFD1FAE5) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 36,
              height: 36,
              child: complete
                  ? const ColoredBox(
                      color: Color(0xFFDCFCE7),
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
                    )
                  : locked
                  ? const ColoredBox(
                      color: Colors.white,
                      child: Icon(
                        Icons.lock_rounded,
                        color: AppColors.gray400,
                        size: 17,
                      ),
                    )
                  : Image.asset(regionImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        landmark.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (complete)
                      const _RewardTag(
                        label: 'Diklaim',
                        color: Color(0xFF047857),
                        background: Color(0xFFDCFCE7),
                      ),
                  ],
                ),
                if (landmark.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    landmark.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 10,
                      height: 1.35,
                    ),
                  ),
                ],
                if (locked) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (landmark.progressPercent / 100).clamp(
                            0.0,
                            1.0,
                          ),
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${landmark.progressPercent.round()}%',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                if (landmark.xpReward > 0 || landmark.coinReward > 0) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (landmark.xpReward > 0)
                        _RewardTag(
                          label: '+${landmark.xpReward} XP',
                          color: const Color(0xFF6D28D9),
                          background: const Color(0xFFF5F3FF),
                        ),
                      if (landmark.coinReward > 0)
                        _RewardTag(
                          label: '+${landmark.coinReward} koin',
                          color: const Color(0xFFB45309),
                          background: const Color(0xFFFFF7ED),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (claimable) ...[
            const SizedBox(width: 6),
            SizedBox(
              height: 32,
              child: FilledButton(
                onPressed: isSubmitting ? null : onClaim,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Klaim'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _RewardTag({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
    ),
  );
}

class _EmptyMap extends StatelessWidget {
  const _EmptyMap();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
    ),
    child: const Column(
      children: [
        Icon(Icons.explore_outlined, size: 38, color: AppColors.primary),
        SizedBox(height: 10),
        Text(
          'Checkpoint belum tersedia',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          'Perjalananmu akan muncul di sini saat area sudah tersedia.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
        ),
      ],
    ),
  );
}

class _MapError extends StatelessWidget {
  final String message;
  const _MapError({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 140,
            child: Image.asset(
              'assets/images/mascot/map.webp',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Peta belum berhasil dimuat',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message.isEmpty
                ? 'Perjalananmu tetap tersimpan. Coba muat ulang untuk melanjutkan.'
                : message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.read<GamificationBloc>().add(
              const GamificationProgressMapRequested(),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}
