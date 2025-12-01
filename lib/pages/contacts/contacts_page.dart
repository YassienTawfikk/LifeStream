// File: LifeStream/lib/pages/contacts/contacts_page.dart (New File)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_stream/constants/index.dart';
import 'package:life_stream/widgets/index.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Dr. Mohamed ElSayed', 'phone': '+201001234567', 'relation': 'Physician'},
    {'name': 'Aya Tawfik', 'phone': '+201009876543', 'relation': 'Sister'},
  ];

  void _addContact(String name, String phone, String relation) {
    setState(() {
      _contacts.add({'name': name, 'phone': phone, 'relation': relation});
    });
    Navigator.pop(context); // Close dialog
  }

  void _removeContact(int index) {
    // Note: To avoid index out of bounds after deletion, we need a slight adjustment
    final removedContactName = _contacts[index]['name'];
    setState(() {
      _contacts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$removedContactName removed from contacts.')),
    );
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Emergency Contact', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Name',
                hint: 'John Doe',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone',
                hint: '+201000000000',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Relation',
                hint: 'Family/Friend/Doctor',
                controller: relationController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                _addContact(nameController.text, phoneController.text, relationController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddContactDialog,
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? EmptyStateWidget(
              icon: Icons.supervisor_account_outlined,
              title: 'No Contacts Added',
              description: 'Add contacts to be notified in an emergency.',
              onRetry: _showAddContactDialog,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return AppCard(
                  onTap: () {},
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(contact['name']!, style: AppTextStyles.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact['phone']!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        if (contact['relation']!.isNotEmpty)
                          Text('Relation: ${contact['relation']}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.lightError),
                      onPressed: () => _removeContact(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}