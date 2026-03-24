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
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        index++;
        continue;
      }

      if (trimmed == '---') {
        blocks.add(const MarkdownBlock(type: MarkdownBlockType.divider));
        index++;
        continue;
      }

      if (trimmed == r'$$') {
        final buffer = <String>[];
        index++;
        while (index < lines.length && lines[index].trim() != r'$$') {
          buffer.add(lines[index]);
          index++;
        }
        if (index < lines.length) {
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.mathBlock,
            text: buffer.join('\n').trim(),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('```')) {
        final meta = trimmed.substring(3).trim();
        final buffer = <String>[];
        index++;
        while (index < lines.length && !lines[index].trim().startsWith('```')) {
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
            meta: meta,
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
            lines[index].trim().startsWith('> ')) {
          buffer.add(lines[index].trim().substring(2));
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
        final indents = <int>[];
        while (index < lines.length &&
            _isChecklistLine(lines[index].trimLeft())) {
          final current = lines[index].trimLeft();
          final indentation = lines[index].length - lines[index].trimLeft().length;
          final markerLength = _checklistMarkerLength(current);
          checked.add(
            current.contains('[x] ') || current.contains('[X] '),
          );
          items.add(current.substring(markerLength).trim());
          indents.add(indentation);
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.checklist,
            items: items,
            checkedItems: checked,
            indentations: indents,
          ),
        );
        continue;
      }

      if (_isUnorderedListLine(trimmed)) {
        final items = <String>[];
        final indents = <int>[];
        while (index < lines.length &&
            _isUnorderedListLine(lines[index].trimLeft())) {
          final indentation = lines[index].length - lines[index].trimLeft().length;
          items.add(lines[index].trimLeft().substring(2).trim());
          indents.add(indentation);
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.bulletList,
            items: items,
            indentations: indents,
          ),
        );
        continue;
      }

      if (_isNumberedListLine(trimmed)) {
        final items = <String>[];
        final indents = <int>[];
        while (index < lines.length &&
            _isNumberedListLine(lines[index].trimLeft())) {
          final current = lines[index].trimLeft();
          final indentation = lines[index].length - lines[index].trimLeft().length;
          final dotIndex = current.indexOf('.');
          items.add(current.substring(dotIndex + 1).trim());
          indents.add(indentation);
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.numberedList,
            items: items,
            indentations: indents,
          ),
        );
        continue;
      }

      if (_isTableHeader(trimmed, index, lines)) {
        final headers = _parseTableCells(trimmed);
        final rows = <List<String>>[];
        index += 2;
        while (index < lines.length && _isTableRow(lines[index])) {
          rows.add(_parseTableCells(lines[index].trimRight()));
          index++;
        }
        blocks.add(
          MarkdownBlock(
            type: MarkdownBlockType.table,
            tableHeaders: headers,
            tableRows: rows,
          ),
        );
        continue;
      }

      final paragraphLines = <String>[];
      // Always consume at least one line if we've reached this point, 
      // even if _startsNewBlock would return true. This prevents infinite loops 
      // when a line looks like a block but isn't handled by any of the specific 
      // block type handlers above.
      paragraphLines.add(lines[index].trimRight());
      index++;

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
    final trimmed = line.trim();
    return trimmed.isEmpty ||
        trimmed == '---' ||
        trimmed.startsWith('```') ||
        trimmed == r'$$' ||
        trimmed.startsWith('# ') ||
        trimmed.startsWith('## ') ||
        trimmed.startsWith('### ') ||
        trimmed.startsWith('> ') ||
        _isUnorderedListLine(trimmed) ||
        _isTableHeader(trimmed, 0, [trimmed, '']) ||
        _isChecklistLine(trimmed) ||
        _isNumberedListLine(trimmed);
  }

  bool _isChecklistLine(String line) {
    return line.startsWith('- [ ] ') ||
        line.startsWith('- [x] ') ||
        line.startsWith('- [X] ') ||
        line.startsWith('* [ ] ') ||
        line.startsWith('* [x] ') ||
        line.startsWith('* [X] ') ||
        line.startsWith('+ [ ] ') ||
        line.startsWith('+ [x] ') ||
        line.startsWith('+ [X] ');
  }

  int _checklistMarkerLength(String line) {
    // Supported forms are "<list-marker> [ ] ", "<list-marker> [x] ", "<list-marker> [X] ".
    return 6;
  }

  bool _isUnorderedListLine(String line) {
    return line.startsWith('- ') || line.startsWith('* ') || line.startsWith('+ ');
  }

  bool _isNumberedListLine(String line) {
    final dotIndex = line.indexOf('.');
    if (dotIndex <= 0) return false;
    final prefix = line.substring(0, dotIndex);
    if (int.tryParse(prefix) == null) return false;
    return dotIndex + 1 < line.length && line[dotIndex + 1] == ' ';
  }

  bool _isTableHeader(String line, int index, List<String> lines) {
    if (index + 1 >= lines.length) return false;
    return _isTableRow(line) && _isTableDivider(lines[index + 1].trim());
  }

  bool _isTableRow(String line) {
    final trimmed = line.trim();
    final firstPipe = trimmed.indexOf('|');
    final secondPipe = trimmed.indexOf('|', firstPipe + 1);
    return trimmed.startsWith('|') &&
        trimmed.endsWith('|') &&
        secondPipe != -1;
  }

  bool _isTableDivider(String line) {
    final trimmed = line.trim();
    if (!_isTableRow(trimmed)) return false;
    final cells = _parseTableCells(trimmed);
    return cells.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
  }

  List<String> _parseTableCells(String line) {
    final trimmed = line.trim();
    return trimmed
        .substring(1, trimmed.length - 1)
        .split('|')
        .map((cell) => cell.trim())
        .toList();
  }
}
