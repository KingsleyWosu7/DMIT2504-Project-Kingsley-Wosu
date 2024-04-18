import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_helper.dart';

class NoteScreen extends StatelessWidget {
  final Note note;
  final TextEditingController _titleController;
  final TextEditingController _bodyController;

  NoteScreen({Key? key, required this.note})
      : _titleController = TextEditingController(text: note.title),
        _bodyController = TextEditingController(text: note.body),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.id == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(hintText: 'Body'),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          note.title = _titleController.text;
          note.body = _bodyController.text;
          if (note.id == null) {
            await DatabaseHelper.instance.create(note);
          } else {
            await DatabaseHelper.instance.update(note);
          }
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
