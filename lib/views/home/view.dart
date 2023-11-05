import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/boolean_list.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/views/edit_note_collection/view.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = AppLogger(
    HomePage,
  );

  Stream<List<NoteCollection>>? noteCollectionStream;
  Stream<List<Note>>? noteStream;

  HomeBloc get bloc => context.read();

  @override
  void initState() {
    super.initState();
    HomeBloc.noteCollectionDao.getStream.then(
      (value) {
        noteCollectionStream = value;
        bloc.add(
          UpdatePageEvent(),
        );
      },
    );
    HomeBloc.noteDao.getStream.then(
      (value) {
        noteStream = value;
        bloc.add(
          UpdatePageEvent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note Maker',
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return StreamBuilder<List<NoteCollection>>(
                stream: noteCollectionStream,
                builder: (context, snapshot) {
                  final showLoading = [
                    snapshot.connectionState == ConnectionState.waiting,
                    noteCollectionStream == null,
                  ].computeOR();
                  if (showLoading) {
                    return const Text(
                      'Loading collections',
                    );
                  }
                  final collections = snapshot.data ?? [];
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              if (collections.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(7.5),
                                  child: Text(
                                    'No collections yet',
                                  ),
                                ),
                              for (final collection in collections)
                                InkWell(
                                  focusColor: Colors.amber,
                                  onTap: () {
                                    context.extra = collection;
                                    context.push(
                                      EditNoteCollection.routeName,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.5),
                                    child: Text(
                                      collection.name,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.extra = null;
                          context.push(
                            EditNoteCollection.routeName,
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return StreamBuilder(
                stream: noteStream,
                builder: (context, snapshot) {
                  final showLoading = [
                    snapshot.connectionState == ConnectionState.waiting,
                    noteStream == null,
                  ].computeOR();
                  final notes = snapshot.data ?? [];
                  if (showLoading) {
                    return const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView(
                      children: <Widget>[
                        for (final note in notes)
                          NoteListTile(
                            note: note,
                            onTap: () {
                              context.extra = note;
                              context.push(
                                EditNote.routeName,
                              );
                              logger.d(
                                'push',
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          context.extra = null;
          final result = await context.push(
            EditNote.routeName,
          );
          logger.d(
            'result: ${result.runtimeType}',
          );
          if (result is Note && context.mounted) {
            bloc.add(
              UpdatePageEvent(),
            );
          }
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
