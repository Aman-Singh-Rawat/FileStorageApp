import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  final String url;

  const PreviewImage({
    super.key,
    required this.url,
  });

  @override
  State<StatefulWidget> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Image"),
      ),
      body: Image.network(
        widget.url,
        fit: BoxFit.fill,
      ),
    );
  }
}