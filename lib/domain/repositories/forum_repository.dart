import '../entities/forum.dart';

abstract class ForumRepository {
  Future<List<ForumThread>> getForums({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  });
  Future<ForumThread> getForum(String slug);
  Future<ForumThread> createForum({
    required String title,
    required String content,
    int? categoryId,
  });
  Future<void> toggleLike(int id);
  Future<List<ForumCategory>> getCategories();
  Future<List<ForumPost>> getPosts(
    String slug, {
    int page = 1,
    int limit = 10,
    String sortBy = 'newest',
  });
  Future<ForumPost> createPost(String slug, String content);
  Future<void> upvotePost(int id);
  Future<void> downvotePost(int id);
  Future<void> removeVote(int id);
}