import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../logic/red_flags.dart';
import '../theme.dart';
import '../widgets/big_button.dart';
import '../widgets/effects.dart';
import 'family_contacts_panel.dart';

/// The core flow: pause, tick the warning signs, see what they mean, then
/// check with family before paying anyone.
class PauseFlowScreen extends StatefulWidget {
  const PauseFlowScreen({super.key});

  @override
  State<PauseFlowScreen> createState() => _PauseFlowScreenState();
}

class _PauseFlowScreenState extends State<PauseFlowScreen> {
  int _step = 0;
  final Set<RedFlag> _ticked = {};
  final _claimed = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _claimed.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _go(int step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_step) {
      case 0:
        body = _PauseStep(onNext: () => _go(1));
      case 1:
        body = _ChecklistStep(
          ticked: _ticked,
          claimed: _claimed,
          amount: _amount,
          onToggle: (f, on) =>
              setState(() => on ? _ticked.add(f) : _ticked.remove(f)),
          onNext: () => _go(2),
        );
      default:
        body = _ResultStep(
          result: assessRisk(_ticked),
          claimedToBe: _claimed.text,
          amount: _amount.text,
        );
    }
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(_step - 1);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Step ${_step + 1} of 3'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(14),
            child: _StepBar(step: _step),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: reduceMotion(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            child: KeyedSubtree(key: ValueKey(_step), child: body),
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              decoration: BoxDecoration(
                gradient: i <= step ? Brand.calm : null,
                color: i <= step ? null : const Color(0xFFD5DEEA),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class _PauseStep extends StatelessWidget {
  const _PauseStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(fontSize: 19, height: 1.4, color: Brand.navy);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const BreathingGuide(),
        const SizedBox(height: 8),
        const Entrance(
          child: Text(
            'Pause. You are in control.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Brand.navy,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Entrance(
          delayMs: 150,
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Reassure(
                  icon: Icons.call_end_rounded,
                  text: 'It is OK to hang up or stop replying right now.',
                  style: body,
                ),
                SizedBox(height: 14),
                _Reassure(
                  icon: Icons.favorite_rounded,
                  text:
                      'A real family member, bank, or police officer will '
                      'not mind if you check first and call them back.',
                  style: body,
                ),
                SizedBox(height: 14),
                _Reassure(
                  icon: Icons.block_rounded,
                  text: 'Do not send money, gift cards, or codes yet.',
                  style: body,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Entrance(
          delayMs: 300,
          child: BigButton(
            label: 'I have paused',
            subtitle: 'Next: check for warning signs',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

class _Reassure extends StatelessWidget {
  const _Reassure({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Brand.teal, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: style)),
    ],
  );
}

class _ChecklistStep extends StatelessWidget {
  const _ChecklistStep({
    required this.ticked,
    required this.claimed,
    required this.amount,
    required this.onToggle,
    required this.onNext,
  });

  final Set<RedFlag> ticked;
  final TextEditingController claimed;
  final TextEditingController amount;
  final void Function(RedFlag, bool) onToggle;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'What is happening?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Brand.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Take your time. There are no wrong answers.',
          style: TextStyle(fontSize: 17, color: Brand.teal),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: claimed,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Who do they say they are? (optional)',
            hintText: 'For example: my grandson, the IRS, my bank',
            prefixIcon: Icon(Icons.person_search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amount,
          decoration: const InputDecoration(
            labelText: 'How much do they want? (optional)',
            hintText: r'For example: $2,000',
            prefixIcon: Icon(Icons.attach_money_rounded),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tap everything that is true:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Brand.navy,
                ),
              ),
            ),
            if (ticked.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Brand.coral,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ticked.length} picked',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final flag in RedFlag.values)
          _FlagTile(
            key: ValueKey('flag-${flag.name}'),
            flag: flag,
            selected: ticked.contains(flag),
            onTap: () => onToggle(flag, !ticked.contains(flag)),
          ),
        const SizedBox(height: 24),
        BigButton(
          label: 'What does this mean?',
          subtitle: 'See your result',
          icon: Icons.insights_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _FlagTile extends StatelessWidget {
  const _FlagTile({
    super.key,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final RedFlag flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        checked: selected,
        button: true,
        label: flag.question,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFEDEE) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? Brand.coral : const Color(0xFFDCE3EE),
                width: selected ? 2.5 : 1.5,
              ),
              boxShadow: selected ? softShadow(Brand.coral) : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Brand.coral : Colors.transparent,
                    border: Border.all(
                      color: selected ? Brand.coral : const Color(0xFF9AA8BC),
                      width: 2.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    flag.question,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.3,
                      color: Brand.navy,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStep extends StatefulWidget {
  const _ResultStep({
    required this.result,
    required this.claimedToBe,
    required this.amount,
  });

  final RiskResult result;
  final String claimedToBe;
  final String amount;

  @override
  State<_ResultStep> createState() => _ResultStepState();
}

class _ResultStepState extends State<_ResultStep> {
  bool _recorded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_recorded) {
      _recorded = true;
      final store = AppScope.store(context);
      // After this frame: changing the store rebuilds listeners.
      WidgetsBinding.instance.addPostFrameCallback((_) => store.recordPause());
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final (Gradient gradient, Color fg, IconData icon) = switch (result.level) {
      RiskLevel.high => (Brand.danger, Colors.white, Icons.gpp_bad_rounded),
      RiskLevel.medium => (Brand.caution, Brand.navy, Icons.warning_rounded),
      RiskLevel.unknown => (Brand.calm, Colors.white, Icons.gpp_maybe_rounded),
    };
    final animate = !reduceMotion(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0.85 : 1, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, s, child) =>
              Transform.scale(scale: s, child: child),
          child: Container(
            key: const ValueKey('risk-banner'),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: softShadow(gradient.colors.last),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: fg, size: 56),
                const SizedBox(height: 10),
                Text(
                  result.headline,
                  style: TextStyle(
                    color: fg,
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.advice,
                  style: TextStyle(color: fg, fontSize: 18, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Entrance(
          delayMs: 200,
          child: Panel(
            color: Color(0xFFE8FBF3),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Brand.teal, size: 40),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You did the right thing.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Brand.navy,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Stopping to check is exactly what beats scammers.',
                        style: TextStyle(fontSize: 16, color: Brand.navy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Why',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Brand.navy,
            ),
          ),
          const SizedBox(height: 8),
          for (final (i, flag) in result.flags.indexed)
            Entrance(
              delayMs: 300 + 80 * i,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Panel(
                  padding: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_rounded,
                        color: Brand.coral,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flag.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Brand.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              flag.why,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                color: Color(0xFF3A4A63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        FamilyContactsPanel(
          claimedToBe: widget.claimedToBe,
          amount: widget.amount,
          flags: result.flags,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(64),
          ),
          child: const Text('Back to start', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
