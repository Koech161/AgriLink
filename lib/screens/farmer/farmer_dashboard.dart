// lib/screens/farmer/farmer_dashboard.dart
import 'package:agrilink/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/produce_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'add_produce_screen.dart';
import 'storage_booking_screen.dart';
import 'transport_screen.dart';
import '../../screens/farmer/marketplace_screen.dart';
import '../farmer/produce_list_screen.dart';


class FarmerDashboard extends StatefulWidget {
  final AppUser user;

  const FarmerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _FarmerDashboardState createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DashboardHome(),
    ProduceListScreen(),
    MarketplaceScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 1 ? _buildFloatingActionButton() : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${widget.user.displayName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            widget.user.county,
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
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: widget.user.profileImageUrl != null
                ? NetworkImage(widget.user.profileImageUrl!)
                : null,
            child: widget.user.profileImageUrl == null
                ? Icon(Icons.person, size: 18, color: Colors.white)
                : null,
          ),
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
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'My Produce',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProduceScreen(user: widget.user)),
        );
      },
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      child: Icon(Icons.add),
    );
  }
}

// Dashboard Home Tab
class DashboardHome extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          _buildQuickStats(context),
          SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(context),
          SizedBox(height: 24),
          
          // Recent Listings
          _buildRecentListings(),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produce')
          .where('status', isEqualTo: 'available')
          .snapshots(),
      builder: (context, snapshot) {
        int activeListings = snapshot.hasData ? snapshot.data!.docs.length : 0;
        double totalValue = 0;
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalValue += (data['quantity'] ?? 0) * (data['pricePerUnit'] ?? 0);
          }
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Active Listings',
                value: activeListings.toString(),
                icon: Icons.inventory_2,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Value',
                value: 'KSh ${totalValue.toStringAsFixed(0)}',
                icon: Icons.attach_money,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _ActionCard(
              title: 'Add Produce',
              icon: Icons.add_circle_outline,
              color: AppColors.primaryGreen,
              onTap: () {
                // Navigate to add produce
              },
            ),
            _ActionCard(
              title: 'Book Storage',
              icon: Icons.warehouse,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StorageBookingScreen()),
                );
              },
            ),
            _ActionCard(
              title: 'Find Transport',
              icon: Icons.local_shipping,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransportScreen()),
                );
              },
            ),
            _ActionCard(
              title: 'Market Trends',
              icon: Icons.trending_up,
              color: Colors.orange,
              onTap: () {
                // Navigate to market trends
              },
            ),
          ],
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
              'Recent Listings',
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
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _EmptyState(
                icon: Icons.inventory_2,
                title: 'No Listings Yet',
                message: 'Start by adding your first produce listing',
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final produce = Produce.fromFirestore(doc.data() as Map<String, dynamic>);
                return _ProduceListItem(produce: produce);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Produce List Item Widget
class _ProduceListItem extends StatelessWidget {
  final Produce produce;

  const _ProduceListItem({Key? key, required this.produce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
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
        title: Text(
          produce.cropType,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${produce.quantity} kgs • KSh ${produce.pricePerUnit}/kg',
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Helpers.getStatusColor(produce.status.toString().split('.').last).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            produce.status.toString().split('.').last.capitalize(),
            style: TextStyle(
              color: Helpers.getStatusColor(produce.status.toString().split('.').last),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}