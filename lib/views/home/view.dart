import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/note/note.dart';
import '../../utils/extensions/state_extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: const Text(
          'Home',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (final note in notes)
              Text(
                note.title,
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(
            '/edit-note',
          );
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
