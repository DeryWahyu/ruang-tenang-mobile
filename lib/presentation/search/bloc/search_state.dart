import 'package:equatable/equatable.dart';
import '../../../domain/entities/search.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final SearchResult? result;
  final String errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.result,
    this.errorMessage = '',
  });

  const SearchState.initial() : this();

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchResult? result,
    String? errorMessage,
    bool clearResult = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, query, result, errorMessage];
}