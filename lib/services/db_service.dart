import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_file_upload/services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbService {
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> saveUploadedFilesData(Map<String, String> data) async {
    return FirebaseFirestore.instance
        .collection("user-files")
        .doc(user!.uid)
        .collection("uploads")
        .doc()
        .set(data);
  }

  Stream<QuerySnapshot> readUploadedFiles() {
    return FirebaseFirestore.instance
        .collection("user-files")
        .doc(user!.uid)
        .collection("uploads")
        .snapshots();
  }

  Future<bool> deleteFile(String docId, String publicId) async {
    final result = await deleteFromCloudinary(publicId);

    if(result) {
      await FirebaseFirestore.instance
          .collection("user-files")
          .doc(user!.uid)
          .collection("uploads")
          .doc(docId)
          .delete();

      return true;
    }
    return false;
  }
}