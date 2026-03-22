import 'package:flutter/material.dart';

import 'markdown_block.dart';
import 'markdown_inline_parser.dart';
import 'markdown_parser.dart';

class MarkdownRenderView extends StatelessWidget {
  const MarkdownRenderView({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 32),
  });

  final String data;
  final EdgeInsets padding;

  static const _parser = MarkdownParser();
  static const _inlineParser = MarkdownInlineParser();

  @override
  Widget build(BuildContext context) {
    final blocks = _parser.parse(data);
    final theme = Theme.of(context);

    if (blocks.isEmpty) {
      return ListView(
        padding: padding,
        children: [
          Text(
            'This note is empty.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: padding,
      itemBuilder: (context, index) =>
          _MarkdownBlockView(block: blocks[index], inlineParser: _inlineParser),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: blocks.length,
    );
  }
}

class _MarkdownBlockView extends StatelessWidget {
  const _MarkdownBlockView({required this.block, required this.inlineParser});

  final MarkdownBlock block;
  final MarkdownInlineParser inlineParser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkColor = theme.colorScheme.primary;

    switch (block.type) {
      case MarkdownBlockType.heading1:
        return _inlineRichText(
          context,
          block.text,
          theme.textTheme.headlineMedium,
          linkColor,
        );
      case MarkdownBlockType.heading2:
        return _inlineRichText(
          context,
          block.text,
          theme.textTheme.headlineSmall,
          linkColor,
        );
      case MarkdownBlockType.heading3:
        return _inlineRichText(
          context,
          block.text,
          theme.textTheme.titleLarge,
          linkColor,
        );
      case MarkdownBlockType.paragraph:
        return _multilineRichText(
          context,
          block.text,
          theme.textTheme.bodyLarge?.copyWith(height: 1.65),
          linkColor,
        );
      case MarkdownBlockType.bulletList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in block.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 9, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _inlineRichText(
                        context,
                        item,
                        theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        linkColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case MarkdownBlockType.numberedList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < block.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _inlineRichText(
                        context,
                        block.items[i],
                        theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        linkColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case MarkdownBlockType.checklist:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < block.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      block.checkedItems[i]
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color: block.checkedItems[i]
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _inlineRichText(
                        context,
                        block.items[i],
                        theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          decoration: block.checkedItems[i]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        linkColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case MarkdownBlockType.quote:
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
          ),
          child: _multilineRichText(
            context,
            block.text,
            theme.textTheme.bodyLarge?.copyWith(
              height: 1.65,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            linkColor,
          ),
        );
      case MarkdownBlockType.codeBlock:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SelectableText(
            block.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              height: 1.55,
            ),
          ),
        );
      case MarkdownBlockType.divider:
        return Divider(color: theme.colorScheme.outlineVariant, height: 24);
    }
  }

  Widget _inlineRichText(
    BuildContext context,
    String text,
    TextStyle? style,
    Color linkColor,
  ) {
    return SelectableText.rich(
      TextSpan(children: inlineParser.parse(text, style, linkColor)),
    );
  }

  Widget _multilineRichText(
    BuildContext context,
    String text,
    TextStyle? style,
    Color linkColor,
  ) {
    final lines = text.split('\n');
    final children = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      children.addAll(inlineParser.parse(lines[i], style, linkColor));
      if (i != lines.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }
    return SelectableText.rich(TextSpan(children: children));
  }
}
