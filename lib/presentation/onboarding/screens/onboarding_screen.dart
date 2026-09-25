import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../common/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      backgroundPath: 'assets/images/mascot/onboarding-listen-bg.webp',
      title: 'Ada ruang untuk bercerita',
      description:
          'Mulai percakapan dengan AI pendamping yang mendengarkan tanpa '
          'menghakimi.',
    ),
    _OnboardingSlide(
      backgroundPath: 'assets/images/mascot/onboarding-journal-bg.webp',
      title: 'Kenali dirimu perlahan',
      description:
          'Catat perasaanmu dan lihat perubahan kecil dari hari ke hari.',
    ),
    _OnboardingSlide(
      backgroundPath: 'assets/images/mascot/onboarding-breathe-bg.webp',
      title: 'Temukan jeda yang menenangkan',
      description:
          'Pilih bacaan, refleksi, atau musik saat kamu butuh ruang untuk '
          'bernapas.',
    ),
    _OnboardingSlide(
      backgroundPath: 'assets/images/mascot/onboarding-community-bg.webp',
      title: 'Tumbuh bersama',
      description:
          'Berbagi cerita dan dukungan dalam komunitas yang saling '
          'menguatkan.',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool(StorageKeys.hasSeenOnboarding, true);
    if (mounted) context.go('/login');
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(_currentPage + 1);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: AppColors.red50,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => ExcludeSemantics(
              child: Image.asset(
                _slides[index].backgroundPath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AppColors.red50),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFFFF9F6).withValues(alpha: 0.58),
                      const Color(0xFFFFF9F6).withValues(alpha: 0.9),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : 0,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(
                            height: AppDimensions.appBarHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: AnimatedOpacity(
                                  opacity: _isLastPage ? 0 : 1,
                                  duration: disableAnimations
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  child: TextButton(
                                    onPressed: _isLastPage
                                        ? null
                                        : _completeOnboarding,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.gray700,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: const StadiumBorder(),
                                    ),
                                    child: Text(
                                      'Lewati',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 8, 30, 22),
                            child: _buildPageControls(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _slides[_currentPage].title,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.foreground,
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _slides[_currentPage].description,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.gray600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, _buildDot),
        ),
        const SizedBox(height: 14),
        AppButton.primary(
          label: _isLastPage ? 'Mulai Sekarang' : 'Selanjutnya',
          size: AppButtonSize.md,
          suffixIcon: Icons.arrow_forward_rounded,
          onPressed: _nextPage,
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return Semantics(
      label: 'Langkah ${index + 1} dari ${_slides.length}',
      selected: isActive,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 26 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.gray300,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String backgroundPath;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.backgroundPath,
    required this.title,
    required this.description,
  });
}
