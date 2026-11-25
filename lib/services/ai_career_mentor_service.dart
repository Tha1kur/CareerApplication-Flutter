import '../core/constants/app_routes.dart';
import '../models/ai_career_plan.dart';
import '../models/profile.dart';
import '../models/user_progress.dart';
import 'scoring_service.dart';

/// Deterministic on-device career roadmap synthesizer.
/// Ported directly from Kotlin `AiCareerMentorEngine.kt` (no external LLM required).
abstract final class AiCareerMentorService {
  static AiCareerPlan generatePlan({
    required Profile profile,
    required Map<String, int> scores,
    required UserProgress progress,
  }) {
    final topCategory = scores.isNotEmpty
        ? ScoringService.topCareerCategory(scores)
        : (profile.goal.trim().isNotEmpty
              ? inferCategoryFromGoal(profile.goal)
              : 'Engineering');

    final maxScore = scores[topCategory] ?? 24;
    final matchPercentage = scores.isNotEmpty
        ? ((maxScore / 32.0) * 100).toInt().clamp(75, 98)
        : 82;

    final userName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Future Leader';

    return switch (topCategory) {
      'Design' => _createDesignPlan(userName, matchPercentage),
      'Management' => _createManagementPlan(userName, matchPercentage),
      'Science' => _createSciencePlan(userName, matchPercentage),
      'Entrepreneurship' => _createEntrepreneurshipPlan(
        userName,
        matchPercentage,
      ),
      _ => _createEngineeringPlan(userName, matchPercentage),
    };
  }

  static String inferCategoryFromGoal(String goal) {
    final lower = goal.toLowerCase();
    if (lower.contains('startup') ||
        lower.contains('founder') ||
        lower.contains('entrepreneur') ||
        lower.contains('venture')) {
      return 'Entrepreneurship';
    }
    if (lower.contains('business') ||
        lower.contains('management') ||
        lower.contains('mba') ||
        lower.contains('finance') ||
        lower.contains('consulting')) {
      return 'Management';
    }
    if (lower.contains('design') ||
        lower.contains('ux') ||
        lower.contains('ui') ||
        lower.contains('art')) {
      return 'Design';
    }
    if (lower.contains('science') ||
        lower.contains('research') ||
        lower.contains('physics') ||
        lower.contains('biology')) {
      return 'Science';
    }
    return 'Engineering';
  }

  static AiCareerPlan _createEngineeringPlan(
    String userName,
    int matchPercentage,
  ) {
    return AiCareerPlan(
      careerTitle: 'Software & Systems Innovator',
      careerCategory: 'Engineering',
      matchPercentage: matchPercentage,
      executiveSummary:
          'Hey $userName, your analytical instincts and aptitude for structured problem-solving strongly align with modern Engineering & Technology. You thrive at building scalable systems, decomposing hard mathematical problems, and turning ideas into functioning software.',
      keyStrengths: const [
        'System architecture & algorithmic thinking',
        'Logical problem decomposition',
        'Hands-on technical implementation',
        'Rapid technical tooling adoption',
      ],
      growthAreas: const [
        'Open-source code collaboration & Git workflows',
        'Production system design & scalability',
        'Cross-disciplinary technical communication',
      ],
      targetEntranceExams: const [
        'JEE Advanced',
        'JEE Main',
        'BITSAT',
        'GATE CS',
      ],
      recommendedSkills: const [
        'Flutter & Modern Mobile',
        'Data Structures & Algorithms',
        'System Design',
        'Cloud Infrastructure (AWS/GCP)',
      ],
      portfolioProjects: const [
        'High-performance mobile application with offline-first persistence',
        'Distributed REST & GraphQL API backend',
        'Open-source developer utility with continuous integration',
      ],
      milestones: const [
        AiCareerMilestone(
          id: 'eng_1',
          title: 'Master Data Structures & Algorithmic Patterns',
          category: 'Core Competencies',
          description: 'Consistently solve array, tree, and dynamic programming challenges. Focus on time and space complexity tradeoffs.',
          priority: 'Essential',
          estimatedTimeline: 'Month 1-2',
          actionRoute: AppRoutes.quiz,
        ),
        AiCareerMilestone(
          id: 'eng_2',
          title: 'Architect & Ship a Full-Featured Mobile App',
          category: 'Portfolio Projects',
          description: 'Build a multi-screen application demonstrating clean architecture, state management, and modern UX.',
          priority: 'Essential',
          estimatedTimeline: 'Month 2-3',
          actionRoute: AppRoutes.colleges,
        ),
        AiCareerMilestone(
          id: 'eng_3',
          title: 'Benchmark Top Technical Institutes & Entrance Cutoffs',
          category: 'Exams & Admissions',
          description: 'Compare NIRF top engineering institutes (IITs, NITs, BITS) and establish structured mock exam schedules.',
          estimatedTimeline: 'Month 3-4',
          actionRoute: AppRoutes.compare,
        ),
        AiCareerMilestone(
          id: 'eng_4',
          title: 'Apply for Merit & Technology Grants',
          category: 'Scholarships',
          description: 'Track and submit applications for top corporate & national scholarships such as Reliance Foundation & AICTE Pragati.',
          estimatedTimeline: 'Month 4-5',
          actionRoute: AppRoutes.scholarships,
        ),
        AiCareerMilestone(
          id: 'eng_5',
          title: 'Participate in Developer Communities & Hackathons',
          category: 'Industry Exposure',
          description: 'Join peer AMAs, collaborate on student hackathons, and seek code reviews from verified industry mentors.',
          priority: 'Medium',
          estimatedTimeline: 'Month 5-6',
          actionRoute: AppRoutes.community,
        ),
      ],
    );
  }

