import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/router/go_router_refresh_stream.dart';
import 'core/theme/app_theme.dart';
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
      ],
      child: MaterialApp.router(
        title: 'Ruang Tenang',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
