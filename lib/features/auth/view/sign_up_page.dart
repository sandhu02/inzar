import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          SignUpSubmitted(name: name, email: email, password: password),
        );
    context.go('/map');
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go('/map');
            }
          },
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 16),

                  // Title: Create your account.
                  Text(
                    'Create your account.',
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle: Your name is never shown on reports.
                  Text(
                    'Your name is never shown on reports.',
                    style: AppTypography.bodySecondary.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // NAME label
                  Text(
                    'NAME',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),

                  // Name input
                  TextField(
                    controller: _nameController,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Display name',
                      hintStyle: AppTypography.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // EMAIL label
                  Text(
                    'EMAIL',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),

                  // Email input
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: AppTypography.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD label
                  Text(
                    'PASSWORD',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 8),

                  // Password input
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'At least 8 characters',
                      hintStyle: AppTypography.bodySecondary,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Create account Button
                  AppButton(
                    label: 'Create account',
                    variant: AppButtonVariant.secondaryLight,
                    isFullWidth: true,
                    height: 52,
                    borderRadius: 16,
                    isLoading: isLoading,
                    onPressed: _onSignUp,
                  ),
                  const SizedBox(height: 20),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTypography.technicalSub.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border, height: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Continue with Google Button
                  AppButton(
                    label: 'Continue with Google',
                    variant: AppButtonVariant.secondaryDark,
                    isFullWidth: true,
                    height: 52,
                    borderRadius: 16,
                    leading: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF101318),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    onPressed: _onGoogleSignIn,
                  ),
                  const SizedBox(height: 18),

                  // Terms note
                  Center(
                    child: Text(
                      'By continuing you accept the Terms and Privacy Policy.',
                      style: AppTypography.disclaimer.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Have an account? Sign in
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Have an account? ',
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

