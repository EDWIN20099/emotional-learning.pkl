import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getEmotions() async {
    final response = await _supabase
        .from('emotions')
        .select('id, name, description')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }
}