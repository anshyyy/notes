import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../data/notesData.dart';
import '../model/note.dart';
import 'editNotePage.dart';

class NoteDetailPage extends StatefulWidget {
  late int noteId;

  NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    NotesDatabase.instance.close();
  }

  Future refreshNotes() async {
    setState(() {
      isLoading = true;
    });
    this.note = await NotesDatabase.instance.readNote(widget.noteId);
    setState(() {
      isLoading = false;
    });
  }

  Widget deleteButton() => IconButton(
      onPressed: () async {
        await NotesDatabase.instance.delete(widget.noteId);
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.delete));
  Widget editButton() => IconButton(
      onPressed: () async {
        if (isLoading) return;
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddEditNotePage(note: note)));
      },
      icon: Icon(Icons.edit_outlined));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(note.createdTime),
                      style: TextStyle(color: Colors.white38),
                    ),
                    SizedBox(height: 8),
                    Text(
                      note.description,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ));
  }
}
