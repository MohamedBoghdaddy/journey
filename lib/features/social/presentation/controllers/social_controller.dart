import 'package:flutter/foundation.dart';

import '../../../../core/utils/debounce.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/search_users.dart';

class SocialController extends ChangeNotifier {
  SocialController({required SearchUsers searchUsers})
      : _searchUsers = searchUsers;

  final SearchUsers _searchUsers;
  final Debounce _debounce = Debounce();

  bool isLoading = false;
  String? error;
  List<Profile> results = [];

  void search(String query) {
    _debounce.run(() async {
      isLoading = true;
      error = null;
      notifyListeners();

      try {
        results = await _searchUsers(query);
      } catch (e) {
        Logger.e('Search users failed', error: e);
        error = 'Search failed';
      }

      isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }
}
