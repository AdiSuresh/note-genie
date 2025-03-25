import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/future_data/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/global_key.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/popup_menu.dart';

class ChatPageTitle extends StatelessWidget {
  final _menuController = OverlayPortalController();

  ChatPageTitle({
    super.key,
  });

  GlobalObjectKey get _buttonKey {
    return GlobalObjectKey(
      _menuController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChatBloc>();
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (
              IdleState(
                chat: AsyncData(
                  data: final c1,
                ),
              ),
              IdleState(
                chat: AsyncData(
                  data: final c2,
                ),
              ),
            ):
            return [
              c1.remoteId != c2.remoteId,
              c1.title != c2.title,
            ].or();
          case _:
        }
        return false;
      },
      builder: (context, state) {
        final chat = bloc.idleState.chat.data;
        final pageTitle = switch (chat) {
          ChatModel(
            remoteId: null,
          ) =>
            'New Chat',
          _ => chat.title,
        };
        final child = Text(
          pageTitle,
          style: context.themeData.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
        return CustomAnimatedSwitcher(
          child: switch (chat) {
            ChatModel(
              remoteId: null,
            ) =>
              child,
            _ => PopupMenu(
                controller: _menuController,
                anchor: TextButton(
                  key: _buttonKey,
                  onPressed: () {
                    _menuController.show();
                  },
                  child: Row(
                    children: [
                      child,
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                items: [
                  ('Rename', () {}),
                  ('Delete', () {}),
                ],
              ),
          },
        );
      },
    );
  }
}
