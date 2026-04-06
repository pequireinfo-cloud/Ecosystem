import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /**
   * Upload an image to Firebase Storage and return the download URL.
   * @param {XFile} image 
   * @param {string} folder 
   * @returns {Promise<string>}
   */
  Future<String> uploadImage(XFile image, String folder) async {
    final file = File(image.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_\${image.name}';
    final ref = _storage.ref().child(folder).child(fileName);
    
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    return downloadUrl;
  }

  /**
   * Upload multiple images and return a list of download URLs.
   * @param {List<XFile>} images 
   * @param {string} folder 
   * @returns {Promise<List<String>>}
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
