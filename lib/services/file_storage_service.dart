import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../models/note_file.dart';

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();
  factory FileStorageService() => _instance;
  FileStorageService._internal();

  final List<NoteFile> _savedFiles = [];

  List<NoteFile> get savedFiles => List.unmodifiable(_savedFiles);

  void saveFile(NoteFile file) {
    final index = _savedFiles.indexWhere((f) => f.name == file.name);
    if (index != -1) {
      _savedFiles[index] = file;
    } else {
      _savedFiles.add(file);
    }
  }

  NoteFile? loadFile(String name) {
    try {
      return _savedFiles.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }

  void deleteFile(String name) {
    _savedFiles.removeWhere((f) => f.name == name);
  }

  void downloadFile(NoteFile file) {
    if (kIsWeb) {
      _downloadFileWeb(file);
    }
    // For Android, files are saved in the savedFiles list
  }

  void _downloadFileWeb(NoteFile file) {
    final bytes = utf8.encode(file.content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', file.fullName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  String readFileFromWeb(String content) {
    return content;
  }
}
