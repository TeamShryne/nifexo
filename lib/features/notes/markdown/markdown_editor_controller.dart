import 'package:flutter/material.dart';

import 'markdown_shortcut.dart';

class MarkdownEditorController {
  const MarkdownEditorController();

  void applyShortcut(
    TextEditingController controller,
    MarkdownShortcutType type,
  ) {
    final value = controller.value;
    final selection = value.selection;
    final start = selection.start < 0 ? value.text.length : selection.start;
    final end = selection.end < 0 ? value.text.length : selection.end;
    final selectedText = value.text.substring(start, end);

    final replacement = switch (type) {
      MarkdownShortcutType.headingOne => _applyLinePrefix(selectedText, '# '),
      MarkdownShortcutType.headingTwo => _applyLinePrefix(selectedText, '## '),
      MarkdownShortcutType.headingThree => _applyLinePrefix(
        selectedText,
        '### ',
      ),
      MarkdownShortcutType.bold => _wrapSelection(
        selectedText,
        '**',
        fallback: 'bold text',
      ),
      MarkdownShortcutType.italic => _wrapSelection(
        selectedText,
        '_',
        fallback: 'italic text',
      ),
      MarkdownShortcutType.strikethrough => _wrapSelection(
        selectedText,
        '~~',
        fallback: 'struck text',
      ),
      MarkdownShortcutType.quote => _applyLinePrefix(selectedText, '> '),
      MarkdownShortcutType.bulletList => _applyLinePrefix(
        selectedText,
        '- ',
        fallback: 'List item',
      ),
      MarkdownShortcutType.numberedList => _applyNumberedList(selectedText),
      MarkdownShortcutType.checklist => _applyLinePrefix(
        selectedText,
        '- [ ] ',
        fallback: 'Checklist item',
      ),
      MarkdownShortcutType.inlineCode => _wrapSelection(
        selectedText,
        '`',
        fallback: 'code',
      ),
      MarkdownShortcutType.codeBlock => _wrapCodeBlock(selectedText),
      MarkdownShortcutType.link => _applyLink(selectedText),
      MarkdownShortcutType.divider => _insertDivider(selectedText),
    };

    controller.value = value.replaced(
      TextRange(start: start, end: end),
      replacement,
    );
  }

  String _applyLinePrefix(
    String selectedText,
    String prefix, {
    String fallback = 'Text',
  }) {
    final base = selectedText.isEmpty ? fallback : selectedText;
    final lines = base.split('\n');
    return lines.map((line) => '$prefix$line').join('\n');
  }

  String _wrapSelection(
    String selectedText,
    String marker, {
    String fallback = 'Text',
  }) {
    final content = selectedText.isEmpty ? fallback : selectedText;
    return '$marker$content$marker';
  }

  String _applyNumberedList(String selectedText) {
    final base = selectedText.isEmpty ? 'List item' : selectedText;
    final lines = base.split('\n');
    return List.generate(
      lines.length,
      (index) => '${index + 1}. ${lines[index]}',
    ).join('\n');
  }

  String _wrapCodeBlock(String selectedText) {
    final content = selectedText.isEmpty ? 'code' : selectedText;
    return '```\n$content\n```';
  }

  String _applyLink(String selectedText) {
    final content = selectedText.isEmpty ? 'link text' : selectedText;
    return '[$content](https://)';
  }

  String _insertDivider(String selectedText) {
    final base = selectedText.trim();
    if (base.isEmpty) {
      return '\n---\n';
    }
    return '$selectedText\n---\n';
  }
}

extension on TextEditingValue {
  TextEditingValue replaced(TextRange range, String replacement) {
    final newText = text.replaceRange(range.start, range.end, replacement);
    final caretOffset = range.start + replacement.length;
    return copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: caretOffset),
      composing: TextRange.empty,
    );
  }
}
