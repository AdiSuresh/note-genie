import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: controller,
      overlayChildBuilder: (context) {
        final rect = this.context.rect;
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
            alignment: Alignment.center,
            children: [
              Listener(
                onPointerDown: (event) {
                  controller.hide();
                },
                child: const ModalBarrier(),
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
                    final items = widget.items;
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: items.indexed.map(
                              (element) {
                                final (i, e) = element;
                                final (title, callback) = e;
                                final borderRadius = switch (i) {
                                  0 => BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                  _ when i == items.length - 1 =>
                                    BorderRadius.vertical(
                                      bottom: Radius.circular(15),
                                    ),
                                  _ => null,
                                };
                                return InkWell(
                                  onTap: () {
                                    controller.hide();
                                    callback();
                                  },
                                  borderRadius: borderRadius,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      title,
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
