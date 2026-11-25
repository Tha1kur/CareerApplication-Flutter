import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/community_models.dart';
import '../providers/community_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White Community Q&A screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Community Q&A
/// - White pill search bar + horizontal violet category pills + honest offline local notice
/// - Floating white Q&A thread cards with upvote, expandable answers, Ask & Contribute dialogs
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAskDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    var selectedCategory = 'Technology';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Ask the Community'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Question Headline',
                        hintText: 'e.g. Which course is best for AI?',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Details & Context',
                        hintText: 'Describe your goals and background…',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: kCommunityCategories
                          .where((c) => c != 'All')
                          .map(
                            (cat) => ChoiceChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              onSelected: (_) =>
                                  setDialogState(() => selectedCategory = cat),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Your Name (Optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Your Stage (e.g. Class 12, 1st Year)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: titleCtrl.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Post Question'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted == true && context.mounted) {
      await context.read<CommunityProvider>().postQuestion(
        title: titleCtrl.text,
        content: contentCtrl.text,
        category: selectedCategory,
        authorName: nameCtrl.text,
        authorRole: roleCtrl.text,
      );
      if (context.mounted) {
        await context
            .read<QuizGamificationProvider>()
            .grantCommunityQuestionReward();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Question posted locally (+35 XP)')),
          );
      }
    }

    titleCtrl.dispose();
    contentCtrl.dispose();
    nameCtrl.dispose();
    roleCtrl.dispose();
  }

  Future<void> _showAnswerDialog(
    BuildContext context,
    CommunityQuestion question,
  ) async {
    final answerCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final badgeCtrl = TextEditingController();
    var isMentor = false;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Contribute Advice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Re: ${question.title}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: answerCtrl,
                      maxLines: 4,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Your Advice / Experience',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Your Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: badgeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Background / College / Role',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilterChip(
                      label: Text(
                        isMentor
                            ? 'Illustrative Mentor Label On'
                            : 'Tag as Mentor (Demo)',
                      ),
                      selected: isMentor,
                      onSelected: (v) => setDialogState(() => isMentor = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: answerCtrl.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Post Advice'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted == true && context.mounted) {
      await context.read<CommunityProvider>().addAnswer(
        questionId: question.id,
        content: answerCtrl.text,
        authorName: nameCtrl.text,
        authorBadge: badgeCtrl.text,
        isVerifiedMentor: isMentor,
      );
      if (context.mounted) {
        await context
            .read<QuizGamificationProvider>()
            .grantCommunityAnswerReward();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Advice posted locally (+50 XP & badge)'),
            ),
          );
      }
    }

    answerCtrl.dispose();
    nameCtrl.dispose();
    badgeCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final items = community.filteredQuestions;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ask Question',
        backgroundColor: const Color(0xFF7433D6),
        foregroundColor: Colors.white,
        onPressed: () => _showAskDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CommunityBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 1. Clean Secondary Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: () => context.safePop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 22,
                              color: isDark
                                  ? scheme.primary
                                  : const Color(0xFF5D26C6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Q&A',
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 22.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                            Text(
                              'Sample local Q&A • Stored offline on this device.',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.forum_rounded,
                          size: 22,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF6B2FD0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. White Pill Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant.withAlpha(185),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow(brightness),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 21,
                          color: isDark
                              ? scheme.onSurfaceVariant
                              : const Color(0xFF56506E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: community.setSearchQuery,
                            style: TextStyle(
                              fontSize: 13.6,
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search discussions, JEE, design, IIM…',
                              hintStyle: TextStyle(
                                fontSize: 13.4,
                                color: isDark
                                    ? scheme.onSurfaceVariant
                                    : const Color(0xFF7B7594),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              community.setSearchQuery('');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // 3. Horizontal Violet Category Pills
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: kCommunityCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = kCommunityCategories[index];
                      final selected = community.selectedCategory == cat;
                      return Material(
                        color: selected
                            ? (isDark
                                  ? scheme.primary
                                  : const Color(0xFF7433D6))
                            : (isDark
                                  ? scheme.surface
                                  : const Color(0xFFEEE7FF)),
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: () => community.setSelectedCategory(cat),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : (isDark
                                          ? scheme.onSurface
                                          : const Color(0xFF423C5C)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 11),

                // 4. Q&A Threads List
                Expanded(
                  child: items.isEmpty
                      ? EmptyStateView(
                          icon: Icons.forum_outlined,
                          title: 'No questions found',
                          subtitle:
                              'Try a different topic or start a new discussion locally.',
                          actionLabel: 'Ask a Question',
                          onAction: () => _showAskDialog(context),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 2, 14, 88),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final q = items[index];
                            return _QuestionCard(
                              question: q,
                              isUpvoted: community.isUpvoted(q.id),
                              upvoteCount: community.displayUpvotes(q),
                              onToggleUpvote: () =>
                                  unawaited(community.toggleUpvote(q.id)),
                              onAnswer: () => _showAnswerDialog(context, q),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    required this.question,
    required this.isUpvoted,
    required this.upvoteCount,
    required this.onToggleUpvote,
    required this.onAnswer,
  });

  final CommunityQuestion question;
  final bool isUpvoted;
  final int upvoteCount;
  final VoidCallback onToggleUpvote;
  final VoidCallback onAnswer;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? scheme.primaryContainer
                    : const Color(0xFFF0E8FF),
                child: Text(
                  q.author.isNotEmpty ? q.author[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? scheme.primary : const Color(0xFF6B2FD0),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.author,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (q.authorRole.isNotEmpty)
                      Text(
                        q.authorRole,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.primaryContainer
                      : const Color(0xFFF3ECFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  q.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? scheme.primary : const Color(0xFF6B2FD0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            q.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            q.content,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12.8,
              height: 1.38,
            ),
          ),
          if (q.tags.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: q.tags
                  .take(4)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          Divider(height: 22, color: scheme.outlineVariant.withAlpha(140)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: Icon(
                      Icons.thumb_up_rounded,
                      size: 15,
                      color: widget.isUpvoted
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    label: Text('${widget.upvoteCount}'),
                    backgroundColor: widget.isUpvoted
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    onPressed: widget.onToggleUpvote,
                  ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                    ),
                    label: Text(
                      '${q.answers.length} ${q.answers.length == 1 ? 'Answer' : 'Answers'}',
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onAnswer,
                child: const Text(
                  'Answer',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            if (q.answers.isEmpty)
              Text(
                'No answers yet. Share your advice!',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              for (final ans in q.answers)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ans.isVerifiedMentor
                        ? (isDark
                              ? const Color(0xFF2B2054)
                              : const Color(0xFFF3ECFF))
                        : scheme.surfaceContainerHighest.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            ans.author,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (ans.isVerifiedMentor)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7433D6),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'Sample Mentor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (ans.authorBadge.isNotEmpty)
                            Text(
                              '• ${ans.authorBadge}',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ans.content,
                        style: textTheme.bodySmall?.copyWith(height: 1.38),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _CommunityBackdropPainter extends CustomPainter {
  const _CommunityBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 1.0],
          colors: isDark
              ? const [
                  AppColors.darkBackgroundTop,
                  AppColors.darkBackground,
                  AppColors.darkBackground,
                ]
              : const [
                  Color(0xFFF6F1FF),
                  Color(0xFFF9F7FF),
                  Color(0xFFF3EEFF),
                ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CommunityBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
