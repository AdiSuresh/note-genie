import 'package:flutter/material.dart';
import '../../utils/extensions/state_extension.dart';

class EditNote extends StatefulWidget {
  const EditNote({
    super.key,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: const Text(
          'Home',
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
            // Expanded TextField
            Expanded(
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Description',
                ),
              ),
            ),

            // Your other widgets here
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () {},
        child: const Text(
          'Save',
        ),
      ),
    );
  }
}
