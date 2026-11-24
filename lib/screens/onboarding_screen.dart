import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import 'setup_screen.dart';

/// First launch: explains the app in one screen and asks for the minimum
/// setup (a trusted family member). Usually done by a grandchild with the
/// grandparent.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);
    final text = Theme.of(context).textTheme;
    final ready = store.contacts.isNotEmpty;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.shield_rounded, size: 80),
            const SizedBox(height: 16),
            Text(
              'Welcome to Kinfirm',
              style: text.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Scammers pretend to be family, the bank, or the police, and '
              'they can even copy a loved one\'s voice.\n\n'
              'Kinfirm helps you pause, spot the warning signs, and check with '
              'your family before you send money.',
              style: text.titleMedium,
            ),
            const SizedBox(height: 24),
            _StepCard(
              number: 1,
              done: ready,
              title: 'Add a family member you trust',
              onTap: () => editContact(context),
            ),
            _StepCard(
              number: 2,
              done: store.hasSafeWord,
              title: 'Choose a family safe word (recommended)',
              onTap: () => editSafeWord(context, store),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('finish-onboarding'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
              ),
              onPressed: ready ? store.completeOnboarding : null,
              child: Text(
                ready ? 'Start' : 'Add a family member to start',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: store.completeOnboarding,
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.done,
    required this.title,
    required this.onTap,
  });

  final int number;
  final bool done;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        child: done ? const Icon(Icons.check_rounded) : Text('$number'),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}
