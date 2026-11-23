import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notes_provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote(NotesProvider provider) {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (provider.editingIndex == null) {
      provider.addNote(text);
    } else {
      provider.updateNote(provider.editingIndex!, text);
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заметки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: state.editingIndex == null
                    ? 'Новая заметка'
                    : 'Редактирование',
                hintText: 'Введите текст заметки',
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveNote(state),
                child: Text(
                  state.editingIndex == null
                      ? 'Сохранить'
                      : 'Сохранить изменения',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: state.notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Заметок пока нет',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(state.notes[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.read<NotesProvider>().editNote(
                                      index,
                                    );

                                    _controller.text = state.notes[index];
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.read<NotesProvider>().deleteNote(
                                      index,
                                    );

                                    _controller.clear();
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
