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
  mathBlock,
  table,
  divider,
}

class MarkdownBlock {
  const MarkdownBlock({
    required this.type,
    this.text = '',
    this.items = const [],
    this.indentations = const [],
    this.checkedItems = const [],
    this.meta = '',
    this.tableHeaders = const [],
    this.tableRows = const [],
  });

  final MarkdownBlockType type;
  final String text;
  final List<String> items;
  final List<int> indentations;
  final List<bool> checkedItems;
  final String meta;
  final List<String> tableHeaders;
  final List<List<String>> tableRows;
}
