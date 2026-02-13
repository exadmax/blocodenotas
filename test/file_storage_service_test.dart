import 'package:flutter_test/flutter_test.dart';
import 'package:blocodenotas/models/note_file.dart';
import 'package:blocodenotas/services/file_storage_service.dart';

void main() {
  group('FileStorageService', () {
    late FileStorageService service;

    setUp(() {
      service = FileStorageService();
      // Clear any existing files
      for (var file in service.savedFiles.toList()) {
        service.deleteFile(file.name);
      }
    });

    test('should save a file', () {
      final file = NoteFile(
        name: 'test',
        content: 'Hello',
        type: FileType.txt,
      );

      service.saveFile(file);

      expect(service.savedFiles.length, equals(1));
      expect(service.savedFiles.first.name, equals('test'));
    });

    test('should load a saved file', () {
      final file = NoteFile(
        name: 'test',
        content: 'Hello',
        type: FileType.txt,
      );

      service.saveFile(file);
      final loaded = service.loadFile('test');

      expect(loaded, isNotNull);
      expect(loaded?.name, equals('test'));
      expect(loaded?.content, equals('Hello'));
    });

    test('should update existing file', () {
      final file1 = NoteFile(
        name: 'test',
        content: 'Hello',
        type: FileType.txt,
      );

      service.saveFile(file1);

      final file2 = NoteFile(
        name: 'test',
        content: 'Updated',
        type: FileType.txt,
      );

      service.saveFile(file2);

      expect(service.savedFiles.length, equals(1));
      expect(service.savedFiles.first.content, equals('Updated'));
    });

    test('should delete a file', () {
      final file = NoteFile(
        name: 'test',
        content: 'Hello',
        type: FileType.txt,
      );

      service.saveFile(file);
      expect(service.savedFiles.length, equals(1));

      service.deleteFile('test');
      expect(service.savedFiles.length, equals(0));
    });

    test('should return null for non-existent file', () {
      final loaded = service.loadFile('nonexistent');
      expect(loaded, isNull);
    });
  });
}
