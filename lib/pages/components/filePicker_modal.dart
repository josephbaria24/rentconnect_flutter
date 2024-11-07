import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerModal extends StatelessWidget {
  final Function(File? imageFile) onImageSelected;

  ImagePickerModal({required this.onImageSelected});

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text(
              'Pick from Gallery',
              style: TextStyle(fontFamily: 'manrope'),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              // Use FilePicker to select an image from the gallery
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null && result.files.single.path != null) {
                File selectedImage = File(result.files.single.path!);
                onImageSelected(selectedImage); // Pass the selected image
                print('Image selected from gallery: ${result.files.single.path}');
              } else {
                print('No image selected.');
                onImageSelected(null);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text(
              'Take Photo',
              style: TextStyle(fontFamily: 'manrope'),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              // Use ImagePicker to capture an image using the camera
              final pickedFile = await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                File capturedImage = File(pickedFile.path);
                onImageSelected(capturedImage); // Pass the captured image
                print('Image captured with camera: ${pickedFile.path}');
              } else {
                print('No image captured.');
                onImageSelected(null);
              }
            },
          ),
        ],
      ),
    );
  }
}
