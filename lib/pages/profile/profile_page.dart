import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/providers/friends_provider.dart';
import 'package:life_stream/widgets/index.dart';
import 'package:life_stream/utils/error_handler.dart';
import 'package:life_stream/utils/snackbar_utils.dart';

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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256, // Aggressive reduction
        maxHeight: 256,
        imageQuality: 50, // High compression
      );
      if (image == null) return;

      setState(() => _isSaving = true);

      // Use AuthProvider to update image
      await ref.read(authProvider.notifier).updateProfileImage(image);

      if (mounted) {
        SnackbarUtils.showSuccessSnackBar(
          context,
          'Profile photo updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getReadableErrorMessage(e);
        SnackbarUtils.showErrorSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(authProvider.notifier)
          .updateProfile(_nameController.text, _bioController.text);

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
            UserAvatar(
              profilePictureUrl: user?.profilePictureUrl,
              name: user?.name ?? 'User',
              radius: 60,
              onTap: _isSaving ? null : _pickImage,
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
                  const SizedBox(height: 24),
                  // Friend Count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ref.watch(friendsProvider).friends.length} Friends',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),

            if (!_isEditing) ...[
              PrimaryButton(
                label: 'Go to Settings',
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(height: 12),
              // Logout Button
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: _handleLogout,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