  static AiCareerPlan _createDesignPlan(String userName, int matchPercentage) {
    return AiCareerPlan(
      careerTitle: 'Product Designer & UX Strategist',
      careerCategory: 'Design',
      matchPercentage: matchPercentage,
      executiveSummary:
          'Hey $userName, your innate creative empathy and visual sensitivity make you a natural for Product & UX Design. You possess an instinct for how interfaces feel, how users think, and how aesthetic harmony elevates human interaction.',
      keyStrengths: const [
        'Empathy-led user research & psychology',
        'Visual design hierarchy & color harmony',
        'Interaction prototyping & user flow mapping',
        'Creative synthesis of ambiguous briefs',
      ],
      growthAreas: const [
        'Accessible design systems (WCAG compliance)',
        'Quantitative usability metrics (A/B testing, SUS)',
        'Design handoff & design-to-code collaboration',
      ],
      targetEntranceExams: const [
        'UCEED',
        'CEED',
        'NID DAT Prelims',
        'NIFT Entrance',
      ],
      recommendedSkills: const [
        'Figma & Design Tokens',
        'User Research & Heuristic Analysis',
        'Interactive Prototyping',
        'Information Architecture',
      ],
      portfolioProjects: const [
        'End-to-end mobile UX case study with user interview artifacts',
        'Scalable Material 3 design token system library',
        'Redesign of a complex civic or healthcare digital service',
      ],
      milestones: const [
        AiCareerMilestone(
          id: 'des_1',
          title: 'Publish 3 Deep UX Case Studies',
          category: 'Portfolio Projects',
          description: 'Document problem statements, user personas, wireframes, iteration trade-offs, and final interactive prototypes.',
          priority: 'Essential',
          estimatedTimeline: 'Month 1-3',
          actionRoute: AppRoutes.colleges,
        ),
        AiCareerMilestone(
          id: 'des_2',
          title: 'UCEED & NID Design Aptitude Preparation',
          category: 'Exams & Admissions',
          description: 'Practice visual drawing, observational sensitivity, spatial reasoning, and design problem solving under timed tests.',
          estimatedTimeline: 'Month 2-4',
          actionRoute: AppRoutes.compare,
        ),
        AiCareerMilestone(
          id: 'des_3',
          title: 'Conduct 5 Guided Usability Testing Sessions',
          category: 'Core Competencies',
          description: 'Draft user testing scripts, observe participants navigating your prototypes, and synthesize behavioral friction logs.',
          estimatedTimeline: 'Month 3-5',
          actionRoute: AppRoutes.community,
        ),
        AiCareerMilestone(
          id: 'des_4',
          title: 'Apply for Creative Arts & Design Fellowships',
          category: 'Scholarships',
          description: 'Identify institutional design grants and government higher education fee waiver schemes for top design schools.',
          priority: 'Medium',
          estimatedTimeline: 'Month 4-6',
          actionRoute: AppRoutes.scholarships,
        ),
      ],
    );
  }

