import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    Navigator.pushNamed(context, "/upload", arguments: _filePickerResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Files"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openFilePicker();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
