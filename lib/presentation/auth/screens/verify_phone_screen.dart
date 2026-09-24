import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _number = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  bool _phoneRequired = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneRequired = context.read<AuthBloc>().state.phoneRequired;
  }

  @override
  void dispose() {
    _number.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode(String challenge) async {
    final error = Validators.whatsappNumber(_number.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sl<AuthRepository>().setVerificationPhone(
        challenge: challenge,
        whatsappNumber: _number.text.trim(),
      );
      if (mounted) setState(() => _phoneRequired = false);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Gagal mengirim kode. Coba login kembali.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(String challenge) async {
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) {
      setState(() => _error = 'Masukkan 6 digit kode OTP');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await sl<AuthRepository>().verifyPhone(
        challenge: challenge,
        code: _code.text.trim(),
      );
      if (mounted) context.read<AuthBloc>().add(const AuthCheckRequested());
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Kode OTP tidak valid atau kedaluwarsa');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verifikasi WhatsApp')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final challenge = state.verificationToken;
                  if (challenge == null || challenge.isEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sesi verifikasi berakhir. Silakan login kembali.',
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Kembali ke login'),
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Kode OTP berlaku 10 menit dan dikirim lewat WhatsApp.',
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (_phoneRequired) ...[
                        const Text(
                          'Tambahkan nomor WhatsApp untuk menerima kode.',
                        ),
                        TextField(
                          controller: _number,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor WhatsApp',
                            hintText: '081234567890',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _busy ? null : () => _sendCode(challenge),
                          child: const Text('Kirim kode'),
                        ),
                      ] else ...[
                        TextField(
                          controller: _code,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          decoration: const InputDecoration(
                            labelText: 'Kode OTP',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _busy ? null : () => _verify(challenge),
                          child: const Text('Verifikasi dan masuk'),
                        ),
                      ],
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Kembali ke login untuk meminta kode baru',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
