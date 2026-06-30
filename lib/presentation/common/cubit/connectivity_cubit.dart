import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Memantau status konektivitas perangkat secara real-time.
///
/// Memancarkan `true` saat online dan `false` saat offline. Dipakai untuk
/// menampilkan banner offline + ajakan bermain Mini Game (yang berjalan
/// sepenuhnya tanpa internet).
class ConnectivityCubit extends Cubit<bool> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(true) {
    _init();
  }

  Future<void> _init() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      emit(_isOnline(initial));
    } catch (_) {
      emit(true); // anggap online bila gagal cek (hindari false alarm)
    }
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      emit(_isOnline(results));
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
