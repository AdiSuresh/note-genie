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
        final menuItems = [
          'Rename',
          'Delete',
        ];
        return CustomAnimatedSwitcher(
          child: switch (chat) {
            ChatModel(
              remoteId: null,
            ) =>
              child,
            _ => TextButton(
                key: _buttonKey,
                onPressed: () {
                  _menuController.toggle();
                },
                child: OverlayPortal(
                  controller: _menuController,
                  overlayChildBuilder: (context) {
                    final rect = _buttonKey.findRect();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Listener(
                          onPointerDown: (event) {
                            _menuController.toggle();
                          },
                          child: ModalBarrier(
                            dismissible: true,
                          ),
                        ),
                        Positioned(
                          top: rect?.top,
                          child: TweenAnimationBuilder(
                            tween: Tween(
                              begin: 0.95,
                              end: 1.0,
                            ),
                            duration: const Duration(
                              milliseconds: 125,
                            ),
                            builder: (context, value, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scale(
                                    value,
                                  ),
                                child: Material(
                                  elevation: 2.5,
                                  borderRadius: BorderRadius.circular(15),
                                  child: IntrinsicWidth(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: menuItems.indexed.map(
                                        (element) {
                                          final (i, e) = element;
                                          final borderRadius = switch (i) {
                                            0 => BorderRadius.vertical(
                                                top: Radius.circular(15),
                                              ),
                                            _ when i == menuItems.length - 1 =>
                                              BorderRadius.vertical(
                                                bottom: Radius.circular(15),
                                              ),
                                            _ => null,
                                          };
                                          return InkWell(
                                            onTap: () {},
                                            borderRadius: borderRadius,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                e,
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
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
              ),
          },
        );
      },
    );
  }
}
