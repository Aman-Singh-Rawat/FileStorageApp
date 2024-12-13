import 'package:cloudinary_file_upload/services/cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  late FilePickerResult _selectedFile;

  void _uploadFile() async {
    final result = await uploadToCloudinary(_selectedFile);

    if(!context.mounted) {
      return;
    }

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File Uploaded Successfully."),
        ),
      );
      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot Upload Your File."),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedFile =
        ModalRoute.of(context)!.settings.arguments as FilePickerResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Area"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              initialValue: _selectedFile.files.first.name,
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
            ),
            TextFormField(
              readOnly: true,
              initialValue: _selectedFile.files.first.extension,
              decoration: const InputDecoration(
                label: Text("Extension"),
              ),
            ),
            TextFormField(
              readOnly: true,
              initialValue: "${_selectedFile.files.first.size} bytes",
              decoration: const InputDecoration(
                label: Text("Size"),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploadFile,
                    child: const Text("Upload"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
