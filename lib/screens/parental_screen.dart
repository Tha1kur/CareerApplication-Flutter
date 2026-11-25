import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/utils/external_link_helper.dart';
import '../widgets/gradient_hero_card.dart';

class _ParentTip {
  const _ParentTip(this.title, this.body);
  final String title;
  final String body;
}

class _ParentResource {
  const _ParentResource(this.title, this.url);
  final String title;
  final String url;
}

class ParentalScreen extends StatelessWidget {
  const ParentalScreen({super.key});

  static const List<_ParentTip> _tips = [
    _ParentTip(
      'Start early & listen',
      'Have open conversations about what your child enjoys, their strengths and interests. Avoid forcing one single career path.',
    ),
    _ParentTip(
      'Focus on skills, not just marks',
      'Encourage projects, competitions, internships and communication practice. These matter more than marks alone.',
    ),
    _ParentTip(
      'Help explore options',
      'Use quizzes, visit colleges, talk to professionals and explore job videos together.',
    ),
    _ParentTip(
      'Mental health matters',
      'Reduce pressure. Help them balance study, hobbies, sleep and relaxation.',
    ),
    _ParentTip(
      'Financial planning',
      'Start planning early for college fees, scholarships and loans so money stress reduces.',
    ),
  ];

  static const List<_ParentResource> _resources = [
    _ParentResource('NCERT Career Guidance PDF', 'https://ncert.nic.in'),
    _ParentResource(
      'National Scholarship Portal',
      'https://scholarships.gov.in',
    ),
    _ParentResource(
      'MyGov – Career & Skill Initiatives',
      'https://www.mygov.in',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('For Parents')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GradientHeroCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Support your child's career journey",
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use these tips & official resources to guide them without pressure.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimary.withAlpha(240),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Parenting tips',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final tip in _tips) ...[
              _ExpandableTipCard(tip: tip),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            Text(
              'Resources & PDFs',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final res in _resources) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              res.title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        res.url,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () => unawaited(
                                launchExternalUrlSafely(context, res.url),
                              ),
                              child: const Text('Open'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: res.url),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text('Link copied'),
                                    ),
                                  );
                              },
                              child: const Text('Copy link'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            Text(
              'You can take the quiz with your child and review the results together.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => context.push(AppRoutes.quiz),
              child: const Text('Take quiz with your child'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.safePop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableTipCard extends StatefulWidget {
  const _ExpandableTipCard({required this.tip});

  final _ParentTip tip;

  @override
  State<_ExpandableTipCard> createState() => _ExpandableTipCardState();
}

class _ExpandableTipCardState extends State<_ExpandableTipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.tip.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _expanded ? 'Hide' : 'Read',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.tip.body,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
