class MarkdownInlineNode {
  const MarkdownInlineNode({
    required this.text,
    this.isBold = false,
    this.isItalic = false,
    this.isStrikethrough = false,
    this.isInlineCode = false,
    this.isInlineMath = false,
    this.linkUrl,
  });

  final String text;
  final bool isBold;
  final bool isItalic;
  final bool isStrikethrough;
  final bool isInlineCode;
  final bool isInlineMath;
  final String? linkUrl;
}

class MarkdownInlineParser {
  const MarkdownInlineParser();

  List<MarkdownInlineNode> parse(String text) {
    final nodes = <MarkdownInlineNode>[];
    var index = 0;
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        nodes.add(MarkdownInlineNode(text: buffer.toString()));
        buffer.clear();
      }
    }

    while (index < text.length) {
      if (text.startsWith('***', index)) {
        final end = text.indexOf('***', index + 3);
        if (end != -1) {
          flush();
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 3, end),
              isBold: true,
              isItalic: true,
            ),
          );
          index = end + 3;
          continue;
        }
      }

      if (text.startsWith('**', index)) {
        final end = text.indexOf('**', index + 2);
        if (end != -1) {
          flush();
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 2, end),
              isBold: true,
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
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 2, end),
              isStrikethrough: true,
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
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 1, end),
              isItalic: true,
            ),
          );
          index = end + 1;
          continue;
        }
      }

      if (text[index] == '*') {
        final isDoubleAsterisk =
            index + 1 < text.length && text[index + 1] == '*';
        final nextIsWhitespace =
            index + 1 < text.length && text[index + 1].trim().isEmpty;
        if (isDoubleAsterisk) {
          buffer.write(text[index]);
          index++;
          continue;
        }
        if (nextIsWhitespace) {
          buffer.write(text[index]);
          index++;
          continue;
        }
        final end = text.indexOf('*', index + 1);
        if (end != -1 && end > index + 1) {
          flush();
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 1, end),
              isItalic: true,
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
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 1, end),
              isInlineCode: true,
            ),
          );
          index = end + 1;
          continue;
        }
      }

      if (text[index] == r'$') {
        final end = text.indexOf(r'$', index + 1);
        if (end != -1) {
          flush();
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 1, end),
              isInlineMath: true,
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
          nodes.add(
            MarkdownInlineNode(
              text: text.substring(index + 1, closeBracket),
              linkUrl: text.substring(openParen + 1, closeParen),
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
    return nodes;
  }
}
