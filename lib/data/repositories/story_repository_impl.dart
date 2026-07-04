import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/remote/story_remote_datasource.dart';
import '../models/story_model.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource _remote;

  StoryRepositoryImpl({required StoryRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<StoryCard>> getStories({
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
    String? categoryId,
    String? search,
  }) async {
    final result = await _remote.getStories(
      page: page,
      limit: limit,
      sortBy: sortBy,
      categoryId: categoryId,
      search: search,
    );
    final items = result['items'] as List<StoryCardModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Story> getStory(String id) async {
    final model = await _remote.getStory(id);
    return model.toEntity();
  }

  @override
  Future<void> toggleHeart(String id) async {
    await _remote.toggleHeart(id);
  }

  @override
  Future<List<StoryCategory>> getCategories() async {
    final models = await _remote.getCategories();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<StoryComment>> getComments(
    String storyId, {
    int page = 1,
    int limit = 10,
  }) async {
    final result = await _remote.getComments(storyId, page: page, limit: limit);
    final items = result['items'] as List<StoryCommentModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<StoryComment> createComment(String storyId, String content) async {
    final model = await _remote.createComment(storyId, content);
    return model.toEntity();
  }

  @override
  Future<void> toggleCommentHeart(String commentId) async {
    await _remote.toggleCommentHeart(commentId);
  }
}