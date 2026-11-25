import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/scholarship.dart';

class ScholarshipRepository {
  ScholarshipRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/data/scholarships.json';

  final AssetBundle _bundle;
  List<Scholarship>? _cache;

  Future<List<Scholarship>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('scholarships.json must be a JSON array');
    }
    _cache = decoded
        .whereType<Map<String, dynamic>>()
        .map(Scholarship.fromJson)
        .toList(growable: false);
    return _cache!;
  }

  Future<Scholarship?> getById(String id) async {
    final all = await loadAll();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<List<Scholarship>> getByIds(Iterable<String> ids) async {
    final idSet = ids.toSet();
    final all = await loadAll();
    return all.where((s) => idSet.contains(s.id)).toList(growable: false);
  }

  static List<Scholarship> filterScholarships({
    required List<Scholarship> all,
    String searchQuery = '',
    String category = 'All',
  }) {
    final query = searchQuery.trim().toLowerCase();
    return all
        .where((scholarship) {
          final matchesCategory =
              category.toLowerCase() == 'all' ||
              scholarship.category.toLowerCase() == category.toLowerCase();

          final matchesSearch =
              query.isEmpty ||
              scholarship.name.toLowerCase().contains(query) ||
              (scholarship.eligibility?.toLowerCase().contains(query) ?? false);

          return matchesCategory && matchesSearch;
        })
        .toList(growable: false);
  }
}
