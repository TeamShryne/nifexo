import 'package:flutter/material.dart';

import '../../../core/models/note.dart';
import '../markdown/markdown_editing_controller.dart';
import '../markdown/markdown_editor_controller.dart';
import '../markdown/markdown_editor_toolbar.dart';
import '../markdown/markdown_render_view.dart';
import '../markdown/markdown_shortcut.dart';
import '../markdown/markdown_shortcuts.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({
    super.key,
    required this.notes,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.onTogglePinned,
  });

  final List<Note> notes;
  final ValueChanged<NoteDraft> onCreate;
  final void Function(String noteId, NoteDraft draft) onUpdate;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onTogglePinned;

  @override
  Widget build(BuildContext context) {
    final activeNotes = notes.where((note) => !note.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () async {
              final draft = await openNoteEditorPage(
                context,
                startInEditMode: true,
              );
              if (draft != null) {
                onCreate(draft);
              }
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: activeNotes.isEmpty
          ? const _EmptyNotesState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              itemBuilder: (context, index) {
                final note = activeNotes[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      final draft = await openNoteEditorPage(
                        context,
                        initial: note,
                      );
                      if (draft != null) {
                        onUpdate(note.id, draft);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  note.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onTogglePinned(note.id),
                                icon: Icon(
                                  note.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onDelete(note.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            note.contentMd.trim().isEmpty
                                ? 'No content yet'
                                : note.contentMd.trim(),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: note.tags.isEmpty
                                ? [const Chip(label: Text('untagged'))]
                                : note.tags
                                      .map((tag) => Chip(label: Text(tag)))
                                      .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: activeNotes.length,
            ),
    );
  }
}

class NoteDraft {
  const NoteDraft({
    required this.title,
    required this.content,
    required this.tags,
  });

  final String title;
  final String content;
  final List<String> tags;
}

Future<NoteDraft?> openNoteEditorPage(
  BuildContext context, {
  Note? initial,
  bool startInEditMode = false,
}) {
  return Navigator.of(context).push<NoteDraft>(
    MaterialPageRoute(
      builder: (_) =>
          NoteEditorPage(initial: initial, startInEditMode: startInEditMode),
    ),
  );
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.initial, this.startInEditMode = false});

  final Note? initial;
  final bool startInEditMode;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  static const _markdownTools = MarkdownShortcuts.primary;

  final _markdownEditorController = const MarkdownEditorController();

  late final TextEditingController _titleController;
  late final MarkdownEditingController _contentController;
  late bool _isEditing;
  late List<String> _tags;
  bool _isPreviewing = false;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initial?.title ?? '');
    _contentController = MarkdownEditingController(
      text: widget.initial?.contentMd ?? '',
    );
    _tags = List.of(widget.initial?.tags ?? const []);
    _isEditing = widget.startInEditMode || _isNew;
    _titleController.addListener(_handleEditorChanged);
    _contentController.addListener(_handleEditorChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleEditorChanged);
    _contentController.removeListener(_handleEditorChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleEditorChanged() {
    setState(() {});
  }

  void _save() {
    Navigator.of(context).pop(
      NoteDraft(
        title: _titleController.text,
        content: _contentController.text,
        tags: _tags,
      ),
    );
  }

  void _applyShortcut(MarkdownShortcutType type) {
    setState(() {
      _markdownEditorController.applyShortcut(_contentController, type);
      _isPreviewing = false;
    });
  }

  Future<void> _openTagsModal() async {
    final tags = await showNoteTagsEditor(context, initialTags: _tags);
    if (tags != null) {
      setState(() {
        _tags = tags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _titleController.text.trim().isEmpty
        ? 'Untitled note'
        : _titleController.text.trim();
    final contentText = _contentController.text.trim();

    if (_isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New Note' : 'Edit Note'),
          actions: [
            IconButton(
              onPressed: _openTagsModal,
              icon: const Icon(Icons.sell_outlined),
              tooltip: 'Tags',
            ),
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
        body: SafeArea(
          child: _NoteEditView(
            key: const ValueKey('edit'),
            titleController: _titleController,
            contentController: _contentController,
            tags: _tags,
            isPreviewing: _isPreviewing,
            onPreviewChanged: (isPreviewing) {
              setState(() {
                _isPreviewing = isPreviewing;
              });
            },
            markdownShortcuts: _markdownTools,
            onShortcutSelected: _applyShortcut,
          ),
        ),
      );
    }

    return Scaffold(
      body: _NoteReadView(
        key: const ValueKey('read'),
        title: titleText,
        content: contentText,
        tags: _tags,
        updatedAt: widget.initial?.updatedAt,
        onEdit: () {
          setState(() {
            _isEditing = true;
          });
        },
      ),
    );
  }
}

class _NoteEditView extends StatelessWidget {
  const _NoteEditView({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.tags,
    required this.isPreviewing,
    required this.onPreviewChanged,
    required this.markdownShortcuts,
    required this.onShortcutSelected,
  });

  final TextEditingController titleController;
  final MarkdownEditingController contentController;
  final List<String> tags;
  final bool isPreviewing;
  final ValueChanged<bool> onPreviewChanged;
  final List<MarkdownShortcut> markdownShortcuts;
  final ValueChanged<MarkdownShortcutType> onShortcutSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: TextField(
            key: const ValueKey('note_title_field'),
            controller: titleController,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              hintText: 'Untitled',
              border: InputBorder.none,
              filled: false,
            ),
          ),
        ),
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: MarkdownEditorToolbar(
            shortcuts: markdownShortcuts,
            onShortcutSelected: onShortcutSelected,
            isPreviewing: isPreviewing,
            onPreviewToggled: onPreviewChanged,
          ),
        ),
        Expanded(
          child: isPreviewing
              ? MarkdownRenderView(
                  key: const ValueKey('note_preview_view'),
                  data: contentController.text,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: TextField(
                    key: const ValueKey('note_content_field'),
                    controller: contentController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      fontSize: 17,
                    ),
                    cursorWidth: 2,
                    decoration: InputDecoration(
                      hintText:
                          'Use markdown shortcuts while typing: #, ##, ###, -, 1., [], >, **, _, `, ~~',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _NoteReadView extends StatelessWidget {
  const _NoteReadView({
    super.key,
    required this.title,
    required this.content,
    required this.tags,
    required this.updatedAt,
    required this.onEdit,
  });

  final String title;
  final String content;
  final List<String> tags;
  final DateTime? updatedAt;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          titleSpacing: 20,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
          ],
        ),
        if (updatedAt != null || tags.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (updatedAt != null)
                    Text(
                      'Updated ${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}',
                      style: theme.textTheme.bodySmall,
                    ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        MarkdownRenderSliver(data: content),
      ],
    );
  }
}

Future<List<String>?> showNoteTagsEditor(
  BuildContext context, {
  required List<String> initialTags,
}) {
  final controller = TextEditingController(text: initialTags.join(', '));

  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit tags', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('note_tags_modal_field'),
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'work, ideas, meeting',
                labelText: 'Tags',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_parseTags(controller.text));
                },
                child: const Text('Apply tags'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

List<String> _parseTags(String input) {
  return input
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();
}

class _EmptyNotesState extends StatelessWidget {
  const _EmptyNotesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No notes yet. Tap the add button to create your first markdown note.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
