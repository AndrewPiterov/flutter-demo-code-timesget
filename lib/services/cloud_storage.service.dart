import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timesget/models/firestore_endpoints.dart';

class CloudStorageService {
  BehaviorSubject<bool> isUpload = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject<int> progress = BehaviorSubject<int>.seeded(0);

  Future<String> upload(File file, String type) async {
    isUpload.add(true);

    try {
      // 1. Prepare
      final ms = DateTime.now().millisecondsSinceEpoch.toString();
      final RegExp regexp = RegExp('([^?/]*\.(jpg|jpeg|m4a|mp4|acc))');
      final filename = ms + regexp.stringMatch(file.path);
      final endpoint = FirestoreEndpoints.praiseComplaints;
      final uploadPath = '$endpoint/$filename';
      print('Upload path: $uploadPath');

      // 2. Perform
      final storage = FirebaseStorage.instance.ref().child(uploadPath);
      final StorageUploadTask uploadTask = storage.putFile(
          file,
          StorageMetadata(
              contentType:
                  type == 'audio' ? 'audio/mpeg' : 'application/octet-stream'));
      uploadTask.events.listen((e) {
        final p =
            (e.snapshot.bytesTransferred / e.snapshot.totalByteCount * 100)
                .floor();
        progress.add(p);
        print('=> $p% uploaded');
      });

      // 3. Wait completion
      final completion = await uploadTask.onComplete;
      isUpload.add(false);
      progress.add(0);
      final fileUri = completion.ref.path;
      print('File is in $fileUri');
      return fileUri;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
