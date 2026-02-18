import 'dart:convert';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;
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

  Future<NoteFile?> pickLocalTextFile() async {
    final result = await picker.FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final selected = result.files.first;
    final fileName = selected.name;
    final type = fileName.toLowerCase().endsWith('.md')
        ? FileType.md
        : FileType.txt;

    String content = '';
    if (selected.bytes != null) {
      content = utf8.decode(selected.bytes!, allowMalformed: true);
    } else if (selected.path != null) {
      final file = io.File(selected.path!);
      if (await file.exists()) {
        content = await file.readAsString();
      }
    }

    if (content.isEmpty && selected.bytes == null && selected.path == null) {
      return null;
    }

    return NoteFile(
      name: _stripKnownExtension(fileName),
      content: content,
      type: type,
    );
  }

  Future<String?> saveFileToDevice(NoteFile file) async {
    if (kIsWeb) {
      _downloadFileWeb(file);
      return file.fullName;
    }

    final directoryPath = await picker.FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Selecione a pasta para salvar',
    );

    if (directoryPath == null || directoryPath.isEmpty) {
      return null;
    }

    final outputPath = '$directoryPath/${file.fullName}';
    final outputFile = io.File(outputPath);
    await outputFile.writeAsString(file.content);
    return outputPath;
  }

  String _stripKnownExtension(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.txt') || lower.endsWith('.md')) {
      return fileName.substring(0, fileName.lastIndexOf('.'));
    }
    return fileName;
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
}
