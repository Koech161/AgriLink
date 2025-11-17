// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../widgets/image_card.dart';
import '../widgets/upload_fab.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../services/cloudinary_service.dart';
import '../models/cloudinary_image.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  List<CloudinaryImage> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    // Simulate loading from local storage or API
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _images = []; // Replace with actual images
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.photo_library, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'AgriGallery',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _onRefresh,
        color: AppColors.primaryGreen,
        height: 150,
        backgroundColor: AppColors.lightGreen,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: _buildContent(),
      ),
      floatingActionButton: UploadFAB(onImagesUploaded: _loadImages),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return LoadingShimmer();
    }

    if (_images.isEmpty) {
      return EmptyState(
        title: 'No Images Yet',
        message: 'Start uploading your farm photos to build your gallery',
        icon: Icons.photo_library_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return ImageCard(image: _images[index]);
        },
      ),
    );
  }
}