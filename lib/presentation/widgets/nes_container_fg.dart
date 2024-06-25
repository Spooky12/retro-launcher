import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';

/// {@template nes_container_fg}
/// A bordered container, with an optional label.
///
/// A copy of nes_ui's [NesContainer] but with a foreground painter
/// {@endtemplate}
class NesContainerFg extends StatelessWidget {
  /// {@macro nes_container_fg}
  const NesContainerFg({
    super.key,
    this.label,
    this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.padding,
    this.painterBuilder,
  });

  /// An optional label for the container.
  final String? label;

  /// Child of the container.
  final Widget? child;

  /// Container width.
  final double? width;

  /// Container height.
  final double? height;

  /// Background color of this container,
  /// when null, defaults to [ThemeData.cardColor].
  final Color? backgroundColor;

  /// An optional padding to apply to the container.
  ///
  /// When omitted, defaults to [NesContainerTheme.padding].
  final EdgeInsets? padding;

  /// The builder that create the painter to use for this container.
  ///
  /// When omitted, defaults to [NesContainerTheme.painter].
  final NesContainerPainterBuilder? painterBuilder;

  @override
  Widget build(BuildContext context) {
    final nesContainerTheme = context.nesThemeExtension<NesContainerTheme>();

    final textStyle = nesContainerTheme.labelTextStyle;

    final containerColor = backgroundColor ?? nesContainerTheme.backgroundColor;

    final padding = this.padding ?? nesContainerTheme.padding;

    final nesTheme = context.nesThemeExtension<NesTheme>();

    final pixelSize = nesContainerTheme.pixelSize ?? nesTheme.pixelSize;

    final painter = painterBuilder ?? nesContainerTheme.painter;

    return CustomPaint(
      foregroundPainter: painter(
        label: label,
        pixelSize: pixelSize,
        textStyle: textStyle,
        backgroundColor: Colors.transparent,
        borderColor: nesContainerTheme.borderColor,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: ColoredBox(
          color: containerColor,
          child: SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
