// lib/widgets/upload_fab.dart
import 'package:flutter/material.dart';
import '../screens/upload_screen.dart';
import '../utils/constants.dart';

class UploadFAB extends StatelessWidget {
  final Function()? onImagesUploaded;

  const UploadFAB({Key? key, this.onImagesUploaded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadScreen(
              onUploadComplete: (urls) {
                onImagesUploaded?.call();
              },
            ),
          ),
        );
      },
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 8,
      child: Icon(Icons.add, size: 28),
    );
  }
}