import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/router/go_router_refresh_stream.dart';
import 'core/theme/app_theme.dart';
import 'presentation/common/widgets/gradient_background.dart';
import 'presentation/music/widgets/global_mini_player.dart';
import 'presentation/gamification/widgets/daily_task_fab.dart';
import 'presentation/common/cubit/connectivity_cubit.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/journal/bloc/journal_bloc.dart';
import 'presentation/mood/bloc/mood_bloc.dart';
import 'presentation/chat/bloc/chat_bloc.dart';

class RuangTenangApp extends StatefulWidget {
  const RuangTenangApp({super.key});

  @override
  State<RuangTenangApp> createState() => _RuangTenangAppState();
}

class _RuangTenangAppState extends State<RuangTenangApp> {
  late final GoRouterRefreshStream _refreshStream;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Use the lazy singleton instance of AuthBloc so the stream matches
    // the state inspected in the router redirect logic.
    _refreshStream = GoRouterRefreshStream(sl<AuthBloc>().stream);
    _router = AppRouter.createRouter(refreshListenable: _refreshStream);
  }

  @override
  void dispose() {
    _refreshStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<JournalBloc>(
          create: (_) => sl<JournalBloc>(),
        ),
        BlocProvider<MoodBloc>(
          create: (_) => sl<MoodBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ruang Tenang',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        builder: (context, child) {
          // Batasi skala teks sistem (0.85–1.3) agar pengaturan font ekstrem
          // pada perangkat lama tidak merusak tata letak.
          final mq = MediaQuery.of(context);
          final clampedScaler = mq.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.3,
          );
          return MediaQuery(
            data: mq.copyWith(textScaler: clampedScaler),
            child: GradientBackground(
              child: _GlobalOverlay(
                router: _router,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Menempatkan elemen global (mini-player musik & FAB tugas harian) di atas
/// konten agar **mengikuti seluruh layar** — selaras dengan web yang
/// menampilkan keduanya pada dashboard layout.
///
/// Pembagian tanggung jawab (anti-tumpang-tindih):
/// - Rute **shell** (punya bottom-nav MainLayout): mini-player & FAB dirender
///   oleh MainLayout sendiri dengan offset per-tab yang tepat. Overlay ini
///   tidak ikut campur agar tidak terjadi dobel.
/// - Rute **non-shell** (di-push, tanpa bottom-nav): overlay menampilkan
///   mini-player di atas safe-area dan FAB di atasnya (dinaikkan lagi bila
///   layar punya FAB sendiri seperti Forum).
class _GlobalOverlay extends StatelessWidget {
  final Widget child;
  final GoRouter router;

  const _GlobalOverlay({required this.child, required this.router});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Rebuild saat lokasi rute berubah.
      animation: router.routerDelegate,
      builder: (context, _) {
        final location = router.routerDelegate.currentConfiguration.uri.path;

        // Hanya tampil pada area terautentikasi (bukan splash/onboarding/auth).
        if (!AppRouter.showsGlobalMiniPlayer(location)) {
          return child;
        }

        final inShell = AppRouter.isShellLocation(location);
        final safeBottom = MediaQuery.of(context).padding.bottom;

        // Konten dasar: untuk rute shell, MainLayout sudah menangani
        // mini-player & FAB. Untuk non-shell, overlay menambahkannya di sini.
        Widget content;
        if (inShell) {
          content = child;
        } else {
          final fabBottom = safeBottom + (AppRouter.hasOwnFab(location) ? 88.0 : 20.0);
          content = Stack(
            children: [
              child,
              Positioned(
                left: 0,
                right: 0,
                bottom: safeBottom + 8,
                child: const GlobalMiniPlayer(),
              ),
              Positioned.fill(
                child: DailyTaskFab(bottomOffset: fabBottom),
              ),
            ],
          );
        }

        // Banner offline melayang di atas konten (kecuali di layar game).
        final showBanner = location != '/game';
        return Stack(
          children: [
            content,
            if (showBanner)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _OfflineBanner(router: router),
              ),
          ],
        );
      },
    );
  }
}

/// Banner tipis di atas layar yang muncul saat perangkat offline, mengajak
/// pengguna memainkan Mini Game (yang berfungsi penuh tanpa internet).
class _OfflineBanner extends StatelessWidget {
  final GoRouter router;
  const _OfflineBanner({required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        if (isOnline) return const SizedBox.shrink();
        final topPad = MediaQuery.of(context).padding.top;
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.fromLTRB(12, topPad + 8, 12, 8),
            color: const Color(0xFF374151),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kamu sedang offline. Yuk main sambil menunggu koneksi.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  onPressed: () => router.push('/game'),
                  child: const Text('Main', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
