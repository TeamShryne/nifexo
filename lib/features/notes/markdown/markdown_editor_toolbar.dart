import 'package:flutter/material.dart';

import 'markdown_shortcut.dart';

class MarkdownEditorToolbar extends StatelessWidget {
  const MarkdownEditorToolbar({
    super.key,
    required this.shortcuts,
    required this.onShortcutSelected,
    required this.isPreviewing,
    required this.onPreviewToggled,
  });

  final List<MarkdownShortcut> shortcuts;
  final ValueChanged<MarkdownShortcutType> onShortcutSelected;
  final bool isPreviewing;
  final ValueChanged<bool> onPreviewToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Markdown tools',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.edit_note),
                  label: Text('Write'),
                ),
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.preview_outlined),
                  label: Text('Preview'),
                ),
              ],
              selected: {isPreviewing},
              onSelectionChanged: (selection) {
                onPreviewToggled(selection.first);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return OutlinedButton.icon(
                onPressed: () => onShortcutSelected(shortcut.type),
                icon: Icon(shortcut.icon, size: 18),
                label: Text(shortcut.label),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: shortcuts.length,
          ),
        ),
      ],
    );
  }
}
