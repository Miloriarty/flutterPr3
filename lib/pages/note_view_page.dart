import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notes_provider.dart';

class NoteViewPage extends StatelessWidget {
  final int noteId;

  const NoteViewPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NotesProvider>().findById(noteId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          note != null && note.isImportant ? '⭐️ Важная заметка' : 'Заметка',
        ),
      ),
      body: note == null
          ? const Center(child: Text('Заметка удалена'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                note.text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}
