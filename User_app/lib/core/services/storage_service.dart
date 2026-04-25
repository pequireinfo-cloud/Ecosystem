import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /**
   * Upload an image to Firebase Storage and return the download URL.
   * Works on both Mobile and Web platforms.
   */
  Future<String> uploadImage(XFile image, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final ref = _storage.ref().child(folder).child(fileName);
    
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

    if (kIsWeb) {
      // Use putData for Web
      final bytes = await image.readAsBytes();
      final uploadTask = await ref.putData(bytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } else {
      // Use putBlob or bytes for mobile too for better consistency if desired,
      // but let's just use putData since it works everywhere.
      final bytes = await image.readAsBytes();
      final uploadTask = await ref.putData(bytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    }
  }

  /**
   * Upload multiple images and return a list of download URLs.
   */
  Future<List<String>> uploadMultipleImages(List<XFile> images, String folder) async {
    List<String> urls = [];
    for (var image in images) {
      final url = await uploadImage(image, folder);
      urls.add(url);
    }
    return urls;
  }
}
