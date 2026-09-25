class PublicJournal {
  final String uuid;
  final String title;
  final String content;
  final String preview;
  final String authorName;
  final String moodLabel;
  final String moodEmoji;
  final List<String> tags;
  final DateTime createdAt;

  const PublicJournal({
    required this.uuid,
    required this.title,
    required this.content,
    required this.preview,
    required this.authorName,
    required this.moodLabel,
    required this.moodEmoji,
    required this.tags,
    required this.createdAt,
  });
}
