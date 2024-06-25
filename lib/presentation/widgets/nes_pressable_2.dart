import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

/// {@template nes_pressable2}
/// A widget that allows a [child] to be pressable.
/// Meaning that it can be clicked or held.
///
/// A copy of nes_ui's [NesPressable] with long press callback
/// {@endtemplate}
class NesPressable2 extends StatefulWidget {
  /// {@macro nes_pressable2}
  const NesPressable2({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.disabled = false,
    this.behavior,
    super.key,
  });

  /// Called when the tap input has happened.
  final VoidCallback? onTap;

  /// Called when the long press input has happened.
  final VoidCallback? onLongPress;

  /// Disabled pressable component
  final bool disabled;

  /// Child.
  final Widget child;

  /// The behavior of the hit test of this widget.
  final HitTestBehavior? behavior;

  @override
  State<NesPressable2> createState() => _NesPressableState();
}

class _NesPressableState extends State<NesPressable2> {
  bool _pressed = false;

  bool get enabled =>
      !widget.disabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final nesTheme = context.nesThemeExtension<NesTheme>();
    final offSet = Offset(
      0,
      _pressed && enabled ? nesTheme.pixelSize.toDouble() : 0,
    );
    return Transform.translate(
      offset: offSet,
      child: MouseRegion(
        cursor: nesTheme.clickCursor,
        child: GestureDetector(
          behavior: widget.behavior,
          onTap: widget.onTap != null && !widget.disabled
              ? () {
                  widget.onTap?.call();
                  Future.delayed(Durations.short2).then(
                    (_) => setState(() => _pressed = false),
                  );
                }
              : null,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onLongPress: enabled ? widget.onLongPress : null,
          onLongPressUp:
              enabled ? () => setState(() => _pressed = false) : null,
          onLongPressCancel:
              enabled ? () => setState(() => _pressed = false) : null,
          child: widget.child,
        ),
      ),
    );
  }
}
