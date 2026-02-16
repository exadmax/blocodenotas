import 'package:flutter/material.dart';
import '../models/note_file.dart';

class FileManagerDialog extends StatelessWidget {
  final List<NoteFile> files;
  final Function(NoteFile) onFileSelected;
  final Function(String) onFileDeleted;

  const FileManagerDialog({
    super.key,
    required this.files,
    required this.onFileSelected,
    required this.onFileDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gerenciador de Arquivos'),
      content: SizedBox(
        width: double.maxFinite,
        child: files.isEmpty
            ? const Center(
                child: Text('Nenhum arquivo salvo'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    leading: Icon(
                      file.type == FileType.txt
                          ? Icons.description
                          : Icons.article,
                      color: file.type == FileType.txt
                          ? Colors.blue
                          : Colors.green,
                    ),
                    title: Text(file.fullName),
                    subtitle: Text(
                      'Modificado: ${_formatDate(file.lastModified)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context, file);
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onFileSelected(file);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, NoteFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${file.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              onFileDeleted(file.name);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
