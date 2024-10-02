import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/app/themes/themes.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/views/note_info/bloc.dart';
import 'package:note_maker/views/note_info/widgets/count_widget.dart';

class NoteInfo extends StatefulWidget {
  static const path = '/note-info';

  const NoteInfo({
    super.key,
  });

  @override
  State<NoteInfo> createState() => _NoteInfoState();
}

class _NoteInfoState extends State<NoteInfo> with TickerProviderStateMixin {
  static final logger = AppLogger(
    NoteInfo,
  );

  late final TabController tabCtrl;

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(
      length: 2,
      vsync: this,
    );
    logger.i(
      'NoteInfo screen',
    );
  }

  NoteInfoBloc get bloc => context.read();
  Note get note => bloc.state.note;

  int countSentences(
    String text,
  ) {
    final sentenceEndingPunctuation = RegExp(
      r'[.!?]',
    );
    final result = sentenceEndingPunctuation
        .allMatches(
          text,
        )
        .length;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final content = Document.fromJson(
      note.content,
    ).toPlainText().trim();
    final nWords = RegExp(
      r"\w+(\'\w+)?",
    )
        .allMatches(
          content,
        )
        .length;
    final nChars = content.length;
    final nCharsWithoutSpaces = content
        .replaceAll(
          ' ',
          '',
        )
        .length;
    final nSentences = countSentences(
      content,
    );
    final counts = <(int, String)>[
      (
        nWords,
        toBeginningOfSentenceCase(
          'words',
        )!,
      ),
      (
        nChars,
        toBeginningOfSentenceCase(
          'characters',
        )!,
      ),
      (
        nCharsWithoutSpaces,
        toBeginningOfSentenceCase(
          'without spaces',
        )!,
      ),
      (
        nSentences,
        toBeginningOfSentenceCase(
          'Sentences',
        )!,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 22.5,
                  top: 22.5,
                  bottom: 15,
                ),
                child: Text(
                  note.title,
                  style: context.themeData.textTheme.titleLarge,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(7.5),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'count',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Last updated',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.5,
                ),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    ...counts.map(
                      (e) {
                        final (count, text) = e;
                        return CountWidget(
                          count: count,
                          text: text,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: tabCtrl,
                    tabs: const [
                      Tab(
                        child: Text(
                          'Collections',
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Linked Notes',
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabCtrl,
                      children: [
                        ListView(),
                        ListView(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ).copyWith(
                      bottom: 15,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shape: Themes.shape,
                      ),
                      onPressed: () {
                        context.extra = note;
                        context.push(
                          EditNote.path,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Edit Note',
                          ),
                          Icon(
                            Icons.edit_document,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
