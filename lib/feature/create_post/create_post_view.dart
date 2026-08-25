import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/camera_service.dart';
import 'package:social_media_app/core/services/post_service.dart';
import 'package:social_media_app/feature/profile/profile_view_model.dart';

class CreatePostView extends ConsumerStatefulWidget {
  const CreatePostView({super.key});

  @override
  ConsumerState<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends ConsumerState<CreatePostView> {
  final TextEditingController _contentController = TextEditingController();
  String? _postError;
  bool _isLoading = false;
  final List<XFile> _localImagePaths = [];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16181C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
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
                setState(() => _localImagePaths.add(path));
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
              final paths = await ref
                  .read(mediaPickerServiceProvider)
                  .pickMultipleMedia();
              if (paths.isNotEmpty) {
                setState(() => _localImagePaths.addAll(paths));
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    if (_localImagePaths.isEmpty && content.isEmpty) {
      setState(() => _postError = 'Post must have text or image');
      return;
    }

    setState(() {
      _isLoading = true;
      _postError = null;
    });

    try {
      await ref
          .read(postServiceProvider)
          .createPost(
            _localImagePaths.isEmpty ? null : _localImagePaths,
            content.isEmpty ? null : content,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _postError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileViewModelProvider).user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF16181C),
                  backgroundImage: profile?.avatarUrl != null
                      ? NetworkImage(profile!.avatarUrl!)
                      : null,
                  child: profile?.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "What's happening?",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            if (_postError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _postError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),

            if (_localImagePaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _localImagePaths.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _localImagePaths.length) {
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16181C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[800]!),
                            ),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                        );
                      }

                      final media = _localImagePaths[index];

                      final extension = media.path
                          .split('.')
                          .last
                          .toLowerCase();

                      final isVideo =
                          media.mimeType?.startsWith('video/') == true ||
                          [
                            'mp4',
                            'mov',
                            'm4v',
                            'webm',
                            'avi',
                            'mkv',
                          ].contains(extension);

                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Container(
                                      color: const Color(0xFF16181C),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(media.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _localImagePaths.removeAt(index),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, -MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[900]!, width: 0.5),
            ),
            color: Colors.black,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.image_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: const Icon(
                  Icons.gif_box_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.sentiment_satisfied_alt_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
