import 'package:flutter/material.dart';
import 'package:flutter_notes/models/note.dart';
import 'package:flutter_notes/services/database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotesHomePage(title: 'Flutter Notes'),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key, required this.title});

  final String title;

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  late Future<List<Note>> _notes;

  @override
  void initState() {
    super.initState();
    _notes = DatabaseHelper.instance.readAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Displaying error message if something goes wrong with loading notes
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData) {
              List<Note> notes = snapshot.data!;
              if (notes.isEmpty) {
                // Displaying a message when there are no notes
                return Center(child: Text('No notes found, add some!'));
              }
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  Note note = notes[index];
                  return ListTile(
                    title: Text(note.title),
                    subtitle: Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      // Navigating to NotePage to edit the selected note
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotePage(note: note)),
                      );
                      // Refresh the list of notes after potentially updating a note
                      setState(() {
                        _notes = DatabaseHelper.instance.readAllNotes();
                      });
                    },
                  );
                },
              );
            }
          }
          // Showing a loading spinner while waiting for the notes to load
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigating to NotePage to create a new note
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotePage(note: Note(title: '', body: ''))),
          );
          // Refresh the list of notes after potentially adding a new note
          setState(() {
            _notes = DatabaseHelper.instance.readAllNotes();
          });
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotePage extends StatelessWidget {
  final Note note;

  NotePage({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: note.title);
    TextEditingController bodyController = TextEditingController(text: note.body);

    return Scaffold(
      appBar: AppBar(
        title: Text(note.id == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter note title here...',
              ),
            ),
            Expanded(
              child: TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  hintText: 'Enter note text here...',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          note.title = titleController.text;
          note.body = bodyController.text;
          // Saving the note to the database or updating it
          if (note.id == null) {
            await DatabaseHelper.instance.create(note);
          } else {
            await DatabaseHelper.instance.update(note);
          }
          // Going back to the previous screen after saving the note
          Navigator.pop(context);
        },
        tooltip: 'Save Note',
        child: const Icon(Icons.save),
      ),
    );
  }
}
