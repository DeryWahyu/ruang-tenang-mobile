import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/gradient_background.dart';

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
      lottiePath: 'assets/lottie/chat.json',
      icon: Icons.favorite_rounded,
      gradient: [Color(0xFFFB7185), Color(0xFFEF4444)],
      title: 'Ruang Aman untuk Bercerita',
      description:
          'AI pendengar setia kami siap memahami keluh kesahmu 24/7. '
          'Privasi sepenuhnya terjaga, tanpa ada penghakiman.',
    ),
    _OnboardingSlide(
      lottiePath: 'assets/lottie/journal.json',
      icon: Icons.menu_book_rounded,
      gradient: [Color(0xFFFB923C), Color(0xFFF59E0B)],
      title: 'Kenali Dirimu Lebih Baik',
      description:
          'Catat perjalanan emosimu lewat jurnal harian. Pahami pola pikiranmu '
          'dan lihat bagaimana kamu bertumbuh setiap harinya.',
    ),
    _OnboardingSlide(
      lottiePath: 'assets/lottie/relax.json',
      icon: Icons.self_improvement_rounded,
      gradient: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      title: 'Tenangkan Pikiranmu',
      description:
          'Redakan stres seketika dengan panduan latihan pernapasan dan '
          'alunan musik relaksasi yang menenangkan jiwa.',
    ),
    _OnboardingSlide(
      lottiePath: 'assets/lottie/community.json',
      icon: Icons.groups_rounded,
      gradient: [Color(0xFFF87171), Color(0xFFDC2626)],
      title: 'Dukungan Sepenuh Hati',
      description:
          'Kamu tidak sendirian. Bergabunglah dengan komunitas yang positif '
          'untuk saling menguatkan dan berbagi cerita.',
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
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      intensity: 2.5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol "Lewati" — disembunyikan di slide terakhir.
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: _isLastPage ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingBase,
                    right: AppDimensions.spacingSm,
                  ),
                  child: TextButton(
                    onPressed: _isLastPage ? null : _completeOnboarding,
                    child: Text(
                      'Lewati',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _OnboardingSlideView(
                  slide: _slides[index],
                  isActive: index == _currentPage,
                ),
              ),
            ),

            // Indikator titik dengan animasi lebar.
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingXl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, _buildDot),
              ),
            ),

            // Tombol aksi utama (scale-on-press dari AppButton).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingXl,
                0,
                AppDimensions.spacingXl,
                AppDimensions.spacing2xl,
              ),
              child: AppButton.primary(
                label: _isLastPage ? 'Mulai Sekarang' : 'Selanjutnya',
                suffixIcon: Icons.arrow_forward_rounded,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 26 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray300,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}

/// Satu halaman onboarding, dengan animasi masuk halus (fade + slide-up)
/// saat menjadi halaman aktif.
class _OnboardingSlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool isActive;

  const _OnboardingSlideView({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing2xl, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi: lingkaran gradient bertema merah + glow lembut.
          AnimatedScale(
            scale: isActive ? 1 : 0.85,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: slide.gradient,
                ),
                boxShadow: AppShadows.lg,
              ),
              child: Lottie.asset(
                slide.lottiePath,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Icon(slide.icon, size: 68, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing2xl),

          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, isActive ? 0 : 40, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      slide.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String lottiePath;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.lottiePath,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
  });
}
