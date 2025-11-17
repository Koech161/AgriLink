// lib/models/cloudinary_image.dart
class CloudinaryImage {
  final String id;
  final String url;
  final String publicId;
  final DateTime uploadedAt;
  final String? caption;
  final Map<String, dynamic>? metadata;

  CloudinaryImage({
    required this.id,
    required this.url,
    required this.publicId,
    required this.uploadedAt,
    this.caption,
    this.metadata,
  });

  factory CloudinaryImage.fromJson(Map<String, dynamic> json) {
    return CloudinaryImage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      url: json['url'],
      publicId: json['publicId'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      caption: json['caption'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'publicId': publicId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'caption': caption,
      'metadata': metadata,
    };
  }
}