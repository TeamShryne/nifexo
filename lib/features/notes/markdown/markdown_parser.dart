import 'markdown_block.dart';

class MarkdownParser {
  const MarkdownParser();

  List<MarkdownBlock> parse(String source) {
    if (source.trim().isEmpty) {
      return const [];
    }

    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final blocks = <MarkdownBlock>[];
    var index = 0;

    while (index < lines.length) {
      final line = lines[index];
      final trimmed = line.trimRight();

      if (trimmed.trim().isEmpty) {
        index++;
        continue;
      }

      if (trimmed.trim() == '---') {
        blocks.add(const MarkdownBlock(type: MarkdownBlockType.divider));
        index++;
        continue;
      }

      if (trimmed.startsWith('```')) {
        final buffer = <String>[];
        index++;
        while (index < lines.length && !lines[index].startsWith('```')) {
          buffer.add(lines[index]);
          index++;
        }
        if (index < lines.length) {
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.codeBlock,
            text: buffer.join('\n'),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('# ')) {
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.heading1,
            text: trimmed.substring(2).trim(),
          ),
        );
        index++;
        continue;
      }

      if (trimmed.startsWith('## ')) {
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.heading2,
            text: trimmed.substring(3).trim(),
          ),
        );
        index++;
        continue;
      }

      if (trimmed.startsWith('### ')) {
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.heading3,
            text: trimmed.substring(4).trim(),
          ),
        );
        index++;
        continue;
      }

      if (trimmed.startsWith('> ')) {
        final buffer = <String>[];
        while (index < lines.length &&
            lines[index].trimLeft().startsWith('> ')) {
          buffer.add(lines[index].trimLeft().substring(2));
          index++;
        }
        blocks.add(
          MarkdownBlock(type: MarkdownBlockType.quote, text: buffer.join('\n')),
        );
        continue;
      }

      if (_isChecklistLine(trimmed)) {
        final items = <String>[];
        final checked = <bool>[];
        while (index < lines.length &&
            _isChecklistLine(lines[index].trimLeft())) {
          final current = lines[index].trimLeft();
          checked.add(
            current.startsWith('- [x] ') || current.startsWith('- [X] '),
          );
          items.add(current.substring(6).trim());
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.checklist,
            items: items,
            checkedItems: checked,
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ')) {
        final items = <String>[];
        while (index < lines.length &&
            lines[index].trimLeft().startsWith('- ')) {
          items.add(lines[index].trimLeft().substring(2).trim());
          index++;
        }
        blocks.add(
          MarkdownBlock(type: MarkdownBlockType.bulletList, items: items),
        );
        continue;
      }

      if (_isNumberedListLine(trimmed)) {
        final items = <String>[];
        while (index < lines.length &&
            _isNumberedListLine(lines[index].trimLeft())) {
          final current = lines[index].trimLeft();
          final dotIndex = current.indexOf('.');
          items.add(current.substring(dotIndex + 1).trim());
          index++;
        }
        blocks.add(
          MarkdownBlock(type: MarkdownBlockType.numberedList, items: items),
        );
        continue;
      }

      final paragraphLines = <String>[];
      while (index < lines.length && !_startsNewBlock(lines[index])) {
        final current = lines[index].trimRight();
        if (current.trim().isNotEmpty) {
          paragraphLines.add(current);
        }
        index++;
      }
      blocks.add(
        MarkdownBlock(
          type: MarkdownBlockType.paragraph,
          text: paragraphLines.join('\n'),
        ),
      );
    }

    return blocks;
  }

  bool _startsNewBlock(String line) {
    final trimmed = line.trimLeft();
    return trimmed.isEmpty ||
        trimmed == '---' ||
        trimmed.startsWith('```') ||
        trimmed.startsWith('# ') ||
        trimmed.startsWith('## ') ||
        trimmed.startsWith('### ') ||
        trimmed.startsWith('> ') ||
        trimmed.startsWith('- ') ||
        _isChecklistLine(trimmed) ||
        _isNumberedListLine(trimmed);
  }

  bool _isChecklistLine(String line) {
    return line.startsWith('- [ ] ') ||
        line.startsWith('- [x] ') ||
        line.startsWith('- [X] ');
  }

  bool _isNumberedListLine(String line) {
    final dotIndex = line.indexOf('.');
    if (dotIndex <= 0) return false;
    final prefix = line.substring(0, dotIndex);
    if (int.tryParse(prefix) == null) return false;
    return dotIndex + 1 < line.length && line[dotIndex + 1] == ' ';
  }
}
