import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQuerySubmitted extends SearchEvent {
  final String query;
  const SearchQuerySubmitted(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}