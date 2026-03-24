import 'package:flutter/material.dart';

import '../../../core/models/note.dart';
import '../markdown/markdown_editing_controller.dart';
import '../markdown/markdown_editor_controller.dart';
import '../markdown/markdown_editor_toolbar.dart';
import '../markdown/markdown_render_view.dart';
import '../markdown/markdown_shortcut.dart';
import '../markdown/markdown_shortcuts.dart';

import '../../../core/services/backup_service.dart';

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
  final Future<void> Function(NoteDraft) onCreate;
  final Future<void> Function(String noteId, NoteDraft draft) onUpdate;
  final Future<void> Function(String noteId) onDelete;
  final Future<void> Function(String noteId) onTogglePinned;

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
                await onCreate(draft);
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
                        await onUpdate(note.id, draft);
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
                                onPressed: () async => await onTogglePinned(note.id),
                                icon: Icon(
                                  note.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                onPressed: () async => await onDelete(note.id),
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

  bool get _hasUnsavedChanges {
    final initial = widget.initial;
    if (initial == null) {
      return _titleController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty ||
          _tags.isNotEmpty;
    }

    if (_titleController.text != initial.title) return true;
    if (_contentController.text != initial.contentMd) return true;
    if (_tags.length != initial.tags.length) return true;
    for (var i = 0; i < _tags.length; i++) {
      if (_tags[i] != initial.tags[i]) return true;
    }
    return false;
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_hasUnsavedChanges) return true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved edits in this note. Discard them and go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _confirmDiscardIfNeeded();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () async {
                final shouldPop = await _confirmDiscardIfNeeded();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
            ),
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
        onExport: widget.initial == null ? null : () {
          BackupService().exportNoteAsMarkdown(widget.initial!);
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
    final text = contentController.text;
    final words = RegExp(r'\S+').allMatches(text).length;
    final characters = text.characters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('note_title_field'),
                controller: titleController,
                textInputAction: TextInputAction.next,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  hintText: 'Untitled',
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
              const SizedBox(height: 12),
              MarkdownEditorToolbar(
                shortcuts: markdownShortcuts,
                onShortcutSelected: onShortcutSelected,
                isPreviewing: isPreviewing,
                onPreviewToggled: onPreviewChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isPreviewing
                ? MarkdownRenderView(
                    key: const ValueKey('note_preview_view'),
                    data: contentController.text,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  )
                : Padding(
                    key: const ValueKey('note_editor_view'),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                            'Write markdown: #, ##, ###, *, -, 1., [link](url), >, **bold**, *italic*, `code`, ~~strike~~',
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
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
            color: theme.colorScheme.surfaceContainerLow,
          ),
          child: Row(
            children: [
              Text(
                '$words words',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 14),
              Text(
                '$characters chars',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                isPreviewing ? 'Preview mode' : 'Edit mode',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
    this.onExport,
  });

  final String title;
  final String content;
  final List<String> tags;
  final DateTime? updatedAt;
  final VoidCallback onEdit;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = content.trim().isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          titleSpacing: 20,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          centerTitle: false,
          actions: [
            if (onExport != null)
              IconButton(
                onPressed: onExport,
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Export as Markdown',
              ),
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
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (updatedAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Updated ${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}',
                        style: theme.textTheme.bodySmall,
                      ),
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
        if (!hasContent)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No content yet. Tap Edit to start writing.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
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
