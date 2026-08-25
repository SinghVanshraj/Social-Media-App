import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    return await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }

  Future<XFile?> pickVideoFromCamera() async {
    return await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(minutes: 5),
    );
  }

  Future<XFile?> pickImageFromGallery() async {
    return await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
  }

  Future<XFile?> pickVideoFromGallery() async {
    return await _imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(minutes: 5),
    );
  }

  Future<List<XFile>> pickMultipleMedia() async {
    return await _imagePicker.pickMultipleMedia(imageQuality: 80);
  }
}

final mediaPickerServiceProvider = Provider((_) => CameraService());
