// lib/screens/transporter/transporter_dashboard.dart
import 'package:agrilink/utils/extensions.dart';
import 'package:agrilink/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'available_jobs_screen.dart';
import 'transporter_profile_screen.dart';
import 'my_jobs_screen.dart';

class TransporterDashboard extends StatefulWidget {
  final AppUser user;

  const TransporterDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _TransporterDashboardState createState() => _TransporterDashboardState();
}

class _TransporterDashboardState extends State<TransporterDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TransporterHomeScreen(),
    AvailableJobsScreen(),
    MyJobsScreen(),
    TransporterProfileScreen(),
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
            'Hello, ${widget.user.displayName}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Transport Dashboard',
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
          label: 'Overview',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'Available Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'My Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Transporter Home Screen
class TransporterHomeScreen extends StatelessWidget {
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
          
          // Active Jobs
          _buildActiveJobs(),
          SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions( context ),
          SizedBox(height: 24),
          
          // Performance Metrics
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transport_jobs')
          .where('transporterId', isEqualTo: 'current_user_id')
          .snapshots(),
      builder: (context, snapshot) {
        int totalJobs = snapshot.hasData ? snapshot.data!.docs.length : 0;
        int activeJobs = snapshot.hasData 
            ? snapshot.data!.docs.where((doc) => 
                ['accepted', 'in_progress'].contains(doc['status'])).length 
            : 0;
        double totalEarnings = snapshot.hasData
            ? snapshot.data!.docs.fold(0.0, (sum, doc) => sum + (doc['price'] ?? 0))
            : 0.0;

        return Row(
          children: [
            Expanded(
              child: _TransporterStatCard(
                title: 'Total Jobs',
                value: totalJobs.toString(),
                icon: Icons.assignment,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TransporterStatCard(
                title: 'Active',
                value: activeJobs.toString(),
                icon: Icons.local_shipping,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _TransporterStatCard(
                title: 'Earnings',
                value: 'KSh ${totalEarnings.toInt()}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Jobs',
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
              .collection('transport_jobs')
              .where('transporterId', isEqualTo: 'current_user_id')
              .where('status', whereIn: ['accepted', 'in_progress'])
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return EmptyState(
                icon: Icons.local_shipping,
                title: 'No Active Jobs',
                message: 'Start by accepting available transport jobs',
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final job = doc.data() as Map<String, dynamic>;
                return _ActiveJobCard(job: job);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
            _TransporterActionCard(
              title: 'Find Jobs',
              icon: Icons.search,
              color: AppColors.primaryGreen,
              onTap: () {
                // Navigate to available jobs
              },
            ),
            _TransporterActionCard(
              title: 'Set Availability',
              icon: Icons.event_available,
              color: Colors.blue,
              onTap: () {
                _showAvailabilityDialog(context);
              },
            ),
            _TransporterActionCard(
              title: 'Vehicle Info',
              icon: Icons.directions_car,
              color: Colors.orange,
              onTap: () {
                _showVehicleInfoDialog(context);
              },
            ),
            _TransporterActionCard(
              title: 'Earnings',
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () {
                // Navigate to earnings
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PerformanceMetric(
                value: '4.8',
                label: 'Rating',
                icon: Icons.star,
              ),
              _PerformanceMetric(
                value: '98%',
                label: 'Success Rate',
                icon: Icons.check_circle,
              ),
              _PerformanceMetric(
                value: '24h',
                label: 'Avg. Response',
                icon: Icons.timer,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAvailabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Available for Jobs'),
              value: true,
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            Text('Working Hours'),
            // Add time pickers for working hours
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Helpers.showSnackBar(context, 'Availability updated!');
              Navigator.pop(context);
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showVehicleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vehicle Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Vehicle Type'),
              initialValue: 'Pickup Truck',
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'License Plate'),
              initialValue: 'KAA 123A',
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Capacity (kg)'),
              initialValue: '1000',
              keyboardType: TextInputType.number,
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
              Helpers.showSnackBar(context, 'Vehicle info updated!');
              Navigator.pop(context);
            },
            child: Text('Save'),
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

// Transporter Stat Card
class _TransporterStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TransporterStatCard({
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

// Active Job Card
class _ActiveJobCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const _ActiveJobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Job #${job['id']?.substring(0, 8) ?? 'N/A'}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(job['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job['status']?.toString().capitalize() ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(job['status']),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${job['pickupLocation'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'To: ${job['deliveryLocation'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KSh ${job['price'] ?? '0'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      '${job['distance'] ?? '0'} km',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View job details
                    },
                    child: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Update job status
                    },
                    child: Text('Update'),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Transporter Action Card
class _TransporterActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TransporterActionCard({
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

// Performance Metric
class _PerformanceMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _PerformanceMetric({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primaryGreen),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}