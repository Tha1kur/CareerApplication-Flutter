import '../models/community_models.dart';
import '../services/local_storage_service.dart';

/// Local seeded Q&A repository preserving the exact 5 baseline threads from Kotlin `CommunityRepository.kt`.
class CommunityRepository {
  CommunityRepository({required this._storage});

  final LocalStorageService _storage;

  static const List<CommunityQuestion> seedQuestions = [
    CommunityQuestion(
      id: 'q_1',
      title: 'How should I balance JEE prep with learning Android and open-source coding?',
      author: 'Rohit Verma',
      authorRole: 'Class 12th PCM Aspirant',
      category: 'Technology',
      content: 'I really love building Android apps in Kotlin, but my teachers and family keep saying I should stop all programming until JEE Advanced is over. Can I balance 2-3 hours of coding on weekends without hurting my exam rank?',
      timestamp: 1715000000000,
      upvotes: 42,
      tags: ['JEE', 'Android', 'Time Management', 'Tech'],
      answers: [
        CommunityAnswer(
          id: 'a_1_1',
          author: 'Arun K. Sharma',
          authorBadge: 'IIT Delhi Alum • Staff Engineer',
          isVerifiedMentor: true,
          content: 'Here is the golden truth: Entrance exams like JEE have a strict expiry window, whereas software engineering is a lifelong craft that rewards you more after you secure an environment with great peers. Dedicate 90% of your current cognitive energy to mastering Physics, Chemistry, and Math. Use 2 hours on Sunday afternoon to write code as a healthy stress reliever. Your algorithmic maturity from math will actually make you a 10x better programmer in college!',
          timestamp: 1715050000000,
          upvotes: 38,
        ),
        CommunityAnswer(
          id: 'a_1_2',
          author: 'Neha Joshi',
          authorBadge: "NIT Trichy '23",
          content: 'Totally agree with Arun sir. I paused heavy development in class 12 and resumed in my first semester. Having a top college tier gave me on-campus hackathons and instant interview referrals that paid off tenfold.',
          timestamp: 1715080000000,
          upvotes: 14,
        ),
      ],
    ),
    CommunityQuestion(
      id: 'q_2',
      title: 'Is a formal design degree from NID / IIT IDC necessary to break into UX/Product Design?',
      author: 'Tanvi Sen',
      authorRole: 'Design Aspirant',
      category: 'Design',
      content: 'I come from a non-design background and I am self-learning Figma and design principles. Do top tech companies hire self-taught product designers, or do they filter out resumes without NID/IIT credentials?',
      timestamp: 1715100000000,
      upvotes: 35,
      tags: ['Product Design', 'UCEED', 'NID', 'Portfolio'],
      answers: [
        CommunityAnswer(
          id: 'a_2_1',
          author: 'Priya Menon',
          authorBadge: 'NID Alum • Design Lead',
          isVerifiedMentor: true,
          content: 'Portfolios are the ultimate currency in design. No hiring manager hires a degree; they hire your ability to solve messy human problems, demonstrate empathy, and articulate decision trade-offs. However, premier design institutes give you three unfair advantages: intense peer critique, access to senior alumni networks, and campus placements. If you are self-taught, make sure your case studies show real user testing, not just pretty Dribbble shots.',
          timestamp: 1715120000000,
          upvotes: 29,
        ),
      ],
    ),
    CommunityQuestion(
      id: 'q_3',
      title: 'What is the best undergraduate stream if my ultimate goal is an MBA from IIM Ahmedabad?',
      author: 'Karan Singhania',
      authorRole: 'Class 11th Commerce Student',
      category: 'Management',
      content: 'I want to pursue an MBA in Strategy or Finance from top IIMs. Should I do B.Com, BBA, Economics (Hons), or Engineering? How does academic diversity factor into IIM shortlisting?',
      timestamp: 1715200000000,
      upvotes: 56,
      tags: ['CAT', 'IIM', 'Business', 'Commerce'],
      answers: [
        CommunityAnswer(
          id: 'a_3_1',
          author: 'Aditya Roy',
          authorBadge: 'IIM Calcutta Alum • Management Consultant',
          isVerifiedMentor: true,
          content: "Top IIMs (Ahmedabad, Bangalore, Calcutta) award extra points for 'Academic Diversity' to non-engineers. Doing Economics (Hons), B.Com, or BBA gives you a significant advantage in composite score cutoffs compared to engineers who face intense competition. Maintain a 90%+ score in 10th, 12th, and graduation, take up student leadership roles, and build quantitative comfort early.",
          timestamp: 1715230000000,
          upvotes: 47,
        ),
      ],
    ),
    CommunityQuestion(
      id: 'q_4',
      title: 'How do I secure an undergraduate summer research fellowship at IISc Bangalore or TIFR?',
      author: 'Sneha Patel',
      authorRole: 'B.Sc Physics 1st Year',
      category: 'Science',
      content: 'I want to build a career in pure scientific research and theoretical physics. What is the process for summer internships at premier national research labs?',
      timestamp: 1715300000000,
      upvotes: 28,
      tags: ['IISc', 'Research', 'Physics', 'INSPIRE'],
      answers: [
        CommunityAnswer(
          id: 'a_4_1',
          author: 'Dr. Shreya Sengupta',
          authorBadge: 'TIFR Postdoc • DST Inspire Fellow',
          isVerifiedMentor: true,
          content: 'There are two major routes: 1) Formal competitive programs: Apply for the Indian Academy of Sciences (IASc-INSA-NASI) Summer Research Fellowship and KVPY/DST Inspire programs by November/December. 2) Direct professor outreach: Read 2-3 recent papers from a professor whose lab aligns with your interest, and send a concise email pointing out a specific problem you would love to assist with. Demonstrating you read their work separates you from 99% of applicants.',
          timestamp: 1715340000000,
          upvotes: 25,
        ),
      ],
    ),
    CommunityQuestion(
      id: 'q_5',
      title: 'Are there full-ride scholarships for engineering students from families with income < 3 LPA?',
      author: 'Vikas Kumar',
      authorRole: 'First-Gen College Aspirant',
      category: 'Admissions & Funding',
      content: "My family's annual income is under ₹2.5 Lakhs. I am worried about college tuition and hostel fees. What are the best legitimate scholarships that cover complete engineering expenses?",
      timestamp: 1715400000000,
      upvotes: 64,
      tags: [
        'Scholarships',
        'Financial Aid',
        'Engineering',
        'Government Grants',
      ],
      answers: [
        CommunityAnswer(
          id: 'a_5_1',
          author: 'Karthik Raman',
          authorBadge: 'Verified Education Counselor',
          isVerifiedMentor: true,
          content: 'Yes, you have strong options! 1) Reliance Foundation Undergraduate Scholarship: Grants up to ₹2,00,000 across your degree based on an aptitude test and merit-cum-means criteria. 2) Central Sector Scheme of Scholarships (NSP): Up to ₹20,000/year for top board percentile students. 3) State EBC / TFW Schemes: Tuition Fee Waiver (TFW) seats exist in almost all state counseling rounds (CET/COMEDK/WBJEE) offering 100% tuition exemption for income under 8 LPA. 4) IITs & NITs offer 100% tuition waiver for family income under ₹1 Lakh and 66% fee remission for income between 1-5 Lakhs.',
          timestamp: 1715430000000,
          upvotes: 58,
        ),
      ],
    ),
  ];

