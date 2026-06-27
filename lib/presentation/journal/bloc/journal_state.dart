import 'package:equatable/equatable.dart';
import '../../../domain/entities/journal.dart';

enum JournalStatus {
  initial,
  loading,        // first-page / refresh
  loadMore,       // fetching next page
  listSuccess,
  detailLoading,
  detailSuccess,
  submitting,     // create/update/delete in progress
  success,        // action completed (with optional message)
  failure,
}

class JournalState extends Equatable {
  final JournalStatus status;
  final List<JournalListItem> items;
  final int total;
  final int page;
  final int limit;
  final Journal? detail;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;

  const JournalState({
    this.status = JournalStatus.initial,
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.detail,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
  });

  const JournalState.initial() : this(status: JournalStatus.initial);

  bool get isLoading => status == JournalStatus.loading;
  bool get isLoadMore => status == JournalStatus.loadMore;
  bool get isDetailLoading => status == JournalStatus.detailLoading;
  bool get isSubmitting => status == JournalStatus.submitting;
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;

  int get totalPages => limit > 0 ? (total / limit).ceil() : 0;
  bool get hasNextPage => page < totalPages;

  JournalState copyWith({
    JournalStatus? status,
    List<JournalListItem>? items,
    int? total,
    int? page,
    int? limit,
    Journal? detail,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return JournalState(
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        total,
        page,
        limit,
        detail,
        errorMessage,
        successMessage,
        searchQuery,
      ];
}
