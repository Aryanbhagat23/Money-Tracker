import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../theme.dart';
import '../widgets/effects.dart';
import 'setup_screen.dart';

/// First launch: explains the app in one screen and asks for the minimum
/// setup (a trusted family member). Usually done by a grandchild with the
/// grandparent.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);
    final ready = store.contacts.isNotEmpty;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Brand.hero),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              Entrance(
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: Brand.mint.withValues(alpha: 0.45),
                          blurRadius: 50,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 72,
                      color: Brand.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Entrance(
                delayMs: 100,
                child: Text(
                  'Welcome to Kinfirm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Entrance(
                delayMs: 200,
                child: Text(
                  'Your family safety shield against scams.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD6E4FF), fontSize: 19),
                ),
              ),
              const SizedBox(height: 24),
              const Entrance(
                delayMs: 300,
                child: _Feature(
                  icon: Icons.pan_tool_rounded,
                  title: 'Pause',
                  text: 'Stop and breathe when someone asks for money.',
                ),
              ),
              const Entrance(
                delayMs: 380,
                child: _Feature(
                  icon: Icons.manage_search_rounded,
                  title: 'Spot the signs',
                  text: 'See the warning signs in plain words.',
                ),
              ),
              const Entrance(
                delayMs: 460,
                child: _Feature(
                  icon: Icons.family_restroom_rounded,
                  title: 'Check with family',
                  text: 'Call or text someone you trust in one tap.',
                ),
              ),
              const SizedBox(height: 20),
              Entrance(
                delayMs: 560,
                child: Panel(
                  child: Column(
                    children: [
                      _StepTile(
                        number: 1,
                        done: ready,
                        title: 'Add a family member you trust',
                        onTap: () => editContact(context),
                      ),
                      const Divider(height: 20),
                      _StepTile(
                        number: 2,
                        done: store.hasSafeWord,
                        title: 'Choose a family safe word (recommended)',
                        onTap: () => editSafeWord(context, store),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('finish-onboarding'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(66),
                  backgroundColor: Brand.gold,
                  foregroundColor: Brand.navy,
                  disabledBackgroundColor: Colors.white24,
                  disabledForegroundColor: Colors.white70,
                ),
                onPressed: ready ? store.completeOnboarding : null,
                child: Text(
                  ready
                      ? "I'm ready. Let's go!"
                      : 'Add a family member to start',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: store.completeOnboarding,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Brand.mint, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                text,
                style: const TextStyle(color: Color(0xFFD6E4FF), fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StepTile extends StatelessWidget {
  const _StepTile({
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
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? Brand.mint : const Color(0xFFE3EAF4),
            ),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white)
                : Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Brand.navy,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Brand.navy,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Brand.navy),
        ],
      ),
    ),
  );
}
