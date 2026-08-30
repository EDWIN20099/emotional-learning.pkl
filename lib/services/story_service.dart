import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStories() async {
    final response = await _supabase
        .from('stories')
        .select('''
          id,
          title,
          content,
          created_at,
          emotion_id,
          emotions (
            id,
            name
          )
        ''')
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getStoriesByEmotion(
    dynamic emotionId,
  ) async {
    final response = await _supabase
        .from('stories')
        .select('''
          id,
          title,
          content,
          created_at,
          emotion_id,
          emotions (
            id,
            name
          )
        ''')
        .eq('emotion_id', emotionId)
        .order('created_at');

    final stories =
        List<Map<String, dynamic>>.from(response);

    final user = _supabase.auth.currentUser;

    // Kalau belum login, hanya tahap pertama yang terbuka.
    if (user == null) {
      return stories
          .asMap()
          .entries
          .map((entry) {
            final story =
                Map<String, dynamic>.from(entry.value);

            story['is_unlocked'] =
                entry.key == 0;

            return story;
          })
          .toList();
    }

    // Ambil reward/quiz yang sudah diselesaikan user.
    final rewards = await _supabase
        .from('user_rewards')
        .select('story_id')
        .eq('user_id', user.id);

    final completedStoryIds = rewards
        .map(
          (reward) => reward['story_id']?.toString(),
        )
        .whereType<String>()
        .toSet();

    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < stories.length; i++) {
      final story =
          Map<String, dynamic>.from(stories[i]);

      if (i == 0) {
        story['is_unlocked'] = true;
      } else {
        final previousStory = stories[i - 1];

        final previousStoryId =
            previousStory['id']?.toString();

        story['is_unlocked'] =
            previousStoryId != null &&
            completedStoryIds.contains(
              previousStoryId,
            );
      }

      result.add(story);
    }

    return result;
  }
}