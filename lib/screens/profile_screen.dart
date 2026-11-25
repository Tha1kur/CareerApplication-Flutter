import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../widgets/gradient_hero_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(
      text: profile.age > 0 ? profile.age.toString() : '',
    );
    _goalController = TextEditingController(text: profile.goal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    await context.read<ProfileProvider>().saveProfile(
      name: _nameController.text.trim(),
      age: age,
      goal: _goalController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  Future<void> _clear() async {
    await context.read<ProfileProvider>().clearProfile();
    _nameController.clear();
    _ageController.clear();
    _goalController.clear();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final savedProfile = context.watch<ProfileProvider>().profile;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = _nameController.text.trim();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GradientHeroCard(
                horizontalGradient: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: scheme.onPrimary.withAlpha(40),
                      child: Text(
                        initial,
                        style: textTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName.isEmpty ? 'Your profile' : displayName,
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Save your details to personalize your AI Career Mentor roadmap.',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimary.withAlpha(235),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your full name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'e.g. 18',
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  final parsed = int.tryParse(raw);
                  if (parsed == null || parsed < 10 || parsed > 100) {
                    return 'Enter a valid age (10–100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _goalController,
                minLines: 3,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Goal / dream career',
                  hintText: 'e.g. Software Engineer, UX Designer, Startup Founder, Research Scientist',
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved profile',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Name: ${savedProfile.name.isEmpty ? '—' : savedProfile.name}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${savedProfile.age > 0 ? savedProfile.age : '—'}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Goal: ${savedProfile.goal.isEmpty ? '—' : savedProfile.goal}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
