import 'package:flutter/foundation.dart';

class NotesProvider extends ChangeNotifier {
  final List<String> _notes = [];
  int? _editingIndex;

  List<String> get notes => List.unmodifiable(_notes);
  int? get editingIndex => _editingIndex;
  bool get isEditing => _editingIndex != null;

  void addNote(String text) {
    _notes.add(text);
    _editingIndex = null;
    notifyListeners();
  }

  void editNote(int index) {
    _editingIndex = index;
    notifyListeners();
  }

  void updateNote(int index, String text) {
    _notes[index] = text;
    _editingIndex = null;
    notifyListeners();
  }

  void deleteNote(int index) {
    _notes.removeAt(index);

    if (_editingIndex == index) {
      _editingIndex = null;
    } else if (_editingIndex != null && _editingIndex! > index) {
      _editingIndex = _editingIndex! - 1;
    }

    notifyListeners();
  }

  void cancelEditing() {
    _editingIndex = null;
    notifyListeners();
  }
}
