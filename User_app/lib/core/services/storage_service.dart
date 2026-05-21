import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class StorageService {
  /**
   * Upload an image to the backend and return the download URL.
   */
  Future<String> uploadImage(XFile image, String folder) async {
    return await ApiService().uploadFile(image.path);
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
