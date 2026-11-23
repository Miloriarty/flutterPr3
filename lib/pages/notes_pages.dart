import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notes_provider.dart';
import 'note_view_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote(NotesProvider provider) {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (provider.editingId == null) {
      provider.addNote(text);
    } else {
      provider.updateNote(provider.editingId!, text);
    }

    _controller.clear();
    _focusNode.unfocus();
  }

  void _cancelEditing(NotesProvider provider) {
    provider.cancelEditing();
    _controller.clear();
    _focusNode.unfocus();
  }

  void _openNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteViewPage(noteId: note.id)),
    );
  }

  void _markImportant(Note note) {
    context.read<NotesProvider>().markImportant(note.id);
    _showSnack('Заметка отмечена как важная ⭐️');
  }

  void _editNote(Note note) {
    context.read<NotesProvider>().startEditing(note.id);
    _controller.text = note.text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    _focusNode.requestFocus();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<bool> _confirmDismiss(Note note, DismissDirection direction) async {
    final provider = context.read<NotesProvider>();

    if (direction == DismissDirection.startToEnd) {
      if (note.isImportant) {
        provider.unmarkImportant(note.id);
        _showSnack('Обычный статус восстановлен');
      }
      return false;
    }

    return true;
  }

  void _onDismissed(Note note) {
    final provider = context.read<NotesProvider>();
    if (provider.editingId == note.id) {
      _controller.clear();
    }
    provider.deleteNote(note.id);
    _showSnack('Заметка удалена');
  }

  Widget _buildNoteCard(Note note, bool isEditingThis) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(note.id),
      confirmDismiss: (direction) => _confirmDismiss(note, direction),
      onDismissed: (_) => _onDismissed(note),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.star_border, color: Colors.white),
            SizedBox(width: 8),
            Text('Обычная', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Удалить', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: note.isImportant ? Colors.amber.shade100 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isEditingThis
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openNote(note),
          onDoubleTap: () => _markImportant(note),
          onLongPress: () => _editNote(note),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.isImportant) ...[
                  const Text('⭐️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    note.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotesProvider>();
    final isEditing = state.isEditing;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заметки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isEditing ? 'Редактирование' : 'Новая заметка',
                hintText: 'Введите текст заметки',
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveNote(state),
                    child: Text(
                      isEditing ? 'Сохранить изменения' : 'Сохранить',
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _cancelEditing(state),
                    child: const Text('Отмена'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Нажатие - открыть ; двойное - ⭐️ ; долгое - редактировать\n'
              'Свайп влево - удалить ; вправо - снять ⭐️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 12),

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
                        final note = state.notes[index];
                        return _buildNoteCard(
                          note,
                          state.editingId == note.id,
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
