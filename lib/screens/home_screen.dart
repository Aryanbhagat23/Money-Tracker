import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../data/app_store.dart';
import '../theme.dart';
import '../widgets/big_button.dart';
import '../widgets/effects.dart';
import 'already_paid_screen.dart';
import 'family_contacts_panel.dart';
import 'pause_flow_screen.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static void push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(store: store),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Entrance(
                  delayMs: 100,
                  child: BigButton(
                    key: const ValueKey('btn-asking'),
                    label: 'Someone is asking me for money',
                    subtitle: 'A call, text, email, or visit',
                    icon: Icons.pan_tool_rounded,
                    gradient: Brand.danger,
                    onPressed: () => push(context, const PauseFlowScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                Entrance(
                  delayMs: 200,
                  child: BigButton(
                    key: const ValueKey('btn-family'),
                    label: 'Call or text my family',
                    subtitle: 'Your trusted people, one tap away',
                    icon: Icons.family_restroom_rounded,
                    gradient: Brand.calm,
                    onPressed: () => push(context, const FamilyScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                Entrance(
                  delayMs: 300,
                  child: BigButton(
                    key: const ValueKey('btn-paid'),
                    label: 'I already sent money',
                    subtitle: 'Calm steps to take right now',
                    icon: Icons.support_rounded,
                    gradient: Brand.support,
                    onPressed: () => push(context, const AlreadyPaidScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                Entrance(delayMs: 400, child: _TipCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.store});

  final AppStore store;

  String get _greeting {
    final h = DateTime.now().hour;
    final part = h < 12
        ? 'Good morning'
        : h < 18
        ? 'Good afternoon'
        : 'Good evening';
    return store.userName.isEmpty ? part : '$part, ${store.userName}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (store.readiness * 100).round();
    final pauses = store.pauseCount;
    return Container(
      decoration: const BoxDecoration(
        gradient: Brand.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 12, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: Brand.gold, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Kinfirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Family & settings',
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () =>
                        HomeScreen.push(context, const SetupScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You are safer when you check before you pay.',
                style: TextStyle(color: Color(0xFFD6E4FF), fontSize: 17),
              ),
              const SizedBox(height: 22),
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      key: const ValueKey('readiness-ring'),
                      value: store.readiness,
                      center: Text(
                        '$pct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pct == 100 ? 'Fully protected' : 'Protection score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nextStep(store),
                            style: const TextStyle(
                              color: Color(0xFFD6E4FF),
                              fontSize: 15,
                            ),
                          ),
                          if (pauses > 0) ...[
                            const SizedBox(height: 8),
                            _Badge(
                              text: pauses == 1
                                  ? 'You checked 1 time. Well done!'
                                  : 'You checked $pauses times. Well done!',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _nextStep(AppStore store) {
    if (store.contacts.isEmpty) return 'Next: add a family member you trust.';
    if (!store.hasSafeWord) return 'Next: choose a family safe word.';
    if (store.userName.isEmpty) return 'Next: add your first name.';
    return 'Family and safe word are ready. Great job!';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Brand.gold,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: Brand.navy),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Brand.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A rotating safety tip, so the home screen teaches something every visit.
class _TipCard extends StatelessWidget {
  static const _tips = [
    'Real police, the IRS, and banks never ask for gift cards or crypto.',
    'Caller ID can be faked. Hang up and call back on a number you know.',
    'AI can copy a voice from a few seconds of audio. Ask for your safe word.',
    'Anyone who says "keep this secret" is a warning sign.',
    'It is always OK to say: "Let me call you back."',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    return Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Brand.gold.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Brand.navy,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's safety tip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Brand.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(fontSize: 18, color: Brand.navy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My family')),
    body: const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: FamilyContactsPanel(),
      ),
    ),
  );
}
