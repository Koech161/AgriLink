// lib/screens/upload_screen.dart
import 'dart:io';

import 'package:agrilink/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../utils/constants.dart';

class UploadScreen extends StatefulWidget {
  final Function(List<String>)? onUploadComplete;

  const UploadScreen({Key? key, this.onUploadComplete}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images != null) {
        setState(() {
          _selectedFiles.addAll(images);
        });
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final uploadedUrls = await _cloudinaryService.uploadImages(_selectedFiles);
      
      if (uploadedUrls.isNotEmpty) {
        widget.onUploadComplete?.call(uploadedUrls);
        Navigator.of(context).pop();
        _showSuccessMessage();
      }
    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreen,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Images uploaded successfully!'),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Upload Images'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload Progress
            if (_isUploading) ...[
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: AppColors.lightGreen,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
              SizedBox(height: 16),
              Text(
                'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
            ],

            // Selected Images Grid
            Expanded(
              child: _selectedFiles.isEmpty
                  ? EmptyState(
                      title: 'No Images Selected',
                      message: 'Tap the + button to select farm photos',
                      icon: Icons.add_photo_alternate_outlined,
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(_selectedFiles[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Action Buttons
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Add Photos'),
                    onPressed: _isUploading ? null : _pickImages,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isUploading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.cloud_upload),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                    onPressed: _isUploading || _selectedFiles.isEmpty
                        ? null
                        : _uploadImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}