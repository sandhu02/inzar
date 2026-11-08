import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? email;

  const VerifyEmailPage({
    super.key,
    this.email,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  String _getDisplayEmail(BuildContext context) {
    if (widget.email != null && widget.email!.isNotEmpty) {
      return widget.email!;
    }
    final unverified = context.read<AuthBloc>().state.unverifiedEmail;
    if (unverified != null && unverified.isNotEmpty) {
      return unverified;
    }
    return 'your email';
  }

  void _onResend(BuildContext context) {
    if (_secondsRemaining > 0) return;

    final email = _getDisplayEmail(context);
    if (email.isEmpty || email == 'your email') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address found to resend to.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(ResendVerificationRequested(email: email));
    _startCooldownTimer();
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sign-in');
    }
  }

  void _onChangeEmail(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sign-up');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = _getDisplayEmail(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go('/map');
            } else if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: state.errorMessage!.contains('sent') ||
                          state.errorMessage!.contains('requested')
                      ? const Color(0xFF1B4E52)
                      : AppColors.primary,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top back button
                GestureDetector(
                  onTap: () => _onBack(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.0),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Mail icon container
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mail_outline_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  'Verify your email',
                  style: AppTypography.screenTitle.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'We sent a verification link to',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Open the link to finish setting up your account. If you don\'t see it, check your spam folder.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),

                // Resend email button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;

                    return AppButton(
                      label: 'Resend email',
                      variant: AppButtonVariant.secondaryLight,
                      isFullWidth: true,
                      height: 52,
                      borderRadius: 16,
                      isLoading: isLoading,
                      onPressed: _secondsRemaining > 0 || isLoading
                          ? null
                          : () => _onResend(context),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Countdown timer text
                Center(
                  child: Text(
                    _secondsRemaining > 0
                        ? 'You can resend again in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                        : 'Didn\'t receive the email? Tap Resend email',
                    style: AppTypography.disclaimer.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.8,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom footer: Wrong address? Change email
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wrong address? ',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onChangeEmail(context),
                          child: Text(
                            'Change email',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

