import 'package:flutter_test/flutter_test.dart';
import 'package:blocodenotas/models/note_file.dart';

void main() {
  group('NoteFile', () {
    test('should create a txt file', () {
      final file = NoteFile(
        name: 'test',
        content: 'Hello World',
        type: FileType.txt,
      );

      expect(file.name, equals('test'));
      expect(file.content, equals('Hello World'));
      expect(file.type, equals(FileType.txt));
      expect(file.extension, equals('.txt'));
      expect(file.fullName, equals('test.txt'));
    });

    test('should create a md file', () {
      final file = NoteFile(
        name: 'readme',
        content: '# Markdown',
        type: FileType.md,
      );

      expect(file.name, equals('readme'));
      expect(file.content, equals('# Markdown'));
      expect(file.type, equals(FileType.md));
      expect(file.extension, equals('.md'));
      expect(file.fullName, equals('readme.md'));
    });

    test('should not add extension twice', () {
      final file = NoteFile(
        name: 'test.txt',
        content: 'Content',
        type: FileType.txt,
      );

      expect(file.fullName, equals('test.txt'));
    });

    test('should copy file with new content', () {
      final original = NoteFile(
        name: 'original',
        content: 'Old content',
        type: FileType.txt,
      );

      final copy = original.copyWith(content: 'New content');

      expect(copy.name, equals('original'));
      expect(copy.content, equals('New content'));
      expect(copy.type, equals(FileType.txt));
      expect(copy.lastModified, equals(original.lastModified));
    });

    test('should copy file with new lastModified when provided', () {
      final original = NoteFile(
        name: 'original',
        content: 'Content',
        type: FileType.txt,
      );
      final updatedAt = original.lastModified.add(const Duration(seconds: 1));

      final copy = original.copyWith(lastModified: updatedAt);

      expect(copy.lastModified, equals(updatedAt));
    });
  });
}
