import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  const PdfViewer({
    super.key,
    required this.pdfUrl,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  downloadFileWeb() async {
    final Uri url = Uri.parse(widget.pdfUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch url');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: downloadFileWeb(),
    );
  }
}
