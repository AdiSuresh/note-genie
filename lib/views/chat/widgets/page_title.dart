import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatPageTitle extends StatelessWidget {
  const ChatPageTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) {
        return false;
      },
      builder: (context, state) {
        final pageTitle = 'Chat';
        return Text(
          pageTitle,
          style: context.themeData.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