  static AiCareerPlan _createManagementPlan(
    String userName,
    int matchPercentage,
  ) {
    return AiCareerPlan(
      careerTitle: 'Business Strategist & Product Leader',
      careerCategory: 'Management',
      matchPercentage: matchPercentage,
      executiveSummary:
          'Hey $userName, you shine at synthesizing cross-functional priorities, aligning teams, and driving commercial outcomes. You have natural leadership presence, communication poise, and strategic clarity.',
      keyStrengths: const [
        'Cross-functional team coordination',
        'Persuasive presentation & stakeholder alignment',
        'Strategic prioritization & roadmapping',
        'Market analysis & business model synthesis',
      ],
      growthAreas: const [
        'Quantitative financial modeling & unit economics',
        'Data analytics & SQL query formulation',
        'Managing organizational conflict & negotiations',
      ],
      targetEntranceExams: const [
        'CAT',
        'XAT',
        'IPMAT (IIM Indore/Rohtak)',
        'GMAT',
      ],
      recommendedSkills: const [
        'Financial Statement Analysis',
        'Agile Product Management',
        'Data Storytelling (SQL/BI)',
        'Business Case Modeling',
      ],
      portfolioProjects: const [
        'Go-To-Market expansion teardown for a unicorn business model',
        'Comprehensive unit economics model with sensitivity analysis',
        'Product strategy memorandum prioritizing 3 growth wedges',
      ],
      milestones: const [
        AiCareerMilestone(
          id: 'mgmt_1',
          title: 'Complete a Strategic Market Teardown',
          category: 'Portfolio Projects',
          description: 'Deconstruct a business model\'s CAC, LTV, moat, and competitive threats into an executive presentation.',
          priority: 'Essential',
          estimatedTimeline: 'Month 1-2',
          actionRoute: AppRoutes.colleges,
        ),
        AiCareerMilestone(
          id: 'mgmt_2',
          title: 'IPMAT & CAT Foundation Quantitative Mastery',
          category: 'Exams & Admissions',
          description: 'Target quantitative aptitude, logical reasoning, and data interpretation with timed benchmark mocks.',
          estimatedTimeline: 'Month 2-4',
          actionRoute: AppRoutes.compare,
        ),
        AiCareerMilestone(
          id: 'mgmt_3',
          title: 'Lead a Student Initiative or Case Competition Team',
          category: 'Leadership & Practice',
          description: 'Take operational ownership of a student forum, case challenge, or social impact project to demonstrate real impact.',
          estimatedTimeline: 'Month 3-5',
          actionRoute: AppRoutes.community,
        ),
        AiCareerMilestone(
          id: 'mgmt_4',
          title: 'Apply for Corporate Leadership Scholarships',
          category: 'Scholarships',
          description: 'Identify merit-based management grants including Aditya Birla Scholarships and OP Jindal Engineering/Management awards.',
          estimatedTimeline: 'Month 4-6',
          actionRoute: AppRoutes.scholarships,
        ),
      ],
    );
  }

  static AiCareerPlan _createSciencePlan(String userName, int matchPercentage) {
    return AiCareerPlan(
      careerTitle: 'Scientific Researcher & Deep-Tech Explorer',
      careerCategory: 'Science',
      matchPercentage: matchPercentage,
      executiveSummary:
          'Hey $userName, your innate curiosity and dedication to rigorous first-principles thinking define your mindset. You are captivated by understanding how the universe works, testing hypotheses, and pioneering breakthroughs.',
      keyStrengths: const [
        'Empirical hypothesis formulation & testing',
        'Critical literature evaluation',
        'Mathematical & statistical rigor',
        'Patience for deep iterative investigation',
      ],
      growthAreas: const [
        'Academic scientific writing & LaTeX formatting',
        'Computational data modeling (Python/SciPy)',
        'Grant proposal and research funding drafting',
      ],
      targetEntranceExams: const [
        'NEST (NISER/CEBS)',
        'IAT (IISERs)',
        'IIT-JAM',
        'CSIR NET',
      ],
      recommendedSkills: const [
        'Statistical Modeling (Python/R)',
        'LaTeX & Scientific Documentation',
        'Experimental Data Analysis',
        'Research Methodology',
      ],
      portfolioProjects: const [
        'Reproduced computational paper on statistical physical dynamics',
        'Genomic / Climate exploratory analysis with published Jupyter notebook',
        'Literature review on emerging clean energy materials',
      ],
      milestones: const [
        AiCareerMilestone(
          id: 'sci_1',
          title: 'Author an Empirical Research Synthesis',
          category: 'Research Output',
          description: 'Select an open scientific problem, survey 15 recent papers, and synthesize unresolved experimental tensions.',
          priority: 'Essential',
          estimatedTimeline: 'Month 1-3',
          actionRoute: AppRoutes.colleges,
        ),
        AiCareerMilestone(
          id: 'sci_2',
          title: 'Prepare for IISER IAT & NEST Examinations',
          category: 'Exams & Admissions',
          description: 'Master multi-disciplinary physics, chemistry, mathematics, and biology concepts for premier research institutes.',
          priority: 'Essential',
          estimatedTimeline: 'Month 2-4',
          actionRoute: AppRoutes.compare,
        ),
        AiCareerMilestone(
          id: 'sci_3',
          title: 'Secure Summer Research Fellowship (IASc / INSA)',
          category: 'Fellowships',
          description: 'Draft research statements and apply to summer research programs at IISc, TIFR, or IIT research labs.',
          estimatedTimeline: 'Month 3-5',
          actionRoute: AppRoutes.scholarships,
        ),
        AiCareerMilestone(
          id: 'sci_4',
          title: 'Apply for INSPIRE & Kishore Vaigyanik Grants',
          category: 'Scholarships',
          description: 'Register for Department of Science & Technology (DST) scholarship funding for pure science research aspirants.',
          estimatedTimeline: 'Month 4-6',
          actionRoute: AppRoutes.scholarships,
        ),
      ],
    );
  }

