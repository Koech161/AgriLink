// lib/screens/buyer/buyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/produce_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
// import '../../utils/helpers.dart';
import 'buyer_marketplace_screen.dart';
import 'orders_screen.dart';
// import 'favorites_screen.dart';
import '../../widgets/empty_state.dart';
import 'buyer_profile_screen.dart';

class BuyerDashboard extends StatefulWidget {
  final AppUser user;

  const BuyerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _BuyerDashboardState createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BuyerHomeScreen(),
    BuyerMarketplaceScreen(),
    OrdersScreen(),
    BuyerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.user.displayName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Find fresh produce',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() => _currentIndex = 1); // Navigate to marketplace
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Buyer Home Screen
class BuyerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          _buildQuickStats(),
          SizedBox(height: 24),
          
          // Featured Categories
          _buildFeaturedCategories(),
          SizedBox(height: 24),
          
          // Recent Listings
          _buildRecentListings(),
          SizedBox(height: 24),
          
          // Top Farmers
          _buildTopFarmers(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: 'current_user_id') // Replace with actual user ID
          .snapshots(),
      builder: (context, snapshot) {
        int totalOrders = snapshot.hasData ? snapshot.data!.docs.length : 0;
        int pendingOrders = snapshot.hasData 
            ? snapshot.data!.docs.where((doc) => doc['status'] == 'pending').length 
            : 0;

        return Row(
          children: [
            Expanded(
              child: _BuyerStatCard(
                title: 'Total Orders',
                value: totalOrders.toString(),
                icon: Icons.shopping_bag,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _BuyerStatCard(
                title: 'Pending',
                value: pendingOrders.toString(),
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _BuyerStatCard(
                title: 'Saved Items',
                value: '12',
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: AppConstants.cropTypes.take(8).map((crop) {
            return _CategoryGridItem(
              icon: crop['icon'],
              name: crop['name'],
              onTap: () {
                // Navigate to category
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentListings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fresh Arrivals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('produce')
              .where('status', isEqualTo: 'available')
              .orderBy('createdAt', descending: true)
              .limit(4)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return EmptyState(
                icon: Icons.store,
                title: 'No Listings Available',
                message: 'Check back later for fresh produce',
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final produce = Produce.fromFirestore(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>
                );
                return _ProduceGridItem(produce: produce);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopFarmers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Farmers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FarmerCard(
                name: 'John Kamau',
                rating: 4.8,
                county: 'Nakuru',
                specialties: ['Tomatoes', 'Maize'],
              ),
              _FarmerCard(
                name: 'Mary Wanjiku',
                rating: 4.9,
                county: 'Meru',
                specialties: ['Bananas', 'Beans'],
              ),
              _FarmerCard(
                name: 'James Kariuki',
                rating: 4.7,
                county: 'Kitale',
                specialties: ['Potatoes', 'Coffee'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Buyer Stat Card
class _BuyerStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BuyerStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Category Grid Item
class _CategoryGridItem extends StatelessWidget {
  final String icon;
  final String name;
  final VoidCallback onTap;

  const _CategoryGridItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Produce Grid Item
class _ProduceGridItem extends StatelessWidget {
  final Produce produce;

  const _ProduceGridItem({Key? key, required this.produce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
          ),
          
          // Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produce.cropType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${produce.quantity} kgs',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'KSh ${produce.pricePerUnit}/kg',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Farmer Card
class _FarmerCard extends StatelessWidget {
  final String name;
  final double rating;
  final String county;
  final List<String> specialties;

  const _FarmerCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.county,
    required this.specialties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightGreen,
                child: Icon(Icons.person, color: AppColors.primaryGreen),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.orange),
                        SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            county,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: specialties.take(2).map((specialty) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}