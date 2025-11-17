// lib/screens/farmer/add_produce_screen.dart
import 'dart:io';

import 'package:agrilink/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/produce_model.dart';
import '../../models/user_model.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class AddProduceScreen extends StatefulWidget {
  final AppUser user;

  const AddProduceScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddProduceScreenState createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();
  
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCrop;
  DateTime? _harvestDate;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Produce'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Selection
              _buildCropSelection(),
              SizedBox(height: 20),
              
              // Quantity Input
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity in kgs',
                  prefixIcon: Icon(Icons.scale),
                  suffixText: 'kgs',
                ),
                validator: Validators.validateQuantity,
              ),
              SizedBox(height: 16),
              
              // Price Input
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per kg',
                  hintText: 'Enter price per kilogram',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'KSh',
                ),
                validator: Validators.validatePrice,
              ),
              SizedBox(height: 16),
              
              // Harvest Date
              _buildHarvestDatePicker(),
              SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add any additional details about your produce...',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 20),
              
              // Image Upload
              _buildImageUploadSection(),
              SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Crop Type',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.cropTypes.map((crop) {
            final isSelected = _selectedCrop == crop['name'];
            return FilterChip(
              label: Text('${crop['icon']} ${crop['name']}'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCrop = selected ? crop['name'] : null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHarvestDatePicker() {
    return InkWell(
      onTap: _selectHarvestDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Harvest Date',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _harvestDate != null
                  ? _harvestDate!.formatDate()
                  : 'Select harvest date',
              style: TextStyle(
                color: _harvestDate != null 
                    ? AppColors.textPrimary 
                    : Colors.grey.shade500,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photos',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Show the quality of your produce (max 4 photos)',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 12),
        
        // Image Grid
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return _buildAddImageButton();
            }
            return _buildImageThumbnail(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _selectImages,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.primaryGreen),
            SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(_selectedImages[index] as File),
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
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProduce,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'List Produce',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _harvestDate = picked);
    }
  }

  Future<void> _selectImages() async {
    if (_selectedImages.length >= 4) {
      Helpers.showSnackBar(context, 'Maximum 4 photos allowed');
      return;
    }

    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (images != null) {
        final remainingSlots = 4 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();
        
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to select images: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduce() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCrop == null) {
      Helpers.showSnackBar(context, 'Please select a crop type', isError: true);
      return;
    }
    if (_harvestDate == null) {
      Helpers.showSnackBar(context, 'Please select harvest date', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _cloudinaryService.uploadImages(_selectedImages);
      }

      // Get crop data
      final crop = AppConstants.cropTypes.firstWhere(
        (c) => c['name'] == _selectedCrop,
      );

      // Create produce object
      final produce = Produce(
        id: 'produce_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: widget.user.uid,
        farmerName: widget.user.displayName,
        cropType: _selectedCrop!,
        cropIcon: crop['icon'],
        quantity: double.parse(_quantityController.text),
        unit: 'kg',
        pricePerUnit: double.parse(_priceController.text),
        harvestDate: _harvestDate!,
        shelfLifeDays: crop['shelfLife'],
        expiryDate: _harvestDate!.add(Duration(days: crop['shelfLife'])),
        imageUrls: imageUrls,
        description: _descriptionController.text,
        county: widget.user.county,
        location: widget.user.location,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.addProduce(produce);

      Helpers.showSnackBar(context, 'Produce listed successfully!');
      Navigator.pop(context);
      
    } catch (e) {
      Helpers.showSnackBar(context, 'Failed to list produce: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Listing Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.photo_camera,
              text: 'Take clear, well-lit photos of your produce',
            ),
            _HelpItem(
              icon: Icons.scale,
              text: 'Be accurate with quantity measurements',
            ),
            _HelpItem(
              icon: Icons.attach_money,
              text: 'Research current market prices for fair pricing',
            ),
            _HelpItem(
              icon: Icons.calendar_today,
              text: 'Freshness matters - provide accurate harvest dates',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({Key? key, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}