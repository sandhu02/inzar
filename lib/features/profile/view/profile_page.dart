import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/design_system/app_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.unauthenticated) {
              context.go('/sign-in');
            }
          },
          builder: (context, state) {
            final user = state.user;
            final name = user?.name ?? 'Ayesha Khan';
            final email = user?.email ?? 'ayesha@example.com';
            final initials = user?.initials ?? 'AK';
            final signInMethod = user?.signInMethod ?? 'Google';
            final reportCount = user?.reportCount ?? 12;

            return Column(
              children: [
                // Top App Bar: Back + Profile
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      children: [
                        // User Avatar
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: AppTypography.screenTitle.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // User Name
                        Text(
                          name,
                          style: AppTypography.headline.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Signed in badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.statusAiBadgeBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.statusAiBadgeBorder, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 14,
                                color: AppColors.statusAiBadgeText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Signed in with $signInMethod',
                                style: AppTypography.disclaimer.copyWith(
                                  color: AppColors.statusAiBadgeText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account Information Card (Page 12)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            children: [
                              _buildProfileRow('Display name', name),
                              const Divider(color: AppColors.border, height: 1),
                              _buildProfileRow('Email', email),
                              const Divider(color: AppColors.border, height: 1),
                              _buildProfileRow('Sign-in method', signInMethod),
                              const Divider(color: AppColors.border, height: 1),
                              _buildProfileRow('Password', user?.isPasswordSet == true ? '••••••••' : 'Not set'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Anonymous by default Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anonymous by default',
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Other people never see your name, email or exact position on reports.',
                                style: AppTypography.bodySecondary.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reports & Data Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            children: [
                              _buildProfileRow('My reports', '$reportCount'),
                              const Divider(color: AppColors.border, height: 1),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Preparing your report archive for download...')),
                                  );
                                },
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Download my data', style: AppTypography.body),
                                      const Icon(Icons.download_rounded, color: AppColors.textSecondary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Sign out button
                        AppButton(
                          label: 'Sign out',
                          variant: AppButtonVariant.secondaryDark,
                          isFullWidth: true,
                          height: 50,
                          borderRadius: 25,
                          onPressed: () {
                            context.read<AuthBloc>().add(const SignOutRequested());
                          },
                        ),
                        const SizedBox(height: 20),

                        // Delete account link
                        GestureDetector(
                          onTap: () {
                            _showDeleteDialog(context);
                          },
                          child: Text(
                            'Delete account',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.statusDeniedText,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently remove your account and disconnect your submitted reports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthBloc>().add(const DeleteAccountRequested());
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.statusDeniedText)),
          ),
        ],
      ),
    );
  }
}

