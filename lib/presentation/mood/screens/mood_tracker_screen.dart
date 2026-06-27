import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/mood.dart';
import '../../common/widgets/app_empty_state.dart';
import '../../common/widgets/app_loading.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';
import '../widgets/mood_picker.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodBloc>().add(const MoodTodayRequested());
      context.read<MoodBloc>().add(const MoodHistoryRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: false,
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistik',
            onPressed: () => context.push('/mood/stats'),
          ),
        ],
      ),
      body: BlocConsumer<MoodBloc, MoodState>(
        listenWhen: (prev, curr) =>
            prev.successMessage != curr.successMessage ||
            (curr.errorMessage != null && curr.status == MoodStatus.failure),
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.errorMessage != null && state.status == MoodStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.destructive,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<MoodBloc>().add(const MoodTodayRequested());
              context.read<MoodBloc>().add(const MoodHistoryRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingBase),
              children: [
                _buildCheckInCard(state),
                const SizedBox(height: AppDimensions.spacingBase),
                _buildHistorySection(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckInCard(MoodState state) {
    final today = state.today;
    final hasChecked = today?.hasChecked ?? false;
    final todaysMood = today?.mood;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.red50,
            AppColors.card,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
        border: Border.all(color: AppColors.red100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bagaimana perasaanmu hari ini?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppDateUtils.formatWithDay(DateTime.now()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),
          const SizedBox(height: AppDimensions.spacingBase),
          if (hasChecked && todaysMood != null)
            _buildRecordedState(todaysMood)
          else if (state.isLoading && today == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingBase),
              child: Center(child: AppLoadingIndicator(size: 28)),
            )
          else
            MoodPicker(
              selectedMood: todaysMood?.mood,
              onMoodSelected: state.isRecording
                  ? null
                  : (mood) => context.read<MoodBloc>().add(MoodRecordRequested(mood)),
            ),
          if (state.isRecording)
            const Padding(
              padding: EdgeInsets.only(top: AppDimensions.spacingBase),
              child: Center(child: AppLoadingIndicator(size: 24)),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordedState(UserMood mood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingBase, vertical: AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: mood.mood.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(mood.displayEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood hari ini: ${mood.mood.label}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Dicatat ${AppDateUtils.formatRelative(mood.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Allow re-recording (server upserts).
              context.read<MoodBloc>().add(const MoodTodayRequested());
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(MoodState state) {
    final history = state.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (history != null && history.totalCount > 0)
              Text(
                '${history.totalCount} catatan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        if (state.status == MoodStatus.historyLoading && history == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing2xl),
            child: Center(child: AppLoadingIndicator(size: 24)),
          )
        else if (history == null || history.moods.isEmpty)
          AppEmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat',
            subtitle: 'Catat mood pertamamu untuk melihatnya di sini.',
            iconSize: 48,
          )
        else
          _buildHistoryList(history.moods),
      ],
    );
  }

  Widget _buildHistoryList(List<UserMood> moods) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moods.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isToday = AppDateUtils.isToday(mood.createdAt);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingBase, vertical: AppDimensions.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mood.mood.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(
                  child: Text(mood.displayEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.mood.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      isToday
                          ? 'Hari ini • ${AppDateUtils.formatTime(mood.createdAt)}'
                          : AppDateUtils.formatDateTime(mood.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
