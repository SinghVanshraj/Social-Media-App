import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/camera_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class ProfileSetupView extends ConsumerStatefulWidget {
  const ProfileSetupView({super.key});

  @override
  ConsumerState<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends ConsumerState<ProfileSetupView> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _usernameError;
  XFile? _localImagePath;
  bool _isLoading = false;

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
              Navigator.pop(context);

              final path = await ref
                  .read(mediaPickerServiceProvider)
                  .pickImageFromCamera();

              if (path != null) {
                setState(() {
                  _localImagePath = path;
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
              Navigator.pop(context);

              final path = await ref
                  .read(mediaPickerServiceProvider)
                  .pickImageFromGallery();

              if (path != null) {
                setState(() {
                  _localImagePath = path;
                });
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _finishSetup({bool skipOptional = false}) async {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      setState(() => _usernameError = 'Username is required');
      return;
    }

    if (username.length < 3) {
      setState(() => _usernameError = 'Username must be at least 3 characters');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(
        () => _usernameError = 'Only letters, numbers and underscores allowed',
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _usernameError = null;
    });

    try {
      final isAvailable = await ref
          .read(profileViewModelProvider.notifier)
          .checkUsername(username);

      if (!isAvailable) {
        setState(() {
          _isLoading = false;
          _usernameError = 'Username already taken';
        });
        return;
      }

      String? avatarUrl;
      if (!skipOptional && _localImagePath != null) {
        avatarUrl = await ref
            .read(profileServiceProvider)
            .uploadAvatar(_localImagePath!.path);
      }
      await ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(
            username: username,
            avatarUrl: avatarUrl,
            bio: skipOptional ? '' : bio,
          );

      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      setState(() {
        _usernameError = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading:
            false,
        actions: [
          TextButton(
            onPressed: () =>
                _isLoading || _usernameController.text.trim().isEmpty
                ? null
                : _finishSetup(skipOptional: true),
            child: Text(
              "Skip",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Set up your profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tell the world who you are. You can always change this later.",
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                    const SizedBox(height: 36),

                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF16181C),
                              backgroundImage: _localImagePath != null
                                  ? FileImage(File(_localImagePath!.path))
                                  : null,
                              child: _localImagePath == null
                                  ? Icon(
                                      Icons.person_outline_rounded,
                                      size: 40,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent[400],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _localImagePath != null
                                      ? Icons.edit_rounded
                                      : Icons.add_a_photo_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildLabel("Username"),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF16181C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[900]!, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        onChanged: (_) => setState(() {
                          _usernameError = null;
                        }),
                        decoration: InputDecoration(
                          prefixText: "@ ",
                          prefixStyle: TextStyle(
                            color: _usernameError != null
                                ? Colors.redAccent
                                : Colors.blueAccent[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintText: "unique_handle",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          errorText: _usernameError,
                          errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel("Bio"),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF16181C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[900]!, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 160,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              "Describe yourself, your work, or your stack...",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          counterStyle: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _finishSetup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Finish Setup",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
