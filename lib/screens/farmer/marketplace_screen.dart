// lib/screens/farmer/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/produce_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Marketplace'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for produce...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Categories
          _buildCategoryFilter(),
          SizedBox(height: 8),
          
          // Market Stats
          _buildMarketStats(),
          SizedBox(height: 16),
          
          // Produce Listings
          Expanded(
            child: _buildProduceListings(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.cropTypes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All Crops',
              isSelected: _selectedCategory == 'all',
              onSelected: () => setState(() => _selectedCategory = 'all'),
            );
          }
          
          final crop = AppConstants.cropTypes[index - 1];
          return _CategoryChip(
            label: '${crop['icon']} ${crop['name']}',
            isSelected: _selectedCategory == crop['name'],
            onSelected: () => setState(() => _selectedCategory = crop['name']!),
          );
        },
      ),
    );
  }

  Widget _buildMarketStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _MarketStatItem(
            value: '1,234',
            label: 'Active Listings',
          ),
          SizedBox(width: 16),
          _MarketStatItem(
            value: 'KSh 2.5M',
            label: 'Total Value',
          ),
          SizedBox(width: 16),
          _MarketStatItem(
            value: '89%',
            label: 'Success Rate',
          ),
        ],
      ),
    );
  }

  Widget _buildProduceListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produce')
          .where('status', isEqualTo: 'available')
          // .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No produce listings available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        var produces = snapshot.data!.docs
            .map((doc) => Produce.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
          
        // Apply filters
        if (_selectedCategory != 'all') {
          produces = produces.where((p) => p.cropType == _selectedCategory).toList();
        }

        if (_searchQuery.isNotEmpty) {
          produces = produces.where((p) => 
            p.cropType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: produces.length,
          itemBuilder: (context, index) {
            return _MarketplaceProduceCard(produce: produces[index]);
          },
        );
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Add filter options here
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onSelected(),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryGreen.withOpacity(0.2),
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MarketStatItem extends StatelessWidget {
  final String value;
  final String label;

  const _MarketStatItem({
    Key? key,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceProduceCard extends StatelessWidget {
  final Produce produce;

  const _MarketplaceProduceCard({Key? key, required this.produce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      produce.cropIcon,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produce.cropType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'by ${produce.farmerName} • ${produce.county}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.favorite_border, color: Colors.grey),
              ],
            ),
            SizedBox(height: 12),
            
            // Images
            if (produce.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: produce.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          produce.imageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
            ],
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MarketDetailItem(
                  icon: Icons.scale,
                  value: '${produce.quantity} kgs',
                ),
                _MarketDetailItem(
                  icon: Icons.attach_money,
                  value: 'KSh ${produce.pricePerUnit}/kg',
                ),
                _MarketDetailItem(
                  icon: Icons.timer,
                  value: '${produce.daysUntilExpiry} days left',
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Description
            if (produce.description.isNotEmpty) ...[
              Text(
                produce.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
            ],
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.chat, size: 16),
                    label: Text('Make Offer'),
                    onPressed: () {
                      _showMakeOfferDialog(context, produce);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart, size: 16),
                    label: Text('Buy Now'),
                    onPressed: () {
                      _showBuyNowDialog(context, produce);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
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

  void _showMakeOfferDialog(BuildContext context, Produce produce) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make an offer for ${produce.cropType}'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Your Offer (KSh per kg)',
                prefixText: 'KSh ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Message (Optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Helpers.showSnackBar(context, 'Offer sent successfully!');
              Navigator.pop(context);
            },
            child: Text('Send Offer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyNowDialog(BuildContext context, Produce produce) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to purchase:'),
            SizedBox(height: 8),
            Text(
              '${produce.quantity} kgs of ${produce.cropType}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Total: KSh ${produce.totalPrice.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Helpers.showSnackBar(context, 'Purchase completed successfully!');
              Navigator.pop(context);
            },
            child: Text('Confirm Purchase'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MarketDetailItem({
    Key? key,
    required this.icon,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}