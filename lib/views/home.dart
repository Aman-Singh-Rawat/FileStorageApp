import 'package:cloudinary_file_upload/services/db_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
        type: FileType.custom);
    setState(() {
      _filePickerResult = result;
    });

    if (_filePickerResult != null) {
      Navigator.pushNamed(context, "/upload", arguments: _filePickerResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Files"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, "/login");
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openFilePicker();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: DbService().readuploadedFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List userUploadedFiles = snapshot.data!.docs;
            if (userUploadedFiles.isEmpty) {
              return const Center(
                child: Text("No files uploaded"),
              );
            } else {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: userUploadedFiles.length,
                itemBuilder: (context, index) {
                  String name = userUploadedFiles[index]["name"];
                  String ext = userUploadedFiles[index]["extension"];
                  String publicId = userUploadedFiles[index]["id"];
                  String fileUrl = userUploadedFiles[index]["url"];

                  return Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ext == "png" || ext == "jpg" || ext == "jpeg"
                              ? Image.network(
                                  fileUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.movie),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                ext == "png" || ext == "jpg" || ext == "jpeg"
                                    ? Icons.image
                                    : Icons.movie,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
