import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/camera_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class EditAvatarScreen extends ConsumerStatefulWidget {
  final String currentAvatar;
  const EditAvatarScreen({super.key, required this.currentAvatar});

  @override
  ConsumerState<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends ConsumerState<EditAvatarScreen> {
  late String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final avatar = widget.currentAvatar.trim();

    _selectedAvatar = avatar.isNotEmpty && avatar != 'null' ? avatar : null;
  }

  XFile? _localImagePath;
  bool _isLoading = false;
  bool _isRemoved = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16181C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text(
              'Take a photo',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              final path = await ref
                  .read(mediaPickerServiceProvider)
                  .pickImageFromCamera();
              if (path != null) {
                setState(() {
                  _localImagePath = path;
                  _selectedAvatar = path.path;
                  _isRemoved = false;
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text(
              'Choose from gallery',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              final path = await ref
                  .read(mediaPickerServiceProvider)
                  .pickImageFromGallery();
              if (path != null) {
                setState(() {
                  _localImagePath = path;
                  _selectedAvatar = path.path;
                  _isRemoved = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _finishSetup() async {
    setState(() {
      _isLoading = true;
    });

    final profileService = ref.read(profileServiceProvider);
    final profileViewModel = ref.read(profileViewModelProvider.notifier);

    try {
      String? avatarUrl;
      if (_isRemoved) {
        avatarUrl = '';
      } else if (_localImagePath != null) {
        avatarUrl = await profileService.uploadAvatar(_localImagePath!.path);
      } else {
        avatarUrl = _selectedAvatar;
      }
      if (!mounted) return;
      await profileViewModel.updateProfile(avatarUrl: avatarUrl);
      if (!mounted) return;
      Navigator.pop(context, avatarUrl);
    } catch (e, stackTrace) {
      debugPrint('Failed to update avatar: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile photo: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Profile photo'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _finishSetup,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: CircleAvatar(
              radius: 90,
              backgroundColor: const Color(0xFF16181C),
              backgroundImage: _localImagePath != null
                  ? FileImage(File(_localImagePath!.path))
                  : (_selectedAvatar != null &&
                            _selectedAvatar!.isNotEmpty &&
                            _selectedAvatar != 'null'
                        ? NetworkImage(_selectedAvatar!)
                        : null),
              child:
                  (_localImagePath == null &&
                      (_selectedAvatar == null ||
                          _selectedAvatar!.isEmpty ||
                          _selectedAvatar == 'null'))
                  ? Icon(
                      Icons.person_outline_rounded,
                      size: 90,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
          ),
          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16181C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedAvatar != null && _selectedAvatar!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedAvatar = null;
                        _localImagePath = null;
                        _isRemoved = true;
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Remove current photo',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
