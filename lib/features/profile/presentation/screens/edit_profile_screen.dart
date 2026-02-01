import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _orgDescController = TextEditingController();
  bool _notifications = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        _nameController.text = user.isOrganization ? (user.organizationName ?? user.name) : user.name;
        _bioController.text = user.bio ?? '';
        _orgDescController.text = user.organizationDescription ?? '';
        _notifications = user.notificationsEnabled;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isOrg = user?.isOrganization ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), actions: [TextButton(onPressed: _isSaving ? null : _save, child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _nameController, decoration: InputDecoration(labelText: isOrg ? 'Organization Name' : 'Display Name', prefixIcon: const Icon(Icons.person))),
        const SizedBox(height: 16),
        TextField(controller: isOrg ? _orgDescController : _bioController, decoration: InputDecoration(labelText: isOrg ? 'Organization Description' : 'Bio', prefixIcon: const Icon(Icons.description), alignLabelWithHint: true), maxLines: 3),
        const SizedBox(height: 24),
        SwitchListTile(title: const Text('Push Notifications'), subtitle: const Text('Get notified about missions'), value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
      ]),
    );
  }

  Future<void> _save() async {
    final user = ref.read(userProvider);
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{'notificationsEnabled': _notifications};
      if (user.isOrganization) {
        updates['organizationName'] = _nameController.text.trim();
        updates['organizationDescription'] = _orgDescController.text.trim();
      } else {
        updates['name'] = _nameController.text.trim();
        updates['bio'] = _bioController.text.trim();
      }
      await ref.read(firebaseServiceProvider).updateUserField(user.uid, updates);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.success)); Navigator.pop(context); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() { _nameController.dispose(); _bioController.dispose(); _orgDescController.dispose(); super.dispose(); }
}
