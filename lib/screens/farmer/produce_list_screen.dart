// lib/screens/farmer/produce_list_screen.dart
import 'package:agrilink/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/produce_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ProduceListScreen extends StatefulWidget {
  @override
  _ProduceListScreenState createState() => _ProduceListScreenState();
}

class _ProduceListScreenState extends State<ProduceListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Produce'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All Listings')),
              PopupMenuItem(value: 'available', child: Text('Available')),
              PopupMenuItem(value: 'booked', child: Text('Booked')),
              PopupMenuItem(value: 'sold', child: Text('Sold')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getProduceStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _EmptyProduceState();
          }

          final produces = snapshot.data!.docs
              .map((doc) => Produce.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: produces.length,
            itemBuilder: (context, index) {
              return _ProduceCard(produce: produces[index]);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getProduceStream() {
    if (_filterStatus == 'all') {
      return FirebaseFirestore.instance
          .collection('produce')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('produce')
          .where('status', isEqualTo: _filterStatus)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }
}

class _ProduceCard extends StatelessWidget {
  final Produce produce;

  const _ProduceCard({Key? key, required this.produce}) : super(key: key);

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      produce.cropIcon,
                      style: TextStyle(fontSize: 18),
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
                        'Harvested ${produce.harvestDate.formatDate()}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: produce.status),
              ],
            ),
            SizedBox(height: 12),
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(
                  icon: Icons.scale,
                  label: 'Quantity',
                  value: '${produce.quantity} kgs',
                ),
                _DetailItem(
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: 'KSh ${produce.pricePerUnit}/kg',
                ),
                _DetailItem(
                  icon: Icons.timer,
                  label: 'Expires in',
                  value: '${produce.daysUntilExpiry} days',
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Actions
            if (produce.status == ProduceStatus.available)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit'),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.visibility, size: 16),
                      label: Text('View Offers'),
                      onPressed: () {},
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
}

class _StatusBadge extends StatelessWidget {
  final ProduceStatus status;

  const _StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusText = status.toString().split('.').last.capitalize();
    final color = Helpers.getStatusColor(status.toString().split('.').last);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
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

class _EmptyProduceState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'No Produce Listed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start by adding your first produce listing',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Produce'),
            onPressed: () {
              // Navigate to add produce
            },
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