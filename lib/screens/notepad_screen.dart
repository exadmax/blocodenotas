import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note_file.dart';
import '../services/file_storage_service.dart';
import '../widgets/file_manager_dialog.dart';

enum ViewMode { normal, richFormat }

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final TextEditingController _textController = TextEditingController();
  final FileStorageService _fileService = FileStorageService();
  NoteFile? _currentFile;
  ViewMode _viewMode = ViewMode.normal;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _newFile() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() => _createNewFile());
    } else {
      _createNewFile();
    }
  }

  void _createNewFile() {
    setState(() {
      _currentFile = null;
      _textController.clear();
      _hasUnsavedChanges = false;
      _viewMode = ViewMode.normal;
    });
  }

  void _saveFile() {
    if (_currentFile == null) {
      _saveAsFile();
    } else {
      final updatedFile = _currentFile!.copyWith(
        content: _textController.text,
        lastModified: DateTime.now(),
      );
      _fileService.saveFile(updatedFile);
      setState(() {
        _currentFile = updatedFile;
        _hasUnsavedChanges = false;
      });
      _showSnackBar('Arquivo salvo: ${updatedFile.fullName}');
    }
  }

  void _saveAsFile() {
    showDialog(
      context: context,
      builder: (context) => _SaveAsDialog(
        onSave: (name, type) {
          final file = NoteFile(
            name: name,
            content: _textController.text,
            type: type,
          );
          _fileService.saveFile(file);
          setState(() {
            _currentFile = file;
            _hasUnsavedChanges = false;
          });
          _showSnackBar('Arquivo salvo como: ${file.fullName}');
        },
      ),
    );
  }

  void _loadFile() {
    showDialog(
      context: context,
      builder: (context) => FileManagerDialog(
        files: _fileService.savedFiles,
        onFileSelected: (file) {
          if (_hasUnsavedChanges) {
            _showUnsavedChangesDialog(() => _openFile(file));
          } else {
            _openFile(file);
          }
        },
        onFileDeleted: (name) {
          _fileService.deleteFile(name);
          setState(() {});
        },
      ),
    );
  }

  void _openFile(NoteFile file) {
    setState(() {
      _currentFile = file;
      _textController.text = file.content;
      _hasUnsavedChanges = false;
      _viewMode = file.type == FileType.md ? ViewMode.richFormat : ViewMode.normal;
    });
  }

  void _downloadFile() {
    if (_currentFile != null) {
      _fileService.downloadFile(_currentFile!);
      _showSnackBar('Download iniciado: ${_currentFile!.fullName}');
    } else {
      _showSnackBar('Salve o arquivo primeiro');
    }
  }

  void _cutText() {
    final selection = _textController.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final text = _textController.text.substring(
        selection.start,
        selection.end,
      );
      Clipboard.setData(ClipboardData(text: text));
      _textController.text = _textController.text.replaceRange(
        selection.start,
        selection.end,
        '',
      );
      _textController.selection = TextSelection.collapsed(
        offset: selection.start,
      );
    }
  }

  void _copyText() {
    final selection = _textController.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final text = _textController.text.substring(
        selection.start,
        selection.end,
      );
      Clipboard.setData(ClipboardData(text: text));
      _showSnackBar('Texto copiado');
    }
  }

  void _selectAll() {
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
  }

  void _toggleViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
    });
  }

  void _showUnsavedChangesDialog(VoidCallback onDiscard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text('Deseja salvar as alterações antes de continuar?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDiscard();
            },
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveFile();
              onDiscard();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentFile?.fullName ?? 'Novo Arquivo',
          style: TextStyle(
            fontWeight: _hasUnsavedChanges ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        actions: [
          if (_hasUnsavedChanges)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.circle, size: 8, color: Colors.orange),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildMenuBar(),
          Expanded(
            child: _buildEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: [
          _buildMenu(
            'Arquivo',
            [
              _MenuItem('Novo', Icons.description, _newFile),
              _MenuItem('Salvar', Icons.save, _saveFile),
              _MenuItem('Salvar Como', Icons.save_as, _saveAsFile),
              _MenuItem('Carregar', Icons.folder_open, _loadFile),
              _MenuItem('Download', Icons.download, _downloadFile),
            ],
          ),
          _buildMenu(
            'Editar',
            [
              _MenuItem('Recortar', Icons.content_cut, _cutText),
              _MenuItem('Copiar', Icons.content_copy, _copyText),
              _MenuItem('Selecionar Tudo', Icons.select_all, _selectAll),
            ],
          ),
          _buildMenu(
            'Exibir',
            [
              _MenuItem(
                'Normal',
                Icons.text_fields,
                () => _toggleViewMode(ViewMode.normal),
                isSelected: _viewMode == ViewMode.normal,
              ),
              _MenuItem(
                'Formato Rich',
                Icons.format_paint,
                () => _toggleViewMode(ViewMode.richFormat),
                isSelected: _viewMode == ViewMode.richFormat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(String title, List<_MenuItem> items) {
    return PopupMenuButton<VoidCallback>(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      onSelected: (callback) => callback(),
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<VoidCallback>(
              value: item.onTap,
              child: Row(
                children: [
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(item.title),
                  if (item.isSelected) ...[
                    const Spacer(),
                    const Icon(Icons.check, size: 20),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEditor() {
    if (_viewMode == ViewMode.richFormat) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: _textController.text,
          selectable: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Digite seu texto aqui...',
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  _MenuItem(this.title, this.icon, this.onTap, {this.isSelected = false});
}

class _SaveAsDialog extends StatefulWidget {
  final Function(String name, FileType type) onSave;

  const _SaveAsDialog({required this.onSave});

  @override
  State<_SaveAsDialog> createState() => _SaveAsDialogState();
}

class _SaveAsDialogState extends State<_SaveAsDialog> {
  final TextEditingController _nameController = TextEditingController();
  FileType _selectedType = FileType.txt;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salvar Como'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do arquivo',
              hintText: 'Digite o nome do arquivo',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Tipo: '),
              const SizedBox(width: 16),
              DropdownButton<FileType>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(
                    value: FileType.txt,
                    child: Text('.txt'),
                  ),
                  DropdownMenuItem(
                    value: FileType.md,
                    child: Text('.md'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.onSave(_nameController.text, _selectedType);
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
