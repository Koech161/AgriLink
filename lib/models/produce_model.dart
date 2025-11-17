// lib/models/produce_model.dart
import './location_model.dart';
enum ProduceStatus { available, booked, sold, expired }

class Produce {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropType;
  final String cropIcon;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final DateTime harvestDate;
  final int shelfLifeDays;
  final DateTime expiryDate;
  final List<String> imageUrls;
  final ProduceStatus status;
  final String description;
  final String county;
  final Location location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Produce({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropType,
    required this.cropIcon,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.harvestDate,
    required this.shelfLifeDays,
    required this.expiryDate,
    this.imageUrls = const [],
    this.status = ProduceStatus.available,
    this.description = '',
    required this.county,
    required this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory Produce.fromFirestore(Map<String, dynamic> data) {
    return Produce(
      id: data['id'],
      farmerId: data['farmerId'],
      farmerName: data['farmerName'],
      cropType: data['cropType'],
      cropIcon: data['cropIcon'],
      quantity: data['quantity'].toDouble(),
      unit: data['unit'],
      pricePerUnit: data['pricePerUnit'].toDouble(),
      harvestDate: DateTime.parse(data['harvestDate']),
      shelfLifeDays: data['shelfLifeDays'],
      expiryDate: DateTime.parse(data['expiryDate']),
      imageUrls: List<String>.from(data['imageUrls']),
      status: ProduceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      description: data['description'],
      county: data['county'],
      location: Location.fromMap(data['location']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropType': cropType,
      'cropIcon': cropIcon,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'harvestDate': harvestDate.toIso8601String(),
      'shelfLifeDays': shelfLifeDays,
      'expiryDate': expiryDate.toIso8601String(),
      'imageUrls': imageUrls,
      'status': status.toString().split('.').last,
      'description': description,
      'county': county,
      'location': location.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  double get totalPrice => quantity * pricePerUnit;
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
  bool get isNearExpiry => daysUntilExpiry <= 3;
}