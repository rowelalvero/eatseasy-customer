// ignore: file_names
// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var logoFile = Rxn<File>();
  var validId = Rxn<File>();
  var proofOfResidence = Rxn<File>();

  RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxList<String> _images = <String>[].obs;
  List<String> get images => _images;
  set setImages(String newValue) {
    _images.add(newValue);
  }

  RxString _validIdUrl = ''.obs;
  String get validIdUrl => _validIdUrl.value;
  set validIdUrl(String value) {
    _validIdUrl.value = value;
  }

  RxString _proofOfResidenceUrl = ''.obs;
  String get proofOfResidenceUrl => _proofOfResidenceUrl.value;
  set proofOfResidenceUrl(String value) {
    _proofOfResidenceUrl.value = value;
  }

  RxString _logoUrl = ''.obs;
  String get logoUrl => _logoUrl.value;
  set logoUrl(String value) {
    _logoUrl.value = value;
  }

  // Add a variable to track the currently uploading image
  RxString imageBeingUploaded = ''.obs;

  Future<void> pickImage(String type) async {
    setLoading = true;
    imageBeingUploaded.value = type; // Set the currently uploading image type

    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      switch (type) {
        case "logo":
          logoFile.value = File(pickedImage.path);
          break;
        case "validId":
          validId.value = File(pickedImage.path);
          break;
        case "proofOfResidence":
          proofOfResidence.value = File(pickedImage.path);
          break;
      }
      uploadImageToFirebase(type);
    }
  }

  RxDouble _uploadProgress = 0.0.obs; // Add a variable to track progress
  double get uploadProgress => _uploadProgress.value;
  set setUploadProgress(double value) {
    _uploadProgress.value = value;
  }

  Future<void> uploadImageToFirebase(String type) async {
    setLoading = true;
    File? file;

    switch (type) {
      case "logo":
        file = logoFile.value;
        break;
      case "validId":
        file = validId.value;
        break;
      case "proofOfResidence":
        file = proofOfResidence.value;
        break;
    }

    if (file == null) return;

    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(file);

      // Start the upload and listen for progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setUploadProgress = progress;
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      switch (type) {
        case "logo":
          logoUrl = downloadUrl;
          break;
        case "validId":
          validIdUrl = downloadUrl;
          break;
        case "proofOfResidence":
          proofOfResidenceUrl = downloadUrl;
          break;
      }

      images.add(downloadUrl);
    } catch (e) {
      debugPrint("Error uploading");
    } finally {
      // Reset the upload progress and the currently uploading image
      setUploadProgress = 0.0;
      imageBeingUploaded.value = ""; // Reset the currently uploading image
      setLoading = false;
    }
  }
}