import 'package:flutter/foundation.dart';

import '../models/college.dart';
import '../models/scholarship.dart';
import '../repositories/college_repository.dart';
import '../repositories/scholarship_repository.dart';
import '../services/local_storage_service.dart';

/// Single source of truth for Colleges, Scholarships, Bookmarks, Comparison selection,
/// and persisted search/filter preferences.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider({
    required this._collegeRepository,
    required this._scholarshipRepository,
    required this._storage,
  });

  static const List<String> collegeStreamFilters = [
    'All',
    'Engineering',
    'Design',
    'Management',
    'Science',
  ];

  static const List<String> scholarshipCategories = [
    'All',
    'Merit',
    'Need-based',
    'STEM',
    'Science',
  ];

  final CollegeRepository _collegeRepository;
  final ScholarshipRepository _scholarshipRepository;
  final LocalStorageService _storage;

  List<College> _allColleges = const [];
  List<Scholarship> _allScholarships = const [];

  Set<String> _savedCollegeIds = const {};
  Set<String> _savedScholarshipIds = const {};
  List<String> _compareCollegeIds = const [];

  String _collegeSearchQuery = '';
  String _collegeTypeFilter = 'All';
  String _scholarshipSearchQuery = '';
  String _scholarshipCategoryFilter = 'All';

  bool _isLoaded = false;
  String? _error;

  List<College> get allColleges => _allColleges;
  List<Scholarship> get allScholarships => _allScholarships;
  Set<String> get savedCollegeIds => _savedCollegeIds;
  Set<String> get savedScholarshipIds => _savedScholarshipIds;
  List<String> get compareCollegeIds => _compareCollegeIds;

  String get collegeSearchQuery => _collegeSearchQuery;
  String get collegeTypeFilter => _collegeTypeFilter;
  String get scholarshipSearchQuery => _scholarshipSearchQuery;
  String get scholarshipCategoryFilter => _scholarshipCategoryFilter;

  bool get isLoaded => _isLoaded;
  String? get error => _error;

  List<College> get filteredColleges => CollegeRepository.filterColleges(
    all: _allColleges,
    searchQuery: _collegeSearchQuery,
    typeFilter: _collegeTypeFilter,
  );

  List<Scholarship> get filteredScholarships =>
      ScholarshipRepository.filterScholarships(
        all: _allScholarships,
        searchQuery: _scholarshipSearchQuery,
        category: _scholarshipCategoryFilter,
      );

  List<College> get savedColleges => _allColleges
      .where((c) => _savedCollegeIds.contains(c.id))
      .toList(growable: false);

  List<Scholarship> get savedScholarships => _allScholarships
      .where((s) => _savedScholarshipIds.contains(s.id))
      .toList(growable: false);

  List<College> get comparedColleges => _compareCollegeIds
      .map(collegeById)
      .whereType<College>()
      .toList(growable: false);

  College? collegeById(String id) {
    for (final c in _allColleges) {
      if (c.id == id) return c;
    }
    return null;
  }

  Scholarship? scholarshipById(String id) {
    for (final s in _allScholarships) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> load() async {
    _error = null;
    try {
      _allColleges = await _collegeRepository.loadAll();
      _allScholarships = await _scholarshipRepository.loadAll();
    } catch (e) {
      _error = e.toString();
    }

    _savedCollegeIds = await _storage.loadSavedCollegeIds();
    _savedScholarshipIds = await _storage.loadSavedScholarshipIds();

    final collegeFilters = await _storage.loadCollegesFilterState();
    _collegeSearchQuery = collegeFilters.search;
    _collegeTypeFilter = collegeFilters.filter;

    final scholarshipFilters = await _storage.loadScholarshipsFilterState();
    _scholarshipSearchQuery = scholarshipFilters.search;
    _scholarshipCategoryFilter = scholarshipFilters.category;

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setCollegeSearchQuery(String query) async {
    _collegeSearchQuery = query;
    notifyListeners();
    await _storage.saveCollegesFilterState(search: query);
  }

  Future<void> setCollegeTypeFilter(String filter) async {
    _collegeTypeFilter = filter;
    notifyListeners();
    await _storage.saveCollegesFilterState(filter: filter);
  }

  Future<void> setScholarshipSearchQuery(String query) async {
    _scholarshipSearchQuery = query;
    notifyListeners();
    await _storage.saveScholarshipsFilterState(search: query);
  }

  Future<void> setScholarshipCategoryFilter(String category) async {
    _scholarshipCategoryFilter = category;
    notifyListeners();
    await _storage.saveScholarshipsFilterState(category: category);
  }

  Future<void> toggleSavedCollege(String collegeId) async {
    _savedCollegeIds = await _storage.toggleSavedCollege(collegeId);
    notifyListeners();
  }

  Future<void> toggleSavedScholarship(String scholarshipId) async {
    _savedScholarshipIds = await _storage.toggleSavedScholarship(scholarshipId);
    notifyListeners();
  }

  /// Toggles comparison selection while enforcing max 3 colleges.
  /// Returns `false` if rejected due to the 3-college cap.
  bool toggleCompareCollege(String collegeId) {
    final current = List<String>.from(_compareCollegeIds);
    if (current.contains(collegeId)) {
      current.remove(collegeId);
      _compareCollegeIds = List<String>.unmodifiable(current);
      notifyListeners();
      return true;
    }
    if (current.length >= CollegeRepository.maxCompareSelection) {
      return false;
    }
    current.add(collegeId);
    _compareCollegeIds = List<String>.unmodifiable(current);
    notifyListeners();
    return true;
  }

  void setCompareSelection(List<String> ids) {
    final validIds = ids
        .where((id) => collegeById(id) != null)
        .toSet()
        .take(CollegeRepository.maxCompareSelection)
        .toList(growable: false);
    _compareCollegeIds = List<String>.unmodifiable(validIds);
    notifyListeners();
  }

  void clearCompareSelection() {
    _compareCollegeIds = const [];
    notifyListeners();
  }
}
