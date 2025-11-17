// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary service implemented using direct unsigned upload HTTP requests.
///
/// Replace `cloudName` and `uploadPreset` when constructing the singleton:
/// `CloudinaryService(cloudName: 'your-cloud', uploadPreset: 'your-preset')`.
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService({String cloudName = 'dmsnelbpc', String uploadPreset = 'nj4f2xoc'}) {
    _instance._cloudName = cloudName;
    _instance._uploadPreset = uploadPreset;
    return _instance;
  }

  CloudinaryService._internal();

  late String _cloudName;
  late String _uploadPreset;

  Uri _uploadUri() => Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  Future<List<String>> uploadImages(List<XFile> files, {String folder = 'agrilink/farmers'}) async {
    final uploadedUrls = <String>[];

    for (final file in files) {
      try {
        final uri = _uploadUri();
        final request = http.MultipartRequest('POST', uri);
        request.fields['upload_preset'] = _uploadPreset;
        if (folder.isNotEmpty) request.fields['folder'] = folder;
        // Use fromBytes instead of fromPath so this works on web (no dart:io)
        final bytes = await file.readAsBytes();
        final filename = file.name.isNotEmpty ? file.name : file.path.split('/').last;
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = json.decode(response.body) as Map<String, dynamic>;
          final secureUrl = body['secure_url'] as String?;
          if (secureUrl != null) uploadedUrls.add(secureUrl);
        } else {
          print('Cloudinary upload failed (${response.statusCode}): ${response.body}');
        }
      } catch (e) {
        print('Upload error: $e');
      }
    }

    return uploadedUrls;
  }

  /// Deleting resources must be done server-side. Client should call your API
  /// which performs the authenticated delete with your Cloudinary API key/secret.
  Future<void> deleteImage(String publicId) async {
    throw UnsupportedError('deleteImage must be implemented server-side');
  }

  String generateThumbnail(String url, {int width = 300, int height = 300}) {
    return url.replaceAll('/upload/', '/upload/c_fill,w_\$width,h_\$height/');
  }
}