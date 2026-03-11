import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace these with your real values
  static const String cloudName = 'dtf4vrzjk';
  static const String uploadPreset = 'storyo_unsigned';

  static Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'storyo/covers'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      throw Exception('Image upload failed: $responseBody');
    }
  }

  static Future<String?> uploadPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'storyo/pdfs'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      throw Exception('PDF upload failed: $responseBody');
    }
  }
}
