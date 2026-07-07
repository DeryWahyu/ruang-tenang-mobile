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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          setState(() => _emailSent = true);
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
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
              decoration: BoxDecoration(
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
            'Lupa Password?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.foreground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Masukkan email yang terdaftar dan kami akan mengirimkan link untuk reset password',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing2xl),

          // Email
          AppInput(
            label: 'Email',
            hint: 'Masukkan email terdaftar',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onSubmit(),
          ),
          const SizedBox(height: AppDimensions.spacingXl),

          // Submit button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return AppButton.primary(
                label: 'Kirim Link Reset',
                isLoading: state.isLoading,
                prefixIcon: Icons.send_rounded,
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
            decoration: BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),

        Text(
          'Email Terkirim!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.foreground,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Kami telah mengirimkan link reset password ke ${_emailController.text}. Silakan cek inbox atau folder spam kamu.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacing2xl),

        AppButton.primary(
          label: 'Kembali ke Login',
          prefixIcon: Icons.login_rounded,
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: AppDimensions.spacingBase),

        AppButton.outline(
          label: 'Kirim Ulang',
          prefixIcon: Icons.refresh_rounded,
          onPressed: () {
            setState(() => _emailSent = false);
          },
        ),
      ],
    );
  }
}
