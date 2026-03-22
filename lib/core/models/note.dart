class Note {
  const Note({
    required this.id,
    required this.title,
    required this.contentMd,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String contentMd;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isArchived;

  Note copyWith({
    String? id,
    String? title,
    String? contentMd,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isArchived,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentMd: contentMd ?? this.contentMd,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
