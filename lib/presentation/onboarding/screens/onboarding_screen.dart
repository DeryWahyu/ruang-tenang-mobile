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
      icon: Icons.chat_bubble_rounded,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.red50,
      title: 'Curhat dengan AI',
      description:
          'Ceritakan perasaanmu kapan saja kepada AI yang penuh empati. '
          'Privasi terjaga, tanpa penghakiman.',
    ),
    _OnboardingSlide(
      icon: Icons.book_rounded,
      iconColor: AppColors.accentOrangeDark,
      iconBgColor: AppColors.accentOrangeLight,
      title: 'Tulis Jurnal & Lacak Mood',
      description:
          'Ekspresikan pikiranmu lewat jurnal harian dan pantau '
          'perubahan suasana hatimu dari waktu ke waktu.',
    ),
    _OnboardingSlide(
      icon: Icons.people_rounded,
      iconColor: AppColors.info,
      iconBgColor: AppColors.infoLight,
      title: 'Bergabung dengan Komunitas',
      description:
          'Temukan dukungan dari sesama, berbagi cerita inspiratif, '
          'dan tumbuh bersama di komunitas yang aman.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool(StorageKeys.hasSeenOnboarding, true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.spacingBase,
                  right: AppDimensions.spacingSm,
                ),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Lewati',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlide(context, slide);
                },
              ),
            ),

            // Dot indicator
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingXl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingXl,
                0,
                AppDimensions.spacingXl,
                AppDimensions.spacing2xl,
              ),
              child: AppButton.primary(
                label: _currentPage == _slides.length - 1
                    ? 'Mulai Sekarang'
                    : 'Selanjutnya',
                suffixIcon: _currentPage == _slides.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing2xl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.iconBgColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              slide.icon,
              size: 60,
              color: slide.iconColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing2xl),

          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.foreground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray300,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
  });
}
