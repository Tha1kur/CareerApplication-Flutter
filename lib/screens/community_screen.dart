import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/community_models.dart';
import '../providers/community_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';

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
      unawaited(HapticFeedback.mediumImpact());
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
      unawaited(HapticFeedback.mediumImpact());
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_rounded, color: scheme.primary),
            const SizedBox(width: 8),
            const Text('Community Q&A'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ask Question',
        onPressed: () => _showAskDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sample local Q&A • New posts, answers & upvotes are stored offline on this device.',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: TextField(
                controller: _searchController,
                onChanged: community.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search discussions, JEE, design, IIM…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            community.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: kCommunityCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = kCommunityCategories[index];
                  return FilterChip(
                    label: Text(cat),
                    selected: community.selectedCategory == cat,
                    onSelected: (_) => community.setSelectedCategory(cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? EmptyStateView(
                      icon: Icons.forum_outlined,
                      title: 'No questions found',
                      subtitle: 'Try a different topic or start a new discussion locally.',
                      actionLabel: 'Ask a Question',
                      onAction: () => _showAskDialog(context),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 88),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final q = items[index];
                        return _QuestionCard(
                          question: q,
                          isUpvoted: community.isUpvoted(q.id),
                          upvoteCount: community.displayUpvotes(q),
                          onToggleUpvote: () {
                            unawaited(HapticFeedback.selectionClick());
                            unawaited(community.toggleUpvote(q.id));
                          },
                          onAnswer: () => _showAnswerDialog(context, q),
                        );
                      },
                    ),
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    q.author.isNotEmpty ? q.author[0].toUpperCase() : 'S',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
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
                          fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    q.category,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              q.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              q.content,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (q.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: q.tags
                    .take(4)
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
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
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: Icon(
                        Icons.thumb_up_rounded,
                        size: 16,
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
                        size: 16,
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
                  child: const Text('Answer'),
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
                for (final ans in q.answers) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ans.isVerifiedMentor
                          ? scheme.primaryContainer.withAlpha(70)
                          : scheme.surfaceContainerHighest.withAlpha(110),
                      borderRadius: BorderRadius.circular(12),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (ans.isVerifiedMentor)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Sample Mentor',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onPrimary,
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
                        Text(ans.content, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
            ],
          ],
        ),
      ),
    );
  }
}
