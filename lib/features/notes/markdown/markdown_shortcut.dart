import 'package:flutter/material.dart';

enum MarkdownShortcutType {
  headingOne,
  headingTwo,
  headingThree,
  bold,
  italic,
  strikethrough,
  quote,
  bulletList,
  numberedList,
  checklist,
  inlineCode,
  codeBlock,
  math,
  link,
  divider,
}

class MarkdownShortcut {
  const MarkdownShortcut({
    required this.type,
    required this.label,
    required this.icon,
  });

  final MarkdownShortcutType type;
  final String label;
  final IconData icon;
}
