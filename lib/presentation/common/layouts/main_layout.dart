import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../gamification/widgets/daily_task_fab.dart';
import '../../mood/widgets/mood_checkin_gate.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/journal')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/music')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/journal');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/music');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(child: child),
            // One-per-day mood check-in popup (renders nothing until needed).
            const MoodCheckinGate(),
            // Floating daily-task button (mirrors the web FAB). Shown only on
            // Home — other tabs have their own controls or no room for it.
            Positioned.fill(
              child: DailyTaskFab(
                bottomOffset: 16,
                visible: selectedIndex == 0,
              ),
            ),
          ],
        ),
      ),
      extendBody: false, // Prevents nested FABs and lists from overlapping with the navbar
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomPadding > 0 ? bottomPadding + 8 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                iconOutline: Icons.home_outlined,
                iconFilled: Icons.home_rounded,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => _onItemTapped(context, 0),
              ),
              _NavBarItem(
                iconOutline: Icons.auto_stories_outlined,
                iconFilled: Icons.auto_stories_rounded,
                label: 'Jurnal',
                isSelected: selectedIndex == 1,
                onTap: () => _onItemTapped(context, 1),
              ),
              _ChatNavButton(
                isSelected: selectedIndex == 2,
                onTap: () => _onItemTapped(context, 2),
              ),
              _NavBarItem(
                iconOutline: Icons.headphones_outlined,
                iconFilled: Icons.headphones_rounded,
                label: 'Musik',
                isSelected: selectedIndex == 3,
                onTap: () => _onItemTapped(context, 3),
              ),
              _NavBarItem(
                iconOutline: Icons.person_outline_rounded,
                iconFilled: Icons.person_rounded,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () => _onItemTapped(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData iconOutline;
  final IconData iconFilled;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconOutline,
    required this.iconFilled,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.mutedForeground;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.10) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? iconFilled : iconOutline,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


/// The hero Chat button in the center of the bottom navigation bar.
///
/// The AI chatbot is the app's flagship feature, so this item is rendered as a
/// clean elevated gradient circle that stands out from the flat side items.
class _ChatNavButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _ChatNavButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFB7185), Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(isSelected ? 0.50 : 0.35),
                blurRadius: isSelected ? 18 : 12,
                spreadRadius: isSelected ? 1 : 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
