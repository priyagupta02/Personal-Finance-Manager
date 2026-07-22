import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Source for a receipt image capture.
enum ReceiptSource { camera, gallery }

/// Picks a receipt image from the camera or gallery and compresses it before
/// it is stored with the transaction.
abstract class ReceiptImageService {
  /// Returns the path to the compressed image, or null if the user cancelled.
  Future<String?> pickAndCompress(ReceiptSource source);
}

class ReceiptImageServiceImpl implements ReceiptImageService {
  ReceiptImageServiceImpl({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> pickAndCompress(ReceiptSource source) async {
    final picked = await _picker.pickImage(
      source: source == ReceiptSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final targetPath =
        '${dir.path}/receipt_${DateTime.now().microsecondsSinceEpoch}.jpg';

    // Compress before storing (min-side resize + JPEG quality 70).
    final result = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      targetPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
    );

    // Fall back to the original if compression is unsupported on the platform.
    return result?.path ?? picked.path;
  }
}
