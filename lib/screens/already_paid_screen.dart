import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../logic/already_paid.dart';
import '../logic/verify_message.dart';

/// Calm, step-by-step help after money has already been sent.
class AlreadyPaidScreen extends StatefulWidget {
  const AlreadyPaidScreen({super.key});

  @override
  State<AlreadyPaidScreen> createState() => _AlreadyPaidScreenState();
}

class _AlreadyPaidScreenState extends State<AlreadyPaidScreen> {
  PaidWith? _method;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final method = _method;
    return Scaffold(
      appBar: AppBar(title: const Text('I already sent money')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Act fast. The sooner you call, the better the chance of '
              'stopping the payment.',
              style: text.titleLarge,
            ),
            const SizedBox(height: 20),
            Text('How did you pay?', style: text.titleLarge),
            const SizedBox(height: 8),
            RadioGroup<PaidWith>(
              groupValue: method,
              onChanged: (v) => setState(() => _method = v),
              child: Column(
                children: [
                  for (final m in PaidWith.values)
                    Card(
                      child: RadioListTile<PaidWith>(
                        key: ValueKey('paid-${m.name}'),
                        value: m,
                        title: Text(m.label, style: text.titleMedium),
                      ),
                    ),
                ],
              ),
            ),
            if (method != null) ...[
              const SizedBox(height: 20),
              Text('Do this now:', style: text.titleLarge),
              ..._numbered(method.steps, text),
            ],
            const SizedBox(height: 20),
            Text('Then:', style: text.titleLarge),
            ..._numbered(alwaysDoSteps, text),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              onPressed: () => AppScope.open(context, ftcReportUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Report to the FTC'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              onPressed: () => AppScope.open(context, ic3ReportUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Report to the FBI (IC3)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              onPressed: () =>
                  AppScope.open(context, telUri(aarpHelplineNumber)),
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('Talk to someone: AARP Fraud Helpline (free)'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _numbered(List<String> steps, TextTheme text) => [
    for (var i = 0; i < steps.length; i++)
      ListTile(
        leading: CircleAvatar(child: Text('${i + 1}')),
        title: Text(steps[i], style: text.titleMedium),
      ),
  ];
}
