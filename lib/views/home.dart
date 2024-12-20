import 'package:cloudinary_file_upload/services/db_service.dart';
import 'package:cloudinary_file_upload/views/preview_image.dart';
import 'package:cloudinary_file_upload/views/preview_video.dart';
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

  void deleteData(String id, publicId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete file"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              final bool deleteResult =
                  await DbService().deleteFile(id, publicId);

                if (deleteResult) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("File deleted"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error in deleting file"),
                    ),
                  );
                }
                Navigator.pop(context);

            },
            child: const Text("Yes"),
          )
        ],
      ),
    );
  }

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
        stream: DbService().readUploadedFiles(),
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
                  bool flag = ext == "png" || ext == "jpg" || ext == "jpeg";

                  return InkWell(
                    onLongPress: () {
                      deleteData(snapshot.data!.docs[index].id, publicId);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => flag
                              ? PreviewImage(url: fileUrl)
                              : PreviewVideo(videoUrl: fileUrl),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: flag
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
                                  flag ? Icons.image : Icons.movie,
                                ),
                                const SizedBox(width: 10),
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
