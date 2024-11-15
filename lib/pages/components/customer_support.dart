import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart'; // To send email
import 'package:get/get.dart';
import 'package:rentcon/pages/toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Assuming ToastNotification class is in this file

class CustomerSupportModal {
  // Function to open a centered dialog and capture user input
  static void openSupportModal(BuildContext context) {
    TextEditingController _textController = TextEditingController();
    XFile? _imageFile; // To hold the selected image file
    final picker = ImagePicker();
    final ToastNotification toastNotification = ToastNotification(context); // Initialize the ToastNotification

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit a Question or Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'manrope'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Describe your issue or question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                Text('Upload screenshot of the problem you encountered',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'manrope')),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      _imageFile = pickedFile;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 177, 177, 177),
                    ),
                    
                    height: 70,
                    child: _imageFile == null
                        ? const Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo),
                            Text('Tap to select a photo.'),
                          ],
                        ))
                        : Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 10),
                ShadButton(
                  backgroundColor: Colors.amber,
                  onPressed: () async {
                    final email = Email(
                      body: 'Question/Issue: ${_textController.text}',
                      subject: 'Customer Support Request',
                      recipients: ['rentconnect.it@gmail.com'],
                      attachmentPaths: _imageFile != null ? [_imageFile!.path] : [],
                      isHTML: false,
                    );

                    try {
                      await FlutterEmailSender.send(email);
                      // Show success message using ToastNotification
                      toastNotification.success('Your request has been sent!');
                      // Clear the text field and image after submission
                      _textController.clear();
                      _imageFile = null;
                      Navigator.pop(context); // Close the dialog
                    } catch (e) {
                      // Show error message if email fails to send
                      toastNotification.error('Failed to send your request. Please try again.');
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
