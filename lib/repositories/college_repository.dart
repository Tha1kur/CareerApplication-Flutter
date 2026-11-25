import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/college.dart';

class CollegeComparisonInsights {
  const CollegeComparisonInsights({
    required this.bestRankedCollege,
    required this.categories,
    required this.cities,
  });

  final College? bestRankedCollege;
  final List<String> categories;
  final List<String> cities;
}

class CollegeRepository {
  CollegeRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/data/colleges.json';
  static const int maxCompareSelection = 3;

  final AssetBundle _bundle;
  List<College>? _cache;

  Future<List<College>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('colleges.json must be a JSON array');
    }
    _cache = decoded
        .whereType<Map<String, dynamic>>()
        .map(College.fromJson)
        .toList(growable: false);
    return _cache!;
  }

  Future<College?> getById(String id) async {
    final all = await loadAll();
    for (final college in all) {
      if (college.id == id) return college;
    }
    return null;
  }

  Future<List<College>> getByIds(Iterable<String> ids) async {
    final idSet = ids.toSet();
    final all = await loadAll();
    return all.where((c) => idSet.contains(c.id)).toList(growable: false);
  }

  static List<College> filterColleges({
    required List<College> all,
    String searchQuery = '',
    String typeFilter = 'All',
  }) {
    final query = searchQuery.trim().toLowerCase();
    return all
        .where((college) {
          final matchesFilter =
              typeFilter.toLowerCase() == 'all' ||
              (college.type?.toLowerCase() == typeFilter.toLowerCase());

          final matchesSearch =
              query.isEmpty ||
              college.name.toLowerCase().contains(query) ||
              (college.city?.toLowerCase().contains(query) ?? false) ||
              (college.state?.toLowerCase().contains(query) ?? false) ||
              college.tags.any((t) => t.toLowerCase().contains(query));

          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

  static CollegeComparisonInsights computeComparisonInsights(
    List<College> colleges,
  ) {
    College? bestRank;
    for (final college in colleges) {
      final rank = college.rank;
      if (rank == null) continue;
      if (bestRank == null || rank < (bestRank.rank ?? 0x7fffffff)) {
        bestRank = college;
      }
    }

    final categories = colleges
        .map((c) => c.type?.trim() ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final cities = colleges
        .map((c) => c.city?.trim() ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return CollegeComparisonInsights(
      bestRankedCollege: bestRank,
      categories: categories,
      cities: cities,
    );
  }
}
