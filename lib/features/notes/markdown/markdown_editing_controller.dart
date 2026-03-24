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
    // Keep IME composing behavior stable (important for paste/edit operations on desktop/mobile keyboards).
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

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
    final mutedStyle = style?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    if (line.startsWith('### ')) {
      return [
        TextSpan(text: '### ', style: mutedStyle),
        ..._inlineNodes(
          theme,
          line.substring(4),
          style?.copyWith(
            fontSize: (style.fontSize ?? 16) + 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ];
    }

    if (line.startsWith('## ')) {
      return [
        TextSpan(text: '## ', style: mutedStyle),
        ..._inlineNodes(
          theme,
          line.substring(3),
          style?.copyWith(
            fontSize: (style.fontSize ?? 16) + 4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ];
    }

    if (line.startsWith('# ')) {
      return [
        TextSpan(text: '# ', style: mutedStyle),
        ..._inlineNodes(
          theme,
          line.substring(2),
          style?.copyWith(
            fontSize: (style.fontSize ?? 16) + 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ];
    }

    if (line.startsWith('> ')) {
      return [
        TextSpan(
          text: '> ',
          style: mutedStyle?.copyWith(color: theme.colorScheme.primary),
        ),
        ..._inlineNodes(
          theme,
          line.substring(2),
          style?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    if (line.startsWith('- [ ] ') ||
        line.startsWith('- [x] ') ||
        line.startsWith('- [X] ') ||
        line.startsWith('* [ ] ') ||
        line.startsWith('* [x] ') ||
        line.startsWith('* [X] ') ||
        line.startsWith('+ [ ] ') ||
        line.startsWith('+ [x] ') ||
        line.startsWith('+ [X] ')) {
      final marker = line.substring(0, 6);
      final isChecked = marker.contains('[x]') || marker.contains('[X]');
      return [
        TextSpan(
          text: marker,
          style: mutedStyle?.copyWith(
            color: isChecked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
        ..._inlineNodes(
          theme,
          line.substring(marker.length),
          style?.copyWith(
            decoration: isChecked ? TextDecoration.lineThrough : null,
          ),
        ),
      ];
    }

    if (line.startsWith('- ') ||
        line.startsWith('* ') ||
        line.startsWith('+ ')) {
      final marker = line.substring(0, 2);
      return [
        TextSpan(
          text: marker,
          style: mutedStyle?.copyWith(fontFamily: 'monospace'),
        ),
        ..._inlineNodes(theme, line.substring(marker.length), style),
      ];
    }

    final numberedMatch = RegExp(r'^(\d+\.\s)(.*)$').firstMatch(line);
    if (numberedMatch != null) {
      return [
        TextSpan(text: numberedMatch.group(1), style: mutedStyle),
        ..._inlineNodes(theme, numberedMatch.group(2)!, style),
      ];
    }

    return _inlineNodes(theme, line, style);
  }

  List<InlineSpan> _inlineNodes(
    ThemeData theme,
    String text,
    TextStyle? baseStyle,
  ) {
    return _inlineParser
        .parse(text)
        .map(
          (node) => TextSpan(
            text: node.text,
            style: baseStyle?.copyWith(
              fontWeight: node.isBold ? FontWeight.w700 : baseStyle.fontWeight,
              fontStyle: node.isItalic || node.isInlineMath
                  ? FontStyle.italic
                  : baseStyle.fontStyle,
              decoration: node.isStrikethrough
                  ? TextDecoration.lineThrough
                  : baseStyle.decoration,
              color: node.linkUrl != null
                  ? theme.colorScheme.primary
                  : baseStyle.color,
              fontFamily: node.isInlineCode || node.isInlineMath
                  ? 'monospace'
                  : baseStyle.fontFamily,
              backgroundColor: node.isInlineCode
                  ? theme.colorScheme.surfaceContainerHighest
                  : node.isInlineMath
                  ? theme.colorScheme.surfaceContainerLow
                  : baseStyle.backgroundColor,
            ),
          ),
        )
        .toList();
  }
}
