import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

class ProfileRemoteDs {
  ProfileRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<UserModel?> getProfile(String userId) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final data = await sb
          .from(DbTables.profiles)
          .select('*')
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserModel.fromMap(data);
    } catch (e) {
      Logger.w('getProfile failed: $e');
      return null;
    }
  }

  Future<UserModel?> upsertProfile(UserModel model) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final data = await sb
          .from(DbTables.profiles)
          .upsert(model.toMap())
          .select('*')
          .maybeSingle();
      if (data == null) return null;
      return UserModel.fromMap(data);
    } catch (e) {
      throw NetworkException('Profile update failed', cause: e);
    }
  }
}
