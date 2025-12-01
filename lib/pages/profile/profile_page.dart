import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/widgets/index.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      await ref.read(authProvider.notifier).updateProfile(
            _nameController.text,
            _bioController.text,
          );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Info (Editable)
            if (_isEditing)
              Column(
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    controller: _bioController,
                    maxLines: 3,
                    minLines: 3,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Save Changes',
                    isLoading: _isSaving,
                    onPressed: _saveProfile,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Cancel',
                    onPressed: () {
                      setState(() => _isEditing = false);
                      final user = ref.read(authProvider).user;
                      _nameController.text = user?.name ?? '';
                      _bioController.text = user?.bio ?? '';
                    },
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.bio!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 40),

            // Stats
            if (!_isEditing)
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Text(
                            '245',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Items',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Text(
                            '1.2K',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Followers',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        children: [
                          Text(
                            '856',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Following',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            if (!_isEditing) ...[
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Go to Settings',
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
