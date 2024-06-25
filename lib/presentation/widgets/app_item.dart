import 'dart:math';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

import 'nes_container_fg.dart';
import 'nes_pressable_2.dart';
import 'pixel_shader_effect.dart';

class AppItem extends StatefulWidget {
  const AppItem({
    required this.app,
    super.key,
  });

  final Application app;

  @override
  State<AppItem> createState() => _AppItemState();
}

class _AppItemState extends State<AppItem> {
  final _overlayController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildOverlay,
      child: NesPressable2(
        onTap: widget.app.openApp,
        onLongPress: _overlayController.show,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: NesContainerFg(
                height: 56,
                width: 56,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.grey.shade100,
                child: PixelShaderEffect(
                  child: switch (widget.app) {
                    ApplicationWithIcon(:final icon) => Image.memory(icon),
                    _ => Center(child: NesIcon(iconData: NesIcons.alien)),
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.app.appName,
              style:
                  Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final OverlayState overlayState =
        Overlay.of(context, debugRequiredFor: widget);
    final RenderBox box = this.context.findRenderObject()! as RenderBox;
    final Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    return _Overlay(
      application: widget.app,
      target: target,
      targetSize: box.size,
      onClose: _overlayController.hide,
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({
    required this.application,
    required this.target,
    required this.targetSize,
    required this.onClose,
  });

  final Application application;
  final Offset target;
  final Size targetSize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final nesTheme = context.nesThemeExtension<NesTheme>();
    final pixelSize = nesTheme.pixelSize;
    return Positioned.fill(
      bottom: MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0.0,
      child: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => onClose(),
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.black26),
            ),
          ),
          CustomSingleChildLayout(
            delegate: _OverlayPositionDelegate(
              target: target,
              targetSize: targetSize,
              offset: Offset(pixelSize * 2, -pixelSize * 2), //For the shadow
            ),
            child: NesDropshadow(
              child: NesContainer(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!application.systemApp) ...[
                      NesButton.icon(
                        type: NesButtonType.error,
                        icon: NesIcons.delete,
                        onPressed: () {
                          application.uninstallApp();
                          onClose();
                        },
                      ),
                      const SizedBox(width: 12.0),
                    ],
                    NesButton.icon(
                      type: NesButtonType.normal,
                      icon: NesIcons.wrench,
                      onPressed: () {
                        application.openSettingsScreen();
                        onClose();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPositionDelegate extends SingleChildLayoutDelegate {
  _OverlayPositionDelegate({
    required this.target,
    required this.targetSize,
    required this.offset,
  });

  final Offset target;
  final Size targetSize;

  final Offset offset;

  static const double verticalOffset = 8.0;
  static const double margin = 10.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final fitsAbove = target.dy -
            targetSize.height / 2 -
            verticalOffset -
            childSize.height +
            offset.dy >=
        margin;

    late final double dy;
    if (fitsAbove) {
      dy = max(
        target.dy -
            targetSize.height / 2 -
            verticalOffset -
            childSize.height +
            offset.dy,
        margin,
      );
    } else {
      dy = min(
        target.dy + targetSize.height / 2 + offset.dy,
        size.height - margin,
      );
    }
    final dx = clampDouble(
      target.dx - childSize.width / 2 - margin + offset.dx,
      margin,
      size.width - childSize.width - margin,
    );

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_OverlayPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        targetSize != oldDelegate.targetSize ||
        offset != oldDelegate.offset;
  }
}
