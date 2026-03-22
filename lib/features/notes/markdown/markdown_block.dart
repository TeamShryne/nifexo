enum MarkdownBlockType {
  heading1,
  heading2,
  heading3,
  paragraph,
  bulletList,
  numberedList,
  checklist,
  quote,
  codeBlock,
  divider,
}

class MarkdownBlock {
  const MarkdownBlock({
    required this.type,
    this.text = '',
    this.items = const [],
    this.checkedItems = const [],
  });

  final MarkdownBlockType type;
  final String text;
  final List<String> items;
  final List<bool> checkedItems;
}
