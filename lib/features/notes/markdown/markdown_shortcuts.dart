import 'package:flutter/material.dart';

import 'markdown_shortcut.dart';

class MarkdownShortcuts {
  static const primary = <MarkdownShortcut>[
    MarkdownShortcut(
      type: MarkdownShortcutType.headingOne,
      label: 'H1',
      icon: Icons.title,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.headingTwo,
      label: 'H2',
      icon: Icons.format_size,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.headingThree,
      label: 'H3',
      icon: Icons.text_fields,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.bold,
      label: 'Bold',
      icon: Icons.format_bold,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.italic,
      label: 'Italic',
      icon: Icons.format_italic,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.strikethrough,
      label: 'Strike',
      icon: Icons.format_strikethrough,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.quote,
      label: 'Quote',
      icon: Icons.format_quote,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.bulletList,
      label: 'Bullets',
      icon: Icons.format_list_bulleted,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.numberedList,
      label: 'Numbered',
      icon: Icons.format_list_numbered,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.checklist,
      label: 'Checklist',
      icon: Icons.checklist,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.inlineCode,
      label: 'Code',
      icon: Icons.code,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.codeBlock,
      label: 'Block',
      icon: Icons.data_object,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.math,
      label: 'Math',
      icon: Icons.functions,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.link,
      label: 'Link',
      icon: Icons.link,
    ),
    MarkdownShortcut(
      type: MarkdownShortcutType.divider,
      label: 'Rule',
      icon: Icons.horizontal_rule,
    ),
  ];
}
