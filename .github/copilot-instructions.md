# Copilot Instructions - Bloco de Notas

## Project Overview
Flutter notepad application supporting **Android and Web** platforms. Enables creating, editing, and managing `.txt` and `.md` files with Markdown rendering capabilities. Files are stored **in-memory only** (no persistence between app sessions).

## Architecture & Patterns

### Core Design
- **Singleton Service**: `FileStorageService` manages all file operations via singleton pattern (`factory` constructor)
- **Immutable Models**: `NoteFile` uses `final` fields with `copyWith()` for updates
- **State Management**: StatefulWidget with `setState` - no external state libraries
- **Separation of Concerns**:
  - `lib/models/` - Data classes (NoteFile, enums)
  - `lib/services/` - Business logic singleton (FileStorageService)
  - `lib/screens/` - Full-screen pages with state
  - `lib/widgets/` - Reusable dialog/widget components

### Platform-Specific Behavior
```dart
// Web: Downloads files using Blob API (universal_html package)
if (kIsWeb) {
  final blob = html.Blob([utf8.encode(content)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  // Trigger browser download
}
// Android: Files saved in FileStorageService._savedFiles list
```

## Critical Conventions

### Language & Localization
- **All user-facing strings MUST be in Portuguese (pt-BR)**
- Variables/code in English, UI text in Portuguese
- Examples: "Arquivo", "Salvar", "Carregar", "Descartar"

### File Handling Pattern
```dart
// Always use copyWith for NoteFile updates
final updated = currentFile.copyWith(
  content: newContent,
  lastModified: DateTime.now(), // Update timestamp on save
);
_fileService.saveFile(updated);
```

### Unsaved Changes Flow
Before destructive operations (new file, load file), check `_hasUnsavedChanges`:
```dart
if (_hasUnsavedChanges) {
  _showUnsavedChangesDialog(() => _performAction());
} else {
  _performAction();
}
```

### View Modes
Two modes: `ViewMode.normal` (editable TextField) and `ViewMode.richFormat` (Markdown widget).
- `.md` files default to richFormat on load
- Switch via "Exibir" menu (Normal/Formato Rich)
- Rich mode uses `flutter_markdown` package for rendering

## Dependencies & Tools

### Key Packages
- `flutter_markdown: ^0.6.18` - Markdown rendering
- `universal_html: ^2.2.4` - Cross-platform HTML APIs (Web downloads)
- `file_picker: ^6.0.0` - Declared but not actively used yet
- `path_provider: ^2.1.0` - Declared but not actively used yet

### Development Workflow
```bash
flutter pub get              # Install dependencies
flutter test                 # Run unit tests
flutter run -d chrome        # Launch Web version
flutter run -d android       # Launch Android version
flutter build web            # Production Web build
flutter build apk            # Production Android build
```

### Testing Philosophy
- Unit tests for models (`note_file_test.dart`) and services (`file_storage_service_test.dart`)
- Each test uses `setUp()` to clear FileStorageService singleton state
- Focus on business logic; UI testing not implemented

## Important Limitations

### Storage Model
⚠️ **Files are NOT persisted to disk** - all saved files stored in `List<NoteFile> _savedFiles` (in-memory).
- Files lost on app restart
- To add persistence: implement `path_provider` for Android or localStorage for Web

### State Tracking
- `_hasUnsavedChanges` flag managed via `TextEditingController.addListener()`
- Reset to `false` after save operations
- Triggers confirmation dialogs before data loss

## Material Design 3 Usage
```dart
// Theme configured in main.dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
)
```
Use Material 3 widgets: `FilledButton`, `ListTile`, `showDialog`, etc.

## Common Tasks

### Adding a New Menu Item
1. Add option to `PopupMenuButton` in [notepad_screen.dart](lib/screens/notepad_screen.dart)
2. Implement handler method in `_NotepadScreenState`
3. Update relevant enums if needed (e.g., `ViewMode`)

### Supporting New File Types
1. Add enum value to `FileType` in [note_file.dart](lib/models/note_file.dart)
2. Update `extension` getter
3. Add icon/color mapping in [file_manager_dialog.dart](lib/widgets/file_manager_dialog.dart)
4. Handle rendering logic in `notepad_screen.dart`

### Platform-Specific Features
Check platform: `import 'package:flutter/foundation.dart' show kIsWeb;`
- Web-only: Use `universal_html` for browser APIs
- Android-only: Use native file APIs (via `path_provider` if implemented)
