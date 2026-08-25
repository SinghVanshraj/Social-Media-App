// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class EditBioScreen extends ConsumerStatefulWidget {
  final String currentBio;
  const EditBioScreen({super.key, required this.currentBio});

  @override
  ConsumerState<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends ConsumerState<EditBioScreen> {

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBio);
    final userId = SupabaseService.auth.currentUser;

    if (userId == null) {
      debugPrint('ProfileView: No authenticated user');
      return;
    }

    if(!mounted) return;
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
        title: const Text('Bio'),
        actions: [
          TextButton(
            onPressed: () async {
              await state.updateProfile(bio: _controller.text.trim());
              if(!mounted) return;
              Navigator.pop(context, true);
            },
            child: const Text('Save', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 5,
          maxLength: 160,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          decoration: InputDecoration(
            hintText: 'Describe yourself...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            counterStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}