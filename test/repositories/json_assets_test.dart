import 'package:career_application_flutter/models/college.dart';
import 'package:career_application_flutter/models/quiz_models.dart';
import 'package:career_application_flutter/models/scholarship.dart';
import 'package:career_application_flutter/repositories/college_repository.dart';
import 'package:career_application_flutter/repositories/quiz_repository.dart';
import 'package:career_application_flutter/repositories/scholarship_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bundled JSON assets', () {
    test(
      'aptitudequiz.json decodes all 8 expected question IDs with options',
      () async {
        final repo = QuizRepository();
        final questions = await repo.loadAll();

        expect(questions.length, 8);
        expect(
          questions.map((q) => q.id).toList(),
          equals([
            'favoriteSubject',
            'handsOnWork',
            'jobPreference',
            'workEnvironment',
            'leadership',
            'problemSolving',
            'creativity',
            'communication',
          ]),
        );

        for (final q in questions) {
          expect(q.question.isNotEmpty, isTrue);
          expect(q.options.isNotEmpty, isTrue);
          for (final opt in q.options) {
            expect(opt.value.isNotEmpty, isTrue);
            expect(opt.label.isNotEmpty, isTrue);
          }
        }
      },
    );

    test('colleges.json decodes all 4 institutions cleanly', () async {
      final repo = CollegeRepository();
      final colleges = await repo.loadAll();

      expect(colleges.length, 4);
      expect(
        colleges.map((c) => c.id).toList(),
        equals(['iitb', 'nid', 'iim-a', 'iitk']),
      );

      final iitb = await repo.getById('iitb');
      expect(iitb, isNotNull);
      expect(iitb!.rank, 1);
      expect(iitb.intake, 'UG/PG');
      expect(await repo.getById('unknown-id'), isNull);
    });

    test(
      'scholarships.json decodes all 5 records and flags 2025 demo dates',
      () async {
        final repo = ScholarshipRepository();
        final scholarships = await repo.loadAll();

        expect(scholarships.length, 5);
        expect(
          scholarships.map((s) => s.id).toList(),
          equals([
            'nsf',
            'obc-postmatric',
            'tata-scholar',
            'adobe-women-tech',
            'inspire',
          ]),
        );

        for (final s in scholarships) {
          expect(s.name.isNotEmpty, isTrue);
          expect(s.category.isNotEmpty, isTrue);
          expect(s.isHistoricalSample, isTrue);
        }
      },
    );

    test('model fromJson handles sparse/null fields defensively', () {
      final college = College.fromJson({'id': 'c1', 'name': 'Minimal College'});
      expect(college.courses, isEmpty);
      expect(college.tags, isEmpty);
      expect(college.formattedLocation, 'Location to be confirmed');

      final scholarship = Scholarship.fromJson({
        'id': 's1',
        'name': 'Future Grant',
        'category': 'Merit',
        'deadline': '31 December 2027',
      });
      expect(scholarship.isHistoricalSample, isFalse);
      expect(scholarship.tags, isEmpty);

      final attempt = QuizAttempt.fromJson({'id': 'a1'});
      expect(attempt.scores, isEmpty);
      expect(attempt.topScore, 0);
    });
  });
}
