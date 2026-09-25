import 'package:flutter/material.dart';

/// Alert dialog style shared by mobile screens.
///
/// App-wide elevated and outlined buttons are sized for full-width form CTAs.
/// Dialog actions need their natural width so multiple actions can sit on one
/// row and stay aligned at the trailing edge.
class AppAlertDialog extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool scrollable;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  const AppAlertDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions,
    this.scrollable = false,
    this.shape,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    const compactButtonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, 44)),
    );
    final actionTheme = baseTheme.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            baseTheme.elevatedButtonTheme.style?.copyWith(
              minimumSize: compactButtonStyle.minimumSize,
            ) ??
            compactButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            baseTheme.outlinedButtonTheme.style?.copyWith(
              minimumSize: compactButtonStyle.minimumSize,
            ) ??
            compactButtonStyle,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            baseTheme.filledButtonTheme.style?.copyWith(
              minimumSize: compactButtonStyle.minimumSize,
            ) ??
            compactButtonStyle,
      ),
    );

    return AlertDialog(
      icon: icon,
      title: title,
      content: content,
      actions: actions
          ?.map((action) => Theme(data: actionTheme, child: action))
          .toList(),
      scrollable: scrollable,
      shape: shape,
      insetPadding:
          insetPadding ??
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
      contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding:
          actionsPadding ?? const EdgeInsets.fromLTRB(20, 8, 20, 16),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 4),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowAlignment: OverflowBarAlignment.end,
      actionsOverflowButtonSpacing: 8,
      titleTextStyle: baseTheme.dialogTheme.titleTextStyle?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      contentTextStyle: baseTheme.dialogTheme.contentTextStyle,
    );
  }
}
