import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/services/supabase_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class EditNameScreen extends ConsumerStatefulWidget {
  final String currentName;
  const EditNameScreen({super.key, required this.currentName});

  @override
  ConsumerState<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends ConsumerState<EditNameScreen> {

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
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
        title: const Text('Name'),
        actions: [
          TextButton(
            onPressed: () async {
              state.updateProfile(fullname: _controller.text.trim());
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
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          ),
        ),
      ),
    );
  }
}