import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const Set<String> _allowedImageExtensions = {
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
};

const int _maxImageBytes = 10 * 1024 * 1024; // 10 MB

/// Uploads a validated image [xFile] to Cloudinary and returns its secure URL.
Future<String?> uploadToCloudinary(XFile? xFile) async {
  if (xFile == null) {
    return null;
  }

  final extension = xFile.name.split('.').last.toLowerCase();
  if (!_allowedImageExtensions.contains(extension)) {
    debugPrint("Unsupported image format: $extension");
    return null;
  }

  final fileBytes = await xFile.readAsBytes();
  if (fileBytes.isEmpty || fileBytes.length > _maxImageBytes) {
    debugPrint("Image size out of allowed bounds.");
    return null;
  }

  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  if (cloudName.isEmpty) {
    debugPrint("CLOUDINARY_CLOUD_NAME is not configured.");
    return null;
  }

  final uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim().isNotEmpty == true
          ? dotenv.env['CLOUDINARY_UPLOAD_PRESET']!.trim()
          : 'preset-for-file-upload';

  final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  final request = http.MultipartRequest("POST", uri);

  final multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: xFile.name,
  );

  request.files.add(multipartFile);
  request.fields['upload_preset'] = uploadPreset;

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
    return jsonResponse["secure_url"] as String?;
  } else {
    debugPrint("Cloudinary upload failed with status: ${response.statusCode}");
    return null;
  }
}
