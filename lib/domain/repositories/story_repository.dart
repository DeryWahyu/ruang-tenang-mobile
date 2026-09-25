import '../entities/story.dart';

abstract class StoryRepository {
  Future<List<StoryCategory>> getCategories();
  Future<List<StoryCard>> getMyStories({int page = 1, String? status});
  Future<Story> saveStory({String? id, required Map<String, dynamic> data});
  Future<void> deleteStory(String id);
  Future<List<StoryCard>> getStories({
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
    String? categoryId,
    String? search,
  });
  Future<Story> getStory(String id);
  Future<void> toggleHeart(String id);
  Future<List<StoryComment>> getComments(
    String storyId, {
    int page = 1,
    int limit = 10,
  });
  Future<StoryComment> createComment(String storyId, String content);
  Future<void> toggleCommentHeart(String storyId, String commentId);
}
