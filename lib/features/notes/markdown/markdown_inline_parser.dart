import 'package:flutter/material.dart';

class MarkdownInlineParser {
  const MarkdownInlineParser();

  List<InlineSpan> parse(String text, TextStyle? baseStyle, Color linkColor) {
    final spans = <InlineSpan>[];
    var index = 0;
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
        buffer.clear();
      }
    }

    while (index < text.length) {
      if (text.startsWith('**', index)) {
        final end = text.indexOf('**', index + 2);
        if (end != -1) {
          flush();
          spans.add(
            TextSpan(
              text: text.substring(index + 2, end),
              style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
          index = end + 2;
          continue;
        }
      }

      if (text.startsWith('~~', index)) {
        final end = text.indexOf('~~', index + 2);
        if (end != -1) {
          flush();
          spans.add(
            TextSpan(
              text: text.substring(index + 2, end),
              style: baseStyle?.copyWith(
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
          index = end + 2;
          continue;
        }
      }

      if (text[index] == '_') {
        final end = text.indexOf('_', index + 1);
        if (end != -1) {
          flush();
          spans.add(
            TextSpan(
              text: text.substring(index + 1, end),
              style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
            ),
          );
          index = end + 1;
          continue;
        }
      }

      if (text[index] == '`') {
        final end = text.indexOf('`', index + 1);
        if (end != -1) {
          flush();
          spans.add(
            TextSpan(
              text: text.substring(index + 1, end),
              style: baseStyle?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          );
          index = end + 1;
          continue;
        }
      }

      if (text[index] == '[') {
        final closeBracket = text.indexOf(']', index + 1);
        final openParen = closeBracket == -1
            ? -1
            : text.indexOf('(', closeBracket);
        final closeParen = openParen == -1 ? -1 : text.indexOf(')', openParen);
        if (closeBracket != -1 &&
            openParen == closeBracket + 1 &&
            closeParen != -1) {
          flush();
          spans.add(
            TextSpan(
              text: text.substring(index + 1, closeBracket),
              style: baseStyle?.copyWith(
                color: linkColor,
                decoration: TextDecoration.underline,
              ),
            ),
          );
          index = closeParen + 1;
          continue;
        }
      }

      buffer.write(text[index]);
      index++;
    }

    flush();
    return spans;
  }
}
