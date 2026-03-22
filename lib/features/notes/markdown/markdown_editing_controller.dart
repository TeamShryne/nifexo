import 'package:flutter/material.dart';

import 'markdown_inline_parser.dart';

class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});

  static const _inlineParser = MarkdownInlineParser();

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final theme = Theme.of(context);
    final lines = text.split('\n');
    final children = <InlineSpan>[];
    var inCodeBlock = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trimLeft();

      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        children.add(
          TextSpan(
            text: line,
            style: style?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
            ),
          ),
        );
      } else if (inCodeBlock) {
        children.add(
          TextSpan(
            text: line,
            style: style?.copyWith(
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      } else {
        children.addAll(_buildLineSpans(line, style, theme));
      }

      if (i != lines.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(style: style, children: children);
  }

  List<InlineSpan> _buildLineSpans(
    String line,
    TextStyle? style,
    ThemeData theme,
  ) {
    final linkColor = theme.colorScheme.primary;
    final mutedStyle = style?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    if (line.startsWith('### ')) {
      return [
        TextSpan(text: '### ', style: mutedStyle),
        ..._inlineParser.parse(
          line.substring(4),
          style?.copyWith(
            fontSize: (style?.fontSize ?? 16) + 2,
            fontWeight: FontWeight.w700,
          ),
          linkColor,
        ),
      ];
    }

    if (line.startsWith('## ')) {
      return [
        TextSpan(text: '## ', style: mutedStyle),
        ..._inlineParser.parse(
          line.substring(3),
          style?.copyWith(
            fontSize: (style?.fontSize ?? 16) + 4,
            fontWeight: FontWeight.w700,
          ),
          linkColor,
        ),
      ];
    }

    if (line.startsWith('# ')) {
      return [
        TextSpan(text: '# ', style: mutedStyle),
        ..._inlineParser.parse(
          line.substring(2),
          style?.copyWith(
            fontSize: (style?.fontSize ?? 16) + 8,
            fontWeight: FontWeight.w800,
          ),
          linkColor,
        ),
      ];
    }

    if (line.startsWith('> ')) {
      return [
        TextSpan(
          text: '> ',
          style: mutedStyle?.copyWith(color: theme.colorScheme.primary),
        ),
        ..._inlineParser.parse(
          line.substring(2),
          style?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
          linkColor,
        ),
      ];
    }

    if (line.startsWith('- [ ] ') ||
        line.startsWith('- [x] ') ||
        line.startsWith('- [X] ')) {
      final isChecked = line.startsWith('- [x] ') || line.startsWith('- [X] ');
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              isChecked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: isChecked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ..._inlineParser.parse(
          line.substring(6),
          style?.copyWith(
            decoration: isChecked ? TextDecoration.lineThrough : null,
          ),
          linkColor,
        ),
      ];
    }

    if (line.startsWith('- ') ||
        line.startsWith('* ') ||
        line.startsWith('+ ')) {
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        ..._inlineParser.parse(line.substring(2), style, linkColor),
      ];
    }

    final numberedMatch = RegExp(r'^(\d+\.\s)(.*)$').firstMatch(line);
    if (numberedMatch != null) {
      return [
        TextSpan(text: numberedMatch.group(1), style: mutedStyle),
        ..._inlineParser.parse(numberedMatch.group(2)!, style, linkColor),
      ];
    }

    return _inlineParser.parse(line, style, linkColor);
  }
}
