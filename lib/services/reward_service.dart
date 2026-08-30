import 'package:supabase_flutter/supabase_flutter.dart';

class RewardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addFlowerReward() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    await _supabase.from('user_rewards').insert({
      'user_id': user.id,
      'reward_type': 'flower',
    });
  }

  Future<int> getFlowerCount() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return 0;
    }

    final response = await _supabase
        .from('user_rewards')
        .select('id')
        .eq('user_id', user.id)
        .eq('reward_type', 'flower');

    return response.length;
  }
}