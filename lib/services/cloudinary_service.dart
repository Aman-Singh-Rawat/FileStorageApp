import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_file_upload/services/db_service.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected!");
    return false;
  }

  File file = File(filePickerResult.files.single.path!);
  String cloudName = dotenv.env["CLOUDINARY_CLOUD_NAME"] ?? "";

  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("POST", uri);

  var fileBytes = await file.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    "file",
    fileBytes,
    filename: file.path
        .split("/")
        .last,
  );

  request.files.add(multipartFile);

  request.fields["upload_preset"] = "preset-for-file-upload";
  request.fields["resource_type"] = "raw";

  var response = await request.send();

  var responseBody = await response.stream.bytesToString();
  print(responseBody);

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(responseBody);
    Map<String, String> requiredData = {
      "name": jsonResponse["display_name"],
      "id": jsonResponse["public_id"],
      "extension": filePickerResult.files.first.extension!,
      "size": jsonResponse["bytes"].toString(),
      "url": jsonResponse["secure_url"],
      "created_at": jsonResponse["created_at"],
    };
    await DbService().saveUploadedFilesData(requiredData);
    print("Upload Successful!");
    return true;
  } else {
    print("Upload failed with status: ${response.statusCode}");
    return false;
  }
}

Future<bool> deleteFromCloudinary(String publicId) async {
  String cloudName = dotenv.env["CLOUDINARY_CLOUD_NAME"] ?? "";
  String apiKey = dotenv.env["CLOUDINARY_API_KEY"] ?? "";
  String apiSecret = dotenv.env["CLOUDINARY_SECRET_KEY"] ?? "";

  int timeStamp = DateTime
      .now()
      .millisecondsSinceEpoch ~/ 1000;

  String toSign = "public_id=$publicId&timestamp=$timeStamp$apiSecret";

  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);

  String signature = digest.toString();

  var uri = Uri.parse("https://api.cloudinary.com/v1_1$cloudName/raw/destroy/");

  var response = await http.post(
    uri,
    body: {
      "public_id": publicId,
      "timestamp": timeStamp.toString(),
      "api_key": apiKey,
      "signature": signature,
    }
  );

  if(response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);

    print(responseBody);

    if(responseBody["result"] == "ok") {
      print("File deleted successfully.");
      return true;
    } else {
      print("Failed to delete the file.");
      return false;
    }
  } else {
    print("Failed to delete the file, status: ${response.statusCode}");
    return false;
  }
}
