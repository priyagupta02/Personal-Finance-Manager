import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Runs on-device OCR on a receipt image and returns the recognized text.
abstract class ReceiptOcrService {
  Future<String> recognizeText(String imagePath);
}

class MlKitReceiptOcrService implements ReceiptOcrService {
  MlKitReceiptOcrService({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }
}
