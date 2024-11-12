import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/sqllite.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final SQLite _db = SQLite();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  int? _editingNoteId;
  String _searchQuery = '';
  Timer? _debounce;

  String? _titleError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    super.dispose();
  }

  void _loadNotes() async {
    final notes = await _db.getNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
    });
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note['title']),
          content: SingleChildScrollView(
            child: Text(note['content']),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(Map<String, dynamic> note) {
    _titleController.text = note['title'];
    _contentController.text = note['content'];
    _editingNoteId = note['id'];
    _showAddNoteDialog();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int id) async {
    await _db.deleteNote(id);
    _loadNotes();
  }

  void _showAddNoteDialog() {
    setState(() {
      _titleError = null;
      _contentError = null;
    });
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                  _editingNoteId == null ? 'Create New Note' : 'Edit Note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        errorText: _titleError,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _titleError =
                              value.isEmpty ? 'Title is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        errorText: _contentError,
                      ),
                      maxLines: 5,
                      onChanged: (value) {
                        setState(() {
                          _contentError =
                              value.isEmpty ? 'Content is required' : null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _titleError = _titleController.text.isEmpty
                          ? 'Title is required'
                          : null;
                      _contentError = _contentController.text.isEmpty
                          ? 'Content is required'
                          : null;
                    });

                    if (_titleError == null && _contentError == null) {
                      _addOrUpdateNote();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateNote() {
    setState(() {
      _titleError = _titleController.text.isEmpty ? 'Title is required' : null;
      _contentError =
          _contentController.text.isEmpty ? 'Content is required' : null;
    });
    return _titleError == null && _contentError == null;
  }

  void _addOrUpdateNote() async {
    if (!_validateNote()) return;

    if (_editingNoteId != null) {
      await _db.updateNote({
        'id': _editingNoteId,
        'title': _titleController.text,
        'content': _contentController.text,
      });
      setState(() {
        _editingNoteId = null;
      });
    } else {
      await _db.insertNote({
        'title': _titleController.text,
        'content': _contentController.text,
      });
    }

    _titleController.clear();
    _contentController.clear();
    _loadNotes();
  }

  void _searchNotes(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.toLowerCase();
        if (_searchQuery.isEmpty) {
          _filteredNotes = _notes;
        } else {
          _filteredNotes = _notes.where((note) {
            return note['title'].toLowerCase().contains(_searchQuery) ||
                note['content'].toLowerCase().contains(_searchQuery);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Notes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchNotes,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredNotes.isEmpty
                  ? Center(child: Text('No notes available'))
                  : ListView.builder(
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = _filteredNotes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            title: Text(note['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(note['content']),
                            onTap: () => _showNoteDetails(note),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.deepPurple,
                                  onPressed: () => _editNote(note),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () => _confirmDelete(note['id']),
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
      bottomNavigationBar: Container(
        height: 80.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: FloatingActionButton(
            onPressed: () {
              _editingNoteId = null;
              _showAddNoteDialog();
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
