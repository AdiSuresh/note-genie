import 'package:flutter/material.dart';
import 'package:note_maker/utils/extensions/global_key.dart';
import 'package:note_maker/widgets/menu_items.dart';

class PopupMenu extends StatefulWidget {
  final OverlayPortalController controller;
  final List<(String, VoidCallback)> items;
  final Widget anchor;

  const PopupMenu({
    super.key,
    required this.controller,
    required this.items,
    required this.anchor,
  });

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  OverlayPortalController get controller {
    return widget.controller;
  }

  final menuItemsKey = GlobalKey();
  double menuItemsWidth = 0.0;

  void setMenuItemsWidth() {
    if (menuItemsWidth > 0.0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        switch (menuItemsKey.findRect()?.width) {
          case final double width:
            setState(() {
              menuItemsWidth = width;
            });
          case _:
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (context) {
        final rect = this.context.rect!;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            if (controller.isShowing) {
              controller.hide();
              return;
            }
          },
          child: Stack(
            children: [
              Listener(
                onPointerDown: (event) {
                  controller.hide();
                },
                child: const ModalBarrier(),
              ),
              Positioned(
                left: rect.bottomCenter.dx,
                top: rect.bottomCenter.dy - rect.height,
                child: TweenAnimationBuilder(
                  tween: Tween(
                    begin: 0.95,
                    end: 1.0,
                  ),
                  duration: const Duration(
                    milliseconds: 125,
                  ),
                  builder: (context, value, child) {
                    setMenuItemsWidth();
                    return Transform(
                      transform: Matrix4.identity()
                        ..translate(
                          -menuItemsWidth / 2,
                        )
                        ..scale(
                          value,
                        ),
                      child: Opacity(
                        opacity: menuItemsWidth > 0.0 ? 1 : 0,
                        child: MenuItems(
                          key: menuItemsKey,
                          items: widget.items.map(
                            (e) {
                              final (title, onTap) = e;
                              return (
                                title,
                                () {
                                  controller.hide();
                                  onTap();
                                }
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      child: widget.anchor,
    );
  }
}

extension on BuildContext {
  Rect? get rect {
    return switch (findRenderObject() as RenderBox?) {
      final RenderBox box => box.localToGlobal(
            Offset.zero,
          ) &
          box.size,
      _ => null,
    };
  }
}
