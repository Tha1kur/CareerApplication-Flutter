import 'package:flutter/foundation.dart';

import '../models/scholarship.dart';
import '../models/tracked_scholarship.dart';
import '../services/local_storage_service.dart';

class TrackerProvider extends ChangeNotifier {
  TrackerProvider({required this._storage});

  final LocalStorageService _storage;

  List<TrackedScholarship> _items = const [];
  ApplicationStage? _selectedStageFilter;
  bool _isLoaded = false;

  List<TrackedScholarship> get items => _items;
  ApplicationStage? get selectedStageFilter => _selectedStageFilter;
  bool get isLoaded => _isLoaded;

  List<TrackedScholarship> get filteredItems {
    if (_selectedStageFilter == null) return _items;
    return _items
        .where((item) => item.stage == _selectedStageFilter)
        .toList(growable: false);
  }

  int countForStage(ApplicationStage stage) =>
      _items.where((item) => item.stage == stage).length;

  Future<void> load() async {
    _items = await _storage.loadTrackedScholarships();
    _isLoaded = true;
    notifyListeners();
  }

  void setStageFilter(ApplicationStage? stage) {
    _selectedStageFilter = stage;
    notifyListeners();
  }

  Future<void> trackScholarship(Scholarship scholarship) async {
    final alreadyTracked = _items.any(
      (item) => item.scholarshipId == scholarship.id,
    );
    if (alreadyTracked) return;

    final newItem = TrackedScholarship(
      scholarshipId: scholarship.id,
      scholarshipName: scholarship.name,
      provider: scholarship.category,
      amount: scholarship.amount ?? 'Varies',
      deadline: scholarship.deadline ?? 'Rolling',
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    _items = await _storage.saveTrackedScholarships([..._items, newItem]);
    notifyListeners();
  }

  Future<int> importSavedScholarships(
    List<Scholarship> savedScholarships,
  ) async {
    final existingIds = _items.map((item) => item.scholarshipId).toSet();
    final now = DateTime.now().millisecondsSinceEpoch;
    final toAdd = savedScholarships
        .where((s) => !existingIds.contains(s.id))
        .map(
          (s) => TrackedScholarship(
            scholarshipId: s.id,
            scholarshipName: s.name,
            provider: s.category,
            amount: s.amount ?? 'Varies',
            deadline: s.deadline ?? 'Rolling',
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    if (toAdd.isEmpty) return 0;

    _items = await _storage.saveTrackedScholarships([..._items, ...toAdd]);
    notifyListeners();
    return toAdd.length;
  }

  Future<void> updateStage(String scholarshipId, ApplicationStage stage) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = _items
        .map((item) {
          if (item.scholarshipId != scholarshipId) return item;
          return item.copyWith(stage: stage, updatedAt: now);
        })
        .toList(growable: false);
    _items = await _storage.saveTrackedScholarships(updated);
    notifyListeners();
  }

  Future<void> toggleDocument(String scholarshipId, String docName) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = _items
        .map((item) {
          if (item.scholarshipId != scholarshipId) return item;
          final docs = Set<String>.from(item.completedDocuments);
          if (!docs.remove(docName)) {
            docs.add(docName);
          }
          return item.copyWith(
            completedDocuments: Set<String>.unmodifiable(docs),
            updatedAt: now,
          );
        })
        .toList(growable: false);
    _items = await _storage.saveTrackedScholarships(updated);
    notifyListeners();
  }

  Future<void> saveNotes(String scholarshipId, String notes) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = _items
        .map((item) {
          if (item.scholarshipId != scholarshipId) return item;
          return item.copyWith(notes: notes.trim(), updatedAt: now);
        })
        .toList(growable: false);
    _items = await _storage.saveTrackedScholarships(updated);
    notifyListeners();
  }

  Future<void> untrackScholarship(String scholarshipId) async {
    final updated = _items
        .where((item) => item.scholarshipId != scholarshipId)
        .toList(growable: false);
    _items = await _storage.saveTrackedScholarships(updated);
    notifyListeners();
  }
}