  Future<List<CommunityQuestion>> loadAll() async {
    final stored = await _storage.loadCustomCommunityQuestions();
    if (stored.isEmpty) {
      return seedQuestions;
    }
    final storedIds = stored.map((q) => q.id).toSet();
    final remainingSeeds = seedQuestions.where(
      (q) => !storedIds.contains(q.id),
    );
    return List<CommunityQuestion>.unmodifiable([...stored, ...remainingSeeds]);
  }

  Future<List<CommunityQuestion>> postQuestion(
    CommunityQuestion question,
  ) async {
    final current = await loadAll();
    final updated = [question, ...current];
    await _storage.saveCommunityQuestions(updated);
    return List<CommunityQuestion>.unmodifiable(updated);
  }

  Future<List<CommunityQuestion>> addAnswer({
    required String questionId,
    required CommunityAnswer answer,
  }) async {
    final current = await loadAll();
    final updated = current
        .map((q) {
          if (q.id != questionId) return q;
          return q.copyWith(answers: [...q.answers, answer]);
        })
        .toList(growable: false);
    await _storage.saveCommunityQuestions(updated);
    return List<CommunityQuestion>.unmodifiable(updated);
  }

  Future<Set<String>> loadUpvotedQuestionIds() =>
      _storage.loadUpvotedQuestionIds();

  Future<Set<String>> toggleUpvote(String questionId) =>
      _storage.toggleQuestionUpvote(questionId);

  static List<CommunityQuestion> filterQuestions({
    required List<CommunityQuestion> all,
    String searchQuery = '',
    String category = 'All',
  }) {
    final query = searchQuery.trim().toLowerCase();
    return all
        .where((q) {
          final matchesCategory =
              category.toLowerCase() == 'all' ||
              q.category.toLowerCase() == category.toLowerCase();
          final matchesQuery =
              query.isEmpty ||
              q.title.toLowerCase().contains(query) ||
              q.content.toLowerCase().contains(query) ||
              q.tags.any((t) => t.toLowerCase().contains(query));
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }
}
