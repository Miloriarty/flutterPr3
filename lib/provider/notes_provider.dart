import 'package:flutter/foundation.dart';

class Note {
  final int id;
  final String text;
  final bool isImportant;

  const Note({required this.id, required this.text, this.isImportant = false});

  Note copyWith({String? text, bool? isImportant}) => Note(
    id: id,
    text: text ?? this.text,
    isImportant: isImportant ?? this.isImportant,
  );
}

class NotesProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  int _nextId = 0;
  int? _editingId;

  List<Note> get notes => List.unmodifiable(_notes);
  int? get editingId => _editingId;
  bool get isEditing => _editingId != null;

  Note? findById(int id) {
    for (final note in _notes) {
      if (note.id == id) return note;
    }
    return null;
  }

  int _indexOf(int id) => _notes.indexWhere((n) => n.id == id);

  void addNote(String text) {
    _notes.add(Note(id: _nextId++, text: text));
    _editingId = null;
    notifyListeners();
  }

  void startEditing(int id) {
    _editingId = id;
    notifyListeners();
  }

  void updateNote(int id, String text) {
    final i = _indexOf(id);
    if (i != -1) _notes[i] = _notes[i].copyWith(text: text);
    _editingId = null;
    notifyListeners();
  }

  void deleteNote(int id) {
    _notes.removeWhere((n) => n.id == id);
    if (_editingId == id) _editingId = null;
    notifyListeners();
  }

  void markImportant(int id) => _setImportant(id, true);

  void unmarkImportant(int id) => _setImportant(id, false);

  void _setImportant(int id, bool value) {
    final i = _indexOf(id);
    if (i == -1 || _notes[i].isImportant == value) return;
    _notes[i] = _notes[i].copyWith(isImportant: value);
    notifyListeners();
  }

  void cancelEditing() {
    _editingId = null;
    notifyListeners();
  }
}
