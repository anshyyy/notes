import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:notes/data/notesData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/views/noteCardWidget.dart';

import '../model/note.dart';
import 'NotedetailPage.dart';
import 'editNotePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Note> notes;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshNotes();
    print("sdfnkjsddnsdnisjd");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    NotesDatabase.instance.close();
  }

  Future refreshNotes() async {
    print("chal jaaaaaaaaaaaa bhai");
    setState(() {
      isLoading = true;
    });
    this.notes = await NotesDatabase.instance.readAllNotes();
    print("refresh states main hu abhi");
    print(this.notes);
    print("mil gya muje notes");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditNotePage()),
          );

          refreshNotes();
        },
      ),
      body: notes.isEmpty
          ? Text("No Notes",
              style: TextStyle(color: Colors.white, fontSize: 24))
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.custom(
                gridDelegate: SliverQuiltedGridDelegate(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  repeatPattern: QuiltedGridRepeatPattern.inverted,
                  pattern: [
                    const QuiltedGridTile(2, 2),
                    const QuiltedGridTile(1, 1),
                    const QuiltedGridTile(1, 1),
                    const QuiltedGridTile(1, 2),
                  ],
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = notes[index % notes.length];
                    print("here is notes $notes");
                    print(note);
                    return GestureDetector(
                      onTap: () async {
                        print("yes i m here");
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                NoteDetailPage(noteId: note.id!)));
                      },
                      child: NoteCardWidget(
                          note: note, index: index % notes.length),
                    );
                  },
                ),
              )),
    );
  }
}
