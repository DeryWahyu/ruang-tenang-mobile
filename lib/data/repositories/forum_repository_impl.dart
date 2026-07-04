import '../../domain/entities/forum.dart';
import '../../domain/repositories/forum_repository.dart';
import '../datasources/remote/forum_remote_datasource.dart';
import '../models/forum_model.dart';

class ForumRepositoryImpl implements ForumRepository {
  final ForumRemoteDataSource _remote;

  ForumRepositoryImpl({required ForumRemoteDataSource remote}) : _remote = remote;

  @override
  Future<List<ForumThread>> getForums({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    final result = await _remote.getForums(
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
    );
    final items = result['items'] as List<ForumThreadModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ForumThread> getForum(String slug) async {
    final model = await _remote.getForum(slug);
    return model.toEntity();
  }

  @override
  Future<ForumThread> createForum({
    required String title,
    required String content,
    int? categoryId,
  }) async {
    final model = await _remote.createForum(
      title: title,
      content: content,
      categoryId: categoryId,
    );
    return model.toEntity();
  }

  @override
  Future<void> toggleLike(String slug) async {
    await _remote.toggleLike(slug);
  }

  @override
  Future<List<ForumCategory>> getCategories() async {
    final models = await _remote.getCategories();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<ForumPost>> getPosts(
    String slug, {
    int page = 1,
    int limit = 10,
    String sortBy = 'newest',
  }) async {
    final result = await _remote.getPosts(slug, page: page, limit: limit, sortBy: sortBy);
    final items = result['items'] as List<ForumPostModel>;
    return items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ForumPost> createPost(String slug, String content) async {
    final model = await _remote.createPost(slug, content);
    return model.toEntity();
  }

  @override
  Future<void> upvotePost(int id) async {
    await _remote.upvotePost(id);
  }

  @override
  Future<void> downvotePost(int id) async {
    await _remote.downvotePost(id);
  }

  @override
  Future<void> removeVote(int id) async {
    await _remote.removeVote(id);
  }
}