import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/note_collection/dao.dart';
import '../../models/note_collection/note_collection.dart';
import 'bloc.dart';
import '../../utils/extensions/state.dart';

class EditNoteCollection extends StatefulWidget {
  static const routeName = '/edit-note-collection';

  const EditNoteCollection({
    super.key,
  });

  @override
  State<EditNoteCollection> createState() => _EditNoteCollectionState();
}

class _EditNoteCollectionState extends State<EditNoteCollection> {
  static final noteCollectionDao = NoteCollectionDao();
  final formKey = GlobalKey<FormState>();
  late final NoteCollection noteCollection;
  final nameCtrl = TextEditingController();
  bool isNew = false;

  EditNoteCollectionBloc get bloc => context.read();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<EditNoteCollectionBloc>();
    isNew = bloc.state.collection == null;
    noteCollection = bloc.state.collection ??
        const NoteCollection(
          name: '',
        );
    nameCtrl.text = noteCollection.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.inversePrimary,
        title: Text(
          '${isNew ? 'Add' : 'Edit'} Collection',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Form(
              key: formKey,
              child: TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                validator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
                onTap: () {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (isValid) {
                    return;
                  }
                  formKey.currentState?.reset();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          final isValid = formKey.currentState?.validate() ?? false;
          if (!isValid) {
            return;
          }
          final result = noteCollection.copyWith(
            name: nameCtrl.text,
          );
          if (isNew) {
            noteCollectionDao
                .insert(
              result,
            )
                .then(
              (value) {
                context.pop(
                  result,
                );
              },
            );
          } else {
            noteCollectionDao
                .update(
              result,
            )
                .then(
              (value) {
                if (value != null) {
                  context.pop(result);
                }
              },
            );
          }
        },
        child: const Text(
          'Save',
        ),
      ),
    );
  }
}
