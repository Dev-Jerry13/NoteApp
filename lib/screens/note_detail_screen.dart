import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../services/file_service.dart';
import '../widgets/attachment_tile.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.note});

  final Note note;

  static Route<void> route(Note note) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation);
        return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final path = await FileService().exportNoteAsTxt(title: note.title, content: note.content);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported to $path')),
                );
              }
            },
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(NoteEditorScreen.route(note)),
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete note?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );

              if (shouldDelete == true && context.mounted) {
                await context.read<NotesProvider>().deleteNote(note.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Hero(
        tag: 'note-${note.id}',
        child: Material(
          color: Colors.transparent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Created: ${dateFormat.format(note.createdAt)}'),
              Text('Updated: ${dateFormat.format(note.updatedAt)}'),
              const SizedBox(height: 16),
              Text(note.content, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (note.attachments.isEmpty)
                const Text('No attachments')
              else
                ...note.attachments.map((f) => AttachmentTile(file: f)),
            ],
          ),
        ),
      ),
    );
  }
}
