enum FileType {
  txt,
  md,
}

class NoteFile {
  String name;
  String content;
  FileType type;
  DateTime lastModified;

  NoteFile({
    required this.name,
    required this.content,
    required this.type,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  String get extension => type == FileType.txt ? '.txt' : '.md';

  String get fullName => name.endsWith(extension) ? name : '$name$extension';

  NoteFile copyWith({
    String? name,
    String? content,
    FileType? type,
    DateTime? lastModified,
  }) {
    return NoteFile(
      name: name ?? this.name,
      content: content ?? this.content,
      type: type ?? this.type,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
