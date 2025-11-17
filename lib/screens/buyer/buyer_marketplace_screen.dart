// lib/screens/buyer/buyer_marketplace_screen.dart
import 'package:agrilink/utils/extensions.dart';
import 'package:agrilink/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/produce_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  @override
  _BuyerMarketplaceScreenState createState() => _BuyerMarketplaceScreenState();
}

// Add to existing widgets
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
class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'newest';
  double _priceRangeStart = 0;
  double _priceRangeEnd = 1000;

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
                hintText: 'Search for produce, farmers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Categories
          _buildCategoryFilter(),
          SizedBox(height: 8),
          
          // Sort & Filter Chips
          _buildSortFilterChips(),
          SizedBox(height: 8),
          
          // Results Count
          _buildResultsCount(),
          SizedBox(height: 8),
          
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
              label: 'All',
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

  Widget _buildSortFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text('Newest'),
            selected: _sortBy == 'newest',
            onSelected: (selected) => setState(() => _sortBy = 'newest'),
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Price: Low to High'),
            selected: _sortBy == 'price_low',
            onSelected: (selected) => setState(() => _sortBy = 'price_low'),
          ),
          SizedBox(width: 8),
          FilterChip(
            label: Text('Price: High to Low'),
            selected: _sortBy == 'price_high',
            onSelected: (selected) => setState(() => _sortBy = 'price_high'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produce')
          .where('status', isEqualTo: 'available')
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$count products found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProduceListings() {
    Query query = FirebaseFirestore.instance
        .collection('produce')
        .where('status', isEqualTo: 'available');

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        query = query.orderBy('createdAt', descending: true);
        break;
      case 'price_low':
        query = query.orderBy('pricePerUnit', descending: false);
        break;
      case 'price_high':
        query = query.orderBy('pricePerUnit', descending: true);
        break;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyState(
            icon: Icons.store,
            title: 'No Produce Available',
            message: 'Check back later for fresh listings',
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
            p.farmerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        // Apply price range filter
        produces = produces.where((p) => 
          p.pricePerUnit >= _priceRangeStart && p.pricePerUnit <= _priceRangeEnd
        ).toList();

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: produces.length,
          itemBuilder: (context, index) {
            return _BuyerProduceCard(produce: produces[index]);
          },
        );
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Price Range
            Text(
              'Price Range (KSh per kg)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_priceRangeStart, _priceRangeEnd),
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                'KSh ${_priceRangeStart.toInt()}',
                'KSh ${_priceRangeEnd.toInt()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRangeStart = values.start;
                  _priceRangeEnd = values.end;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Location Filter
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.kenyanCounties.take(6).map((county) {
                return FilterChip(
                  label: Text(county),
                  onSelected: (selected) {},
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            
            // Freshness Filter
            Text(
              'Harvest Date',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: Text('Last 7 days'), onSelected: (selected) {}),
                FilterChip(label: Text('Last 30 days'), onSelected: (selected) {}),
                FilterChip(label: Text('Any time'), onSelected: (selected) {}),
              ],
            ),
            
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
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

// Buyer Produce Card
class _BuyerProduceCard extends StatelessWidget {
  final Produce produce;
  final bool isFavorite = false;

  const _BuyerProduceCard({Key? key, required this.produce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Farmer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(Icons.person, size: 16, color: AppColors.primaryGreen),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produce.farmerName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        produce.county,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    Helpers.showSnackBar(context, 
                      isFavorite ? 'Removed from favorites' : 'Added to favorites'
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Produce Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                    image: produce.imageUrls.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(produce.imageUrls.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: produce.imageUrls.isEmpty
                      ? Center(
                          child: Text(
                            produce.cropIcon,
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12),
                
                // Details
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
                      SizedBox(height: 4),
                      Text(
                        '${produce.quantity} kgs available',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Harvested ${produce.harvestDate.formatDate()}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 12, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            '${produce.daysUntilExpiry} days until expiry',
                            style: TextStyle(
                              fontSize: 10,
                              color: produce.isNearExpiry ? Colors.orange : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price & Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KSh ${produce.pricePerUnit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      'per kg',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildActionButtons(context),
                  ],
                ),
              ],
            ),
            
            // Description
            if (produce.description.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                produce.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Quick Buy Button
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.shopping_cart, size: 16, color: Colors.white),
            onPressed: () {
              _showQuickBuyDialog(context);
            },
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(width: 8),
        
        // Make Offer Button
        OutlinedButton(
          onPressed: () {
            _showMakeOfferDialog(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            side: BorderSide(color: AppColors.primaryGreen),
          ),
          child: Text(
            'Offer',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showQuickBuyDialog(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Buy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buy ${produce.cropType} from ${produce.farmerName}'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Quantity (kgs)',
                hintText: 'Enter quantity to purchase',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Text('Total: KSh [calculated]'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Helpers.showSnackBar(context, 'Order placed successfully!');
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

  void _showMakeOfferDialog(context) {
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
                labelText: 'Quantity (kgs)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Message to Farmer (Optional)',
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
              Helpers.showSnackBar(context, 'Offer sent to farmer!');
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
}