  static AiCareerPlan _createEntrepreneurshipPlan(
    String userName,
    int matchPercentage,
  ) {
    return AiCareerPlan(
      careerTitle: 'Venture Founder & Innovation Catalyst',
      careerCategory: 'Entrepreneurship',
      matchPercentage: matchPercentage,
      executiveSummary:
          'Hey $userName, you have the grit to forge new pathways, spot latent market inefficiencies, and build ventures from the ground up. You are resourceful, comfortable with ambiguity, and driven by high-leverage impact.',
      keyStrengths: const [
        'Zero-to-one resourcefulness & bias for action',
        'Customer discovery & problem validation',
        'Speed in rapid prototyping & hypothesis testing',
        'Resilience in the face of setbacks',
      ],
      growthAreas: const [
        'Customer acquisition cost (CAC) & unit economics',
        'Cap table management & venture fundraising terms',
        'Recruiting and managing high-performing talent',
      ],
      targetEntranceExams: const [
        'IPMAT / CAT',
        'Y Combinator / Startup Incubators',
        'NSRCEL / E-Cell Challenges',
      ],
      recommendedSkills: const [
        'Customer Problem Discovery',
        'No-Code / Rapid Prototyping',
        'Investor Pitch Deck Design',
        'Financial Runway Modeling',
      ],
      portfolioProjects: const [
        'Functional MVP launched to 50 real active users',
        'Comprehensive Investor Pitch Deck with unit economic model',
        'Customer discovery report based on 25 in-depth user interviews',
      ],
      milestones: const [
        AiCareerMilestone(
          id: 'ent_1',
          title: 'Conduct 20 Customer Pain-Point Interviews',
          category: 'Problem Validation',
          description: 'Speak directly to target users without selling. Identify recurring frustrations they actively pay money or time to solve.',
          priority: 'Essential',
          estimatedTimeline: 'Month 1-2',
          actionRoute: AppRoutes.community,
        ),
        AiCareerMilestone(
          id: 'ent_2',
          title: 'Launch MVP and Acquire First 50 Users',
          category: 'Product Execution',
          description: 'Build the smallest possible solution that solves the core problem and measure retention relentlessly.',
          priority: 'Essential',
          estimatedTimeline: 'Month 2-4',
          actionRoute: AppRoutes.colleges,
        ),
        AiCareerMilestone(
          id: 'ent_3',
          title: 'Draft 12-Month Financial Unit Economics Model',
          category: 'Finance & Strategy',
          description: 'Project cash runway, pricing tiers, gross margin, and customer acquisition costs under realistic scenarios.',
          estimatedTimeline: 'Month 3-5',
          actionRoute: AppRoutes.compare,
        ),
        AiCareerMilestone(
          id: 'ent_4',
          title: 'Apply for Startup India Seed Grants & College Incubators',
          category: 'Grants & Funding',
          description: 'Submit applications for non-dilutive government grants, college E-Cell seed funds, and angel competitions.',
          estimatedTimeline: 'Month 4-6',
          actionRoute: AppRoutes.scholarships,
        ),
      ],
    );
  }
}
