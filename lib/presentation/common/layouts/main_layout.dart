import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
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
          },
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.red50,
          surfaceTintColor: Colors.transparent,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.mutedForeground),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined, color: AppColors.mutedForeground),
              selectedIcon: Icon(Icons.book_rounded, color: AppColors.primary),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_outlined, color: AppColors.mutedForeground),
              selectedIcon: Icon(Icons.chat_rounded, color: AppColors.primary),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.music_note_outlined, color: AppColors.mutedForeground),
              selectedIcon: Icon(Icons.music_note_rounded, color: AppColors.primary),
              label: 'Music',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.mutedForeground),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
