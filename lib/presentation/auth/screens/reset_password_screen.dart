import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_input.dart';
import '../../common/widgets/gradient_background.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthResetPasswordRequested(
              token: widget.token,
              password: _passwordController.text,
              passwordConfirmation: _confirmPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          setState(() => _resetSuccess = true);
        }
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
      },
      child: GradientBackground(
        intensity: 2.5,
        child: Scaffold(
          backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            child: _resetSuccess ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    ));
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.red50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Title
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.foreground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Masukkan password baru untuk akunmu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing2xl),

          // New password
          AppInput(
            label: 'Password Baru',
            hint: 'Masukkan password baru',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: Validators.password,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDimensions.spacingBase),

          // Confirm password
          AppInput(
            label: 'Konfirmasi Password',
            hint: 'Masukkan ulang password baru',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: (value) => Validators.confirmPassword(
              value,
              _passwordController.text,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onSubmit(),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Submit button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return AppButton.primary(
                label: 'Reset Password',
                isLoading: state.isLoading,
                prefixIcon: Icons.check_rounded,
                onPressed: _onSubmit,
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingBase),

          // Back to login
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Kembali ke Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimensions.spacing3xl),

        // Success icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),

        Text(
          'Password Berhasil Direset!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.foreground,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Password kamu sudah diperbarui. Silakan login dengan password baru.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing2xl),

        AppButton.primary(
          label: 'Masuk Sekarang',
          prefixIcon: Icons.login_rounded,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
