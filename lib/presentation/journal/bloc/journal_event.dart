import 'package:equatable/equatable.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

/// Load the journal list (first page or next page).
class JournalListRequested extends JournalEvent {
  final bool refresh;
  final List<String>? tags;

  const JournalListRequested({this.refresh = false, this.tags});

  @override
  List<Object?> get props => [refresh, tags];
}

/// Load more (next page) — only valid if there is a next page.
class JournalLoadMoreRequested extends JournalEvent {
  const JournalLoadMoreRequested();
}

/// Search journals by query.
class JournalSearchRequested extends JournalEvent {
  final String query;

  const JournalSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search and return to the list.
class JournalSearchCleared extends JournalEvent {
  const JournalSearchCleared();
}

/// Load a single journal by uuid.
class JournalDetailRequested extends JournalEvent {
  final String uuid;

  const JournalDetailRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}

/// Create a new journal.
class JournalCreateRequested extends JournalEvent {
  final String title;
  final String content;
  final List<String> tags;
  final int? moodId;

  const JournalCreateRequested({
    required this.title,
    required this.content,
    this.tags = const [],
    this.moodId,
  });

  @override
  List<Object?> get props => [title, content, tags, moodId];
}

/// Update an existing journal (partial).
class JournalUpdateRequested extends JournalEvent {
  final String uuid;
  final String? title;
  final String? content;
  final List<String>? tags;
  final int? moodId;

  const JournalUpdateRequested({
    required this.uuid,
    this.title,
    this.content,
    this.tags,
    this.moodId,
  });

  @override
  List<Object?> get props => [uuid, title, content, tags, moodId];
}

/// Delete a journal.
class JournalDeleteRequested extends JournalEvent {
  final String uuid;

  const JournalDeleteRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}
