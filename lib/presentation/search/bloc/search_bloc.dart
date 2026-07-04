import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/constants/app_features.dart';
import '../../../domain/entities/search.dart';
import '../../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _repository;

  SearchBloc({required SearchRepository repository})
      : _repository = repository,
        super(const SearchState.initial()) {
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onSearchQuerySubmitted(SearchQuerySubmitted event, Emitter<SearchState> emit) async {
    final q = event.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial, query: '', clearResult: true));
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, query: q));
    try {
      final remoteResult = await _repository.searchGlobal(q);
      
      final lowerQ = q.toLowerCase();
      final localFeatures = kAllAppFeatures.where((f) {
        return f.title.toLowerCase().contains(lowerQ) || f.subtitle.toLowerCase().contains(lowerQ);
      }).toList();

      final combinedResult = SearchResult(
        articles: remoteResult.articles,
        songs: remoteResult.songs,
        features: localFeatures,
        total: remoteResult.total + localFeatures.length,
      );

      emit(state.copyWith(status: SearchStatus.success, result: combinedResult));
    } on ApiException catch (e) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: 'Pencarian gagal'));
    }
  }

  Future<void> _onSearchCleared(SearchCleared event, Emitter<SearchState> emit) async {
    emit(const SearchState.initial());
  }
}