import 'package:flutter/foundation.dart';

import '../models/community_models.dart';
import '../repositories/community_repository.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider({required this._repository});

  final CommunityRepository _repository;

  List<CommunityQuestion> _questions = const [];
  Set<String> _upvotedQuestionIds = const {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoaded = false;

  List<CommunityQuestion> get questions => _questions;
  Set<String> get upvotedQuestionIds => _upvotedQuestionIds;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoaded => _isLoaded;

  List<CommunityQuestion> get filteredQuestions =>
      CommunityRepository.filterQuestions(
        all: _questions,
        searchQuery: _searchQuery,
        category: _selectedCategory,
      );

  bool isUpvoted(String questionId) => _upvotedQuestionIds.contains(questionId);

  int displayUpvotes(CommunityQuestion question) =>
      question.upvotes + (isUpvoted(question.id) ? 1 : 0);

  Future<void> load() async {
    _questions = await _repository.loadAll();
    _upvotedQuestionIds = await _repository.loadUpvotedQuestionIds();
    _isLoaded = true;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<CommunityQuestion> postQuestion({
    required String title,
    required String content,
    required String category,
    String authorName = '',
    String authorRole = '',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newQuestion = CommunityQuestion(
      id: 'user_q_$now',
      title: title.trim(),
      author: authorName.trim().isNotEmpty
          ? authorName.trim()
          : 'Anonymous Scholar',
      authorRole: authorRole.trim().isNotEmpty ? authorRole.trim() : 'Student',
      category: category,
      content: content.trim(),
      timestamp: now,
      upvotes: 1,
      tags: [category, 'StudentAMA'],
    );
    _questions = await _repository.postQuestion(newQuestion);
    notifyListeners();
    return newQuestion;
  }

  Future<CommunityAnswer> addAnswer({
    required String questionId,
    required String content,
    String authorName = '',
    String authorBadge = '',
    bool isVerifiedMentor = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newAnswer = CommunityAnswer(
      id: 'ans_$now',
      author: authorName.trim().isNotEmpty
          ? authorName.trim()
          : 'Community Contributor',
      authorBadge: authorBadge.trim().isNotEmpty
          ? authorBadge.trim()
          : 'Peer Mentor',
      isVerifiedMentor: isVerifiedMentor,
      content: content.trim(),
      timestamp: now,
    );
    _questions = await _repository.addAnswer(
      questionId: questionId,
      answer: newAnswer,
    );
    notifyListeners();
    return newAnswer;
  }

  Future<void> toggleUpvote(String questionId) async {
    _upvotedQuestionIds = await _repository.toggleUpvote(questionId);
    notifyListeners();
  }
}
