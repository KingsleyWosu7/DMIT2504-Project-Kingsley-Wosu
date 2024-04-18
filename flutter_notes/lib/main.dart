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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notes = DatabaseHelper.instance.readAllNotes();
  }

  void _searchNotes() {
    setState(() {
      _notes = DatabaseHelper.instance.searchNotes(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchNotes,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Notes",
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _searchNotes();
                  },
                ),
              ),
              onSubmitted: (value) => _searchNotes(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Note note = snapshot.data![index];
                        return ListTile(
                          title: Text(note.title),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NotePage(note: note)),
                            );
                            setState(() {
                              _notes = DatabaseHelper.instance.readAllNotes();
                            });
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading notes'));
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotePage(note: Note(title: '', body: ''))),
          );
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
        actions: [
          if (note.id != null) // Only show the delete button if the note exists (has an ID)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter note title here...'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(hintText: 'Enter note text here...'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          note.title = titleController.text;
          note.body = bodyController.text;
          if (note.id == null) {
            await DatabaseHelper.instance.create(note);
          } else {
            await DatabaseHelper.instance.update(note);
          }
          Navigator.pop(context);
        },
        tooltip: 'Save Note',
        child: const Icon(Icons.save),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this note?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.delete(note.id!);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
