import 'package:material_ui/material_ui.dart';

import '../logic/red_flags.dart';
import '../widgets/big_button.dart';
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
        appBar: AppBar(title: Text('Step ${_step + 1} of 3')),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _PauseStep extends StatelessWidget {
  const _PauseStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.pan_tool_rounded, size: 72),
        const SizedBox(height: 16),
        Text(
          'Pause. You are in control.',
          style: text.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'It is OK to hang up or stop replying right now.\n\n'
          'A real family member, bank, or police officer will not mind if '
          'you check first and call them back.\n\n'
          'Do not send money, gift cards, or codes yet.',
          style: text.titleLarge,
        ),
        const SizedBox(height: 32),
        BigButton(
          label: 'I have paused',
          subtitle: 'Next: check for warning signs',
          icon: Icons.arrow_forward_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
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
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('What is happening?', style: text.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: claimed,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Who do they say they are? (optional)',
            hintText: 'For example: my grandson, the IRS, my bank',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amount,
          decoration: const InputDecoration(
            labelText: 'How much do they want? (optional)',
            hintText: r'For example: $2,000',
          ),
        ),
        const SizedBox(height: 24),
        Text('Tick everything that is true:', style: text.titleLarge),
        const SizedBox(height: 8),
        for (final flag in RedFlag.values)
          Card(
            child: CheckboxListTile(
              key: ValueKey('flag-${flag.name}'),
              value: ticked.contains(flag),
              onChanged: (v) => onToggle(flag, v ?? false),
              title: Text(flag.question, style: text.titleMedium),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        const SizedBox(height: 24),
        BigButton(
          label: 'What does this mean?',
          icon: Icons.arrow_forward_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    required this.result,
    required this.claimedToBe,
    required this.amount,
  });

  final RiskResult result;
  final String claimedToBe;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (Color bg, Color fg, IconData icon) = switch (result.level) {
      RiskLevel.high => (
        const Color(0xFFB3261E),
        Colors.white,
        Icons.dangerous_rounded,
      ),
      RiskLevel.medium => (
        const Color(0xFFF2B705),
        Colors.black,
        Icons.warning_rounded,
      ),
      RiskLevel.unknown => (
        const Color(0xFF1F4E8C),
        Colors.white,
        Icons.help_rounded,
      ),
    };
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          key: const ValueKey('risk-banner'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg, size: 48),
              const SizedBox(height: 8),
              Text(
                result.headline,
                style: text.headlineSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(result.advice, style: text.titleMedium?.copyWith(color: fg)),
            ],
          ),
        ),
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Why:', style: text.titleLarge),
          for (final flag in result.flags)
            ListTile(
              leading: const Icon(Icons.error_outline_rounded),
              title: Text(
                flag.question,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(flag.why, style: text.bodyLarge),
            ),
        ],
        const SizedBox(height: 24),
        FamilyContactsPanel(
          claimedToBe: claimedToBe,
          amount: amount,
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
