import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_helper.dart';
import 'note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    setState(() {
      _noteList = DatabaseHelper.instance.readAllNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Notes'),
      ),
      body: FutureBuilder(
        future: _noteList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Note> notes = snapshot.data as List<Note>;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index].title),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoteScreen(note: notes[index])),
                    );
                    _updateNoteList();
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteScreen(note: Note(title: '', body: ''))),
          );
          _updateNoteList();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
