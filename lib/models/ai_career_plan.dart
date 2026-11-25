class AiCareerMilestone {
  const AiCareerMilestone({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.priority = 'High',
    this.estimatedTimeline = '1-3 Months',
    this.actionRoute,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String priority;
  final String estimatedTimeline;
  final String? actionRoute;
}

class AiCareerPlan {
  const AiCareerPlan({
    required this.careerTitle,
    required this.careerCategory,
    required this.matchPercentage,
    required this.executiveSummary,
    required this.keyStrengths,
    required this.growthAreas,
    required this.targetEntranceExams,
    required this.recommendedSkills,
    required this.portfolioProjects,
    required this.milestones,
  });

  final String careerTitle;
  final String careerCategory;
  final int matchPercentage;
  final String executiveSummary;
  final List<String> keyStrengths;
  final List<String> growthAreas;
  final List<String> targetEntranceExams;
  final List<String> recommendedSkills;
  final List<String> portfolioProjects;
  final List<AiCareerMilestone> milestones;
}
