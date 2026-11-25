import 'package:career_application_flutter/core/constants/app_routes.dart';
import 'package:career_application_flutter/models/profile.dart';
import 'package:career_application_flutter/models/user_progress.dart';
import 'package:career_application_flutter/services/ai_career_mentor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiCareerMentorService', () {
    test('generates Engineering plan for top Engineering scores', () {
      final plan = AiCareerMentorService.generatePlan(
        profile: const Profile(name: 'Aman Gupta', age: 18, goal: 'Software'),
        scores: const {
          'Engineering': 32,
          'Design': 10,
          'Management': 8,
          'Science': 14,
          'Entrepreneurship': 6,
        },
        progress: const UserProgress(points: 200),
      );

      expect(plan.careerCategory, 'Engineering');
      expect(plan.careerTitle, 'Software & Systems Innovator');
      expect(plan.matchPercentage, 98); // clamped at 98
      expect(plan.executiveSummary, contains('Aman Gupta'));
      expect(plan.targetEntranceExams, contains('JEE Advanced'));
      expect(plan.milestones.length, 5);
    });

    test('generates Design, Management, and Science plans accurately', () {
      final designPlan = AiCareerMentorService.generatePlan(
        profile: const Profile(name: 'Ananya'),
        scores: const {'Design': 30, 'Engineering': 8},
        progress: const UserProgress(),
      );
      expect(designPlan.careerCategory, 'Design');
      expect(designPlan.targetEntranceExams, contains('UCEED'));
      expect(designPlan.milestones.any((m) => m.id == 'des_1'), isTrue);

      final mgmtPlan = AiCareerMentorService.generatePlan(
        profile: const Profile(name: 'Rohan'),
        scores: const {'Management': 28, 'Engineering': 10},
        progress: const UserProgress(),
      );
      expect(mgmtPlan.careerCategory, 'Management');
      expect(mgmtPlan.targetEntranceExams, contains('CAT'));

      final sciPlan = AiCareerMentorService.generatePlan(
        profile: const Profile(name: 'Divya'),
        scores: const {'Science': 29, 'Engineering': 12},
        progress: const UserProgress(),
      );
      expect(sciPlan.careerCategory, 'Science');
      expect(sciPlan.targetEntranceExams, contains('NEST (NISER/CEBS)'));
    });

    test('infers Entrepreneurship from profile goal when scores are empty', () {
      final plan = AiCareerMentorService.generatePlan(
        profile: const Profile(
          name: 'Sameer',
          age: 20,
          goal: 'I want to launch a startup and build a venture',
        ),
        scores: const {},
        progress: const UserProgress(),
      );

      expect(plan.careerCategory, 'Entrepreneurship');
      expect(plan.careerTitle, 'Venture Founder & Innovation Catalyst');
      expect(plan.matchPercentage, 82);
      expect(plan.milestones.any((m) => m.title.contains('MVP')), isTrue);
    });

    test(
      'uses Future Leader fallback name and clamps low score match to 75%',
      () {
        final plan = AiCareerMentorService.generatePlan(
          profile: const Profile(),
          scores: const {'Engineering': 4},
          progress: const UserProgress(),
        );

        expect(plan.executiveSummary, contains('Future Leader'));
        expect(plan.matchPercentage, 75);
      },
    );

    test(
      'all milestone action routes across all 5 categories are valid AppRoutes',
      () {
        const validRoutes = {
          AppRoutes.quiz,
          AppRoutes.colleges,
          AppRoutes.scholarships,
          AppRoutes.compare,
          AppRoutes.community,
        };

        for (final category in [
          'Engineering',
          'Design',
          'Management',
          'Science',
          'Entrepreneurship',
        ]) {
          final plan = AiCareerMentorService.generatePlan(
            profile: const Profile(name: 'Student'),
            scores: {category: 28},
            progress: const UserProgress(),
          );
          for (final milestone in plan.milestones) {
            expect(milestone.id.isNotEmpty, isTrue);
            if (milestone.actionRoute != null) {
              expect(validRoutes.contains(milestone.actionRoute), isTrue);
            }
          }
        }
      },
    );
  });
}
