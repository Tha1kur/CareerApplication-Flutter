import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../services/local_storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this._storage});

  final LocalStorageService _storage;

  Profile _profile = const Profile();
  bool _isLoaded = false;

  Profile get profile => _profile;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _profile = await _storage.loadProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required int age,
    required String goal,
  }) async {
    final updated = Profile(
      name: name.trim(),
      age: age < 0 ? 0 : age,
      goal: goal.trim(),
    );
    _profile = updated;
    notifyListeners();
    await _storage.saveProfile(updated);
  }

  Future<void> clearProfile() async {
    _profile = const Profile();
    notifyListeners();
    await _storage.clearProfile();
  }
}
