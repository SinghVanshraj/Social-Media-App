// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class EditUsernameScreen extends ConsumerStatefulWidget {
  final String currentUsername;
  const EditUsernameScreen({super.key, required this.currentUsername});

  @override
  ConsumerState<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends ConsumerState<EditUsernameScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);

    final userId = SupabaseService.auth.currentUser;

    if (userId == null) {
      debugPrint('ProfileView: No authenticated user');
      return;
    }

    if (!mounted) return;
    Future.microtask(() {
      ref.read(profileViewModelProvider.notifier).loadProfile(userId.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(profileViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Username'),
        actions: [
          TextButton(
            onPressed: () async {
              final username = _controller.text.toLowerCase().trim();
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username cannot be empty')),
                );
                return;
              }
              final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
              if (!usernameRegex.hasMatch(username)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Username can only contain letters, numbers, and underscores.',
                    ),
                  ),
                );
                return;
              }
              if (username == widget.currentUsername.trim().toLowerCase()) {
                Navigator.pop(context, true);
              }
              try {
                final available = await state.checkUsername(username);
                if (!available) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username is already taken')),
                  );
                  return;
                }
                await state.updateProfile(username: username);
                if (!mounted) return;

                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update username: $e')),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                prefixText: '@ ',
                prefixStyle: TextStyle(
                  color: Colors.blueAccent[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Usernames must be unique and can contain letters, numbers, and underscores.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
