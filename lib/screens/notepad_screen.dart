import 'dart:async';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/note_file.dart';
import '../services/file_storage_service.dart';
import '../widgets/file_manager_dialog.dart';

enum ViewMode { normal, richFormat }

enum _LoadSource { appMemory, device }

enum _WebSaveChoice { appOnly, pcOnly, appAndPc }

enum _MenuAction {
  newFile,
  save,
  saveAs,
  load,
  download,
  cut,
  copy,
  selectAll,
  viewNormal,
  viewRich,
}

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();
  final FileStorageService _fileService = FileStorageService();
  NoteFile? _currentFile;
  ViewMode _viewMode = ViewMode.normal;
  bool _hasUnsavedChanges = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

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
    _editorScrollController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  void _newFile() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() async => _createNewFile());
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

  Future<void> _saveFile() async {
    if (kIsWeb) {
      await _saveFileWeb();
      return;
    }

    if (_isAndroid) {
      await _saveAsFile(
        saveToDevice: true,
        initialName: _currentFile?.name,
        initialType: _currentFile?.type ?? FileType.txt,
      );
      return;
    }

    await _saveInMemoryOnly();
  }

  Future<void> _saveFileWeb() async {
    final choice = await _showWebSaveOptions();
    if (choice == null) {
      return;
    }

    if (_currentFile == null) {
      await _saveAsFile(
        downloadAfterSave:
            choice == _WebSaveChoice.pcOnly || choice == _WebSaveChoice.appAndPc,
      );
      return;
    }

    final updatedFile = _currentFile!.copyWith(
      content: _textController.text,
      lastModified: DateTime.now(),
    );

    _fileService.saveFile(updatedFile);
    setState(() {
      _currentFile = updatedFile;
      _hasUnsavedChanges = false;
    });

    if (choice == _WebSaveChoice.pcOnly || choice == _WebSaveChoice.appAndPc) {
      await _fileService.saveFileToDevice(updatedFile);
      _showSnackBar('Arquivo salvo e baixado: ${updatedFile.fullName}');
      return;
    }

    _showSnackBar('Arquivo salvo no aplicativo: ${updatedFile.fullName}');
  }

  Future<void> _saveInMemoryOnly() async {
    if (_currentFile == null) {
      await _saveAsFile();
      return;
    }

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

  Future<void> _saveAsFile({
    bool downloadAfterSave = false,
    bool saveToDevice = false,
    String? initialName,
    FileType initialType = FileType.txt,
  }) async {
    final result = await showDialog<_SaveAsResult>(
      context: context,
      builder: (context) => _SaveAsDialog(
        initialName: initialName,
        initialType: initialType,
      ),
    );

    if (result == null) {
      return;
    }

    final file = NoteFile(
      name: result.name,
      content: _textController.text,
      type: result.type,
      lastModified: DateTime.now(),
    );

    _fileService.saveFile(file);
    setState(() {
      _currentFile = file;
      _hasUnsavedChanges = false;
    });

    if (downloadAfterSave || saveToDevice) {
      final path = await _fileService.saveFileToDevice(file);
      if (path != null) {
        final action = kIsWeb ? 'baixado' : 'salvo no dispositivo';
        _showSnackBar('Arquivo $action: ${file.fullName}');
      }
      return;
    }

    _showSnackBar('Arquivo salvo como: ${file.fullName}');
  }

  Future<void> _loadFile() async {
    final source = await showModalBottomSheet<_LoadSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_copy_outlined),
              title: const Text('Carregar do aplicativo'),
              subtitle: const Text('Arquivos salvos nesta sessão'),
              onTap: () => Navigator.pop(context, _LoadSource.appMemory),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Carregar do dispositivo'),
              subtitle: Text(
                kIsWeb
                    ? 'Enviar arquivo do computador'
                    : 'Abrir arquivo do armazenamento do celular',
              ),
              onTap: () => Navigator.pop(context, _LoadSource.device),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }

    if (source == _LoadSource.appMemory) {
      _openFileManager();
      return;
    }

    await _loadFromDevice();
  }

  void _openFileManager() {
    showDialog(
      context: context,
      builder: (context) => FileManagerDialog(
        files: _fileService.savedFiles,
        onFileSelected: (file) {
          if (_hasUnsavedChanges) {
            _showUnsavedChangesDialog(() async => _openFile(file));
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

  Future<void> _loadFromDevice() async {
    final file = await _fileService.pickLocalTextFile();

    if (file == null) {
      _showSnackBar('Nenhum arquivo selecionado');
      return;
    }

    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() async => _openFile(file));
    } else {
      _openFile(file);
    }
  }

  void _openFile(NoteFile file) {
    _fileService.saveFile(file);
    setState(() {
      _currentFile = file;
      _textController.text = file.content;
      _hasUnsavedChanges = false;
      _viewMode =
          file.type == FileType.md ? ViewMode.richFormat : ViewMode.normal;
    });
  }

  Future<void> _downloadFile() async {
    if (_currentFile == null) {
      _showSnackBar('Salve o arquivo primeiro');
      return;
    }

    final file = _currentFile!.copyWith(
      content: _textController.text,
      lastModified: DateTime.now(),
    );

    _fileService.saveFile(file);
    setState(() {
      _currentFile = file;
      _hasUnsavedChanges = false;
    });

    await _fileService.saveFileToDevice(file);
    _showSnackBar(kIsWeb
        ? 'Download iniciado: ${file.fullName}'
        : 'Arquivo salvo no dispositivo: ${file.fullName}');
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

  Future<void> _showUnsavedChangesDialog(Future<void> Function() onDiscard) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text('Deseja salvar as alterações antes de continuar?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await onDiscard();
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
            onPressed: () async {
              Navigator.pop(context);
              await _saveFile();
              await onDiscard();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<_WebSaveChoice?> _showWebSaveOptions() async {
    return showModalBottomSheet<_WebSaveChoice>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_outlined),
              title: const Text('Salvar no aplicativo'),
              subtitle: const Text('Mantém o arquivo na sessão atual'),
              onTap: () => Navigator.pop(context, _WebSaveChoice.appOnly),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Salvar no computador'),
              subtitle: const Text('Baixa o arquivo para o seu PC'),
              onTap: () => Navigator.pop(context, _WebSaveChoice.pcOnly),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt_outlined),
              title: const Text('Salvar no aplicativo e no computador'),
              onTap: () => Navigator.pop(context, _WebSaveChoice.appAndPc),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _currentFile?.fullName ?? 'Novo Arquivo',
              style: TextStyle(
                fontWeight:
                    _hasUnsavedChanges ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            actions: [
              if (_hasUnsavedChanges)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.circle, size: 10, color: Colors.orange),
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStructuredMenuBar(isCompact),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildEditorPanel()),
                          const SizedBox(height: 12),
                          _buildStatusSection(isCompact),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.newFile:
        _newFile();
        break;
      case _MenuAction.save:
        await _saveFile();
        break;
      case _MenuAction.saveAs:
        await _saveAsFile(
          initialName: _currentFile?.name,
          initialType: _currentFile?.type ?? FileType.txt,
          saveToDevice: _isAndroid,
        );
        break;
      case _MenuAction.load:
        await _loadFile();
        break;
      case _MenuAction.download:
        await _downloadFile();
        break;
      case _MenuAction.cut:
        _cutText();
        break;
      case _MenuAction.copy:
        _copyText();
        break;
      case _MenuAction.selectAll:
        _selectAll();
        break;
      case _MenuAction.viewNormal:
        _toggleViewMode(ViewMode.normal);
        break;
      case _MenuAction.viewRich:
        _toggleViewMode(ViewMode.richFormat);
        break;
    }
  }

  Widget _buildStructuredMenuBar(bool isCompact) {
    final menuGroups = [
      (
        'Arquivo',
        [
          _MenuEntry(
            action: _MenuAction.newFile,
            label: 'Novo',
            icon: Icons.description_outlined,
          ),
          _MenuEntry(
            action: _MenuAction.save,
            label: 'Salvar',
            icon: Icons.save_outlined,
          ),
          _MenuEntry(
            action: _MenuAction.saveAs,
            label: 'Salvar Como',
            icon: Icons.save_as_outlined,
          ),
          _MenuEntry(
            action: _MenuAction.load,
            label: 'Carregar',
            icon: Icons.folder_open_outlined,
          ),
          if (kIsWeb || _isAndroid)
            _MenuEntry(
              action: _MenuAction.download,
              label: kIsWeb ? 'Baixar' : 'Salvar no Dispositivo',
              icon: Icons.download_outlined,
            ),
        ],
      ),
      (
        'Editar',
        const [
          _MenuEntry(
            action: _MenuAction.cut,
            label: 'Recortar',
            icon: Icons.content_cut,
          ),
          _MenuEntry(
            action: _MenuAction.copy,
            label: 'Copiar',
            icon: Icons.content_copy,
          ),
          _MenuEntry(
            action: _MenuAction.selectAll,
            label: 'Selecionar Tudo',
            icon: Icons.select_all,
          ),
        ],
      ),
      (
        'Exibir',
        [
          _MenuEntry(
            action: _MenuAction.viewNormal,
            label: 'Normal',
            icon: _viewMode == ViewMode.normal
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          _MenuEntry(
            action: _MenuAction.viewRich,
            label: 'Formato Rich',
            icon: _viewMode == ViewMode.richFormat
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
        ],
      ),
    ];

    if (isCompact) {
      return Card(
        child: PopupMenuButton<_MenuAction>(
          tooltip: 'Menu',
          onSelected: (action) {
            unawaited(_handleMenuAction(action));
          },
          itemBuilder: (context) {
            final allItems = <PopupMenuEntry<_MenuAction>>[];
            for (final group in menuGroups) {
              final title = group.$1;
              final items = group.$2;
              allItems.add(
                PopupMenuItem<_MenuAction>(
                  enabled: false,
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
              allItems.addAll(
                items.map(
                  (item) => PopupMenuItem<_MenuAction>(
                    value: item.action,
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(item.label),
                      ],
                    ),
                  ),
                ),
              );
              if (group != menuGroups.last) {
                allItems.add(const PopupMenuDivider());
              }
            }
            return allItems;
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu),
                SizedBox(width: 8),
                Text('Menu'),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 4,
            children: [
              _buildCategoryMenu(
                title: 'Arquivo',
                items: [
                  _MenuEntry(
                    action: _MenuAction.newFile,
                    label: 'Novo',
                    icon: Icons.description_outlined,
                  ),
                  _MenuEntry(
                    action: _MenuAction.save,
                    label: 'Salvar',
                    icon: Icons.save_outlined,
                  ),
                  _MenuEntry(
                    action: _MenuAction.saveAs,
                    label: 'Salvar Como',
                    icon: Icons.save_as_outlined,
                  ),
                  _MenuEntry(
                    action: _MenuAction.load,
                    label: 'Carregar',
                    icon: Icons.folder_open_outlined,
                  ),
                  if (kIsWeb || _isAndroid)
                    _MenuEntry(
                      action: _MenuAction.download,
                      label: kIsWeb ? 'Baixar' : 'Salvar no Dispositivo',
                      icon: Icons.download_outlined,
                    ),
                ],
              ),
              _buildCategoryMenu(
                title: 'Editar',
                items: const [
                  _MenuEntry(
                    action: _MenuAction.cut,
                    label: 'Recortar',
                    icon: Icons.content_cut,
                  ),
                  _MenuEntry(
                    action: _MenuAction.copy,
                    label: 'Copiar',
                    icon: Icons.content_copy,
                  ),
                  _MenuEntry(
                    action: _MenuAction.selectAll,
                    label: 'Selecionar Tudo',
                    icon: Icons.select_all,
                  ),
                ],
              ),
              _buildCategoryMenu(
                title: 'Exibir',
                items: [
                  _MenuEntry(
                    action: _MenuAction.viewNormal,
                    label: 'Normal',
                    icon: _viewMode == ViewMode.normal
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  _MenuEntry(
                    action: _MenuAction.viewRich,
                    label: 'Formato Rich',
                    icon: _viewMode == ViewMode.richFormat
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryMenu({
    required String title,
    required List<_MenuEntry> items,
  }) {
    return PopupMenuButton<_MenuAction>(
      tooltip: title,
      onSelected: (action) {
        unawaited(_handleMenuAction(action));
      },
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem<_MenuAction>(
                value: item.action,
                child: Row(
                  children: [
                    Icon(item.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(item.label),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }

  Widget _buildStatusSection(bool isCompact) {
    final statusLabel = _hasUnsavedChanges ? 'Com alterações pendentes' : 'Atualizado';

    final chips = [
      _InfoChip(label: 'Arquivo', value: _currentFile?.fullName ?? 'Não salvo'),
      _InfoChip(label: 'Tipo', value: _currentFile == null ? '-' : (_currentFile?.type == FileType.md ? '.md' : '.txt')),
      _InfoChip(
        label: 'Modo',
        value: _viewMode == ViewMode.normal ? 'Editor de texto' : 'Visualização Markdown',
      ),
      _InfoChip(label: 'Status', value: statusLabel),
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
        children: chips,
      ),
    );
  }

  Widget _buildEditorPanel() {
    final editorBackground = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest
        .withValues(alpha: 0.25);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              _viewMode == ViewMode.richFormat
                  ? 'Pré-visualização'
                  : 'Conteúdo do arquivo',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: editorBackground,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _viewMode == ViewMode.richFormat
                    ? (_textController.text.trim().isEmpty
                        ? const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Digite seu texto para visualizar no formato Rich.'),
                            ),
                          )
                        : Scrollbar(
                            controller: _previewScrollController,
                            thumbVisibility: true,
                            child: Markdown(
                              controller: _previewScrollController,
                              data: _textController.text,
                              selectable: true,
                              padding: const EdgeInsets.all(12),
                            ),
                          ))
                    : Scrollbar(
                        controller: _editorScrollController,
                        thumbVisibility: true,
                        child: TextField(
                          controller: _textController,
                          scrollController: _editorScrollController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Digite seu texto aqui...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final _MenuAction action;
  final String label;
  final IconData icon;

  const _MenuEntry({
    required this.action,
    required this.label,
    required this.icon,
  });
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _SaveAsResult {
  final String name;
  final FileType type;

  const _SaveAsResult({required this.name, required this.type});
}

class _SaveAsDialog extends StatefulWidget {
  final String? initialName;
  final FileType initialType;

  const _SaveAsDialog({
    this.initialName,
    required this.initialType,
  });

  @override
  State<_SaveAsDialog> createState() => _SaveAsDialogState();
}

class _SaveAsDialogState extends State<_SaveAsDialog> {
  late final TextEditingController _nameController;
  late FileType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedType = widget.initialType;
  }

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
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(
                context,
                _SaveAsResult(
                  name: _nameController.text.trim(),
                  type: _selectedType,
                ),
              );
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
