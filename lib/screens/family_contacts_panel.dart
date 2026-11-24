import 'package:material_ui/material_ui.dart';

import '../app_scope.dart';
import '../logic/red_flags.dart';
import '../logic/verify_message.dart';
import 'setup_screen.dart';

/// Safe-word reminder plus a Call / "Is this really you?" text button for
/// every trusted family member.
class FamilyContactsPanel extends StatelessWidget {
  const FamilyContactsPanel({
    super.key,
    this.claimedToBe = '',
    this.amount = '',
    this.flags = const [],
  });

  final String claimedToBe;
  final String amount;
  final List<RedFlag> flags;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.store(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (store.hasSafeWord)
          Card(
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Ask the caller: "What is our family safe word?"\n'
                'If they cannot say it, hang up.',
                style: text.titleMedium,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('Check with your family', style: text.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Call them on the number saved here, not a number the caller gave you.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 12),
        if (store.contacts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'You have not added a family member yet.',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SetupScreen()),
                    ),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add family member'),
                  ),
                ],
              ),
            ),
          ),
        for (final contact in store.contacts)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    contact.relation.isEmpty
                        ? contact.name
                        : '${contact.name} (${contact.relation})',
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: ValueKey('call-${contact.id}'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: () =>
                        AppScope.open(context, telUri(contact.phone)),
                    icon: const Icon(Icons.call_rounded),
                    label: Text(
                      'Call ${contact.name}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: ValueKey('text-${contact.id}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: () => AppScope.open(
                      context,
                      smsUri(
                        contact,
                        buildVerifyMessage(
                          senderName: store.userName,
                          contact: contact,
                          claimedToBe: claimedToBe,
                          amount: amount,
                          flags: flags,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.sms_rounded),
                    label: const Text(
                      'Text: "Is this really you?"',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
