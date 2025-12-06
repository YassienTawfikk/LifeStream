import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/providers/auth_provider.dart';
import 'package:life_stream/widgets/buttons.dart';
import 'package:life_stream/widgets/text_field.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }

      try {
        await ref
            .read(authProvider.notifier)
            .changePassword(
              _currentPasswordController.text,
              _newPasswordController.text,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create a new password. Ensure it differs from previous ones for security.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: _currentPasswordController,
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _newPasswordController,
                obscureText: true,
                validator: (v) => v!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Confirm new password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: authState.isLoading ? () {} : _submit,
                label: 'Change Password',
                isLoading: authState.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
