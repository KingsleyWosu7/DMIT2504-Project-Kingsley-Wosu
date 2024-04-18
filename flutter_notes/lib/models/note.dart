class Note {
  int? id; // for database use
  String title;
  String body;

  Note({this.id, required this.title, required this.body});

  // Convert a Note into a Map. The keys must correspond to the names of the 
  // columns in the database. This is useful for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }

  // Create a copy of the Note with potentially new properties.
  // This is useful for updating the ID after inserting a new note into the database.
  Note copy({int? id, String? title, String? body}) {
    return Note(
      id: id ?? this.id, // Use existing ID if new one isn't provided
      title: title ?? this.title, // Use existing title if new one isn't provided
      body: body ?? this.body, // Use existing body if new one isn't provided
    );
  }

  // Extract a Note object from a Map. This is used for database operations.
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      body: map['body'],
    );
  }
}
