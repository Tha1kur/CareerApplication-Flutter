import 'package:career_application_flutter/models/college.dart';
import 'package:career_application_flutter/models/quiz_models.dart';
import 'package:career_application_flutter/models/scholarship.dart';
import 'package:career_application_flutter/services/scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScoringService.calculateQuizScores', () {
    test('empty answers returns zero for all 5 domains', () {
      final scores = ScoringService.calculateQuizScores(const QuizAnswers());
      expect(scores, {
        'Engineering': 0,
        'Design': 0,
        'Management': 0,
        'Science': 0,
        'Entrepreneurship': 0,
      });
    });

    test('engineering profile matches exact Kotlin weighted totals', () {
      const answers = QuizAnswers(
        favoriteSubject: 'math',
        handsOnWork: 'yes',
        jobPreference: 'private',
        workEnvironment: 'mixed',
        leadership: 'somewhat',
        problemSolving: 'analytical',
        creativity: 'somewhat',
        communication: 'written',
      );

      final scores = ScoringService.calculateQuizScores(answers);
      // Engineering: math(10)+yes(4)+private(3)+mixed(2)+analytical(5)+somewhat(2) = 26
      expect(scores['Engineering'], 26);
      // Design: yes(4)+private(3)+somewhat(3)+written(3) = 13
      expect(scores['Design'], 13);
      // Management: math(4)+private(3)+mixed(2)+somewhat(3) = 12
      expect(scores['Management'], 12);
      // Science: yes(2)+analytical(5)+written(3) = 10
      expect(scores['Science'], 10);
      // Entrepreneurship: mixed(2)+somewhat(3) = 5
      expect(scores['Entrepreneurship'], 5);
      expect(ScoringService.topCareerCategory(scores), 'Engineering');
    });

    test('creative design profile yields Design as top match', () {
      const answers = QuizAnswers(
        favoriteSubject: 'arts',
        handsOnWork: 'yes',
        jobPreference: 'private',
        workEnvironment: 'independent',
        leadership: 'not',
        problemSolving: 'creative',
        creativity: 'very',
        communication: 'written',
      );

      final scores = ScoringService.calculateQuizScores(answers);
      // Design: arts(10)+yes(4)+private(3)+independent(3)+not(2)+creative(6)+very(6)+written(3) = 37
      expect(scores['Design'], 37);
      expect(ScoringService.topCareerCategory(scores), 'Design');
    });

    test('business & entrepreneurship profile yields high Entrepreneurship and Management', () {
      const answers = QuizAnswers(
        favoriteSubject: 'commerce',
        handsOnWork: 'no',
        jobPreference: 'business',
        workEnvironment: 'team',
        leadership: 'very',
        problemSolving: 'people',
        creativity: 'somewhat',
        communication: 'public',
      );

      final scores = ScoringService.calculateQuizScores(answers);
      // Management: commerce(8)+no(2)+business(5)+team(4)+very(5)+people(5)+public(4) = 33
      // Entrepreneurship: commerce(8)+business(10)+team(3)+very(5)+people(4)+public(4) = 34
      expect(scores['Management'], 33);
      expect(scores['Entrepreneurship'], 34);
      expect(ScoringService.topCareerCategory(scores), 'Entrepreneurship');
    });

    test('science research profile yields Science as top match', () {
      const answers = QuizAnswers(
        favoriteSubject: 'science',
        handsOnWork: 'no',
        jobPreference: 'government',
        workEnvironment: 'independent',
        leadership: 'not',
        problemSolving: 'analytical',
        creativity: 'not',
        communication: 'written',
      );

      final scores = ScoringService.calculateQuizScores(answers);
      // Science: science(10)+no(3)+government(4)+independent(3)+not(2)+analytical(5)+not(3)+written(3) = 33
      expect(scores['Science'], 33);
      expect(ScoringService.topCareerCategory(scores), 'Science');
    });

    test('tie preserves Kotlin category insertion order', () {
      final scores = ScoringService.calculateQuizScores(const QuizAnswers());
      expect(ScoringService.topCareerCategory(scores), 'Engineering');
    });
  });

  group('ScoringService.calculateLevel', () {
    test('zero points initializes at level 1 with zero progress', () {
      final info = ScoringService.calculateLevel(0);
      expect(info.level, 1);
      expect(info.currentXp, 0);
      expect(info.nextLevelXp, 150);
      expect(info.progressFraction, closeTo(0.0, 0.001));
    });

    test('halfway progress calculates 0.5 fraction', () {
      final info = ScoringService.calculateLevel(75);
      expect(info.level, 1);
      expect(info.currentXp, 75);
      expect(info.progressFraction, closeTo(0.5, 0.001));
    });

    test('exact level boundary promotes to level 2 with zero excess', () {
      final info = ScoringService.calculateLevel(150);
      expect(info.level, 2);
      expect(info.currentXp, 0);
      expect(info.progressFraction, closeTo(0.0, 0.001));
    });

    test('high XP advances to level 7 with remainder 50', () {
      final info = ScoringService.calculateLevel(950);
      expect(info.level, 7);
      expect(info.currentXp, 50);
      expect(info.progressFraction, closeTo(50 / 150, 0.001));
    });

    test('negative points clamp cleanly to zero', () {
      final info = ScoringService.calculateLevel(-40);
      expect(info.level, 1);
      expect(info.currentXp, 0);
    });
  });

  group('Recommendation helpers', () {
    test(
      'buildAnswerSummaryChips and reasonChipsForCareer reflect answers',
      () {
        const answers = QuizAnswers(
          favoriteSubject: 'math',
          handsOnWork: 'yes',
          problemSolving: 'analytical',
        );
        expect(
          ScoringService.buildAnswerSummaryChips(answers),
          containsAll([
            'Enjoys Mathematics',
            'Likes hands-on work',
            'Analytical problem-solver',
          ]),
        );
        expect(
          ScoringService.reasonChipsForCareer('Engineering', answers),
          containsAll([
            'Strong in STEM subjects',
            'Enjoys analytical problem solving',
            'Likes practical, hands-on work',
          ]),
        );
      },
    );

    test(
      'collegesForCareer sorts by rank and scholarshipsForCareer matches tags',
      () {
        const colleges = [
          College(id: 'iitk', name: 'IITK', type: 'Engineering', rank: 3),
          College(id: 'iitb', name: 'IITB', type: 'Engineering', rank: 1),
          College(
            id: 'nid',
            name: 'NID',
            type: 'Design',
            tags: ['Design', 'UI/UX'],
            rank: 10,
          ),
        ];
        final engColleges = ScoringService.collegesForCareer(
          'Engineering',
          colleges,
        );
        expect(engColleges.map((c) => c.id).toList(), ['iitb', 'iitk']);

        const scholarships = [
          Scholarship(
            id: 's1',
            name: 'STEM Award',
            category: 'STEM',
            tags: ['STEM', 'Tech'],
          ),
          Scholarship(
            id: 's2',
            name: 'Need Grant',
            category: 'Need-based',
            tags: ['Need-based'],
          ),
        ];
        final engScholarships = ScoringService.scholarshipsForCareer(
          'Engineering',
          scholarships,
        );
        expect(engScholarships.map((s) => s.id).toList(), ['s1']);
      },
    );
  });
}
