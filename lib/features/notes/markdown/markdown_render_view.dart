import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'markdown_block.dart';
import 'markdown_inline_parser.dart';
import 'markdown_parser.dart';

class MarkdownRenderView extends StatefulWidget {
  const MarkdownRenderView({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 32),
    this.physics,
    this.shrinkWrap = false,
  });

  final String data;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  State<MarkdownRenderView> createState() => _MarkdownRenderViewState();
}

class _MarkdownRenderViewState extends State<MarkdownRenderView> {
  static const _parser = MarkdownParser();
  static const _inlineParser = MarkdownInlineParser();

  late List<MarkdownBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = _parser.parse(widget.data);
  }

  @override
  void didUpdateWidget(covariant MarkdownRenderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _blocks = _parser.parse(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_blocks.isEmpty) {
      return ListView(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
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
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemBuilder: (context, index) => _MarkdownBlockView(
        block: _blocks[index],
        inlineParser: _inlineParser,
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _blocks.length,
    );
  }
}

class MarkdownRenderSliver extends StatefulWidget {
  const MarkdownRenderSliver({super.key, required this.data});

  final String data;

  @override
  State<MarkdownRenderSliver> createState() => _MarkdownRenderSliverState();
}

class _MarkdownRenderSliverState extends State<MarkdownRenderSliver> {
  static const _parser = MarkdownParser();
  static const _inlineParser = MarkdownInlineParser();

  late List<MarkdownBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = _parser.parse(widget.data);
  }

  @override
  void didUpdateWidget(covariant MarkdownRenderSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _blocks = _parser.parse(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_blocks.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Text(
            'This note is empty.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      sliver: SliverList.separated(
        itemBuilder: (context, index) => _MarkdownBlockView(
          block: _blocks[index],
          inlineParser: _inlineParser,
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _blocks.length,
      ),
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

    switch (block.type) {
      case MarkdownBlockType.heading1:
        return _richLine(context, block.text, theme.textTheme.headlineMedium);
      case MarkdownBlockType.heading2:
        return _richLine(context, block.text, theme.textTheme.headlineSmall);
      case MarkdownBlockType.heading3:
        return _richLine(context, block.text, theme.textTheme.titleLarge);
      case MarkdownBlockType.paragraph:
        return _richMultiline(
          context,
          block.text,
          theme.textTheme.bodyLarge?.copyWith(height: 1.7),
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
                      padding: const EdgeInsets.only(top: 8, right: 12),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 1.6,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _richLine(
                        context,
                        item,
                        theme.textTheme.bodyLarge?.copyWith(height: 1.7),
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
                      child: _richLine(
                        context,
                        block.items[i],
                        theme.textTheme.bodyLarge?.copyWith(height: 1.7),
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
                      child: _richLine(
                        context,
                        block.items[i],
                        theme.textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          decoration: block.checkedItems[i]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
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
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
          ),
          child: _richMultiline(
            context,
            block.text,
            theme.textTheme.bodyLarge?.copyWith(
              height: 1.7,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      case MarkdownBlockType.codeBlock:
        return _CodeBlockCard(text: block.text, meta: block.meta);
      case MarkdownBlockType.mathBlock:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            block.text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case MarkdownBlockType.table:
        return _MarkdownTable(
          headers: block.tableHeaders,
          rows: block.tableRows,
        );
      case MarkdownBlockType.divider:
        return Divider(color: theme.colorScheme.outlineVariant, height: 24);
    }
  }

  Widget _richLine(BuildContext context, String text, TextStyle? baseStyle) {
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: _buildSpans(context, baseStyle, text),
      ),
    );
  }

  Widget _richMultiline(
    BuildContext context,
    String text,
    TextStyle? baseStyle,
  ) {
    final lines = text.split('\n');
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      spans.addAll(_buildSpans(context, baseStyle, lines[i]));
      if (i != lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }

  List<InlineSpan> _buildSpans(
    BuildContext context,
    TextStyle? baseStyle,
    String text,
  ) {
    final theme = Theme.of(context);
    final nodes = inlineParser.parse(text);
    return nodes
        .map(
          (node) => TextSpan(
            text: node.text,
            style: _nodeStyle(theme, baseStyle, node),
            recognizer: node.linkUrl == null
                ? null
                : (TapGestureRecognizer()
                    ..onTap = () async {
                      final uri = Uri.tryParse(node.linkUrl!);
                      if (uri != null) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }),
          ),
        )
        .toList();
  }

  TextStyle? _nodeStyle(
    ThemeData theme,
    TextStyle? baseStyle,
    MarkdownInlineNode node,
  ) {
    return baseStyle?.copyWith(
      fontWeight: node.isBold ? FontWeight.w700 : baseStyle.fontWeight,
      fontStyle: node.isItalic || node.isInlineMath
          ? FontStyle.italic
          : baseStyle.fontStyle,
      decoration: node.isStrikethrough || node.linkUrl != null
          ? (node.isStrikethrough
                ? TextDecoration.lineThrough
                : TextDecoration.underline)
          : baseStyle.decoration,
      color: node.linkUrl != null ? theme.colorScheme.primary : baseStyle.color,
      fontFamily: node.isInlineCode || node.isInlineMath
          ? 'monospace'
          : baseStyle.fontFamily,
      backgroundColor: node.isInlineCode
          ? theme.colorScheme.surfaceContainerHighest
          : node.isInlineMath
          ? theme.colorScheme.surfaceContainerLow
          : baseStyle.backgroundColor,
    );
  }
}

class _CodeBlockCard extends StatelessWidget {
  const _CodeBlockCard({required this.text, required this.meta});

  final String text;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = meta.trim().isEmpty ? 'Code' : meta.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CopyCodeButton(text: text),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyCodeButton extends StatefulWidget {
  const _CopyCodeButton({required this.text});

  final String text;

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() {
      _copied = true;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _copied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copy,
      icon: Icon(_copied ? Icons.check : Icons.copy_all_outlined, size: 16),
      label: Text(_copied ? 'Copied' : 'Copy'),
    );
  }
}

class _MarkdownTable extends StatelessWidget {
  const _MarkdownTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: DataTable(
            columnSpacing: 28,
            horizontalMargin: 16,
            border: TableBorder(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              left: BorderSide(color: theme.colorScheme.outlineVariant),
              right: BorderSide(color: theme.colorScheme.outlineVariant),
              horizontalInside: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
              verticalInside: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest,
            ),
            dataRowColor: WidgetStatePropertyAll(theme.colorScheme.surface),
            headingTextStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            dataRowMinHeight: 52,
            dataRowMaxHeight: 80,
            columns: headers
                .map((header) => DataColumn(label: Text(header)))
                .toList(),
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: List.generate(
                      headers.length,
                      (index) => DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(
                            index < row.length ? row[index] : '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
